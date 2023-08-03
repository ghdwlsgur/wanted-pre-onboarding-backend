from flask_restx import Api

api = Api(    
    version='1.0',
    title="HJH's API Server",
    description="HJH's Board API Server!",
    terms_url="/",
    contact="redmax45@naver.com",
    license="MIT",
    doc='/'
)