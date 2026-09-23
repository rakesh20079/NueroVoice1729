# NeuroVoice 1729

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.x-EE4C2C?logo=pytorch)](https://pytorch.org)
[![PennyLane](https://img.shields.io/badge/PennyLane-Quantum%20VQC-7014F2)](https://pennylane.ai)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?logo=python)](https://www.python.org)

**NeuroVoice 1729** is an AI-powered neurological biomarker screening system that analyzes sustained vowel phonation (`/a/`) to detect early vocal stability perturbations, tremor incidence, and clinical dysphonia markers using classical deep neural networks and 8-qubit Variational Quantum Circuits (PennyLane VQC).

---

## Key Features

- **Real-Time Microphone Audio Acquisition**: Standardized 16,000 Hz single-channel capture with strict sustained vowel duration validation (5–10s) and silence trimming.
- **38 Clinical Dysphonia & Acoustic Biomarkers**:
  - 13 MFCC means & 13 MFCC standard deviations
  - Fundamental Frequency ($F_0$) via YIN algorithm
  - Praat-Parselmouth biometrics: Jitter (`local`, `rap`, `ppq5`), Shimmer (`local`, `apq3`, `apq5`), and Harmonic-to-Noise Ratio (HNR)
  - Zero Crossing Rate, Spectral Centroid, and Spectral Rolloff
- **4-Model Inference Engine**:
  1. `Classical FP32`: 3-layer deep neural network with BatchNorm & Dropout
  2. `Classical INT8`: PyTorch dynamic quantized engine for zero-latency mobile execution
  3. `Hybrid Quantum FP32`: PennyLane 8-qubit Variational Quantum Classifier (VQC) with angle embedding and strongly entangling CNOT layers
  4. `Hybrid Quantum INT8`: Serverless quantized hybrid quantum model
- **FastAPI + SQLite3 Backend**: End-to-end REST API persisting screening sessions, audio recordings, and acoustic telemetry.
- **Sovereign Clinical Dashboard**:
  - Live animated waveform visualizer during recording
  - Real-time pipeline execution monitor
  - In-app voice rehearing & interactive audio waveform with seek/play controls
  - V1 vs V2 Clinical Benchmarks Report (comparing 37-subject pilot vs 574-subject group-stratified clinical evaluation)

---

## System Architecture

```
SIH1729/
├── backend/
│   ├── app/
│   │   ├── config.py             # Audio sample rates (16kHz), model weights & paths
│   │   ├── database.py           # SQLite engine & session generator
│   │   ├── main.py               # FastAPI application & CORS configuration
│   │   ├── ml/
│   │   │   ├── model_loader.py   # PyTorch ClassicalModel & PennyLane HybridQuantumModel
│   │   │   ├── preprocessor.py   # Librosa 16kHz resampling, trim & Praat extraction
│   │   │   └── predictor.py      # StandardScaler transform, inference & biomarker scores
│   │   ├── models/screening.py   # SQLAlchemy ORM schema
│   │   ├── schemas/screening.py  # Pydantic response models
│   │   └── routers/              # API endpoints (/api/screen, /api/history, /api/audio)
│   ├── uploads/                  # Audio storage
│   ├── requirements.txt          # Python dependencies
│   └── run.py                    # Server launcher
├── lib/
│   ├── models/                   # ScreeningSessionProvider & HistoryItem state
│   ├── screens/                  # Flutter screens (Home, Recording, Pipeline, Result, Detail, History, Report)
│   ├── services/api_service.dart # HTTP REST client & audio streaming
│   ├── theme/                    # Clean clinical typography & colors
│   └── widgets/                  # Particle canvas, waveform player, topology widgets
├── V1/                           # V1 Pilot research notebooks & weights
└── V2/                           # V2 Production clinical models (Scaler, PyTorch, Quantum)
```

---

## Getting Started

### 1. Backend Server Setup

```bash
cd backend
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
python run.py
```

The API documentation is accessible at `http://127.0.0.1:8000/docs`.

### 2. Mobile App Setup (Flutter)

```bash
# Connect an Android device or start an emulator
# For physical Android devices connected via USB:
adb reverse tcp:8000 tcp:8000

# Install dependencies and run
flutter pub get
flutter run
```

---

## Research Benchmarks (V1 vs V2)

| Metric | V1 Pilot (37 Subjects) | V2 Clinical Cohort (574 Subjects) | Gain / Improvement |
|---|---|---|---|
| **Peak Test Accuracy** | 76.47% | **94.25%** | **+17.78%** |
| **Mean Cross-Val AUC** | 0.827 | **0.964** | **+0.137** |
| **Validation Strategy** | Random 80/20 | **StratifiedGroupKFold (Zero Leakage)** | Robust Clinical Safety |
| **Inference Latency** | 16.0 ms | **0.21 ms (INT8)** / **15.6 ms (VQC)** | Real-time on mobile |

---

## License

Built by **Team 1729 Labs**.
