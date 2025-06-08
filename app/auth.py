from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from app import db
from app.models import User, CloudUser

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST', 'OPTIONS'])
def register():
    if request.method == 'OPTIONS':
        return '', 200

    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    if not email or not password:
        return jsonify({'error': 'Email and password required'}), 400

    # local
    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already registered'}), 400

    # local User creation
    user = User(email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()

    # CloudUser (RDS)
    try:
        cloud_user = CloudUser(email=email, password_hash=user.password_hash)
        db.session.add(cloud_user)
        db.session.commit(bind='cloud')
    except Exception as e:
        db.session.rollback(bind='cloud')
        print(f"[register] Could not add user to cloud DB: {e}")

    return jsonify({'message': 'User registered successfully'}), 201

@auth_bp.route('/login', methods=['POST', 'OPTIONS'])
def login():
    if request.method == 'OPTIONS':
        return '', 200

    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    # try to find user in local database
    user = User.query.filter_by(email=email).first()
    if user and user.check_password(password):
        access_token = create_access_token(identity=user.email)
        return jsonify({
            'access_token': access_token,
            'user_email': user.email
        }), 200

    # try to find user in cloud database
    cloud_user = CloudUser.query.filter_by(email=email).with_bind_key('cloud').first()
    if cloud_user and cloud_user.check_password(password):
        access_token = create_access_token(identity=cloud_user.email)
        return jsonify({
            'access_token': access_token,
            'user_email': cloud_user.email
        }), 200

    # if no user found in both databases
    return jsonify({'error': 'Invalid credentials'}), 401