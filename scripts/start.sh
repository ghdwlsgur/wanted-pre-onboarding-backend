#!/bin/sh

sleep 120

flask db migrate
flask db upgrade && gunicorn -w 4 -b 0.0.0.0:8080 'board:create_app()'
