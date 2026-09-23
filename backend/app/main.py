from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.database import engine, Base
from backend.app.routers.screening import router as screening_router
from backend.app.routers.history import router as history_router
from backend.app.ml.model_loader import registry

# Create database tables automatically
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="NeuroVoice API",
    description="FastAPI Backend for Parkinson's Voice Screening utilizing PyTorch & Pennylane Quantum Models",
    version="2.0.0"
)

# CORS setup for Flutter web & mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(screening_router)
app.include_router(history_router)

@app.get("/")
def root():
    return {
        "service": "NeuroVoice AI Backend",
        "status": "operational",
        "version": "2.0.0",
        "docs_url": "/docs"
    }

@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "models_count": 4,
        "classical_fp32_ready": registry.classical_fp32 is not None,
        "classical_int8_ready": registry.classical_int8 is not None,
        "quantum_fp32_ready": registry.hybrid_quantum_wrapper.is_loaded_fp32,
        "quantum_int8_ready": registry.hybrid_quantum_wrapper.is_loaded_int8,
        "classical_model_ready": registry.classical_fp32 is not None,
        "hybrid_quantum_ready": registry.hybrid_quantum_wrapper.is_loaded_fp32,
        "selected_features_count": len(registry.selected_features),
        "selected_features": registry.selected_features
    }
