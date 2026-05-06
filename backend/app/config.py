import os
from dotenv import load_dotenv

load_dotenv()


def _to_bool(value: str, default: bool = False) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {'1', 'true', 'yes', 'on'}


class Config:
    HUGGING_FACE_API_KEY = os.getenv('HUGGING_FACE_API_KEY', '')
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', '')
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')
    FIREBASE_PROJECT_ID = os.getenv('FIREBASE_PROJECT_ID', '')
    FIREBASE_CLIENT_EMAIL = os.getenv('FIREBASE_CLIENT_EMAIL', '')
    FIREBASE_PRIVATE_KEY = os.getenv('FIREBASE_PRIVATE_KEY', '')

    SMTP_HOST = os.getenv('SMTP_HOST', '')
    SMTP_PORT = int(os.getenv('SMTP_PORT', '587'))
    SMTP_USERNAME = os.getenv('SMTP_USERNAME', '')
    SMTP_PASSWORD = os.getenv('SMTP_PASSWORD', '')
    SMTP_SENDER_EMAIL = os.getenv('SMTP_SENDER_EMAIL', '')
    SMTP_SENDER_NAME = os.getenv('SMTP_SENDER_NAME', 'Secure Lens Pro')
    SMTP_USE_TLS = _to_bool(os.getenv('SMTP_USE_TLS', 'true'), default=True)
    SMTP_USE_SSL = _to_bool(os.getenv('SMTP_USE_SSL', 'false'), default=False)

    EMAIL_OTP_EXPIRY_SECONDS = int(os.getenv('EMAIL_OTP_EXPIRY_SECONDS', '600'))
