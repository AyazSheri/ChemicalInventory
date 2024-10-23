from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from api.routes import api  # Importing routes from the api folder

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///chemicals.db'  # Replace with your database URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Initialize the API
api.init_app(app)

if __name__ == '__main__':
    app.run(debug=True)
