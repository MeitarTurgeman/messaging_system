from app import ma
from app.models import Message, User
from marshmallow import fields

class UserSchema(ma.SQLAlchemySchema):
    class Meta:
        model = User

    id = ma.auto_field()
    email = ma.auto_field()

user_schema = UserSchema()

class MessageSchema(ma.SQLAlchemySchema):
    class Meta:
        model = Message

    id = ma.auto_field()
    sender = ma.auto_field()
    receiver = ma.auto_field()
    subject = ma.auto_field()
    message = ma.auto_field()
    creation_date = ma.auto_field()
    is_read = ma.auto_field()

message_schema = MessageSchema()
messages_schema = MessageSchema(many=True)