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
        git remote add root https://github.com/Bitrhythm/bitrhythm.github.io.git
        git remote add zh https://github.com/Bitrhythm/zh.git
        git remote add en https://github.com/Bitrhythm/en.git
    else
        git remote add root git@github.com:Bitrhythm/bitrhythm.github.io.git
        git remote add zh git@github.com:Bitrhythm/zh.git
        git remote add en git@github.com:Bitrhythm/en.git
    fi

    echo ""
    echo "Initialize remote repository for themes"
    git remote add theme-landscape https://github.com/hexojs/hexo-theme-landscape.git
    git remote add theme-next https://github.com/theme-next/hexo-theme-next.git

    echo ""
    echo "Initialize remote repository for theme plugins"
    git remote add theme-next-pjax https://github.com/theme-next/theme-next-pjax.git
    git remote add theme-next-pdf https://github.com/theme-next/theme-next-pdf.git
    git remote add theme-next-canvas-ribbon https://github.com/theme-next/theme-next-canvas-ribbon.git
fi

if [[ $@ =~ framework ]]
then
    echo ""
    read -p "Initialize framework and its plugins for zh? Y/N " answer
    if [[ $answer = "Y" ]]
    then
        if [[ ! -d zh ]]
        then
            echo "Initialize hexo framework for zh..."
            hexo init zh/ && rm -rf zh/themes/landscape/

            echo "Initialize plugins of hexo framework for zh..."
            cd zh
            npm uninstall hexo-renderer-marked --save \
                && npm install hexo-renderer-markdown-it --save \
                && npm install @iktakahiro/markdown-it-katex --save

            npm install hexo --save
            npm install hexo-server --save

            npm install hexo-generator-alias --save
            npm install hexo-generator-archive --save
            npm install hexo-generator-category --save
            npm install hexo-generator-feed --save
            npm install hexo-generator-index --save
            npm install hexo-generator-search --save
            npm install hexo-generator-sitemap --save
            npm install hexo-generator-tag --save

            npm install hexo-renderer-ejs --save
            npm install hexo-renderer-stylus --save

            npm install hexo-filter-auto-spacing --save
            npm install hexo-filter-nofollow

            npm install hexo-symbols-count-time --save
            npm install hexo-related-popular-posts --save

            npm install && npm update && npm audit fix

            git add . && git commit -m "Initialize framework and its plugins for zh"
            cd ..
        fi
    fi

    echo ""
    read -p "Initialize framework and its plugins for en? Y/N " answer
    if [[ $answer = "Y" ]]
    then
        if [[ ! -d en ]]
        then
            echo "Initialize hexo framework for en..."
            hexo init en/ && rm -rf en/themes/landscape/

            echo "Initialize plugins of hexo framework for en..."
            cd en
            npm uninstall hexo-renderer-marked --save \
                && npm install hexo-renderer-markdown-it --save \
                && npm install @iktakahiro/markdown-it-katex --save

            npm install hexo --save
            npm install hexo-server --save

            npm install hexo-generator-alias --save
            npm install hexo-generator-archive --save
            npm install hexo-generator-category --save
            npm install hexo-generator-feed --save
            npm install hexo-generator-index --save
            npm install hexo-generator-search --save
            npm install hexo-generator-sitemap --save
            npm install hexo-generator-tag --save

            npm install hexo-renderer-ejs --save
            npm install hexo-renderer-stylus --save

            npm install hexo-filter-auto-spacing --save
            npm install hexo-filter-nofollow

            npm install hexo-symbols-count-time --save
            npm install hexo-related-popular-posts --save

            npm install && npm update && npm audit fix

            git add . && git commit -m "Initialize framework and its plugins for en"
            cd ..
        fi
    fi
fi

if [[ $@ =~ theme ]]
then
    echo ""
    read -p "Initialize themes and theme plugins for zh? Y/N " answer
    if [[ $answer = "Y" ]]
    then
        read -p "Initialize landscape theme for zh? Y/N " answer
        if [[ $answer = "Y" ]]
        then
            echo "Which version should be used?"
            read -p "Please enter a branch or tag name: " version
            git subtree add --prefix=zh/themes/landscape/ theme-landscape $version --squash
        fi

        read -p "Initialize next theme and its plugins for zh? Y/N " answer
        if [[ $answer = "Y" ]]
        then
            echo "Initialize next theme for zh"
            echo "Which version should be used?"
            read -p "Please enter a branch or tag name: " version
            git subtree add --prefix=zh/themes/next/ theme-next $version --squash

            echo "Initialize plugins of next theme for zh"
            git subtree add --prefix=zh/themes/next/source/lib/pjax theme-next-pjax master --squash
            git subtree add --prefix=zh/themes/next/source/lib/pdf/ theme-next-pdf master --squash
            git subtree add --prefix=zh/themes/next/source/lib/canvas-ribbon/ theme-next-canvas-ribbon master --squash
        fi
    fi

    echo ""
    read -p "Initialize themes and theme plugins for en? Y/N " answer
    if [[ $answer = "Y" ]]
    then
        read -p "Initialize landscape theme for en? Y/N " answer
        if [[ $answer = "Y" ]]
        then
            echo "Which version should be used?"
            read -p "Please enter a branch or tag name: " version
            git subtree add --prefix=en/themes/landscape/ theme-landscape $version --squash
        fi

        read -p "Initialize next theme and its plugins for en? Y/N " answer
        if [[ $answer = "Y" ]]
        then
            echo "Initialize next theme for en"
            echo "Which version should be used?"
            read -p "Please enter a branch or tag name: " version
            git subtree add --prefix=en/themes/next/ theme-next $version --squash

            echo "Initialize plugins of next theme for en"
            git subtree add --prefix=en/themes/next/source/lib/pjax theme-next-pjax master --squash
            git subtree add --prefix=en/themes/next/source/lib/pdf/ theme-next-pdf master --squash
            git subtree add --prefix=en/themes/next/source/lib/canvas-ribbon/ theme-next-canvas-ribbon master --squash
        fi
    fi
fi
