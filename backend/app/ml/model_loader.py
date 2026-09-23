import os
import warnings
warnings.filterwarnings("ignore")
import torch
import torch.nn as nn
import numpy as np
import joblib
from typing import List, Tuple, Optional, Dict
from backend.app.config import (
    SCALER_PATH,
    SELECTED_FEATURES_PATH,
    CLASSICAL_MODEL_PATH,
    CLASSICAL_MOBILE_PATH,
    CLASSICAL_QUANTIZED_PATH,
    HYBRID_QUANTUM_MODEL_PATH,
    HYBRID_QUANTUM_QUANTIZED_PATH,
    N_QUBITS
)

# 1. Classical Model Architecture from v2-sih.ipynb
class ClassicalModel(nn.Module):
    def __init__(self, n_features: int = 8):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(n_features, 16),
            nn.ReLU(),
            nn.Linear(16, 8),
            nn.ReLU(),
            nn.Linear(8, 1)
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return torch.sigmoid(self.net(x))

# 2. Hybrid Quantum Architecture from v2-sih.ipynb
class HybridQuantumModelWrapper:
    def __init__(self, n_features: int = 8, n_qubits: int = 8):
        self.model_fp32 = None
        self.model_int8 = None
        self.is_loaded_fp32 = False
        self.is_loaded_int8 = False

        try:
            import pennylane as qml
            import torch.ao.quantization as tq

            dev = qml.device("default.qubit", wires=n_qubits)
            N_LAYERS = 3

            @qml.qnode(dev, interface="torch", diff_method="backprop")
            def quantum_circuit(inputs, weights):
                qml.AngleEmbedding(inputs, wires=range(n_qubits))
                qml.BasicEntanglerLayers(weights, wires=range(n_qubits))
                return [qml.expval(qml.PauliZ(i)) for i in range(n_qubits)]

            weight_shapes = {"weights": (N_LAYERS, n_qubits)}
            quantum_layer = qml.qnn.TorchLayer(quantum_circuit, weight_shapes)

            class _HybridModel(nn.Module):
                def __init__(self):
                    super().__init__()
                    self.pre = nn.Sequential(nn.Linear(n_features, n_qubits), nn.Tanh())
                    self.quantum = quantum_layer
                    self.post = nn.Sequential(nn.Linear(n_qubits, 16), nn.ReLU(), nn.Linear(16, 1))

                def forward(self, x):
                    x = self.pre(x) * np.pi
                    x = self.quantum(x)
                    x = self.post(x)
                    return torch.sigmoid(x)

            # Load Hybrid FP32
            self.model_fp32 = _HybridModel()
            if os.path.exists(HYBRID_QUANTUM_MODEL_PATH):
                state_fp32 = torch.load(HYBRID_QUANTUM_MODEL_PATH, map_location="cpu")
                self.model_fp32.load_state_dict(state_fp32)
                self.model_fp32.eval()
                self.is_loaded_fp32 = True

            # Load Hybrid Quantized INT8
            if os.path.exists(HYBRID_QUANTUM_QUANTIZED_PATH):
                try:
                    m_base = _HybridModel()
                    self.model_int8 = tq.quantize_dynamic(m_base, {nn.Linear}, dtype=torch.qint8)
                    state_int8 = torch.load(HYBRID_QUANTUM_QUANTIZED_PATH, map_location="cpu")
                    self.model_int8.load_state_dict(state_int8)
                    self.model_int8.eval()
                    self.is_loaded_int8 = True
                except Exception as eq:
                    print(f"[ModelLoader] Quantum quantized load notice: {eq}")
        except Exception as e:
            print(f"[ModelLoader] Quantum model initialization warning: {e}")

    def predict_fp32(self, x_tensor: torch.Tensor) -> float:
        if self.model_fp32 is not None and self.is_loaded_fp32:
            with torch.no_grad():
                out = self.model_fp32(x_tensor)
                return float(out.item())
        return 0.5

    def predict_int8(self, x_tensor: torch.Tensor) -> float:
        if self.model_int8 is not None and self.is_loaded_int8:
            with torch.no_grad():
                out = self.model_int8(x_tensor)
                return float(out.item())
        elif self.model_fp32 is not None:
            return self.predict_fp32(x_tensor)
        return 0.5


class ModelRegistry:
    def __init__(self):
        self.scaler = None
        self.selected_features: List[str] = []
        
        # 4 Distinct Models
        self.classical_fp32: Optional[nn.Module] = None
        self.classical_int8: Optional[nn.Module] = None
        self.hybrid_quantum_wrapper: Optional[HybridQuantumModelWrapper] = None
        self.load_all()

    @property
    def classical_model(self):
        return self.classical_fp32

    def load_all(self):
        # 1. Load scaler
        if os.path.exists(SCALER_PATH):
            self.scaler = joblib.load(SCALER_PATH)
        else:
            raise FileNotFoundError(f"Scaler not found at {SCALER_PATH}")

        # 2. Load selected feature names
        if os.path.exists(SELECTED_FEATURES_PATH):
            self.selected_features = joblib.load(SELECTED_FEATURES_PATH)
        else:
            self.selected_features = [
                'mfcc_std_1', 'mfcc_mean_1', 'mfcc_std_3', 'mfcc_std_0',
                'mfcc_std_10', 'mfcc_std_2', 'mfcc_std_11', 'f0_mean'
            ]

        # 3. Model 1: Classical FP32
        self.classical_fp32 = ClassicalModel(len(self.selected_features))
        if os.path.exists(CLASSICAL_MODEL_PATH):
            state = torch.load(CLASSICAL_MODEL_PATH, map_location="cpu")
            self.classical_fp32.load_state_dict(state)
            self.classical_fp32.eval()
        elif os.path.exists(CLASSICAL_MOBILE_PATH):
            self.classical_fp32 = torch.jit.load(CLASSICAL_MOBILE_PATH, map_location="cpu")
            self.classical_fp32.eval()

        # 4. Model 2: Classical Quantized INT8
        if os.path.exists(CLASSICAL_QUANTIZED_PATH):
            try:
                self.classical_int8 = torch.jit.load(CLASSICAL_QUANTIZED_PATH, map_location="cpu")
                self.classical_int8.eval()
            except Exception as e:
                print(f"[ModelLoader] Could not load classical_quantized_mobile: {e}")
                self.classical_int8 = self.classical_fp32
        else:
            self.classical_int8 = self.classical_fp32

        # 5. Models 3 & 4: Hybrid Quantum FP32 and Hybrid Quantum INT8
        self.hybrid_quantum_wrapper = HybridQuantumModelWrapper(
            n_features=len(self.selected_features),
            n_qubits=N_QUBITS
        )

    def get_available_models(self) -> List[Dict[str, str]]:
        return [
            {"id": "classical_fp32", "name": "Classical FP32", "type": "Classical Deep NN"},
            {"id": "classical_int8", "name": "Classical INT8", "type": "Classical Quantized"},
            {"id": "quantum_fp32", "name": "Quantum FP32", "type": "Hybrid VQC (3 Layers)"},
            {"id": "quantum_int8", "name": "Quantum INT8", "type": "Hybrid VQC Quantized"}
        ]

# Global singleton
registry = ModelRegistry()
