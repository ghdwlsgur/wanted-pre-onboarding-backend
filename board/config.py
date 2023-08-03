import os

BASE_DIR = os.path.dirname(__file__)

# MYSQL_USER
# MYSQL_PASSWORD
# MYSQL_HOST
# MYSQL_PORT 
# MYSQL_DATABASE
# JWT_SECRET_KEY 

# 데이터베이스 접속 정보
db = {
    'user': os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv("MYSQL_PASSWORD"),
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'port': int(os.getenv('MYSQL_PORT', 3306)),
    'database': os.getenv('MYSQL_DATABASE', 'PROJECT')
}

# 데이터베이스 접속 주소
SQLALCHEMY_DATABASE_URI = f"mysql+mysqlconnector://{db['user']}:{db['password']}@{db['host']}:{db['port']}/{db['database']}?charset=utf8"
# SQLAlchemy의 이벤트 처리 옵션
SQLALCHEMY_TRAK_MODIFICATIONS = False
# JSON WEB TOKEN - SECRET KEY
JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'dev')