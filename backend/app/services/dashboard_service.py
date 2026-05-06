from __future__ import annotations

from datetime import datetime, timedelta, timezone

from app.services.firebase_service import get_firestore_client

DANGER_LEVELS = {"high", "critical", "phishing", "danger"}
WARNING_LEVELS = {"warning", "medium", "suspicious"}


def get_admin_metrics() -> dict:
    try:
        db = get_firestore_client()
        user_docs = [doc.to_dict() or {} for doc in db.collection("users").stream()]
        scan_docs = [doc.to_dict() or {} for doc in db.collection("scan_results").stream()]
    except Exception as error:
        print(f"Failed to load admin metrics: {error}")
        return {
            "total_users": 0,
            "high_risk_users": 0,
            "recent_threats": 0,
            "average_cyber_score": 0,
        }

    user_entries = [
        user for user in user_docs
        if str(user.get("role", "user")).lower() != "admin"
    ]

    total_users = len(user_entries)

    high_risk_users = 0
    explicit_scores: list[float] = []

    for user in user_entries:
        score = _coerce_score(user.get("cyberScore"))
        risk_level = _resolve_risk_level(score, str(user.get("riskLevel", "")))

        if score is not None:
            explicit_scores.append(float(score))

        if risk_level == "high":
            high_risk_users += 1

    danger_scans = 0
    warning_scans = 0
    recent_threats = 0
    week_ago = datetime.now(timezone.utc) - timedelta(days=7)

    for scan in scan_docs:
        level = str(scan.get("riskLevel") or scan.get("risk_level") or "").lower()
        created_at = scan.get("createdAt") or scan.get("created_at")

        if level in DANGER_LEVELS:
            danger_scans += 1
        elif level in WARNING_LEVELS:
            warning_scans += 1

        if isinstance(created_at, datetime):
            if created_at.tzinfo is None:
                created_at = created_at.replace(tzinfo=timezone.utc)

            if created_at >= week_ago and level in DANGER_LEVELS:
                recent_threats += 1

    if explicit_scores:
        average_cyber_score = round(sum(explicit_scores) / len(explicit_scores))
    else:
        average_cyber_score = _estimate_score(danger_scans, warning_scans)

    if high_risk_users == 0 and total_users > 0 and danger_scans > 0:
        high_risk_users = min(total_users, danger_scans)

    return {
        "total_users": total_users,
        "high_risk_users": high_risk_users,
        "recent_threats": recent_threats,
        "average_cyber_score": average_cyber_score,
    }


def get_admin_users() -> dict:
    try:
        db = get_firestore_client()
        user_snapshots = list(db.collection("users").stream())
    except Exception as error:
        print(f"Failed to load admin users: {error}")
        return {"users": []}

    users = []

    for snapshot in user_snapshots:
        data = snapshot.to_dict() or {}
        role = str(data.get("role", "user")).lower()

        if role == "admin":
            continue

        score = _coerce_score(data.get("cyberScore"))
        risk_level = _resolve_risk_level(score, str(data.get("riskLevel", "")))

        users.append(
            {
                "id": snapshot.id,
                "name": str(data.get("name", "Unnamed User")),
                "email": str(data.get("email", "")),
                "role": role,
                "photo_url": str(data.get("photoUrl", "")),
                "cyber_score": round(score) if score is not None else None,
                "risk_level": risk_level,
                "status_label": _status_label(risk_level),
                "created_at": _format_created_at(data.get("createdAt")),
            }
        )

    users.sort(
        key=lambda item: (
            _risk_priority(item["risk_level"]),
            item["name"].lower(),
        )
    )

    return {"users": users}


def _estimate_score(danger_scans: int, warning_scans: int) -> int:
    if danger_scans == 0 and warning_scans == 0:
        return 0

    score = 92 - (danger_scans * 8) - (warning_scans * 3)
    return max(25, min(96, score))


def _coerce_score(value) -> float | None:
    if isinstance(value, (int, float)):
        return float(value)

    if isinstance(value, str):
        try:
            return float(value.strip())
        except ValueError:
            return None

    return None


def _resolve_risk_level(score: float | None, raw_level: str) -> str:
    level = raw_level.strip().lower()

    if level in DANGER_LEVELS:
        return "high"
    if level in WARNING_LEVELS:
        return "medium"
    if level in {"low", "safe", "clear"}:
        return "low"

    if score is None:
        return "medium"
    if score < 60:
        return "high"
    if score < 80:
        return "medium"
    return "low"


def _status_label(risk_level: str) -> str:
    if risk_level == "high":
        return "Needs Attention"
    if risk_level == "medium":
        return "Monitor"
    return "Stable"


def _risk_priority(risk_level: str) -> int:
    if risk_level == "high":
        return 0
    if risk_level == "medium":
        return 1
    return 2


def _format_created_at(value) -> str:
    if isinstance(value, datetime):
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc).strftime("%d %b %Y")

    return "Not available"
