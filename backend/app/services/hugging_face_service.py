import json
import re

import requests

from app.config import Config


class HuggingFaceService:
    HF_ZERO_SHOT_URL = "https://router.huggingface.co/hf-inference/models/facebook/bart-large-mnli"
    GEMINI_URL = (
        "https://generativelanguage.googleapis.com/v1beta/models/"
        "gemini-2.5-flash:generateContent"
    )

    def __init__(self):
        self.api_key = Config.HUGGING_FACE_API_KEY
        self.gemini_api_key = Config.GEMINI_API_KEY

    def analyze_email(self, content: str) -> dict:
        content = (content or "").strip()
        if not content:
            return {
                "risk_level": "medium",
                "matched_signals": ["Empty content"],
                "summary": "No message content was provided, so the system could not complete a meaningful safety analysis.",
            }

        ai_result = self._analyze_with_gemini(
            scan_type="message",
            content=content,
        )
        if ai_result is not None:
            return ai_result

        return self._fallback_email_analysis(content)

    def analyze_url(self, url: str) -> dict:
        url = (url or "").strip()
        if not url:
            return {
                "risk_level": "medium",
                "matched_signals": ["Empty URL"],
                "summary": "No URL was provided, so the system could not complete a meaningful link safety analysis.",
            }

        ai_result = self._analyze_with_gemini(
            scan_type="url",
            content=url,
        )
        if ai_result is not None:
            return ai_result

        return self._fallback_url_analysis(url)

    def _analyze_with_gemini(self, *, scan_type: str, content: str) -> dict | None:
        if not self.gemini_api_key:
            return None

        prompt = self._build_prompt(scan_type=scan_type, content=content)

        try:
            response = requests.post(
                f"{self.GEMINI_URL}?key={self.gemini_api_key}",
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
                timeout=40,
            )
            data = response.json()
        except Exception:
            return None

        if isinstance(data, dict) and data.get("error"):
            return None

        try:
            raw_text = data["candidates"][0]["content"]["parts"][0]["text"]
        except Exception:
            return None

        parsed = self._extract_json(raw_text)
        if not parsed:
            return None

        risk_level = str(parsed.get("risk_level", "medium")).strip().lower()
        if risk_level not in {"low", "medium", "high"}:
            risk_level = "medium"

        matched_signals = parsed.get("matched_signals", [])
        if not isinstance(matched_signals, list):
            matched_signals = []

        matched_signals = [
            str(item).strip()
            for item in matched_signals
            if str(item).strip()
        ][:5]

        summary = str(parsed.get("summary", "")).strip()
        if not summary:
            return None

        return {
            "risk_level": risk_level,
            "matched_signals": matched_signals,
            "summary": summary,
        }

    def _build_prompt(self, *, scan_type: str, content: str) -> str:
        if scan_type == "message":
            return f"""
You are a cybersecurity analyst.

Analyze the following suspicious message or email for phishing, scam, fraud, credential theft, social engineering, urgency pressure, malicious intent, or safe behavior.

Return ONLY valid JSON in this exact format:
{{
  "risk_level": "low" or "medium" or "high",
  "matched_signals": ["short reason 1", "short reason 2", "short reason 3"],
  "summary": "2-4 sentence brief explanation of why the message is risky or safe in simple language."
}}

Rules:
- Be specific to the actual message.
- If risky, mention the exact patterns that make it risky.
- If relatively safe, explain why it appears safe but still mention any caution if needed.
- Do not use markdown.
- Do not add any text outside JSON.

Message:
{content}
""".strip()

        return f"""
You are a cybersecurity analyst.

Analyze the following URL for phishing, impersonation, misleading subdomains, suspicious keywords, obfuscation, unsafe protocol usage, brand spoofing, or signs of safety.

Return ONLY valid JSON in this exact format:
{{
  "risk_level": "low" or "medium" or "high",
  "matched_signals": ["short reason 1", "short reason 2", "short reason 3"],
  "summary": "2-4 sentence brief explanation of why the URL is risky or safe in simple language."
}}

Rules:
- Be specific to the actual URL.
- Check for suspicious structure, protocol, domain tricks, excessive subdomains, brand confusion, scam language, and deceptive patterns.
- If relatively safe, explain why it appears safe but still mention any caution if needed.
- Do not use markdown.
- Do not add any text outside JSON.

URL:
{content}
""".strip()

    def _extract_json(self, text: str) -> dict | None:
        text = text.strip()

        try:
            parsed = json.loads(text)
            if isinstance(parsed, dict):
                return parsed
        except Exception:
            pass

        match = re.search(r"\{.*\}", text, re.DOTALL)
        if not match:
            return None

        try:
            parsed = json.loads(match.group(0))
            if isinstance(parsed, dict):
                return parsed
        except Exception:
            return None

        return None

    def _fallback_email_analysis(self, content: str) -> dict:
        text = content.lower()

        keyword_signals = []
        suspicious_keywords = [
            "verify",
            "password",
            "bank",
            "otp",
            "urgent",
            "suspended",
            "login",
            "account",
            "click",
            "winner",
            "lottery",
            "claim",
            "free",
            "gift",
            "refund",
            "reset",
        ]

        for word in suspicious_keywords:
            if word in text:
                keyword_signals.append(word)

        model_labels = []
        model_score = 0
        top_label = "unknown"

        if self.api_key:
            try:
                response = requests.post(
                    self.HF_ZERO_SHOT_URL,
                    headers={"Authorization": f"Bearer {self.api_key}"},
                    json={
                        "inputs": content,
                        "parameters": {
                            "candidate_labels": [
                                "phishing",
                                "safe",
                                "spam",
                                "urgent scam",
                                "credential theft",
                            ]
                        },
                    },
                    timeout=30,
                )
                data = response.json()

                if isinstance(data, dict):
                    model_labels = data.get("labels", [])
                    scores = data.get("scores", [])
                elif isinstance(data, list) and len(data) > 0 and isinstance(data[0], dict):
                    if "labels" in data[0] and "scores" in data[0]:
                        model_labels = data[0].get("labels", [])
                        scores = data[0].get("scores", [])
                    else:
                        sorted_items = sorted(
                            [item for item in data if isinstance(item, dict)],
                            key=lambda item: item.get("score", 0),
                            reverse=True,
                        )
                        model_labels = [item.get("label", "unknown") for item in sorted_items]
                        scores = [item.get("score", 0) for item in sorted_items]

                if model_labels:
                    top_label = model_labels[0]
                if scores:
                    model_score = scores[0]

            except Exception:
                pass

        keyword_count = len(keyword_signals)

        if keyword_count >= 3 or (top_label in ["phishing", "urgent scam", "credential theft"] and model_score >= 0.60):
            risk_level = "high"
        elif keyword_count >= 1 or model_score >= 0.45:
            risk_level = "medium"
        else:
            risk_level = "low"

        matched_signals = keyword_signals[:4]
        if not matched_signals and top_label not in ["safe", "unknown"]:
          matched_signals = [top_label]

        if risk_level == "high":
            summary = (
                f"This message looks highly suspicious because it uses patterns like "
                f"{', '.join(matched_signals) if matched_signals else 'urgent pressure and credential-related language'}. "
                "It may be trying to push you into clicking a link, verifying an account, or sharing sensitive information. "
                "Do not share passwords, OTPs, banking details, or personal data until the sender is independently verified."
            )
        elif risk_level == "medium":
            summary = (
                f"This message shows some caution signals such as "
                f"{', '.join(matched_signals) if matched_signals else 'unexpected request patterns'}. "
                "It may be legitimate, but it still needs manual verification before you click links or respond. "
                "Check the sender identity, the purpose of the request, and whether the language feels manipulative or rushed."
            )
        else:
            summary = (
                "This message appears relatively safer because it does not strongly match common phishing or scam patterns. "
                "Even so, you should still verify unexpected requests, attachments, and links before taking action."
            )

        return {
            "risk_level": risk_level,
            "matched_signals": matched_signals,
            "summary": summary,
        }

    def _fallback_url_analysis(self, url: str) -> dict:
        text = url.lower()
        indicators = []

        if len(url) > 50:
            indicators.append("Long URL")
        if "@" in url or "-" in url:
            indicators.append("Obfuscation pattern")
        if url.count(".") > 2:
            indicators.append("Multiple subdomains")
        if any(word in text for word in ["login", "verify", "bank", "gift", "free", "win", "claim", "secure", "update"]):
            indicators.append("Suspicious keywords")
        if text.startswith("http://"):
            indicators.append("Non-secure HTTP")

        score = len(indicators)

        if score >= 3:
            risk_level = "high"
        elif score >= 1:
            risk_level = "medium"
        else:
            risk_level = "low"

        if risk_level == "high":
            summary = (
                f"This URL looks highly suspicious because it contains "
                f"{', '.join(indicators)}. "
                "These patterns are commonly seen in phishing or deceptive links that try to mimic trusted pages. "
                "Do not open it unless the domain is independently verified."
            )
        elif risk_level == "medium":
            summary = (
                f"This URL has some risky indicators such as "
                f"{', '.join(indicators)}. "
                "It may not be malicious, but it should be checked carefully before visiting. "
                "Review the domain name, spelling, and whether the link matches the expected website."
            )
        else:
            summary = (
                "This URL appears relatively safe because it does not show strong phishing or deception patterns. "
                "Still, you should be careful with unknown links and verify the domain before opening it."
            )

        return {
            "risk_level": risk_level,
            "matched_signals": indicators,
            "summary": summary,
        }
