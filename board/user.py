
from flask_restx import Resource, Namespace, reqparse
from werkzeug.security import generate_password_hash, check_password_hash 
from .user_api_models import user_req_model, signup_res_model, login_res_model
from datetime import datetime 

from board import db 
from .models import User 
from sqlalchemy.exc import DBAPIError

from flask_jwt_extended import create_access_token
import uuid 

ns = Namespace("api/user")

# 회원가입 응답 클래스 (유저 정보)
class UserData:
  def __init__(self, id: str, email: str, password: str, created_at: datetime):
    self.id = id 
    self.email = email 
    self.password = password 
    self.created_at = created_at

  def to_dict(self):
      return {
        'id': self.id,
        'email': self.email,
        'password': self.password,
        'created_at': self.created_at
      }
      
# 회원가입 응답 클래스
class ResponseData:
  def __init__(self, message: str, statusCode: int, user: UserData):
    self.message = message 
    self.statusCode = statusCode
    self.user = user 
    
  def to_dict(self):
    return {
      'message': self.message,
      'statusCode': self.statusCode,
      'user': self.user.to_dict() if self.user else None
    }
        
# 로그인 응답 클래스
class LoginResponseData:
  def __init__(self, message: str, statusCode: str, access_token: str):
    self.message = message 
    self.statusCode = statusCode 
    self.access_token = access_token
    
  def to_dict(self):
    return {
      'message': self.message,
      'statusCode': self.statusCode,
      'accessToken': self.access_token 
    }

# 이메일, 비밀번호 유효성 검사 유틸리티 클래스
class UserRequestValidate():    
  def valid_email_format(self, email: str) -> bool:
    if '@' in email:
      return True 
    else:
      return False 
      
  def valid_password_format(self, password: str) -> bool:
    if len(password) >= 8:
      return True 
    else:
      return False 


parser = reqparse.RequestParser()
parser.add_argument('email', type=str, required=True)
parser.add_argument('password', type=str, required=True)    
  
# 로그인 
@ns.route("/login")
class Login(Resource):
  @ns.doc(responses={
      200: 'Success',
      400: 'Bad Request',
      401: 'Invalid username or password',              
  })
  @ns.marshal_with(login_res_model)
  @ns.expect(user_req_model)  
  @ns.doc(description="사용자에게 이메일과 비밀번호를 입력받아 로그인을 진행합니다.")
  def post(self) -> LoginResponseData:    
    args = parser.parse_args()        
    inp_email: str = args["email"]
    inp_password: str = args["password"]
    
    validator = UserRequestValidate()
    if not validator.valid_email_format(inp_email):
      response_data = LoginResponseData("Invalid email format", 400, None)
      return response_data.to_dict()
    
    if not validator.valid_password_format(inp_password):
      response_data = LoginResponseData("Invalid password format", 400, None)
      return response_data.to_dict()
    
    user = User.query.filter_by(email=inp_email).first()
    if not user:
      response_data = LoginResponseData("User does not exist", 401, None)
      return response_data.to_dict()
    elif not check_password_hash(user.password, inp_password):
      response_data = LoginResponseData("Incorrect password", 400, None)
      return response_data.to_dict()      
    else:
      access_token = create_access_token(identity=user.id)
      response_data = LoginResponseData("Login Success", 200, access_token)
      return response_data.to_dict()      
        

# 회원가입 
@ns.route("/signup")
class SignUp(Resource):  
  @ns.doc(responses={
        200: 'Success',
        400: 'Bad Request',
        409: 'Email already exists',
        500: 'Internal Server Error'        
    })
  @ns.marshal_with(signup_res_model)
  @ns.expect(user_req_model)
  @ns.doc(description="사용자에게 고유 이메일과 비밀번호를 입력받아 회원가입을 진행합니다.")
  def post(self) -> ResponseData:        
    args = parser.parse_args()        
    inp_email: str = args["email"]
    inp_password: str = args["password"]
            
    validator = UserRequestValidate()            
    if not validator.valid_email_format(inp_email): 
      response_data = ResponseData("Invalid email format", 400, None)
      return response_data.to_dict(), 400 
    
    if not validator.valid_password_format(inp_password):
      response_data = ResponseData("Invalid password format", 400, None)
      return response_data.to_dict(), 400
        
    if self.exist_email(inp_email):
      response_data = ResponseData("Email already exists", 409, None)
      return response_data.to_dict(), 409      
    
    user = User(      
      id=self.generate_unique_id(),
      email=inp_email,
      password=generate_password_hash(inp_password),      
      created_at=datetime.utcnow(),
    )
    
    try:      
      db.session.add(user)
      db.session.commit()
    except DBAPIError:
      db.session.rollback()
      response_data = ResponseData("Database error", 500, None)
      return response_data.to_dict(), 500
    
    user_data = UserData(user.id, user.email, user.password, user.created_at)
    response_data = ResponseData("Regist Success", 200, user_data)
    return response_data.to_dict(), 200 
      
  def generate_unique_id(self) -> str:
    return str(uuid.uuid4())
   
  def exist_email(self, email: str) -> bool:  
    if User.query.filter_by(email=email).first() is not None:
      return True
    else:
      return False 