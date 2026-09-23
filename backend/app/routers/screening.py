import os
import uuid
import json
import shutil
from datetime import datetime
from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from backend.app.database import get_db
from backend.app.models.screening import Screening
from backend.app.schemas.screening import ScreeningResponse
from backend.app.ml.preprocessor import extract_all_features_with_duration
from backend.app.ml.predictor import run_inference
from backend.app.config import UPLOADS_DIR

router = APIRouter(prefix="/api", tags=["Screening"])

@router.get("/models")
def get_models():
    """
    List the 4 available machine learning and quantum models.
    """
    from backend.app.ml.model_loader import registry
    return registry.get_available_models()

@router.post("/screen", response_model=ScreeningResponse)
async def screen_audio(
    file: UploadFile = File(...),
    mode: str = Query("classical_fp32", description="Model mode: 'classical_fp32', 'classical_int8', 'quantum_fp32', or 'quantum_int8'"),
    db: Session = Depends(get_db)
):
    """
    Upload voice audio file (.wav, .m4a, .mp3, etc.), extract acoustic and praat dysphonia
    features, run PyTorch / PennyLane inference, persist to SQLite, and return screening metrics.
    """
    if not file.filename:
        raise HTTPException(status_code=400, detail="Empty filename provided")

    # Generate unique ID and save file
    screening_id = f"NV-{datetime.utcnow().strftime('%Y')}-{uuid.uuid4().hex[:6].upper()}"
    ext = os.path.splitext(file.filename)[1].lower() or ".wav"
    saved_filename = f"{screening_id}{ext}"
    saved_path = UPLOADS_DIR / saved_filename

    try:
        with open(saved_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        file_size_kb = round(os.path.getsize(saved_path) / 1024, 1)
        print("\n" + "=" * 70)
        print(f"[NeuroVoice API] Voice Screening Audio Received:")
        print(f"   * Session ID:    {screening_id}")
        print(f"   * Audio File:    {saved_filename} ({file_size_kb} KB)")
        print(f"   * Selected Mode: {mode}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save audio file: {e}")

    # Feature Extraction (librosa + praat-parselmouth from v2-sih.ipynb)
    try:
        features, duration = extract_all_features_with_duration(str(saved_path))
        print(f"[NeuroVoice Audio] Acoustic & Praat Extraction Finished:")
        print(f"   * Duration:       {round(duration, 2)}s")
        print(f"   * Jitter (local): {round(features.get('jitter_local', 0.0) * 100, 3)}%")
        print(f"   * Shimmer (apq3): {round(features.get('shimmer_apq3', 0.0) * 100, 3)}%")
        print(f"   * HNR:            {round(features.get('hnr', 0.0), 2)} dB")
        print(f"   * F0 Mean:        {round(features.get('f0_mean', 0.0), 2)} Hz")
    except Exception as e:
        if saved_path.exists():
            os.remove(saved_path)
        raise HTTPException(status_code=422, detail=f"Feature extraction failed on audio: {e}")

    # Model Inference
    try:
        print(f"[NeuroVoice Model] Running Inference: '{mode}'...")
        prediction = run_inference(features, mode=mode)
        print(f"[NeuroVoice Result] {prediction['model_used']}:")
        print(f"   * Prediction:     {prediction['risk_category']} (Risk Score: {prediction['risk_score']})")
        print(f"   * Confidence:     {prediction['confidence']}%")
        print(f"   * Vocal Stability:{prediction['vocal_stability']}%")
        print(f"   * Tremor Index:   {prediction['tremor_incidence']}%")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Model inference failed: {e}")

    # Save to SQLite Database
    db_screening = Screening(
        id=screening_id,
        timestamp=datetime.utcnow(),
        audio_filename=saved_filename,
        risk_category=prediction["risk_category"],
        risk_score=prediction["risk_score"],
        confidence=prediction["confidence"],
        model_used=prediction["model_used"],
        jitter=prediction["jitter"],
        shimmer=prediction["shimmer"],
        hnr=prediction["hnr"],
        vocal_stability=prediction["vocal_stability"],
        tremor_incidence=prediction["tremor_incidence"],
        articulation_rate=prediction["articulation_rate"],
        duration_sec=round(duration, 2),
        rationale=prediction["rationale"],
        feature_vector_json=json.dumps(prediction["selected_features"])
    )
    db.add(db_screening)
    db.commit()
    db.refresh(db_screening)
    print(f"[NeuroVoice DB] Persisted screening {screening_id} to SQLite.")
    print("=" * 70 + "\n")

    return ScreeningResponse(
        id=db_screening.id,
        timestamp=db_screening.timestamp,
        audio_filename=db_screening.audio_filename,
        risk_category=db_screening.risk_category,
        risk_score=db_screening.risk_score,
        confidence=db_screening.confidence,
        model_used=db_screening.model_used,
        jitter=db_screening.jitter,
        shimmer=db_screening.shimmer,
        hnr=db_screening.hnr,
        vocal_stability=db_screening.vocal_stability,
        tremor_incidence=db_screening.tremor_incidence,
        articulation_rate=db_screening.articulation_rate,
        duration_sec=db_screening.duration_sec,
        rationale=db_screening.rationale,
        feature_vector=prediction["selected_features"]
    )

@router.get("/audio/{filename}")
async def get_audio_file(filename: str):
    """
    Stream audio file for in-app playback.
    """
    file_path = UPLOADS_DIR / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Audio file not found")
    return FileResponse(path=str(file_path), media_type="audio/wav")
