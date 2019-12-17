---
layout: blog
title: 信息的表示和处理（2）--习题解答
category: CS-APP
tags: CS-APP 习题解答
---

## 习题解答

* 2.1
    * A. 0011 1001 1010 0111 1111 1000
    * B. 0xC97B
    * C. 1101 0101 1110 0100 1100
    * D. 26E7B5
<!--more-->

* 2.2

    | n | $2^{n}$（十进制）| $2^{n}$（十六进制）|
    |:--|:----------------:|-------------------:|
    | 9 | 512 | 0x200 |
    | 19| 524288 | 0x80000 |
    | 14 | 16384 | 0x4000 |
    | 16 | 65536 | 0x10000 |
    | 17 | 131072 | 0x20000 |
    | 5 | 32 | 0x20 |
    | 7 | 128 | 0x80 |

* 2.3

    | 十进制 | 二进制 | 十六进制 |
    |:-------|:------:|---------:|
    | 0 | 0000 0000 | 0x00 |
    | 167 | 1010 0111 | 0xA7 |
    | 62 | 0011 1110 | 0x3E |
    | 188 | 1011 1100 | 0xBC |
    | 56 | 0011 0111 | 0x37 |
    | 136 | 1000 1000 | 0x88|
    | 243 | 1111 0011 | 0xF3 |
    | 82 | 0101 0010 | 0x52 |
    | 172 | 1010 1100 | 0xAC |
    | 231 | 1110 0111 | 0xE7 |

* 2.4
    * A. 0x503c+0x8=0x5044
    * B. 0x503c-0x40=0x4FFC
    * C. 0x503c+64=0x503c+0x40=0x507C
    * D. 0x50ea-0x503c=0xAE

* 2.5 0x87654321
    * A. 小端法：0x21   大端法：0x87
    * B. 小端法：0x21   0x43    大端法：0x87    0x65
    * C. 小端法：0x21   0x43    0x65    大端法：0x87 0x65 0x43

* 2.6
    * A. 0x00359141 0000 0000 0011 0101 1001 0001 0100 0001 0x4A564504  0100 1010 0101 0110 0100 0101 0000 0100
    * B. 将0x00359141左移两位和0x4A564504匹配位数最多，21位匹配。
    * C. 整数的第一个非零位不匹配。

* 2.7 0x61  0x62    0x63    0x64    0x65    0x66

* 2.8 

    | 运算 | 结果 |
    |:-----|-----:|
    | a | [01101001] |
    | b | [01010101] |
    | ~a | [10010110]|
    | ~b | [10101010] |
    | a&b| [01000001] |
    | a\|b | [01111101] |
    | a^b | [00111100] |

* 2.9
    * A.

        | R | G | B | 颜色 | 补 |
        |:--|:--|:--|:-----|:---|
        | 0 | 0 | 0 | 黑色 | 白色|
        | 0 | 0 | 1 | 蓝色 | 黄色|
        | 0 | 1 | 0 | 绿色 | 红紫色 |
        | 0 | 1 | 1 | 蓝绿色| 红色 |
        | 1 | 0 | 0 | 红色 | 蓝绿色 |
        | 1 | 0 | 1 | 红紫色 | 绿色 |
        | 1 | 1 | 0 | 黄色 | 蓝色 |
        | 1 | 1 | 1 | 白色 | 黑色 |
    * B. 蓝色 \| 绿色 = 蓝绿色  黄色 & 蓝绿色 = 白色    红色 ^ 红紫色 = 蓝色

* 2.10

    | 步骤 | *x | *y |
    |:-----|:--:|---:|
    | 初始| a | b |
    | 第1步| a | a^b |
    | 第2步 | b | a^b |
    | 第3步 | b | a |

* 2.11
    * A. 最后一次循环中，first=last=k
    * B. 因为每个数是它的加法逆元，异或为0。
    * C. 见代码部分2-11-C。

* 2.12
    * A. 0x87654321&0xFF
    * B. 0x87654321^(~0xFF)
    * C. 0x87654321\|0xFF

* 2.13  bis=z\|m bic = z & ~m
    * x \| y = bis(x,y)
    * x^y = (x&~y)\|(y&~x)=bis(bic(x,y),(y,x))

* 2.14 x=0x66 0110 0110 y=0x39 0011 1001

    | 表达式 | 值 | 表达式 | 值 |
    |:-------|:---|:------:|:---|
    | x & y | 0x20 | x&&y | 0x01 |
    | x \| y| 0x7F | x\|\|y | 0x01 |
    | ~x\|~y | 0xDF | !x\|\|!y | 0x00 |
    | x & !y | 0x46 | x&&~y | 0x01 |

* 2.15  !(x^y) 

* 2.16

    | x | x<<3 | x>>2（逻辑） | x>>2（算术）|
    |:--|:-----|:-------------|:------------|
    | 0xC3 | 0x18 | 0x30 | 0xF0 |
    | 0x75 | 0xA8 | 0x1D | 0x1D |
    | 0x87 | 0x38 | 0x21 | 0xE1 |
    | 0x66 | 0x30 | 0x19 | 0x19 |


* 2.17

    | $\vec{x}$ | $B2U_4(\vec{x})$ | $B2T_4(\vec{x})$ |
    |:----------|:-----------------|:-----------------|
    | 0xE | $2^{3}+2^{2}+2^{1}=14$ | $-2^{3}+2^{2}+2^{1}=-2$ |
    | 0x0 | 0 | 0 |
    | 0x5 | $2^{2}+2^{0}=5$ | $2^{2}+2^{0}=5$ |
    | 0x8 | $2^{3}=8$ | $-2^{3}=-8$ |
    | 0xD | $2^{3}+2^{2}+2^{0}=13$ | $-2^{3}+2^{2}+2^{0}=-3$ |
    | 0xF | $2^{3}+2^{2}+2^{1}+2^{0}=15$ | $-2^{3}+2^{2}+2^{1}+2^{0}=-1$ |

* 2.18
    * A. $$2*16^{2}+14^16=736$$
    * B. -88
    * C. 40
    * D. -48
    * E. 120
    * F. 136
    * G. 504
    * H. 192
    * I. -72

* 2.19

    | x | $T2U_4(x)$ |
    |:--|:-----------|
    | -8 | 8 |
    | -3 | 13 |
    | -2 | 14 |
    | -1 | 15 |
    | 0 | 0 |
    | 5 | 5 |

* 2.20 当x小于0时，结果时$x+2^{4}$；当x大于0时，结果是它本身。

* 2.21

    | 表达式 | 类型 | 求值 |
    | -2147483647-1 == 2147483648U | 无符号数 | 1 |
    | -2147483647-1 < 2147483647 | 补码 | 1 |
    | -2147483647-1U < 2147483647 |无符号数 | 0 |
    | -2147483647-1 < -2147483647 | 补码 | 1 |
    | -2147483647-1U < -2147483647 | 无符号数 | 1 |

* 2.22
    * A. $-2^{4}+2^{1}+2^{0}=-5$
    * B. $-2^{5}+2^{4}+2^{1}+2^{0}=-5$
    * C. $-2^{6}+2^{5}+2^{4}+2^{1}+2^{0}=-5$

* 2.23
    * A.

    | w | fun1(w) | fun2(w) |
    |:--|:--------|:--------|
    | 0x00000076 | 0x00000076 | 0x00000076 |
    | 0x87654321 | 0x00000021 | 0x00000021 |
    | 0x000000C9 | 0x000000C9 | 0xFFFFFFC9 |
    | 0xEDCBA987 | 0x00000087 | 0xFFFFFF87 |

    * B. 可以获取无符号数的低位字节数。

* 2.24 4位数值截断为3位

    | 十六进制 | 无符号 | 补码 |
    |:---------|:-------|:-----|
    | 0 | 0 | 0 |
    | 2 | 2 | 2 |
    | 9 | 1 | 1 |
    | B | 3 | 3 |
    | F | 7 | -1 |

* 2.25 length为无符号数，当length=0时，length-1会将结果转换为无符号数，是UMax，这样会导致内存访问越界。将`i<=length-1`改为`i<length`即可。

* 2.26 
    * A. 当字符串t比字符串s长的时候，该函数返回不正确的结果，因为无符号数作减法结果非负。
    * B. 
    * C. 将`strlen(s)-strlen(t)>0`改为`strlen(s)>strlen(t)`

* 2.27 见代码部分2.27

* 2.28
    
    | x | $-_{4}^{u}x$ |
    |:--|:-------------|
    | 0 | 0 |
    | 5 | 11 |
    | 8 | 8 |
    | D | 3 |
    | F | 1 |

* 2.29

    | x | y | x + y | $x+_{5}^t y$ | 情况 |
    |:--|:--|:------|:-------------|:-----|
    | [10100] | [10001] | [101001] | [01001] | 1 |
    | [11000] | [11000] | [110000] | [10000] | 2 |
    | [10111] | [01000] | [11111] | [11111] | 2 |
    | [00010] | [00101] | [00111] | [00111] | 3 |
    | [01100] | [00100] | [10000] | [10000] | 4 |

* 2.30 见代码部分2.30

* 2.31 由于补码加法在二进制运算方式上和无符号加法是一致的，所以补码加法也会形成一个阿贝尔群，无论是否溢出(x+y)-x==y并且(x+y)-y=x

* 2.32 当y=TMin时，-y也为TMin，这时tadd_ok的结果是当x<0会发生溢出返回0，当x非负时不会发生溢出返回1。而事实上刚好相反，tsub_ok的结果应该是当x<0时不会发生溢出应返回1，当x非负时，会发生溢出返回1。

* 2.33

    | x | $-_4^{t}x$ |
    |:--|:-----------|
    | 0 | 0 |
    | 5 | B |
    | 8 | 8 |
    | D | 3 |
    | F | 1 |

* 2.34 

    | 模式 | x | y | x\*y | 截断的x\*y |
    |:-----|:--|:--|:-----|:-----------|
    | 无符号 | [100] | [101] | [010100] | [100] |
    | 补码 | [100] | [101] | [001100] | [100] |
    | 无符号 | [010] | [111] | [001110] | [110] |
    | 补码 | [010] | [111] | [111110] | [110] |
    | 无符号|[110] | [110] | [100100] | [100] |
    | 补码 | [110] | [110] | [000100] | [100] |

* 2.35
    * 1. 我们知道$$x*y$$可以写成一个$2w$位的补码数字。用$u$来表示低$w$位表示的无符号数，$v$表示高$w$位的补码数字。那么，根据公式（2-3），我们可以得到$x\*y=v2^{w}+u$。 
    * 我们还知道$u=T2U_w(p)$，因为它们是从同一个位模式得出来的无符号和补码数字，因此根据等式（2.6），我们有$u=p+p_{w-1}2^{w}$，这里$p_{w-1}$是p的最高有效位。设$t=v+p_{w-1}$，我们有$x*y=p+t2^{w}$。
    * 当$t=0$时，有$x*y=p$；乘法不会溢出。当$t\neq 0$，有$x*y\neq p$；乘法溢出。
    * 2. 根据整数除法的定义，用非零数x除以p会得到商q和余数r，即$p=x*q+r$，且$\|r\| < \|x\|$。
    * 3. 假设$q=y$，那么有$x*y=x*y+r+t2^{w}$。在此，我们可以得到$r+t2^{w}=0$。但是$\|r\| < \|x\| \leq 2^{w}$，所以只有当$t=0$时，这个等式才会成立，此时$r=0$。


## 代码部分

`show_bytes.c`
```cpp
#include <stdio.h>

typedef unsigned char *byte_pointer;

void show_bytes(byte_pointer start, size_t len){
    size_t i;
    for(i=0; i < len; i++){
        printf("%.2x\t",start[i]);
    }
    printf("\n");
}

void show_int(int x){
    show_bytes((byte_pointer)&x, sizeof(int));
}

void show_float(float x){
    show_bytes((byte_pointer)&x, sizeof(float));
}

void show_pointer(void *x){
    show_bytes((byte_pointer)&x,sizeof(void *));
}
```

* 2.11-C
```cpp
void reverse_array(int a[], int cnt){
    int first,last;
    for(first=0,last=cnt-1;first<last;first++,last--){
        inplace_swap(&a[first],&a[last]);
    }
}
```

* 2.23
```cpp
    int fun1(unsigned word){
        return (int)((word<<24)>>24);
    }

    int fun2(unsigned word){
        return ((int)word<<24)>>24;
    }
```
* 2.27
```cpp
    /* Determine whether arguments can be added without overflow */
    int uadd_ok(unsigned x, unsigned y);

    int uadd_ok(unsigned x, unsigned y){
        unsigned s = x + y;
        return s>x&&s>y;
    }
```

* 2.30 
```cpp
    /* Determine whether arguments can be added without overflow */
    int tadd_ok(int x,int y);

    int tadd_ok(int x,int y){
        int sum=x+y;
        return !(x>0&&y>0&&sum<0)&&!(x<=0&&y<=0&&sum>0);
    }
```