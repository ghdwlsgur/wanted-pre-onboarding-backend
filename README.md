
### 애플리케이션의 실행 방법 (엔드포인트 호출 방법 포함)

- 로컬 실행 (도커 컴포즈)

```bash
# 환경변수 설정
export MYSQL_HOST=localhost
export MYSQL_PASSWORD=[MYSQL비밀번호]
export JWT_SECRET_KEY=dev
export DOCKER_USERNAME=[도커허브-아이디]

# Flask 이미지 빌드 및 도커 허브 푸시
docker build -t $DOCKER_USERNAME/flask:board-v1 ./
docker push $DOCKER_USERNAME/flask:board-v1

# Nginx 이미지 빌드 및 도커 허브 푸시
cd nginx
docker build -t $DOCKER_USERNAME/nginx:board-v1 ./
docker push $DOCKER_USERNAME/nginx:board-v1

cd ../
# 도커 컴포즈 실행
docker compose up -d
```

- 애플리케이션 배포

```bash
# 환경변수 설정
export MYSQL_PASSWORD=[MYSQL비밀번호]
export JWT_SECRET_KEY=[JWT 토큰]
export DOCKER_USERNAME=[도커허브-아이디]
# AWS
export AWS_REGION=ap-northeast-2
export AWS_RESOURCE_PREFIX=board

# Flask 이미지 빌드 및 도커 허브 푸시
docker build -t $DOCKER_USERNAME/flask:board-v1 ./
docker push $DOCKER_USERNAME/flask:board-v1

# Nginx 이미지 빌드 및 도커 허브 푸시
cd nginx
docker build -t $DOCKER_USERNAME/nginx:board-v1 ./
docker push $DOCKER_USERNAME/nginx:board-v1

cd ../_terraform
# 테라폼 변수 파일 생성
vi terraform.tfvars
MYSQL_PASSWORD = [MYSQL_PASSWORD]
JWT_SECRET_KEY = [JWT_SECRET_KEY]
AWS_ACCESS_KEY = [AWS 액세스 키]
AWS_SECRET_KEY = [AWS 씨크릿 키]

terraform init
terraform plan
terraform apply -auto-approve # 인프라 배포

# ecs cli 로그인
ecs-cli configure --cluster ${AWS_RESOURCE_NAME_PREFIX}-cluster --default-launch-type EC2 --config-name ${AWS_RESOURCE_NAME_PREFIX}-cluster --region ${AWS_REGION}

cd ..
# ecs 배포
ecs-cli compose --project-name board --file docker-compose.yml  \
            --debug service up \
            --deployment-max-percent 100 --deployment-min-healthy-percent 0 \
            --region ${AWS_REGION} --ecs-profile default --cluster-config ${AWS_RESOURCE_NAME_PREFIX}-cluster
```

- 엔드포인트 호출 방법

```bash
# 회원가입
curl -X 'POST' \
  'http://localhost/api/user/signup' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "test@test.com",
  "password": "12345678"
}'

# 로그인
curl -X 'POST' \
  'http://localhost/api/user/login' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "test@test.com",
  "password": "12345678"
}'

# 게시글 작성 (로그인 결과 전달 받은 JWT 토큰 헤더 기입)
curl -X 'POST' \
  'http://localhost/api/board' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY5MTI0MzIxNywianRpIjoiMDBlZTg0YTYtNTRkYi00MWQ4LTliYTYtYzljMDE0OWFkOThhIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImNlMWRjNGM2LWExNGMtNDI1OC1iOWZmLTIzMGNhMWVkNmYyNyIsIm5iZiI6MTY5MTI0MzIxNywiZXhwIjoxNjkxMjQ0MTE3fQ.ClnAxca6x0vvGUGxvA8f9cS5a3qKqsz3ARNwF9u2br4' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "안녕하세요.",
  "content": "반갑습니다."
}'

# 게시글 리스트 조회
curl -X 'GET' \
  'http://localhost/api/board/boards?page=1&per_page=10' \
  -H 'accept: application/json'


# 게시글 조회
curl -X 'GET' \
  'http://localhost/api/board/30d112cc-839d-49b1-b36f-86823eb65dca' \
  -H 'accept: application/json'


# 게시글 수정
curl -X 'PUT' \
  'http://localhost/api/board/30d112cc-839d-49b1-b36f-86823eb65dca' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY5MTI0MzIxNywianRpIjoiMDBlZTg0YTYtNTRkYi00MWQ4LTliYTYtYzljMDE0OWFkOThhIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImNlMWRjNGM2LWExNGMtNDI1OC1iOWZmLTIzMGNhMWVkNmYyNyIsIm5iZiI6MTY5MTI0MzIxNywiZXhwIjoxNjkxMjQ0MTE3fQ.ClnAxca6x0vvGUGxvA8f9cS5a3qKqsz3ARNwF9u2br4' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "안녕하세요2.",
  "content": "반갑습니다2."
}'

# 게시글 삭제
curl -X 'DELETE' \
  'http://localhost/api/board/30d112cc-839d-49b1-b36f-86823eb65dca' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY5MTI0MzIxNywianRpIjoiMDBlZTg0YTYtNTRkYi00MWQ4LTliYTYtYzljMDE0OWFkOThhIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6ImNlMWRjNGM2LWExNGMtNDI1OC1iOWZmLTIzMGNhMWVkNmYyNyIsIm5iZiI6MTY5MTI0MzIxNywiZXhwIjoxNjkxMjQ0MTE3fQ.ClnAxca6x0vvGUGxvA8f9cS5a3qKqsz3ARNwF9u2br4'
```

---

### 데이터베이스 테이블 구조

<div align="center">

![DATABASE_ERD](https://github.com/ghdwlsgur/terraform/assets/77400522/ec183871-3472-4ceb-8cc5-8ec7d7ebf1eb)

</div>

- **User (사용자)**

<div align="center">

| Attribute  | DataType    | Description      |
| ---------- | ----------- | ---------------- |
| id         | VARCHAR(50) | Primary Key      |
| email      | VARCHAR(50) | Unique, Not Null |
| password   | VARCHAR(50) | Not Null         |
| created_at | DateTime    | Default: utcnow  |

</div>

- **Board (게시글)**

<div align="center">

| Attribute  | DataType     | Description                    |
| ---------- | ------------ | ------------------------------ |
| id         | VARCHAR(50)  | Primary Key                    |
| user_id    | VARCHAR(50)  | Foreign Key (유저 기본키 참조) |
| title      | VARCHAR(200) | Not Null / 제목                |
| content    | TEXT         | Not Null / 내용                |
| created_at | TIMESTAMP    | Default: utcnow / 작성일       |
| updated_at | TIMESTAMP    | 수정일                         |
| deleted_at | TIMESTAMP    | 삭제일                         |

</div>


### 구현 방법 및 이유에 대한 간략한 설명

장고보다 가볍고 마이크로서비스에 많이 사용되고 있는 flask로 API 서버를 개발하고 싶었으며 flask-restx에서 지원하는 swagger-ui로 API 정의서를 자동으로 만들고 SQLAlchemy를 활용하여 직접적으로 데이터베이스를 관리하지 않게 되어 API 개발에 집중할 수 있었습니다.

### API 명세(request/response 포함)

- http://board-alb-368374587.ap-northeast-2.elb.amazonaws.com/
- Infra Resource Down (23/08/15~)

### AWS 아키텍처

![스크린샷 2023-08-05 오후 11 44 55](https://github.com/ghdwlsgur/ecs-infra/assets/77400522/fa551c2c-5361-424c-a274-ef93ae355135)

가장 먼저 10.0.0.0/16 대역을 가지는 VPC가 생성되고 그 안에 인터넷 게이트웨이와 연결되어 있는 퍼블릭 서브넷 세 개와 인터넷 게이트웨이와 연결되어 있지 않은 프라이빗 서브넷 세 개가 생성됩니다. 이후 세 개의 퍼블릭 서브넷 범위에서 ECS의 오토스케일링 서비스가 생성되게 되며 세 퍼블릭 서브넷 중 한 곳에 ECS 에이전트 EC2가 LAUNCH CONFIGURATION에 의해서 프로비저닝됩니다.

![스크린샷 2023-08-05 오후 11 45 02](https://github.com/ghdwlsgur/ecs-infra/assets/77400522/7eea9e97-d4c7-4949-9b15-4ee6ea02db60)

ECS 최적화 이미지로 프로비저닝한 ECS 에이전트 EC2는 별도의 패키지 설치 없이 도커와 ecs-cli가 사용 가능한 상태이며 서비스는 테라폼에서 정의한 태스크 정의서 안에 있는 json 파일을 읽고 NGINX 이미지를 EC2 내부에 컨테이너로 생성합니다. EC2 인스턴스에 접속하여 실행중인 컨테이너 목록을 확인하면 NGINX 이미지를 가진 컨테이너가 실행되는 것을 확인하실 수 있습니다.

![스크린샷 2023-08-05 오후 11 45 09](https://github.com/ghdwlsgur/ecs-infra/assets/77400522/25288c9b-14db-4f96-8780-2600ea85934b)

NGINX 컨테이너는 ALB의 타겟으로 등록되어 ALB를 통해 들어오는 트래픽은 NGINX 컨테이너로 전달됩니다.

![스크린샷 2023-08-05 오후 11 45 16](https://github.com/ghdwlsgur/ecs-infra/assets/77400522/985b3221-02b3-41e7-be0d-156dc543d30c)

사용자가 로컬에서 ECS 서비스로 ecs-cli 명령어를 실행하면 도커 컴포즈 파일의 내용과 ecs-params에 정의된 각 컨테이너에 할당할 리소스(CPU, MEMORY) 정보를 포함하여 Task 파일(JSON)로 변환하며 이 변환된 Task 파일을 ECS의 서비스가 실행하게 됩니다. 이 과정에서 docker-compose 야믈 파일에 기술된 depends_on 속성은 사용할 수 없어 로컬 컨테이너 생성 동작과 다르게 동작하여 Flask 컨테이너 실행 시 MySQL 컨테이너가 생성될 때까지 대기하여야 하므로 약 1분간의 대기시간을 추가하였습니다. 서비스는 Task에 포함된 내용을 바탕으로 도커 허브의 이미지를 풀하여 세 개의 컨테이너를 생성합니다. Task에 정의된 도커 허브 이미지 저장소가 프라이빗 저장소로 설정되어 있을 경우 ECS 에이전트에서 접근이 불가능하게 되므로 퍼블릭 설정이 필요합니다.

![스크린샷 2023-08-05 오후 11 45 26](https://github.com/ghdwlsgur/ecs-infra/assets/77400522/489ffc82-0db8-40d4-81e2-a7fcfaaca4f8)

사전에 ALB 로드밸런서에서 Nginx 컨테이너로 타겟을 등록하였으므로 이전 과정에서 컨테이너 변경이 있었다고 해도 동일하게 Nginx 이름을 가진 Nginx 컨테이너가 존재하므로 여전히 ALB에서 인입되는 HTTP 트래픽은 Nginx 컨테이너로 전달되어 네트워크 구성 설정은 필요하지 않았으며 8080포트가 열려있는 플라스크 컨테이너에 트래픽을 전달하기 위해 Nginx는 80으로 오는 트래픽을 8080 포트로 리다이렉트됩니다.

지금까지의 과정은 테라폼으로 인프라를 프로비저닝하고 ecs-cli 명령어를 통해 로컬에 있는 도커 컴포즈에 선언된 컨테이너들을 AWS ECS의 에이전트인 EC2 클러스터에 배포하는 과정입니다.
