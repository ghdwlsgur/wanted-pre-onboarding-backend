from board import db
from datetime import datetime

class User(db.Model):
  id = db.Column(db.String(50), primary_key=True)
  email = db.Column(db.String(150), unique=True, nullable=False)
  password = db.Column(db.String(200), nullable=False)
  created_at = db.Column(db.DateTime(), nullable=False, default=datetime.utcnow)
  
class Board(db.Model):
  id = db.Column(db.String(50), primary_key=True)
  user_id = db.Column(db.String(50), db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)  
  title = db.Column(db.String(200), nullable=False)  
  content = db.Column(db.Text, nullable=False)
  created_at = db.Column(db.DateTime(), default=datetime.utcnow)
  updated_at = db.Column(db.DateTime())  
  deleted_at = db.Column(db.DateTime())
  
  # User 모델에서 해당 사용자가 작성한 게시글을 user.boards와 같은 형태로 참조 가능 
  # User 모델과 Board 모델 사이 양방향 참조하고 필요한 경우만 SQLAlchemy가 데이터를 조회
  # User 모델과 관계가 끊어질 경우 게시글 자동 삭제
  user = db.relationship('User', backref=db.backref('boards', lazy=True, cascade='all,delete-orphan'))
  
  
