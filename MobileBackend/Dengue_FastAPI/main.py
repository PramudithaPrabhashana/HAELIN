from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
import traceback
from fastapi.middleware.cors import CORSMiddleware

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
scaler = joblib.load("scaler (1).pkl")

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
        prediction = model.predict(features_scaled)
        return {"prediction": int(prediction[0])}  # 0 = no dengue, 1 = dengue

    except Exception as e:
        traceback_str = traceback.format_exc()
        raise HTTPException(status_code=500, detail=f"{str(e)}\n{traceback_str}")
