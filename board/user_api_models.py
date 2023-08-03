from flask_restx import fields 
from .extensions import api 


user_model = api.model("User", {
  "id": fields.String(description='고유 아이디'), 
  "email": fields.String(description='이메일', required=True),
  "password": fields.String(description='해시 비밀번호', required=True, min=8),
  "created_at": fields.DateTime(description='유저 생성일')
})

signup_res_model = api.model("SignUpResponse", {
  "message": fields.String,
  "statusCode": fields.Integer,
  "user": fields.Nested(user_model)
})

user_req_model = api.model("UserRequest", {
  "email": fields.String(description='이메일', required=True),
  "password": fields.String(description='비밀번호', required=True)  
})

login_res_model = api.model("LoginResponse", {
  "message": fields.String, 
  "statusCode": fields.String, 
  "accessToken": fields.String(description='JWT 토큰')
})



