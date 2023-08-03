from flask import Flask
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from .extensions import api 
from . import config

db = SQLAlchemy()
migrate = Migrate()


def create_app():
    app = Flask(__name__)
    app.config.from_object(config)  # read config.py
    jwt = JWTManager(app)

    # ORM
    db.init_app(app)
    migrate.init_app(app, db)
    from . import models 
                
    
    # Flask-RestX            
    from . import user, board
    api.init_app(app)    
    api.add_namespace(user.ns)
    api.add_namespace(board.ns)

        
       
    return app
