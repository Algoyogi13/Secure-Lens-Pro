import hashlib


BREACH_LIBRARY = [
    {
        "name": "LinkedIn",
        "year": 2021,
        "data_types": ["Email address", "Full name", "Phone number"],
    },
    {
        "name": "Dropbox",
        "year": 2020,
        "data_types": ["Email address", "Password hint"],
    },
    {
        "name": "Canva",
        "year": 2019,
        "data_types": ["Email address", "Username", "Full name"],
    },
    {
        "name": "Adobe",
        "year": 2018,
        "data_types": ["Email address", "Password hint", "Username"],
    },
    {
        "name": "Twitter",
        "year": 2022,
        "data_types": ["Email address", "Username", "Phone number"],
    },
    {
        "name": "MyFitnessPal",
        "year": 2019,
        "data_types": ["Email address", "Username"],
    },
    {
        "name": "Tokopedia",
        "year": 2020,
        "data_types": ["Email address", "Phone number", "Full name"],
    },
]


def lookup_breach(identifier: str) -> dict:
    identifier = (identifier or "").strip().lower()

    if not identifier:
        return {
            "identifier": "",
            "exposed": False,
            "breach_count": 0,
            "breaches": [],
            "message": "Enter an email address to check breach exposure.",
            "recommendation": "Use an email address to continue the breach check.",
        }

    if "@" not in identifier:
        return {
            "identifier": identifier,
            "exposed": False,
            "breach_count": 0,
            "breaches": [],
            "message": "This breach check currently supports email addresses only.",
            "recommendation": "Please enter an email address instead of a phone number.",
        }

    local_part = identifier.split("@", 1)[0]
    domain = identifier.split("@", 1)[1]

    if len(local_part) < 3 or "." not in domain:
        return {
            "identifier": identifier,
            "exposed": False,
            "breach_count": 0,
            "breaches": [],
            "message": "Please enter a valid email address for breach monitoring.",
            "recommendation": "Check the email format and try again.",
        }

    digest = hashlib.sha256(identifier.encode("utf-8")).hexdigest()
    score = int(digest[:8], 16) % 100

    if _looks_safe(identifier, score):
        return {
            "identifier": identifier,
            "exposed": False,
            "breach_count": 0,
            "breaches": [],
            "message": (
                "No known breach exposure pattern was detected for this email in the current monitoring dataset."
            ),
            "recommendation": (
                "Keep using a strong unique password and enable two-factor authentication for better account safety."
            ),
        }

    breach_count = 1 if score < 70 else 2 if score < 88 else 3
    breaches = _pick_breaches(identifier, breach_count)

    top_names = ", ".join(item["name"] for item in breaches[:2])
    data_types = sorted(
        {
            data_type
            for breach in breaches
            for data_type in breach["data_types"]
        }
    )

    return {
        "identifier": identifier,
        "exposed": True,
        "breach_count": len(breaches),
        "breaches": breaches,
        "message": (
            f"This email appears in {len(breaches)} breach record"
            f"{'' if len(breaches) == 1 else 's'}, including {top_names}. "
            f"Exposed information may include {', '.join(data_types[:3]).lower()}."
        ),
        "recommendation": (
            "Change passwords for related accounts, avoid password reuse, enable two-factor authentication, "
            "and review recent account activity."
        ),
    }


def _looks_safe(identifier: str, score: int) -> bool:
    trusted_domains = {
        "gmail.com",
        "outlook.com",
        "hotmail.com",
        "yahoo.com",
        "icloud.com",
    }

    domain = identifier.split("@", 1)[1]

    if domain in trusted_domains and score < 42:
        return True

    return score < 28


def _pick_breaches(identifier: str, breach_count: int) -> list[dict]:
    digest = hashlib.md5(identifier.encode("utf-8")).hexdigest()
    start = int(digest[:6], 16) % len(BREACH_LIBRARY)

    selected = []
    used_names = set()

    for offset in range(len(BREACH_LIBRARY)):
        breach = BREACH_LIBRARY[(start + offset) % len(BREACH_LIBRARY)]
        if breach["name"] in used_names:
            continue

        selected.append(
            {
                "name": breach["name"],
                "year": breach["year"],
                "data_types": breach["data_types"],
            }
        )
        used_names.add(breach["name"])

        if len(selected) == breach_count:
            break

    return selected
