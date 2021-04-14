#!/usr/bin/env bash
#file: deploy.sh

if [[ $# -eq 0 ]]
then
    echo "Usage: specify module name to deploy"
    echo "For example: 'bash deploy.sh root zh' will deploy both root and zh"
fi

for directory in "$@"
do
    if [[ $directory = "root" ]]
    then
        echo ""
        echo "Prepare for $directory..."
        HEAD=$(git rev-parse HEAD)
        git subtree add --prefix=$directory/public/ $directory master --squash

        echo ""
        echo "Generate for $directory..."
        cd $directory
        rm -rf public/ && cp -r source/ public/
        git add -f public/ && git commit -m "Deployed by Git"
        cd ..

        echo ""
        echo "Deploy for $directory..."
        git subtree split --prefix=$directory/public/ --branch $directory
        git subtree push --prefix=$directory/public/ $directory master --squash

        echo ""
        echo "Cleanup for $directory"
        git reset --hard $HEAD
    else
        echo ""
        echo "Prepare for $directory..."
        HEAD=$(git rev-parse HEAD)
        git subtree add --prefix=$directory/public/ $directory master --squash

        echo ""
        echo "Generate for $directory..."
        cd $directory
        npm install && npm update
        hexo clean && hexo generate
        git add -f public/ && git commit -m "Deployed by Git"
        cd ..

        echo ""
        echo "Deploy for $directory..."
        git subtree split --prefix=$directory/public/ --branch $directory
        git subtree push --prefix=$directory/public/ $directory master --squash

        echo ""
        echo "Cleanup for $directory"
        git reset --hard $HEAD
    fi
done
