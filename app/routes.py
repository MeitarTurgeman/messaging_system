from flask import Blueprint, request, jsonify, send_from_directory
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models import Message
from app.schemas import message_schema, messages_schema

messages_bp = Blueprint('messages', __name__)

@messages_bp.route('/messages', methods=['GET', 'POST'])
@jwt_required()
def messages():
    current_user = get_jwt_identity()
    
    if request.method == 'POST':
        try:
            data = request.get_json()
            new_message = Message(
                sender=current_user,
                receiver=data['receiver'],
                subject=data.get('subject', ''),
                message=data['message']
            )
            db.session.add(new_message)
            db.session.commit()
            return jsonify(message_schema.dump(new_message)), 201
        except Exception as e:
            return jsonify({'error': str(e)}), 400

    # GET method - return only messages for current user
    query = Message.query.filter(
        (Message.receiver == current_user) | (Message.sender == current_user)
    ).order_by(Message.creation_date.desc())
    
    if request.args.get('unread', 'false').lower() == 'true':
        query = query.filter_by(is_read=False, receiver=current_user)
    
    messages = query.all()
    return jsonify(messages_schema.dump(messages)), 200

@messages_bp.route('/messages/<int:message_id>', methods=['GET', 'DELETE'])
@jwt_required()
def message_operations(message_id):
    current_user = get_jwt_identity()
    message = Message.query.get_or_404(message_id)
    
    # Verify user has access to this message
    if current_user not in [message.sender, message.receiver]:
        return jsonify({'error': 'Unauthorized'}), 403
    
    if request.method == 'GET':
        if not message.is_read and current_user == message.receiver:
            message.is_read = True
            db.session.commit()
        return jsonify(message_schema.dump(message)), 200
    
    elif request.method == 'DELETE':
        db.session.delete(message)
        db.session.commit()
        return jsonify({'message': 'Message deleted successfully'}), 200

 @messages_bp.route('/health', methods=['GET'])
   def health_check():
       return jsonify({"status": "healthy", "version": "1.1"})

@messages_bp.route('/')
def index():
    return send_from_directory('../public', 'index.html')