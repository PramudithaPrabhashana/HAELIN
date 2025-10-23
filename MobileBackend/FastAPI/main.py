# main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
import traceback

app = FastAPI(title="Chikungunya/Chikungunya Prediction API")

# Load model and scaler (make sure these files exist in same folder)
model = joblib.load("chik_model.pkl")
scaler = joblib.load("scaler.pkl")

# Input model - field names match your CSV columns (snake-case okay)
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
        # Create array in same feature order you trained with
        features = np.array([[
            data.sex, data.fever, data.cold, data.joint_pains, data.myalgia,
            data.headache, data.fatigue, data.vomitting, data.arthritis,
            data.Conjuctivitis, data.Nausea, data.Maculopapular_rash,
            data.Eye_Pain, data.Chills, data.Swelling
        ]], dtype=float)

        # Scale then predict
        features_scaled = scaler.transform(features)
        prediction = model.predict(features_scaled)
        return {"prediction": int(prediction[0])}
    except Exception as e:
        traceback_str = traceback.format_exc()
        raise HTTPException(status_code=500, detail=f"{str(e)}\n{traceback_str}")
