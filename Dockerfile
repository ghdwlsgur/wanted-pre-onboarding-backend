FROM python:3.8 
WORKDIR /app 
COPY ["requirements.txt", "./"]
COPY /scripts/start.sh start.sh 
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . . 
RUN chmod +x start.sh
EXPOSE 8080
ENV FLASK_APP=board
ENV FLASK_DEBUG=true
ENV MYSQL_USER $MYSQL_USER
ENV MYSQL_PASSWORD $MYSQL_PASSWORD
ENV MYSQL_HOST $MYSQL_HOST
ENV MYSQL_DATABASE $MYSQL_DATABASE
ENV JWT_SECRET_KEY $JWT_SECRET_KEY
CMD ["./start.sh"]


