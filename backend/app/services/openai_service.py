import requests
from app.config import Config


class OpenAIService:
    def __init__(self):
        self.api_key = Config.OPENAI_API_KEY
        self.url = "https://api.openai.com/v1/chat/completions"

    def generate_chat_reply(self, message: str) -> dict:
        if not self.api_key:
            return {"reply": "OpenAI API key missing."}

        try:
            response = requests.post(
                self.url,
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": "gpt-4o-mini",
                    "messages": [
                        {
                            "role": "system",
                            "content": (
                                "You are a cybersecurity assistant for a final year project app called Secure Lens Pro. "
                                "Answer clearly, briefly, and helpfully. Focus on phishing, suspicious URLs, cyber hygiene, "
                                "password safety, breach awareness, and safe online behavior."
                            ),
                        },
                        {
                            "role": "user",
                            "content": message,
                        },
                    ],
                    "temperature": 0.4,
                },
                timeout=30,
            )

            data = response.json()
        except Exception as error:
            return {"reply": f"OpenAI request failed: {error}"}

        if isinstance(data, dict) and data.get("error"):
            return {
                "reply": f"OpenAI error: {data['error'].get('message', 'Unknown error')}"
            }

        try:
            text = data["choices"][0]["message"]["content"]
        except Exception:
            text = "No response received from OpenAI."

        return {"reply": text}
