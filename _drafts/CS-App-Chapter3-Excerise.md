---
title: 程序的机器表示（3）--习题解答
category: CS-APP
tags: CS-APP 习题解答
---

## 练习题解答

* 3.1

    | 操作数 | 值 | 寻址方式 |
    |:-------|:---|:---------|
    | %rax | 0x100 | 寄存器寻址 |
    | 0x104 | 0xAB | 绝对寻址 |
    | $0x108 | 0x108 | 立即数寻址 |
    | (%rax) | 0xFF | 间接寻址 |
    | 4(%rax) | 0xAB | （基址+偏移量）寻址 |
    | 9(%rax,%rdx) | 0x11 | 变址寻址 |
    | 260(%rcx,%rdx) | 0x13 | 变址寻址 |
    | 0xFC(,%rcx,4) | 0xFF | 比例变址寻址 |
    | (%rax,%rdx,4) | 0x11 | 比例变址寻址 |

<!--more-->

* 3.2
    * `movl %rax,(%rsp)`
    * `movw (%rax), %dx`
    * `movb $0xFF, %bl`
    * `movb (%rsp,%rdx,4), %dl`
    * `movq (%rdx), %rax`
    * `movw %dx, (%rax)`

* 3.3
    * `movb $0xF, (%ebx)` 在x86_64机器中不能使用32位寄存器%ebx作为地址寄存器
    * `movl %rax, (%rsp)` 指令后缀与寄存器不匹配，movl用来转移32位值，%rax是64位寄存器
    * `movw (%rax), 4(%rsp)` 在x86_64机器中不支持从内存地址到内存地址的转移
    * `movb %al, %sl` 没有寄存器名称为%sl
    * `movq %rax, $0x123` 不能将立即数作为内存地址
    * `movl %eax, %rdx` 寄存器长度不符，并且没有指明扩展方式。
    * `movb %si, 8(%rbp)` 指令后缀和寄存器不匹配，%si是2个字节，应该使用`movw`。

* 3.4

    | src_t | dest_t | 指令 | 注释 |
    |:------|:-------|:-----|:-----|
    | long | long | `movq (%rdi), %rax` & `movq %rax, (%rsi)` | 读取8个字节&保存8个字节|
    | char | int | `movsbl (%rdi), %eax` & `movl %eax, (%rsi)` | 将char符号扩展成int&保存4个字节 |
    | char | unsigned | `movsbl (%rdi), %eax` & `movl %eax, (%rsi)` | 将char符号扩展为int&保存4个字节 |
    | unsigned char | long | `movzbq (%rdi),%rax` & `movq %rax, (%rsi)` | 读一个字介并0扩展&保存8个字节 |
    | int | char | `movl (%rdi), %eax` & `movb %al,(%rsi)` | 读取4个字节&保存最低位字节|
    | unsigned | unsigned char | `movl (%rdi), %eax` & `movb %al, (%rsi)` | 读取4个字节&保存低位字节 |
    | char | short | `movsbw (%rdi), %ax` & `movw %ax, (%rsi)` | 读取1个字节并符号扩展为2个字节&保存2个字节 |

* 3.5
```cpp
void decode1(long *xp, long *yp, long *zp){
    long x = *xp; //x %r8
    long y = *yp; //y %rcx
    long z = *zp; //z %rax

    *yp=x;
    *zp=y;
    *xp=z;
}
```

* 3.6
    
    | 表达式 | 结果 |
    |:-------|:-----|
    | `leaq 6(%rax), %rdx` | 6x |
    | `leaq (%rax,%rcx), %rdx` | x+y |
    | `leaq (%rax,%rcx,4), %rdx` | x+4y |
    | `leaq 7(%rax,%rax,8), %rdx` | 9x+7 |
    | `leaq 0xA(,%rcx,4), %rdx` | 10+4y |
    | `leaq 9(%rax,%rcx,2), %rdx`| 9+x+2y |

* 3.7 `long t=5x+2y+8z`

* 3.8

    | 指令 | 目的 | 值 |
    |:-----|:-----|:---|
    | `addq %rcx, (%rax)` | 0x100 | 0x100 |
    | `subq %rdx, 8(%rax)` | 0x108 | 0xA8 |
    | `imulq $16, (%rax,%rdx,8)` | 0x118 | 0x110 |
    | `incq 16(%rax)` | 0x110 | 0x14 |
    | `decq %rcx` | %rcx | 0x0 |
    | `subq %rdx,%rax` | %rax | 0xFD |

* 3.9	`shlq $0x04, %rax` `sarq %cl, %rax`

* 3.10
```cpp
long arith2(long x, long y, long z){
	long t1=x|y;
	long t2=t1>>3;
	long t3=~t2;
	long t4=z-t3;
}
```
* 3.11
	* A. `xorq %rdx, %rdx`指令将寄存器`%rdx`置0
	* B. 将寄存器`%rdx`设置为0的更直接的方法是用指令`movq $0, %rdx`。
	* C. 

* 3.12
```cpp
void uremdiv(unsigned long x, unsigned long y, unsigned long *qp, unsigned long *rp){
    unsigned long q = x/y;
    unsigned long r = x%y;
    *qp = q;
    *rp = r;
}
```
汇编代码如下：
```
	.file	"uremdiv.c"
	.text
	.globl	uremdiv
	.type	uremdiv, @function
uremdiv:
.LFB0:
	.cfi_startproc
	movq	%rdi, %rax
	movq	%rdx, %rdi
	movl	$0, %edx
	divq	%rsi
	movq	%rax, (%rdi)
	movq	%rdx, (%rcx)
	ret
	.cfi_endproc
.LFE0:
	.size	uremdiv, .-uremdiv
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```
相对于由符号除法，只是将指令`cqto`改为`movl $0, %edx`

* 3.13
    * A. `typedef data_t int; #define COMP <`
    * B. `typedef data_t short; #define COMP >=`
    * C. `typedef data_t unsigned char; #define  COMP <=`
    * D. `typedef data_t long; #define COMP !=`

* 3.14
    * A. `data_t`为`long`，`TEST`为`>=`
    * B. `data_t`为`short,unsigned short`， `TEST`为`=`
    * C. `data_t`为`unsigned char`，`TEST`为`>`
    * D. `data_t`为`int, unsigned int`，`TEST`为`!=`

* 3.15
    * A. 4003fe
    * B. 400425
    * C. 400543 400545
    * D. 400560

