#!/bin/bash

echo "Commit description:"
read commit_message

git add .
git commit -m "$commit_message"
git push

if [ $? -eq 0 ]; then
	echo "Done!"
else
	echo "Something went wrong!"
fi


