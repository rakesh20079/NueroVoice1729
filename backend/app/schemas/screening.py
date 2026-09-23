from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, List, Dict, Any

class ScreeningBase(BaseModel):
    id: str
    timestamp: datetime
    audio_filename: str
    risk_category: str
    risk_score: float
    confidence: float
    model_used: str
    jitter: float
    shimmer: float
    hnr: float
    vocal_stability: float
    tremor_incidence: float
    articulation_rate: float
    duration_sec: float
    rationale: Optional[str] = None

class ScreeningResponse(ScreeningBase):
    feature_vector: Optional[Dict[str, float]] = None

    model_config = ConfigDict(from_attributes=True)

class HistorySummary(BaseModel):
    id: str
    timestamp: datetime
    risk_category: str
    risk_score: float
    confidence: float
    model_used: str
    jitter: float
    shimmer: float
    hnr: float
    vocal_stability: float
    tremor_incidence: float
    articulation_rate: float
    duration_sec: float
    audio_url: str

    model_config = ConfigDict(from_attributes=True)

class BatchDeleteRequest(BaseModel):
    ids: List[str]

class BatchDeleteResponse(BaseModel):
    success: bool
    deleted_count: int
    deleted_ids: List[str]
