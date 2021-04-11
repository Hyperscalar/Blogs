#!/usr/bin/env bash
#file: initialize.sh

if [[ $# -eq 0 ]]
then
    echo "Usage: specify module name(s) to initialize"
    echo "Available modules are remote, framework and theme"
    echo "For example: 'bash initialize.sh remote' will initilize remote"
    echo "    'bash initialize.sh remote framework theme' will initilize remote, framework and theme"
fi

if [[ $@ =~ remote ]]
then
    echo ""
    echo "Initialize remote repository for deployments"
    if [[ $(git remote get-url origin) =~ ^https ]]
    then
        git remote add root https://github.com/Hyperscalar/hyperscalar.github.io.git
        git remote add zh https://github.com/Hyperscalar/zh.git
        git remote add en https://github.com/Hyperscalar/en.git
    else
        git remote add root git@github.com:Hyperscalar/hyperscalar.github.io.git
        git remote add zh git@github.com:Hyperscalar/zh.git
        git remote add en git@github.com:Hyperscalar/en.git
    fi
fi

if [[ $@ =~ framework ]]
then
    echo ""
    read -p "Which directory should be used? " directory
    read -p "Initialize framework and its plugins for $directory? Y/N " answer
    if [[ $answer = "Y" ]]
    then
        if [[ ! -d $directory ]]
        then
            echo "Initialize framework for $directory..."
            hexo init $directory

            cd $directory

            echo "Initialize plugins of framework for $directory..."
            npm install hexo --save
            npm install hexo-server --save

            npm install hexo-generator-index --save
            npm install hexo-generator-category --save
            npm install hexo-generator-tag --save
            npm install hexo-generator-archive --save
            npm install hexo-generator-alias --save
            npm install hexo-generator-feed --save
            npm install hexo-generator-sitemap --save

            npm install hexo-theme-landscape --save

            npm uninstall hexo-renderer-marked --save && npm install hexo-renderer-markdown-it --save
            npm install hexo-renderer-ejs --save
            npm install hexo-renderer-stylus --save
            npm install hexo-renderer-nunjucks --save

            npm install && npm update

            cd ..
        fi
    fi
fi

if [[ $@ =~ theme ]]
then
    echo ""
    read -p "Which directory should be used? " directory
    read -p "Initialize themes and its plugins for $directory? Y/N " answer
    if [[ $answer = "Y" ]]
    then
        read -p "Initialize next theme and its plugins for $directory? Y/N " answer
        if [[ $answer = "Y" ]]
        then
            cd $directory

            echo "Initialize next theme for $directory"
            npm install hexo-theme-next --save

            echo "Initialize plugins of next theme for $directory"
            npm install @next-theme/plugins --save
            npm install hexo-generator-searchdb --save
            npm install hexo-filter-mathjax --save
            npm install hexo-word-counter --save
            npm install hexo-related-popular-posts --save
            npm install hexo-optimize --save
            npm install hexo-pangu --save

            npm install && npm update

            cd ..
        fi
    fi
fi
