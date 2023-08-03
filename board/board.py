from flask_restx import Resource, Namespace, reqparse
from flask_jwt_extended import (jwt_required, get_jwt_identity)
from .board_api_models import req_model, res_model

from board import db 
from .models import Board
from sqlalchemy.exc import DBAPIError

import uuid 
from datetime import datetime 
from typing import List


authorizations = {
  'Bearer': {
    'type': 'apiKey',
    'in': 'header',
    'name': 'Authorization'
  }
}
ns = Namespace("api/board", authorizations=authorizations)

# 게시글 응답 클래스 (게시글 정보) - CREATE, READ, UPDATE, DELETE
class BoardData:
  def __init__(self, id: str, userId: str, title: str, content: str, created_at: datetime = None, updated_at: datetime = None, deleted_at: datetime = None):
    self.id = id 
    self.userId = userId
    self.title = title 
    self.content = content 
    self.created_at = created_at 
    self.updated_at = updated_at 
    self.deleted_at = deleted_at 
    
  def to_dict(self):
    return {
      'id': self.id,
      'userId': self.userId,
      'title': self.title,
      'content': self.content,
      'created_at': self.created_at.isoformat() if self.created_at else None,
      'updated_at': self.updated_at.isoformat() if self.updated_at else None,
      'deleted_at': self.deleted_at.isoformat() if self.deleted_at else None
    }
    
# 게시글 리스트 응답 클래스 - READ
class ResponseListData:
  def __init__(self, message: str, statusCode: int, totalPage: int, totalBoard: int, page: int, per_page: int, boards: List[BoardData]):
    self.message = message 
    self.statusCode = statusCode 
    self.totalPage = totalPage 
    self.totalBoard = totalBoard
    self.page = page 
    self.per_page = per_page
    self.boards = boards
    
  def to_dict(self):
    return {
      'message': self.message,
      'statusCode': self.statusCode, 
      'totalPage': self.totalPage,
      'totalBoard': self.totalBoard, 
      'page': self.page, 
      'per_page': self.per_page,
      'boards': self.boards if self.boards else None
    }


# 게시글 응답 클래스 - CREATE, READ, UPDATE, DELETE
class ResponseData:
  def __init__(self, message: str, statusCode: int, board: BoardData):
    self.message = message 
    self.statusCode = statusCode 
    self.board = board
    
  def to_dict(self):
    return {
      'message': self.message,
      'statusCode': self.statusCode, 
      'board': self.board.to_dict() if self.board else None
    }
    

parser = reqparse.RequestParser()
parser.add_argument('title', type=str, required=True)
parser.add_argument('content', type=str, required=True)

# 게시글 등록
@ns.route("")
class CreateBoard(Resource):
  @ns.doc(responses={
    200: 'Success',
    500: 'Interner Server Error'
  })
  @ns.marshal_with(res_model)
  @ns.expect(req_model)
  @ns.doc(description="사용자가 새로운 게시글을 생성합니다.", security='Bearer')
  @jwt_required()
  def post(self) -> ResponseData:
    args = parser.parse_args()
    inp_user_id = get_jwt_identity()
    inp_title: str = args["title"]
    inp_content: str = args["content"]
    
    board = Board(
      id=self.generate_unique_id(),
      user_id=inp_user_id,
      title=inp_title,
      content=inp_content,
      created_at=datetime.utcnow()
    )
    
    try:
      db.session.add(board)
      db.session.commit()
      board_data = BoardData(board.id, board.user_id, board.title, board.content, board.created_at)
      response_data = ResponseData("Create Board Success", 200, board_data)
      return response_data.to_dict(), 200
    except DBAPIError:      
      db.session.rollback()
      response_data = ResponseData("Database error", 500, None)
      return response_data.to_dict(), 500
          
  def generate_unique_id(self) -> str:
    return str(uuid.uuid4())


@ns.route("/<string:id>")
@ns.doc(params={'id': '게시글 아이디'})
class RUDBoard(Resource):
  # 게시글 조회 
  @ns.doc(response={
    200: 'Success',
    404: 'Not Found',
  })
  @ns.marshal_with(res_model)
  @ns.doc(description="특정 게시글을 조회합니다.")
  def get(self, id) -> ResponseData:
    board = Board.query.get_or_404(id)
    
    board_data = BoardData(board.id, board.user_id, board.title, board.content, board.created_at, board.updated_at)
    response_data = ResponseData("Get Board Success", 200, board_data)
    return response_data.to_dict(), 200 
  
  # 게시글 수정
  @ns.doc(response={
    200: 'Success',
    403: 'Unauthorized operation',
    404: 'Not Found'
  })
  @ns.marshal_with(res_model)
  @ns.expect(req_model)
  @ns.doc(description="사용자가 작성한 게시글을 수정합니다.", security='Bearer')
  @jwt_required()
  def put(self, id) -> ResponseData:
    args = parser.parse_args()
    inp_user_id = get_jwt_identity()
    inp_title: str = args["title"]
    inp_content: str = args["content"]
  
    board = Board.query.get_or_404(id)
    if board.user_id == inp_user_id:
      board.title = inp_title
      board.content = inp_content
      board.updated_at = datetime.utcnow()
      
      try:        
        db.session.commit()
        board_data = BoardData(board.id, board.user_id, board.title, board.content, board.created_at, board.updated_at)
        response_data = ResponseData("Update Board Success", 200, board_data)
        return response_data.to_dict(), 200
      except DBAPIError:
        db.session.rollback()
        response_data = ResponseData("Database error", 500, None)
        return response_data.to_dict(), 500
    else:
      response_data = ResponseData("Unauthorized operation", 403, None)
      return response_data.to_dict(), 403 
  
  # 게시글 삭제 (논리적 삭제)
  @ns.doc(response={
    200: 'Success', 
    403: 'Unauthorized operation',
    404: 'Not Found'
  })
  @ns.marshal_with(res_model)
  @ns.doc(description="사용자가 작성한 게시글을 삭제합니다.", security='Bearer')
  @jwt_required()
  def delete(self, id) -> ResponseData:    
    inp_user_id = get_jwt_identity()
    
    board = Board.query.get_or_404(id)
    if board.user_id == inp_user_id:
      board.deleted_at = datetime.utcnow()      
      
      try:
        db.session.commit()
        board_data = BoardData(board.id, board.user_id, board.title, board.content, board.created_at, board.updated_at, board.deleted_at)
        response_data = ResponseData("Delete Board Success", 200, board_data)
        return response_data.to_dict(), 200 
      except DBAPIError: 
        db.session.rollback()
        response_data = ResponseData("Database error", 500, None)
        return response_data.to_dict(), 500 
    else:
      response_data = ResponseData("Unauthorized operation", 403, None)
      return response_data.to_dict(), 403


@ns.route("/boards")            
@ns.doc(params={'page': '페이지 번호', 'per_page': '페이지당 게시글 개수'})
class GetBoards(Resource):
  @ns.doc(response={
    200: 'Success'    
  })
  @ns.doc(description="게시글 리스트를 조회합니다.")
  def get(self):
    
    parser = reqparse.RequestParser()
    parser.add_argument('page', type=int, default=1)
    parser.add_argument('per_page', type=int, default=20)
    args = parser.parse_args()
    inp_page = args["page"]
    inp_per_page = args["per_page"]
    
    pagination = Board.query.filter(Board.deleted_at.is_(None)).paginate(page=inp_page, per_page=inp_per_page, error_out=False)
    boards = pagination.items
    boards_data = [BoardData(board.id, board.user_id, board.title, board.content, board.created_at, board.updated_at).to_dict() for board in boards]    
    
    response_data = ResponseListData("Get Board List Success", 200, pagination.pages, pagination.total, inp_page, inp_per_page, boards_data)
    return response_data.to_dict(), 200 
  
  
