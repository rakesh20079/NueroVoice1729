import uvicorn
import os
import sys
import warnings

warnings.filterwarnings("ignore")

# Ensure backend root is on sys.path
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

backend_dir = os.path.join(BASE_DIR, "backend")

if __name__ == "__main__":
    print("=" * 60)
    print("  Starting NeuroVoice FastAPI Backend on http://127.0.0.1:8000")
    print("  Swagger UI Documentation: http://127.0.0.1:8000/docs")
    print("=" * 60)
    uvicorn.run(
        "backend.app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        reload_dirs=[backend_dir],
        log_level="info"
    )
