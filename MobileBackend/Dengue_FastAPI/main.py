from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
import traceback
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

app = FastAPI(title="Dengue Prediction API")

# Enable CORS so Spring Boot can call it
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or your Spring Boot URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model and scaler
model = joblib.load("dengue_model.pkl")
scaler = joblib.load("scaler (1).pkl")  # rename your scaler file appropriately

# Input schema: matches the checkboxes in the app
class Symptoms(BaseModel):
    Fever: int
    Headache: int
    JointPain: int
    Bleeding: int

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict_dengue")
def predict_dengue(data: Symptoms):
    try:
        # Convert to array
        features = np.array([[data.Fever, data.Headache, data.JointPain, data.Bleeding]], dtype=float)

        # Scale
        features_scaled = scaler.transform(features)

        # Predict
        prediction = int(model.predict(features_scaled)[0])

        # Prediction probability/score
        if hasattr(model, "predict_proba"):
            pred_score = float(model.predict_proba(features_scaled)[0][prediction])
        else:
            pred_score = None

        # Current date/time
        pred_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        return {
            "prediction": prediction,      # 0 = no dengue, 1 = dengue
            "pred_score": pred_score,      # confidence score
            "pred_date": pred_date         # prediction timestamp
        }

    except Exception as e:
        traceback_str = traceback.format_exc()
        raise HTTPException(status_code=500, detail=f"{str(e)}\n{traceback_str}")
