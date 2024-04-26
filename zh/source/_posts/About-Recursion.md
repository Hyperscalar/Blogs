---
title: 浅谈递归
date: 2018-08-29
updated: 2018-10-18
categories:
- 编程
- 递归
tags:
- 思考
- 总结
mathjax: true
---

递归是指在编程中函数在函数体中调用自身的过程，体现的是分而治之的思想。

用一张图来说明：

{% asset_img Recursion-Google.png 不过这个递归好像会导致栈区溢出 😂 %}

<!-- more -->

## 从与循环的关系看递归

从这个角度看，递归可以分为两种。

1. **可以直接改写成循环的**，这里称为第一类递归。
2. **改写成循环的时候需要用到栈的**，这里称为第二类递归。

第一种情况的例子有用于求最大公约数的辗转相除算法，还有求斐波那契数列第 n 项的算法，二分查找等：

``` Java
// 递归式辗转相除算法
public class Recursion {

    public static int gcd(int either, int other) {
        if (other == 0) {
            return either;
        }
        return gcd(other, either % other)
    }
}

// 循环式辗转相除算法
public class Iteration {

    public static int gcd(int either, int other) {
        while (other != 0) {
            int remainder = either % other;
            either = other;
            other = remainder;
        }
        return either;
    }
}

// 递归式斐波那契算法
public class Recursion {

    public static int fibonacci(int number) {
        if (number < 2) {
            return number;
        }
        return fibonacci(number - 1) + fibonacci(number - 2);
    }
}

// 尾递归式斐波那契算法
public class TailRecursion {

    public static int fibonacci(int number) {
        return fibonacci(0, 1, number);
    }

    private static int fibonacci(int current, int next, int number) {
        if (number < 1) {
            return current;
        }
        if (number < 2) {
            return next;
        }
        return fibonacci(next, current + next, number--);
    }
}

// 循环式斐波那契算法
public class Iteration {

    public static int fibonacci(int number) {
        int current = 0;
        int next = 1;
        for (int i = 0; i < number; i++) {
            int temporary = current + next;
            current = next;
            next = temporary;
        }
        return current;
    }
}
```

通过上面的代码可以看到，这一类的递归和循环之间存在着比较直接的对应关系，改写成循环不需要借助任何辅助数据结构，并且改写成循环之后还有可能降低开销甚至时间复杂度。例如：求斐波那契数列第 n 项的算法的递归形式的时间复杂的是惊人的 $O(2^n)$，尾递归形式的时间复杂度是 $O(n)$，而对应的循环形式的时间复杂度也是 $O(n)$。

第二种情况的例子有二叉树的遍历等：

``` Java
// 这里以二叉树的中序遍历为例

// 二叉树节点
public class Node<Item> {

    Item item;
    Node<Item> left;
    Node<Item> right;
}

// 递归式二叉树中序遍历
public class Recursion {

    public static void traverse(Node<Item> root) {
        if (root == null) {
            return;
        }

        traverse(root.left);
        System.out.println(root.item);
        traverse(root.right);
    }
}

// 循环式二叉树中序遍历
public class Iteration {

    public static void traverse(Node<Item> root) {
        Stack<Node<Item>> stack = new Stack();
        Node<Item> node = root;
        while (node != null || !stack.isEmpty()) {
            while (node != null) {
                stack.push(node);
                node = node.left();
            }

            node = stack.pop();
            System.out.println(node.item);
            node = node.right();
        }
    }
}
```

通过上面的代码可以看到，这一类递归若要改写成循环需要借助栈的帮助，就此例而言时间复杂度没有变化，都为 $O(n)$。

## 如何区分这两种递归

### 尾递归

在具体讨论如何区分这两种递归之前，我们先来了解一个已有的定义：*尾递归*

在具体讨论尾递归之前，我们先来了解一下另一个已有的定义：*尾调用*

尾调用是指：一个函数里的最后一个动作是返回一个函数调用的情形。例如：

``` C
int g() {
    // ...
    return 0;
}

// 函数 f 中最后一个动作是返回对函数 g 的调用，这就称之为尾调用
int f() {
    // ...
    return g();
}

// 函数 h 最后一个动作不是返回对函数 g 的调用，而是返回对函数 g 的调用结果再加 1，这就不是尾调用了
int h() {
    // ...
    return g() + 1;
}

// 函数 i 可以改写成函数 f，但函数 i 不能算是严格意义上的尾调用
int i() {
    // ...
    int g = g();
    return g;
}
```

而尾递归就是尾调用的的特例，尾递归函数中最后一个动作是返回对该函数自身的调用。上文中，辗转相除算法的递归形式就是尾递归的例子。而尾递归属于第一类递归，即可以直接改写为循环，不需要栈的辅助。而很多现代的编译期甚至会直接对尾递归进行优化，消除调用过程中的栈帧，这样就再也不会 StackOverflow 啦。

### 递归函数的执行过程

为了了解为什么递归会分成这两种以及为什么尾递归属于第一类递归，我们先来分析递归函数的执行过程。

对于任何递归函数，其执行流程都可以看成两部分：

- 向下调用

  向下调用是指：函数调用自身这个过程。如果把递归函数的执行过程看成一颗以初始调用为根的树，向下调用会向下加大树的深度，也就是会增加栈帧。

- 向上返回

  向上返回是指：函数调用执行完毕，结束自身并向调用方放回的过程。如果把递归函数的执行过程看成一颗以初始调用为根的树，向上返回会向上减小树的深度，也就是会减少栈帧。

以辗转相除算法的递归函数为例，其执行过程如下图所示：

{% asset_img Recursion-Process.svg 辗转相除算法的递归函数执行流程图示 %}

再以二叉树的中序遍历递归函数为例，其递归调用过程如下：

{% asset_img Inorder-Traverse.svg 二叉树的中序遍历递归函数执行流程图示 %}

### 观察

首先，我们来看辗转相除算法的递归调用过程，可以发现其具备以下特征：

1. 递归调用过程单调，这里的单调是指该函数的执行过程是先连续的向下调用，紧接着连续的向上返回直至结束。
2. 只在向下调用的过程中用到参数。

然后，我们来看二叉树的中序遍历的递归调用过程：

1. 递归调用过程不单调，向下调用和向上返回交叉着进行。
2. 在向下调用的过程中用到参数后并返回后，继续使用到了参数。

基于以上观察，我们了解到区分递归函数的关键可能与以下因素有关。

1. 向上返回过程中是否用到参数。
2. 递归调用过程是否单调。

### 思考

#### 递归调用过程不单调

我们先来思考最显而易见的情形，当递归函数的调用过程不单调时，就如上文中提到的二叉树的中序遍历，由于每一层的递归调用的参数都有可能在接下来的调用过程中被再次用到，所以必须要把每一层的调用信息（包括参数，局部变量等）都存入栈中，以备在后面的调用过程中再次使用，所以，当递归调用过程不单调的时候，栈是必须的，因此该类递归属于第二类递归，即在改写为循环时需要使用到栈。

#### 递归调用过程单调

既然递归调用过程不单调属于第二类递归，那么是不是递归调用过程单调就属于第一类递归了呢？答案比想象中的要复杂，请看下面的分析：

##### 尾递归

首先我们来看递归调用过程单调中最简单的情形——尾递归：

```Java
// 递归式辗转相除算法
public class Recursion {

    public static int gcd(int either, int other) {
        if (other == 0) {
            return either;
        }
        return gcd(other, either % other)
    }
}

// 循环式辗转相除算法
public class Iteration {

    public static int gcd(int either, int other) {
        while (other != 0) {
            int remainder = either % other;
            either = other;
            other = remainder;
        }
        return either;
    }
}
```

我们可以看到，尾递归函数的调用过程不仅单调，而且在连续向上返回的过程中除了向上层传递结果并没有额外操作，所有运算在连续向下调用的过程中就已完成，基于这种特点，我们可以认为其和循环直接等价。所以尾递归属于第一类循环，即改写为循环时无需使用栈。

##### 用到常数

现在我们在尾递归的基础上增加一些操作，在不改变其调用过程的单调性的前提下，在连续向上返回的这个过程中加入额外的运算：

```Java
// 下面的代码仅用于说明概念，其作用已经不再是辗转相除法求最大公约数
// 递归
public class Recursion {

    private static final CONSTANT = 2;

    public static int gcd(int either, int other) {
        if (other == 0) {
            return either;
        }
        return gcd(other, either % other) + CONSTANT;
    }
}

// 循环
public class Iteration {

    private static final CONSTANT = 2;

    public static int gcd(int either, int other) {
        int sum = 0;
        while (other != 0) {
            int remainder = either % other;
            either = other;
            other = remainder;

            sum += CONSTANT;
        }
        return either + sum;
    }
}
```

我们可以看到，虽然现在的递归函数已经不像尾递归那么“纯正”，但其仍然属于第一类递归。看来在向上返回的过程中加上和常数的操作并不能改变其性质。

##### 用到参数

既然加上和常数操作不能改变其性质，那么要是加上和变量的操作呢？递归函数里面的变量从哪里来呢？参数！嗯，所以我们现在来试试在不改变其调用过程的单调性的前提下，在向上返回的过程中加上对参数的操作：

```Java
// 下面的代码仅用于说明概念，其作用已经不再是辗转相除法求最大公约数
// 递归
public class Recursion {

    public static int gcd(int either, int other) {
        if (other == 0) {
            return either;
        }
        return gcd(other, either % other) + other;
    }
}

// 循环
public class Iteration {

    public static int gcd(int either, int other) {
        int sum = 0;
        while (other != 0) {
            sum += other;

            int remainder = either % other;
            either = other;
            other = remainder;
        }
        return either + sum;
    }
}
```

什么？？？怎么还是可以在改写为循环的时候不用到栈？难道递归调用过程单调就能断定递归函数属于第一类递归吗？其实不然，请看下面的例子：

```Java
// 先序遍历二叉树最作边的路径上的全部节点

// 二叉树节点
public class Node<Item> {

    Item item;
    Node<Item> left;
    Node<Item> right;
}

// 递归式二叉树先序遍历最左路径
public class Recursion {

    public static void traverse(Node<Item> root) {
        if (root == null) {
            return;
        }

        System.out.println(root.item);
        traverse(root.left);
    }
}

// 循环式二叉树中先序遍历最左路径
public class Iteration {

    public static void traverse(Node<Item> root) {
        while (root != null) {
            System.out.println(root.item);
            root = root.left;
        }
    }
}

// 递归式二叉树后序遍历最左路径
public class Recursion {

    public static void traverse(Node<Item> root) {
        if (root == null) {
            return;
        }

        traverse(root.left);
        System.out.println(root.item);
    }
}

// 循环式二叉树中后序遍历最左路径
public class Iteration {

    public static void traverse(Node<Item> root) {
        Stack<Node<Item>> stack = new Stack();
        for (Node<Item> node = root; node != null; node = node.left) {
            stack.push(node);
        }
        while (!stack.isEmpty()) {
            Node<Item> node = stack.pop();
            System.out.println(node);
        }
    }
}
```

我们可以看到，在这个例子中，递归函数的调用过程仍然单调，同样也实在连续向上返回的过程中用到了参数，但为什么这个例子中就要用到栈呢？仔细观察，我们可以发现，上一个例子中我们作的操作比较特殊，这个操作是对一个整数的加法，而对整数的加法是一个累计的操作，我们只关心这个累计而来的结果，而不关心他是从第一个累加到最后一个还是从最后一个累加到第一个，所以在改写为循环时，通过把这些本该在第一次循环完之后再做的累加操作直接放在第一次循环中执行，就可以在不影响结果的情况下消除栈的使用。而在这个例子中，对二叉树节点的遍历操作，遍历的顺序也是影响结果的因素之一，所以对于后序遍历，我们必需要用到栈。

说到这里，我们再来回顾一下刚才用到常数的例子，无论是对于常数的累加操作，还是遍历操作，顺序都不会对结果造成任何影响，所以我们可以在改写为循环是消除掉对栈的使用。

### 结论

- 递归调用过程不单调 -> 改写为循环时需要用到栈（第二类递归）

- 递归调用过程单调

  - 向上返回过程中没有用到参数 -> 改写为循环时不需要用到栈（第一类递归）

  - 向上返回过程中用到了参数
    - 递归调用过程中参数的使用顺序对结果无影响 -> 改写为循环时不需要用到栈（第一类递归）
    - 递归调用过程中参数的使用顺序对结果有影响 -> 改成为循环时需要用到栈（第二类递归）

> 由于作者水平所限，并不能从数学的角度严格证明上面的结论。因此上面的结论只是基于作者自己的观察作出的总结，因此可能不够完备，甚至错误。
>
> 本文的目的在于尝试提供一种相对简单的判别方法用于在将一个递归函数真正改写为循环之前判断其需不需要栈的辅助。
>
> 如果你发现了文章中的问题，或者有更好的思路，记得在下方评论哦。😊
