#!/bin/bash

cd "$(dirname "$0")/.."

deploy(){
	echo "Building and restarting the project..."
	docker compose up -d --build
	if [ $? -eq 0 ]; then 
		echo "Ready!"
	else
		echo "Build error!"
	fi
}

push(){
	echo "Enter a commit description"
	read commit_message
	git add .
	git commit -m "$commit_message"
	git push
	if [ $? -eq 0 ]; then
		echo "Sent to GitHub!"
	else
		echo "Sent error!"
	fi
}

if [ "$1" == "deploy" ]; then
	deploy
elif [ "$1" == "push" ]; then
	push
else
	echo "Using: ./project.sh [deploy|push]"
fi
