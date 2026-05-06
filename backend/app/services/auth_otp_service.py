import hashlib
import random
import re
import smtplib
import ssl
from email.message import EmailMessage
from time import time

from app.config import Config

_EMAIL_RE = re.compile(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
_ALLOWED_PURPOSES = {
    'signup': 'Sign Up Verification',
    'login': 'Login Verification',
}
_OTP_STORE: dict[str, dict[str, int | str]] = {}


def request_email_otp(email: str, purpose: str = 'signup') -> dict:
    normalized_email = email.strip().lower()
    normalized_purpose = purpose.strip().lower() or 'signup'

    validation_error = _validate_request(normalized_email, normalized_purpose)
    if validation_error is not None:
        return validation_error

    code = f'{random.SystemRandom().randint(0, 999999):06d}'
    expires_at = int(time()) + Config.EMAIL_OTP_EXPIRY_SECONDS

    try:
        _send_otp_email(
            email=normalized_email,
            code=code,
            purpose=normalized_purpose,
            expires_at=expires_at,
        )
    except RuntimeError as error:
        return {
            'success': False,
            'message': str(error),
        }

    _OTP_STORE[_store_key(normalized_email, normalized_purpose)] = {
        'code_hash': _hash_code(code),
        'expires_at': expires_at,
        'attempts_left': 5,
    }

    return {
        'success': True,
        'message': 'Verification code sent successfully.',
        'expires_in': Config.EMAIL_OTP_EXPIRY_SECONDS,
    }


def verify_email_otp(email: str, code: str, purpose: str = 'signup') -> dict:
    normalized_email = email.strip().lower()
    normalized_purpose = purpose.strip().lower() or 'signup'
    normalized_code = code.strip()

    validation_error = _validate_request(normalized_email, normalized_purpose)
    if validation_error is not None:
        return validation_error

    if not re.fullmatch(r'\d{6}', normalized_code):
        return {
            'success': False,
            'message': 'Enter the 6-digit verification code.',
        }

    key = _store_key(normalized_email, normalized_purpose)
    payload = _OTP_STORE.get(key)

    if payload is None:
        return {
            'success': False,
            'message': 'No active verification request was found. Please request a new code.',
        }

    now = int(time())
    if now > int(payload['expires_at']):
        _OTP_STORE.pop(key, None)
        return {
            'success': False,
            'message': 'Your verification code has expired. Please request a new code.',
        }

    if _hash_code(normalized_code) != payload['code_hash']:
        remaining = int(payload['attempts_left']) - 1
        if remaining <= 0:
            _OTP_STORE.pop(key, None)
            return {
                'success': False,
                'message': 'Too many incorrect attempts. Please request a new code.',
            }

        payload['attempts_left'] = remaining
        return {
            'success': False,
            'message': f'Incorrect code. {remaining} attempt(s) remaining.',
        }

    _OTP_STORE.pop(key, None)
    return {
        'success': True,
        'message': 'Verification successful.',
    }


def _validate_request(email: str, purpose: str) -> dict | None:
    if not _EMAIL_RE.fullmatch(email):
        return {
            'success': False,
            'message': 'Please enter a valid email address.',
        }

    if purpose not in _ALLOWED_PURPOSES:
        return {
            'success': False,
            'message': 'Unsupported verification flow.',
        }

    return None


def _hash_code(code: str) -> str:
    return hashlib.sha256(code.encode('utf-8')).hexdigest()


def _store_key(email: str, purpose: str) -> str:
    return f'{purpose}:{email}'


def _send_otp_email(*, email: str, code: str, purpose: str, expires_at: int) -> None:
    if not Config.SMTP_HOST or not Config.SMTP_PORT or not Config.SMTP_SENDER_EMAIL:
        raise RuntimeError(
            'Email OTP is not configured on the backend yet. Add SMTP settings in backend/.env first.'
        )

    sender = Config.SMTP_SENDER_EMAIL
    display_name = Config.SMTP_SENDER_NAME.strip() or 'Secure Lens Pro'
    subject_prefix = _ALLOWED_PURPOSES[purpose]
    expires_in_minutes = max(1, Config.EMAIL_OTP_EXPIRY_SECONDS // 60)

    message = EmailMessage()
    message['From'] = f'{display_name} <{sender}>'
    message['To'] = email
    message['Subject'] = f'{subject_prefix} OTP - Secure Lens Pro'
    message.set_content(
        (
            f'Your Secure Lens Pro verification code is {code}.\n\n'
            f'This code will expire in {expires_in_minutes} minute(s).\n\n'
            'If you did not request this code, you can safely ignore this email.'
        )
    )

    context = ssl.create_default_context()

    try:
        if Config.SMTP_USE_SSL:
            with smtplib.SMTP_SSL(Config.SMTP_HOST, Config.SMTP_PORT, context=context) as server:
                if Config.SMTP_USERNAME:
                    server.login(Config.SMTP_USERNAME, Config.SMTP_PASSWORD)
                server.send_message(message)
        else:
            with smtplib.SMTP(Config.SMTP_HOST, Config.SMTP_PORT) as server:
                if Config.SMTP_USE_TLS:
                    server.starttls(context=context)
                if Config.SMTP_USERNAME:
                    server.login(Config.SMTP_USERNAME, Config.SMTP_PASSWORD)
                server.send_message(message)
    except Exception as error:
        raise RuntimeError(f'Failed to send verification email: {error}') from error
