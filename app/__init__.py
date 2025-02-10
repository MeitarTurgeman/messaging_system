from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config

db = SQLAlchemy()
ma = Marshmallow()
jwt = JWTManager()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Enable CORS for all routes
    CORS(app, resources={r"/*": {"origins": "*"}})
    
    db.init_app(app)
    ma.init_app(app)
    jwt.init_app(app)

    from app.routes import messages_bp
    from app.auth import auth_bp
    
    app.register_blueprint(messages_bp)
    app.register_blueprint(auth_bp)

    with app.app_context():
        db.create_all()

    return app