import os
import sys
import numpy as np
import soundfile as sf
import tempfile

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from fastapi.testclient import TestClient
from backend.app.main import app
from backend.app.ml.preprocessor import extract_all_features
from backend.app.ml.predictor import run_inference
from backend.app.ml.model_loader import registry

def generate_test_wav(filepath: str, duration: float = 2.0, sr: int = 16000):
    t = np.linspace(0, duration, int(sr * duration), endpoint=False)
    # Synthetic sustained vowel /a/ at 180Hz fundamental with harmonics and micro-tremor
    signal = 0.5 * np.sin(2 * np.pi * 180 * t) + 0.2 * np.sin(2 * np.pi * 360 * t)
    # Add slight amplitude fluctuation (shimmer)
    mod = 1.0 + 0.03 * np.sin(2 * np.pi * 5 * t)
    signal = signal * mod
    sf.write(filepath, signal.astype(np.float32), sr)

def test_full_pipeline():
    print("--- 1. Testing Model Registry & Health ---")
    client = TestClient(app)
    res = client.get("/api/health")
    assert res.status_code == 200, f"Health check failed: {res.text}"
    health_data = res.json()
    print("Health response:", health_data)
    assert health_data["classical_model_ready"] is True
    assert health_data["hybrid_quantum_ready"] is True
    assert health_data["selected_features_count"] == 8

    print("--- 2. Generating synthetic voice audio ---")
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        temp_wav_path = tmp.name

    try:
        generate_test_wav(temp_wav_path)

        print("--- 3. Testing Feature Extraction ---")
        # Test exact notebook method: extract_all_features(wav_path) -> dict
        feats_direct = extract_all_features(temp_wav_path)
        assert isinstance(feats_direct, dict)
        print(f"Direct notebook extract_all_features returned {len(feats_direct)} features.")

        # Test API helper: extract_all_features_with_duration(wav_path) -> (dict, float)
        from backend.app.ml.preprocessor import extract_all_features_with_duration
        feats, dur = extract_all_features_with_duration(temp_wav_path)
        print(f"Extracted {len(feats)} features. Duration: {dur:.2f}s")
        for k in registry.selected_features:
            assert k in feats, f"Missing selected feature {k}"
            print(f"  {k} = {feats[k]:.4f}")

        print("--- 4. Testing All 4 ML Models ---")
        models_to_test = ["classical_fp32", "classical_int8", "quantum_fp32", "quantum_int8"]
        for m in models_to_test:
            pred = run_inference(feats, mode=m)
            print(f"  Model '{m}' -> {pred['model_used']} | Risk: {pred['risk_category']} | Conf: {pred['confidence']}%")
            assert "risk_category" in pred
            assert 0.0 <= pred["risk_score"] <= 1.0

        print("--- 5. Testing API GET /api/models ---")
        m_res = client.get("/api/models")
        assert m_res.status_code == 200
        available_models = m_res.json()
        print(f"Available models count: {len(available_models)}")
        assert len(available_models) == 4

        print("--- 6. Testing API POST /api/screen ---")
        with open(temp_wav_path, "rb") as f:
            response = client.post(
                "/api/screen?mode=classical_int8",
                files={"file": ("test_voice.wav", f, "audio/wav")}
            )
        assert response.status_code == 200, f"Upload failed: {response.text}"
        screen_result = response.json()
        print("Screening result ID:", screen_result["id"])
        print("Risk:", screen_result["risk_category"], "| Confidence:", screen_result["confidence"])
        session_id = screen_result["id"]

        print("--- 6. Testing API GET /api/history ---")
        hist_res = client.get("/api/history")
        assert hist_res.status_code == 200
        history_list = hist_res.json()
        print(f"History list contains {len(history_list)} records")
        assert any(item["id"] == session_id for item in history_list)

        print("--- 7. Testing API Batch Delete ---")
        del_res = client.post("/api/history/delete-batch", json={"ids": [session_id]})
        assert del_res.status_code == 200
        del_data = del_res.json()
        print("Deleted count:", del_data["deleted_count"])
        assert del_data["deleted_count"] >= 1

        print("--- ALL BACKEND TESTS PASSED SUCCESSFULLY! ---")
    finally:
        if os.path.exists(temp_wav_path):
            os.remove(temp_wav_path)

if __name__ == "__main__":
    test_full_pipeline()
