#!/usr/bin/env bash
#file: initialize.sh

echo "Configure remote repositories for deployment..."
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

echo "Initialize frameworks"
if [[ ! -d zh ]]
then
    hexo init zh && rm -rf zh/themes/landscape

    cd zh
    npm uninstall hexo-renderer-marked --save && npm install hexo-renderer-markdown-it --save
    npm install hexo-generator-alias --save
    npm install hexo-generator-sitemap --save
    npm install hexo-generator-feed --save
    npm install hexo-generator-searchdb --save
    npm install hexo-symbols-count-time --save

    npm install && npm update
    git add . && git commit -m "Initialize framework of zh"
    cd ..
fi

if [[ ! -d en ]]
then
    hexo init en && rm -rf en/themes/landscape

    cd en
    npm uninstall hexo-renderer-marked --save && npm install hexo-renderer-markdown-it --save
    npm install hexo-generator-alias --save
    npm install hexo-generator-sitemap --save
    npm install hexo-generator-feed --save
    npm install hexo-generator-searchdb --save
    npm install hexo-symbols-count-time --save

    npm install && npm update
    git add . && git commit -m "Initialize framework of en"
    cd ..
fi

echo "Initialize themes..."
echo "Initialize landscape theme..."
echo "Which version should be used?"
read -p "Please enter a branch or tag name: " version
git remote add theme-landscape https://github.com/hexojs/hexo-theme-landscape.git
git subtree add --prefix=zh/themes/landscape theme-landscape $version --squash
git subtree add --prefix=en/themes/landscape theme-landscape $version --squash

echo "Initialize next theme..."
echo "Which version should be used?"
read -p "Please enter a branch or tag name: " version
git remote add theme-next https://github.com/theme-next/hexo-theme-next.git
git subtree add --prefix=zh/themes/next theme-next $version --squash
git subtree add --prefix=en/themes/next theme-next $version --squash

echo "Initialize material theme..."
echo "Which version should be used?"
read -p "Please enter a branch or tag name: " version
git remote add theme-material https://github.com/viosey/hexo-theme-material.git
git subtree add --prefix=zh/themes/material theme-material $version --squash
git subtree add --prefix=en/themes/material theme-material $version --squash

echo "Initialize plugins..."
git remote add theme-next-reading-progress https://github.com/theme-next/theme-next-reading-progress.git
git subtree add --prefix=zh/themes/next/source/lib/reading_progress theme-next-reading-progress master --squash
git subtree add --prefix=en/themes/next/source/lib/reading_progress theme-next-reading-progress master --squash

git remote add theme-next-bookmark https://github.com/theme-next/theme-next-bookmark.git
git subtree add --prefix=zh/themes/next/source/lib/bookmark theme-next-bookmark master --squash
git subtree add --prefix=en/themes/next/source/lib/bookmark theme-next-bookmark master --squash

git remote add theme-next-fancybox3 https://github.com/theme-next/theme-next-fancybox3.git
git subtree add --prefix=zh/themes/next/source/lib/fancybox theme-next-fancybox3 master --squash
git subtree add --prefix=en/themes/next/source/lib/fancybox theme-next-fancybox3 master --squash

git remote add theme-next-pdf https://github.com/theme-next/theme-next-pdf.git
git subtree add --prefix=zh/themes/next/source/lib/pdf theme-next-pdf master --squash
git subtree add --prefix=en/themes/next/source/lib/pdf theme-next-pdf master --squash

git remote add theme-next-jquery-lazyload https://github.com/theme-next/theme-next-jquery-lazyload.git
git subtree add --prefix=zh/themes/next/source/lib/jquery_lazyload theme-next-jquery-lazyload master --squash
git subtree add --prefix=en/themes/next/source/lib/jquery_lazyload theme-next-jquery-lazyload master --squash

git remote add theme-next-fastclick https://github.com/theme-next/theme-next-fastclick.git
git subtree add --prefix=zh/themes/next/source/lib/fastclick theme-next-fastclick master --squash
git subtree add --prefix=en/themes/next/source/lib/fastclick theme-next-fastclick master --squash

git remote add theme-next-ribbon https://github.com/hustcc/ribbon.js.git
git subtree add --prefix=zh/themes/next/source/lib/ribbon theme-next-ribbon master --squash
git subtree add --prefix=en/themes/next/source/lib/ribbon theme-next-ribbon master --squash

git remote add theme-next-han https://github.com/theme-next/theme-next-han.git
git subtree add --prefix=zh/themes/next/source/lib/Han theme-next-han master --squash

git remote add theme-next-pangu https://github.com/theme-next/theme-next-pangu.git
git subtree add --prefix=zh/themes/next/source/lib/pangu theme-next-pangu master --squash
