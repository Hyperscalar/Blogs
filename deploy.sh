#!/usr/bin/env bash
#file: deploy.sh

if [[ $# -eq 0 ]]
then
    echo "Usage: specify module name to deploy"
    echo "For example: 'bash deploy.sh root zh' will deploy both root and zh"
fi

if [[ $@ =~ root ]]
then
    echo "Prepare for root..."
    HEAD=$(git rev-parse HEAD)
    git subtree add --prefix=root/public/ root master --squash

    echo "Generate for root"
    cd root
    rm -rf public/ && cp -r source/ public/
    git add -f public/ && git commit -m "Deployed by Git"
    cd ..

    echo "Deploy for root..."
    git subtree split --prefix=root/public/ --branch root
    git subtree push --prefix=root/public/ root master --squash

    echo "Cleanup for root"
    git reset --hard $HEAD
fi

if [[ $@ =~ zh ]]
then
    echo "Prepare for zh..."
    HEAD=$(git rev-parse HEAD)
    git subtree add --prefix=zh/public/ zh master --squash

    echo "Generate for zh"
    cd zh
    npm install && npm update && npm audit fix
    hexo clean && hexo generate
    git add -f public/ && git commit -m "Deployed by Git"
    cd ..

    echo "Deploy for zh..."
    git subtree split --prefix=zh/public/ --branch zh
    git subtree push --prefix=zh/public/ zh master --squash

    echo "Cleanup for zh"
    git reset --hard $HEAD
fi

if [[ $@ =~ en ]]
then
    echo "Prepare for en..."
    HEAD=$(git rev-parse HEAD)
    git subtree add --prefix=en/public/ en master --squash

    echo "Generate for en"
    cd en
    npm install && npm update && npm audit fix
    hexo clean && hexo generate
    git add -f public/ && git commit -m "Deployed by Git"
    cd ..

    echo "Deploy for en..."
    git subtree split --prefix=en/public/ --branch en
    git subtree push --prefix=en/public/ en master --squash

    echo "Cleanup for en"
    git reset --hard $HEAD
fi
