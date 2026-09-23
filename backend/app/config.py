import os
from pathlib import Path

# Base Paths
BASE_DIR = Path(__file__).resolve().parent.parent
WORKSPACE_DIR = BASE_DIR.parent
MODELS_DIR = WORKSPACE_DIR / "V2" / "final_export" / "models"
UPLOADS_DIR = BASE_DIR / "uploads"
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)

# Database
DATABASE_URL = f"sqlite:///{BASE_DIR / 'neurovoice.db'}"

# ML Parameters (Matching notebook v2-sih.ipynb)
SAMPLE_RATE = 16000
N_MFCC = 13
N_QUBITS = 8
N_SELECTED_FEATURES = N_QUBITS

# Model Paths
SCALER_PATH = MODELS_DIR / "feature_scaler.joblib"
SELECTED_FEATURES_PATH = MODELS_DIR / "selected_features.joblib"
CLASSICAL_MODEL_PATH = MODELS_DIR / "classical_fp32.pt"
CLASSICAL_MOBILE_PATH = MODELS_DIR / "classical_mobile.pt"
CLASSICAL_QUANTIZED_PATH = MODELS_DIR / "classical_quantized_mobile.pt"
HYBRID_QUANTUM_MODEL_PATH = MODELS_DIR / "hybrid_quantum_fp32.pt"
HYBRID_QUANTUM_QUANTIZED_PATH = MODELS_DIR / "hybrid_quantum_quantized.pt"
