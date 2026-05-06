from __future__ import annotations

from functools import lru_cache

import firebase_admin
from firebase_admin import credentials, firestore

from app.config import Config


def _service_account_payload() -> dict:
    return {
        "type": "service_account",
        "project_id": Config.FIREBASE_PROJECT_ID,
        "client_email": Config.FIREBASE_CLIENT_EMAIL,
        "private_key": Config.FIREBASE_PRIVATE_KEY.replace("\\n", "\n"),
        "token_uri": "https://oauth2.googleapis.com/token",
    }


@lru_cache(maxsize=1)
def get_firestore_client():
    if (
        not Config.FIREBASE_PROJECT_ID
        or not Config.FIREBASE_CLIENT_EMAIL
        or not Config.FIREBASE_PRIVATE_KEY
    ):
        raise RuntimeError(
            "Firebase is not configured yet. Add FIREBASE_PROJECT_ID, "
            "FIREBASE_CLIENT_EMAIL, and FIREBASE_PRIVATE_KEY in backend/.env"
        )

    try:
        firebase_admin.get_app()
    except ValueError:
        firebase_admin.initialize_app(
            credentials.Certificate(_service_account_payload())
        )

    return firestore.client()


def save_scan_result(scan_type: str, result: dict, user_id: str | None = None) -> None:
    try:
        db = get_firestore_client()
    except Exception as error:
        print(f"Skipping Firebase save because config is incomplete: {error}")
        return

    payload = {
        "scanType": scan_type,
        "riskLevel": str(result.get("risk_level", "unknown")).lower(),
        "summary": str(result.get("summary", "")),
        "raw": result,
        "userId": user_id or "",
        "createdAt": firestore.SERVER_TIMESTAMP,
    }

    db.collection("scan_results").add(payload)


def save_assistant_activity(message: str, user_id: str | None = None) -> None:
    try:
        db = get_firestore_client()
    except Exception as error:
        print(f"Skipping assistant activity save because config is incomplete: {error}")
        return

    db.collection("assistant_activity").add(
        {
            "message": message,
            "userId": user_id or "",
            "createdAt": firestore.SERVER_TIMESTAMP,
        }
    )
