from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from flask_bcrypt import Bcrypt

db = SQLAlchemy()
bcrypt = Bcrypt()

# Association table for User and PI many-to-many relationship
user_pi = db.Table('user_pi',
    db.Column('user_id', db.Integer, db.ForeignKey('user.id'), primary_key=True),
    db.Column('pi_id', db.Integer, db.ForeignKey('pi.id'), primary_key=True)
)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)  # Store hashed passwords
    pis = db.relationship('PI', secondary=user_pi, backref=db.backref('users', lazy=True))

    # Method to hash and set the password
    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')

    # Method to check if the password is correct
    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)

class PI(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)  # Store hashed passwords
    rooms = db.relationship('Room', backref='pi', lazy=True)

    # Method to hash and set the password
    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')

    # Method to check if the password is correct
    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)

class Building(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    rooms = db.relationship('Room', backref='building', lazy=True)

class Room(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    building_id = db.Column(db.Integer, db.ForeignKey('building.id'), nullable=False)
    room_number = db.Column(db.String(10), nullable=False)
    pi_id = db.Column(db.Integer, db.ForeignKey('pi.id'), nullable=False)
    contact_name = db.Column(db.String(80), nullable=True)
    contact_phone = db.Column(db.String(15), nullable=True)
    spaces = db.relationship('Space', backref='room', lazy=True)
    chemicals = db.relationship('Chemical', backref='room', lazy=True)

class Space(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    room_id = db.Column(db.Integer, db.ForeignKey('room.id'), nullable=False)
    description = db.Column(db.String(200), nullable=True)
    space_type = db.Column(db.String(50), nullable=True)
    space_id = db.Column(db.String(50), nullable=True)

class Chemical(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    cas_number = db.Column(db.String(50), nullable=False)
    barcode = db.Column(db.String(10), unique=True, nullable=False, default='')
    room_id = db.Column(db.Integer, db.ForeignKey('room.id'), nullable=False)
    space_id = db.Column(db.Integer, db.ForeignKey('space.id'), nullable=True)  # Foreign key to Space
    amount = db.Column(db.Float, nullable=False)
    unit = db.Column(db.String(10), nullable=False)
    expiration_date = db.Column(db.DateTime, nullable=True)
    date_added = db.Column(db.DateTime, default=datetime.utcnow)
    total_weight_lbs = db.Column(db.Float, nullable=False)
    space = db.relationship('Space', backref='chemicals', lazy=True)

    
