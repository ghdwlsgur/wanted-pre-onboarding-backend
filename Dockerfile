FROM python:3.8 
WORKDIR /app 
COPY ["requirements.txt", "./"]
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . . 
EXPOSE 8080
ENV FLASK_APP=board
ENV FLASK_DEBUG=true
ENV MYSQL_USER $MYSQL_USER
ENV MYSQL_PASSWORD $MYSQL_PASSWORD
ENV MYSQL_HOST $MYSQL_HOST
ENV MYSQL_DATABASE $MYSQL_DATABASE
ENV JWT_SECRET_KEY $JWT_SECRET_KEY
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8080", "board:create_app()"]
