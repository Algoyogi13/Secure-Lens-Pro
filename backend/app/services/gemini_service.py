import requests
from app.config import Config


class GeminiService:
    def __init__(self):
        self.api_key = Config.GEMINI_API_KEY
        self.url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            "gemini-2.5-flash:generateContent"
        )

    def generate_chat_reply(self, message: str) -> dict:
        user_message = (message or "").strip()

        if not user_message:
            return {
                "reply": "Please ask a cybersecurity, privacy, or phone-safety related question.",
            }

        if not self.api_key:
            return {
                "reply": (
                    "AI assistant is not configured right now. "
                    "Please add the Gemini API key in the backend settings."
                )
            }

        prompt = (
            "You are a cybersecurity assistant for a final year project app called "
            "Secure Lens Pro.\n\n"
            "Your scope includes:\n"
            "- cybersecurity\n"
            "- phishing and scam detection\n"
            "- suspicious links, messages, emails, OTP fraud, and fake websites\n"
            "- password safety, account protection, privacy, safe browsing\n"
            "- mobile and phone protection\n"
            "- device safety, app permissions, suspicious apps, call/SMS scams, Wi-Fi safety\n"
            "- online fraud prevention and digital safety\n\n"
            "If the user's question is directly or indirectly related to digital safety, "
            "online safety, account safety, phone safety, or privacy, answer helpfully.\n"
            "If the question is clearly unrelated to these topics, politely say that you only "
            "help with cybersecurity, privacy, and phone/device safety.\n\n"
            "Answer clearly, naturally, and briefly in practical language.\n\n"
            f"User question: {user_message}"
        )

        try:
            response = requests.post(
                f"{self.url}?key={self.api_key}",
                headers={"Content-Type": "application/json"},
                json={
                    "contents": [
                        {
                            "parts": [
                                {"text": prompt}
                            ]
                        }
                    ]
                },
                timeout=30,
            )
            data = response.json()
        except Exception:
            return {
                "reply": (
                    "The AI assistant is temporarily unavailable. "
                    "Please try again in a moment."
                )
            }

        if isinstance(data, dict) and data.get("error"):
            return {
                "reply": (
                    "The AI assistant is currently busy or unavailable. "
                    "Please try again after a short while."
                )
            }

        try:
            text = data["candidates"][0]["content"]["parts"][0]["text"].strip()
        except Exception:
            text = (
                "I could not generate a response right now. "
                "Please try again in a moment."
            )

        return {"reply": text}
