from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import requests
import os

# Load environment variables
load_dotenv()

DEEPSEEK_API_URL = "https://openrouter.ai/api/v1/chat/completions"
API_KEY = os.getenv("DEEPSEEK_API_KEY")

if not API_KEY:
    raise ValueError("❌ API key not found. Please set DEEPSEEK_API_KEY in .env file.")

app = FastAPI(title="Medical Chatbot API (No RAG)")

# Request body model
class UserMessage(BaseModel):
    message: str

@app.get("/")
def root():
    return {"message": "Medical Chatbot API is running without RAG. Use POST /chat to talk to it."}

@app.post("/chat")
def chat(user_message: UserMessage):
    """Simple chatbot endpoint without RAG"""
    payload = {
        "model": "mistralai/mistral-7b-instruct:free",

        "messages": [
            {"role": "system", "content": "You are a helpful medical assistant. Give general health guidance, but remind users to consult a doctor for serious issues."},
            {"role": "user", "content": user_message.message}
        ],
        "stream": False
    }

    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(DEEPSEEK_API_URL, json=payload, headers=headers, timeout=60)
        response.raise_for_status()
        data = response.json()

        # Extract reply
        reply = data.get("choices", [{}])[0].get("message", {}).get("content", "No response received.")
        return {"reply": reply}

    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=str(e))
