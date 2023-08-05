from flask_restx import fields 
from .extensions import api 


req_model = api.model("BoardRequest", {  
  "title": fields.String(description='제목', required=True),
  "content": fields.String(description='내용', required=True)
})

board_model = api.model("Board", {
  "id": fields.String(description='게시글 아이디', required=True),
  "userId": fields.String(description='유저 고유 아이디', required=True),
  "title": fields.String(description='제목', required=True),
  "content": fields.String(description='내용', required=True),
  "created_at": fields.DateTime(description='생성일 (KST)'),
  "updated_at": fields.DateTime(description='수정일 (KST)'),
  "deleted_at": fields.DateTime(description='삭제일 (KST)'),
})

res_model = api.model("BoardResponse", {
  "message": fields.String, 
  "statusCode": fields.Integer, 
  "board": fields.Nested(board_model)
})

list_model = api.model("BoardListResponse", {
  "message": fields.String, 
  "statusCode": fields.Integer, 
  "totalPage": fields.Integer, 
  "totalBoard": fields.Integer, 
  "page": fields.Integer, 
  "per_page": fields.Integer,
  "boards": fields.List(fields.Nested(board_model))
})
