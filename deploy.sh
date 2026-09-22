#!/bin/bash

PROJECT_NAME='flask-app'

echo "Composing project: $PROJECT_NAME"

docker compose up -d --build

if [ $? -eq 0 ]; then
	echo "Done!"
else 
	echo "Something went wrong!"
fi
