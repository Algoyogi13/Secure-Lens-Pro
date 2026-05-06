from flask import Blueprint, jsonify, request
from flask_cors import cross_origin

from app.services.auth_otp_service import request_email_otp, verify_email_otp
from app.services.breach_service import lookup_breach
from app.services.cyber_score import calculate_cyber_score
from app.services.dashboard_service import get_admin_metrics, get_admin_users
from app.services.firebase_service import save_assistant_activity, save_scan_result
from app.services.gemini_service import GeminiService
from app.services.hugging_face_service import HuggingFaceService

api_blueprint = Blueprint('api', __name__)
hf_service = HuggingFaceService()
gemini_service = GeminiService()


@api_blueprint.get('/health')
@cross_origin()
def health_check():
    return jsonify({'status': 'ok', 'service': 'secure-lens-backend'})


@api_blueprint.route('/auth/email-otp/request', methods=['POST', 'OPTIONS'])
@cross_origin()
def request_email_otp_route():
    payload = request.get_json(silent=True) or {}
    email = payload.get('email', '')
    purpose = payload.get('purpose', 'signup')
    return jsonify(request_email_otp(email, purpose))


@api_blueprint.route('/auth/email-otp/verify', methods=['POST', 'OPTIONS'])
@cross_origin()
def verify_email_otp_route():
    payload = request.get_json(silent=True) or {}
    email = payload.get('email', '')
    code = payload.get('code', '')
    purpose = payload.get('purpose', 'signup')
    return jsonify(verify_email_otp(email, code, purpose))


@api_blueprint.route('/scan/email', methods=['POST', 'OPTIONS'])
@cross_origin()
def scan_email():
    payload = request.get_json(silent=True) or {}
    content = payload.get('content', '')
    user_id = str(payload.get('user_id', '')).strip() or None

    result = hf_service.analyze_email(content)
    save_scan_result('email', result, user_id=user_id)

    return jsonify(
        {
            'type': 'email',
            'content_length': len(content),
            **result,
        }
    )


@api_blueprint.route('/scan/url', methods=['POST', 'OPTIONS'])
@cross_origin()
def scan_url():
    payload = request.get_json(silent=True) or {}
    url = payload.get('url', '')
    user_id = str(payload.get('user_id', '')).strip() or None

    result = hf_service.analyze_url(url)
    save_scan_result('url', result, user_id=user_id)

    return jsonify(
        {
            'type': 'url',
            'url': url,
            **result,
        }
    )


@api_blueprint.route('/breach/check', methods=['POST', 'OPTIONS'])
@cross_origin()
def breach_check():
    payload = request.get_json(silent=True) or {}
    identifier = payload.get('identifier', '')
    user_id = str(payload.get('user_id', '')).strip() or None

    result = lookup_breach(identifier)

    save_scan_result(
        'breach',
        {
            'risk_level': 'high' if result.get('exposed') else 'low',
            'summary': result.get('message', ''),
            **result,
        },
        user_id=user_id,
    )

    return jsonify(result)


@api_blueprint.route('/chat', methods=['POST', 'OPTIONS'])
@cross_origin()
def chat():
    payload = request.get_json(silent=True) or {}
    message = payload.get('message', '')
    user_id = str(payload.get('user_id', '')).strip() or None

    save_assistant_activity(message, user_id=user_id)
    return jsonify(gemini_service.generate_chat_reply(message))


@api_blueprint.route('/score', methods=['POST', 'OPTIONS'])
@cross_origin()
def score_user():
    payload = request.get_json(silent=True) or {}
    user_id = str(payload.get('user_id', '')).strip() or None
    return jsonify(calculate_cyber_score(user_id=user_id))


@api_blueprint.get('/admin/metrics')
@cross_origin()
def admin_metrics():
    return jsonify(get_admin_metrics())


@api_blueprint.get('/admin/users')
@cross_origin()
def admin_users():
    return jsonify(get_admin_users())
