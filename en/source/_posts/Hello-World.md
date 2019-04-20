---
title: Hello World
date: 2018-03-20
updated: 2018-09-10
categories:
- Miscellaneous
tags:
- Test
pdf: true
---
# Hello World

This is my personal blog.

Mainly about technology learning and thinking, but not limited to this.

Insist on originality, Update aperiodically.

<!-- more -->

## Code

``` Java
// Java
class HelloWorld {

    public static void main() {
        System.out.println("Hello World!");
    }
}
```

``` C
// C
#include "stdio.h"

int main() {
    printf("Hello World!\n");
    return 0;
}
```

``` C++
// C++
#include "iostream"

int main() {
    std::cout << "Hello World!" << std::endl;
    return 0;
}
```

## Note

{% note default %} Hello World! {% endnote %}

{% note primary %} Hello World! {% endnote %}

{% note success %} Hello World! {% endnote %}

{% note info %} Hello World! {% endnote %}

{% note warning %} Hello World! {% endnote %}

{% note danger %} Hello World! {% endnote %}

## Image

{% asset_img San-Francisco.png San Francisco %}

## PDF

{% pdf https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf %}
