from dotenv import load_dotenv
load_dotenv()

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
    
    CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

    @app.after_request
    def after_request(response):
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
        response.headers['Access-Control-Allow-Methods'] = 'GET,POST,PUT,DELETE,OPTIONS'
        return response

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