#!/bin/sh

sleep 30
flask db upgrade && gunicorn -w 4 -b 0.0.0.0:8080 'board:create_app()'
