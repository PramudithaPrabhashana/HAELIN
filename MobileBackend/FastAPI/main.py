from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
import traceback
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Chikungunya Prediction API")

# Enable CORS for Spring Boot
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or restrict to your frontend/backend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model and scaler
model = joblib.load("chik_model.pkl")
scaler = joblib.load("scaler.pkl")

# Input model - field names match your training CSV columns
class Symptoms(BaseModel):
    sex: int
    fever: int
    cold: int
    joint_pains: int
    myalgia: int
    headache: int
    fatigue: int
    vomitting: int
    arthritis: int
    Conjuctivitis: int
    Nausea: int
    Maculopapular_rash: int
    Eye_Pain: int
    Chills: int
    Swelling: int

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict_chikun")
def predict_chikun(data: Symptoms):
    try:
        # Convert to array (must match training order)
        features = np.array([[
            data.sex, data.fever, data.cold, data.joint_pains, data.myalgia,
            data.headache, data.fatigue, data.vomitting, data.arthritis,
            data.Conjuctivitis, data.Nausea, data.Maculopapular_rash,
            data.Eye_Pain, data.Chills, data.Swelling
        ]], dtype=float)

        # Scale features
        features_scaled = scaler.transform(features)

        # Predict class (0 or 1)
        prediction = int(model.predict(features_scaled)[0])

        # Predict probability (confidence)
        if hasattr(model, "predict_proba"):
            pred_score = float(model.predict_proba(features_scaled)[0][prediction])
        else:
            pred_score = None

        # Prediction timestamp
        pred_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        return {
            "prediction": prediction,      # 0 = no chikungunya, 1 = chikungunya
            "pred_score": pred_score,      # confidence score
            "pred_date": pred_date         # prediction time
        }

    except Exception as e:
        traceback_str = traceback.format_exc()
        raise HTTPException(status_code=500, detail=f"{str(e)}\n{traceback_str}")
