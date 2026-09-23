import os
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import desc

from backend.app.database import get_db
from backend.app.models.screening import Screening
from backend.app.schemas.screening import (
    HistorySummary,
    ScreeningResponse,
    BatchDeleteRequest,
    BatchDeleteResponse
)
from backend.app.config import UPLOADS_DIR

router = APIRouter(prefix="/api/history", tags=["History"])

@router.get("", response_model=List[HistorySummary])
def get_all_screenings(db: Session = Depends(get_db)):
    """
    Retrieve all screening records ordered by most recent first.
    """
    records = db.query(Screening).order_by(desc(Screening.timestamp)).all()
    results = []
    for r in records:
        results.append(
            HistorySummary(
                id=r.id,
                timestamp=r.timestamp,
                risk_category=r.risk_category,
                risk_score=r.risk_score,
                confidence=r.confidence,
                model_used=r.model_used,
                jitter=r.jitter,
                shimmer=r.shimmer,
                hnr=r.hnr,
                vocal_stability=r.vocal_stability,
                tremor_incidence=r.tremor_incidence,
                articulation_rate=r.articulation_rate,
                duration_sec=r.duration_sec,
                audio_url=f"/api/audio/{r.audio_filename}"
            )
        )
    return results

@router.get("/{screening_id}", response_model=ScreeningResponse)
def get_screening_detail(screening_id: str, db: Session = Depends(get_db)):
    """
    Retrieve single screening detail.
    """
    record = db.query(Screening).filter(Screening.id == screening_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="Screening record not found")
    return record

@router.delete("/{screening_id}")
def delete_screening(screening_id: str, db: Session = Depends(get_db)):
    """
    Delete a single screening session and its associated audio file.
    """
    record = db.query(Screening).filter(Screening.id == screening_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="Screening record not found")

    # Remove audio file from disk if present
    file_path = UPLOADS_DIR / record.audio_filename
    if file_path.exists():
        try:
            os.remove(file_path)
        except Exception:
            pass

    db.delete(record)
    db.commit()
    return {"success": True, "deleted_id": screening_id}

@router.post("/delete-batch", response_model=BatchDeleteResponse)
def delete_batch(payload: BatchDeleteRequest, db: Session = Depends(get_db)):
    """
    Batch delete multiple selected screening sessions (matches Flutter multiselect delete).
    """
    if not payload.ids:
        return BatchDeleteResponse(success=True, deleted_count=0, deleted_ids=[])

    records = db.query(Screening).filter(Screening.id.in_(payload.ids)).all()
    deleted_ids = []

    for r in records:
        deleted_ids.append(r.id)
        file_path = UPLOADS_DIR / r.audio_filename
        if file_path.exists():
            try:
                os.remove(file_path)
            except Exception:
                pass
        db.delete(r)

    db.commit()
    return BatchDeleteResponse(
        success=True,
        deleted_count=len(deleted_ids),
        deleted_ids=deleted_ids
    )
