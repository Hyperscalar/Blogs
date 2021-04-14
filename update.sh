#!/usr/bin/env bash
#file: update.sh

if [[ $# -eq 0 ]]
then
    echo "Usage: specify module name(s) to update"
    echo "For example: 'bash update.sh zh en' will update both zh and en"
fi

for directory in "$@"
do
    echo ""
    read -p "Update framework, themes, and plugins for $directory? Y/N " answer
    if [[ $answer = "Y" ]]
    then
        cd $directory
        npm install && npm update
        git add package.json package-lock.json && git commit -m "Update framework and its plugins for $directory"
        cd ..
    fi
done
