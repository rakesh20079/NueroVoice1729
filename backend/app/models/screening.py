from sqlalchemy import Column, String, Float, DateTime, Text
from datetime import datetime
from backend.app.database import Base

class Screening(Base):
    __tablename__ = "screenings"

    id = Column(String, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    audio_filename = Column(String, nullable=False)
    
    # Classification & Probabilities
    risk_category = Column(String, nullable=False)  # "Low Risk", "Moderate Risk", "High Risk"
    risk_score = Column(Float, nullable=False)       # 0.0 - 1.0 (raw model probability)
    confidence = Column(Float, nullable=False)       # 0.0 - 100.0%
    model_used = Column(String, default="Classical PyTorch + Pennylane Quantum")
    
    # Acoustic Biomarkers
    jitter = Column(Float, nullable=False)
    shimmer = Column(Float, nullable=False)
    hnr = Column(Float, nullable=False)
    vocal_stability = Column(Float, nullable=False)
    tremor_incidence = Column(Float, nullable=False)
    articulation_rate = Column(Float, nullable=False)
    duration_sec = Column(Float, nullable=False)
    
    # Clinical Explanation & Raw Data
    rationale = Column(Text, nullable=True)
    feature_vector_json = Column(Text, nullable=True)
