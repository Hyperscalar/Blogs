#!/usr/bin/env bash
#file: update.sh

if [[ $# -eq 0 ]]
then
    echo "Usage: specify module name(s) to update"
    echo "Available modules are zh and en"
    echo "For example: 'bash update.sh zh en' will update both zh and en"
fi

if [[ $@ =~ zh ]]
then
    echo "Framework update for zh"
    cd zh
    npm install && npm update && npm audit fix
    git add package.json package-lock.json && git commit -m "Framework of zh updated at $(date +%F\ %T\ %Z)"
    cd ..

    echo "Theme update for zh..."
    echo "Update landscape theme for zh..."
    echo "Which target version should be used?"
    read -p "Please enter a branch or tag name: " version
    git subtree pull --prefix=zh/themes/landscape/ theme-landscape $version --squash -m "Landscape theme of zh updated at $(date +%F\ %T\ %Z)"

    echo "Update next theme for zh..."
    echo "Which target version should be used?"
    read -p "Please enter a branch or tag name: " version
    git subtree pull --prefix=zh/themes/next/ theme-next $version --squash -m "Next theme of zh updated at $(date +%F\ %T\ %Z)"

    echo "Update material theme for zh..."
    echo "Which target version should be used?"
    read -p "Please enter a branch or tag name: " version
    git subtree pull --prefix=zh/themes/material/ theme-material $version --squash -m "Material theme of zh updated at $(date +%F\ %T\ %Z)"

    echo "Plugins update for zh..."
    git subtree pull --prefix=zh/themes/next/source/lib/reading_progress/ theme-next-reading-progress master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/bookmark/ theme-next-bookmark master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/fancybox/ theme-next-fancybox3 master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/pdf/ theme-next-pdf master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/jquery_lazyload/ theme-next-jquery-lazyload master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/fastclick/ theme-next-fastclick master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/ribbon/ theme-next-ribbon master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/quicklink/ theme-next-quicklink master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/Han/ theme-next-han master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=zh/themes/next/source/lib/pangu/ theme-next-pangu master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
fi

if [[ $@ =~ en ]]
then
    echo "Framework update for en"
    cd en
    npm install && npm update && npm audit fix
    git add package.json package-lock.json && git commit -m "Framework of en updated at $(date +%F\ %T\ %Z)"
    cd ..

    echo "Theme update for en..."
    echo "Update landscape theme for en..."
    echo "Which target version should be used?"
    read -p "Please enter a branch or tag name: " version
    git subtree pull --prefix=en/themes/landscape/ theme-landscape $version --squash -m "Landscape theme of en updated at $(date +%F\ %T\ %Z)"

    echo "Update next theme for en..."
    echo "Which target version should be used?"
    read -p "Please enter a branch or tag name: " version
    git subtree pull --prefix=en/themes/next/ theme-next $version --squash -m "Next theme of en updated at $(date +%F\ %T\ %Z)"

    echo "Update material theme for en..."
    echo "Which target version should be used?"
    read -p "Please enter a branch or tag name: " version
    git subtree pull --prefix=en/themes/material/ theme-material $version --squash -m "Material theme of en updated at $(date +%F\ %T\ %Z)"

    echo "Plugins update for en..."
    git subtree pull --prefix=en/themes/next/source/lib/reading_progress/ theme-next-reading-progress master --squash -m "Plugin of en updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=en/themes/next/source/lib/bookmark/ theme-next-bookmark master --squash -m "Plugin of en updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=en/themes/next/source/lib/fancybox/ theme-next-fancybox3 master --squash -m "Plugin of en updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=en/themes/next/source/lib/pdf/ theme-next-pdf master --squash -m "Plugin of zh updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=en/themes/next/source/lib/jquery_lazyload/ theme-next-jquery-lazyload master --squash -m "Plugin of en updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=en/themes/next/source/lib/fastclick/ theme-next-fastclick master --squash -m "Plugin of en updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=en/themes/next/source/lib/ribbon/ theme-next-ribbon master --squash -m "Plugin of en updated at $(date +%F\ %T\ %Z)"
    git subtree pull --prefix=en/themes/next/source/lib/quicklink/ theme-next-quicklink master --squash -m "Plugin of en updated at $(date +%F\ %T\ %Z)"
fi
