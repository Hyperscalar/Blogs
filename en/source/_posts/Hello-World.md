---
title: Hello World
date: 2018-03-20
categories:
- Miscellaneous
tags:
- Test
mathjax: true
---

This is my personal blog.

Mainly about technology learning and thinking, but not limited to this.

Insist on originality, Update aperiodically.

<!-- more -->

## Code

```java
// Java
class HelloWorld {

    public static void main() {
        System.out.println("Hello World!");
    }
}
```

```c
// C
#include "stdio.h"

int main() {
    printf("Hello World!\n");
    return 0;
}
```

## Equation

$$
E = mc^2
$$

## Diagram

```mermaid
graph TD
A[Hard] -->|Text| B(Round)
B --> C{Decision}
C -->|One| D[Result 1]
C -->|Two| E[Result 2]
```

## Image

{% asset_img San-Francisco.png San Francisco %}

## Note

{% note default %} Hello World! {% endnote %}

{% note primary %} Hello World! {% endnote %}

{% note success %} Hello World! {% endnote %}

{% note info %} Hello World! {% endnote %}

{% note warning %} Hello World! {% endnote %}

{% note danger %} Hello World! {% endnote %}
