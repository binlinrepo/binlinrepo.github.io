---
title: 程序的机器级表示（3）
category: CS-APP AT&T 汇编语言 GCC
tags: CS-APP
---

计算机执行**机器代码**，用字节序列编码低级的操作，包括数据处理、管理内存、读写存储设备上的数据、以及利用网络通信。编译器基于编程语言的规则、目标及其的指令集和操作系统遵循的管理，经过一系列阶段生成机器代码。GCC C语言编译器以**汇编代码**的形式产生输出，汇编代码是机器代码的文本表示，给出程序中每一条指令。
<!--more-->

## 程序编码

`gcc -Og -o p p1.c p2.c` gcc是GNU C编译器，编译选项-Og告诉编译器使用会生成符合原始C代码整体结果的机器代码优化登记。

首先，C**预处理器**扩展源代码，插入所有用`#include`命令指定的文件，并扩展所有用`#define`声明指定的宏。其次，**编译器**产生两个源文件的汇编代码，名称分别为p1.s和p2.s。接下来，**汇编器**将汇编代码转化成二进制**目标代码**文件p1.o和p2.o。目标代码是机器代码的一种形式，它包含所有指令的二进制表示，但是还没有填入全局地址。最后**链接器**将两个目标代码文件和实现库函数（例如`printf`）的代码合并，并产生最终可执行代码文件p。

对于机器级编程来说，其中两种抽象尤为重要。第一种是由**指令集体系结果或指令集架构**来定义机器级程序的格式和行为，它定义了处理器状态、指令的格式，以及每条指令对状态的影响。第二种抽象是，机器级程序使用的内存地址都是虚拟地址，提供的内存模型看上去是一个非常大的字节数组。

x86_64的机器代码和原始的C代码差别非常大。一些通常对C语言程序员隐藏的处理器状态都是可见的。

**程序计数器**（PC，在x86_64中用%rip表示）给出将要执行的下一条指令在内存中的地址。

**整数寄存器文件**包含16个命名的位置，分别存储64位的值。

**条件码寄存器**保存着最近执行的算数单元或逻辑指令的状态信息。

一组向量寄存器可以存放一个或多个整数或浮点数值。

`mstore.c`如下：
```
long mult2(long, long);

void multstore(long x, long y, long *dest){
    long t = mult2(x,y);
    *dest = t;
}
```

在命令行上使用“-S”选项，就能看到C语言编译器产生的汇编代码：`gcc -Og -S mstore.c`生成`mstore.s`
```s
	.file	"mstore.c"
	.text
	.globl	multstore
	.type	multstore, @function
multstore:
.LFB0:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movq	%rdx, %rbx
	call	mult2@PLT
	movq	%rax, (%rbx)
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	multstore, .-multstore
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```
所有以“.”开头的行都是指导汇编器和链接器工作的伪指令。

`pushq`指令表示应该将寄存器`%rbx`的内容压入程序栈中。

如果我们使用“-c”命令行选项，GCC会编译并汇编该代码：`gcc -Og -c mstore.c`生成`mstore.o`

可以通过**反汇编器**查看机器代码，`objdump -d mstore.o`，如下所示：
```o
mstore.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <multstore>:
   0:	53                   	push   %rbx
   1:	48 89 d3             	mov    %rdx,%rbx
   4:	e8 00 00 00 00       	callq  9 <multstore+0x9>
   9:	48 89 03             	mov    %rax,(%rbx)
   c:	5b                   	pop    %rbx
   d:	c3                   	retq
```

在左边，我们看到14个十六进制字节值，它们分成了若干组，每组有1～5个字节。每组都是一条指令，右边是等价的汇编语言。

x86-64的指令长度从1到15字节不等。常用的指令以及操作数较少的指令所需的字节数少，而那些不太常用或操作数较多的指令所需字节数较多。指令结尾的“q”是大小指示符。

生成实际可执行的代码需要一组目标代码运行链接器，而这一组目标代码文件中必须含有一个`main`函数。假设在文件`main.c`中有下面这样的函数：
```cpp
#include <stdio.h>

void multstore(long, long, long *);

int main(){
    long d;
    multstore(2, 3, &d);
    printf("2*3-->%ld\n",d);
    return 0;
}

long mult2(long a, long b){
    long s = a*b;
    return s;
}
```

执行`gcc -Og -o prog main.c mstore.c`生成`prog`，文件prog不仅包含了两个过程的代码，还包含了用来启动和终止程序的代码，以及与系统交互的代码。反汇编prog文件`objdump -d proj`如下所示：
```
0000000000000741 <multstore>:
 741:	53                   	push   %rbx
 742:	48 89 d3             	mov    %rdx,%rbx
 745:	e8 ef ff ff ff       	callq  739 <mult2>
 74a:	48 89 03             	mov    %rax,(%rbx)
 74d:	5b                   	pop    %rbx
 74e:	c3                   	retq
 74f:	90                   	nop
```
这段代码与mstore反汇编产生的代码几乎完全一样。其中一个主要的区别在于列出的地址不同----链接器将这段代码的地址移到了一段不同的地址范围中。第二个不同之处在于链接器填上了`callq`指令调用函数`mult2`需要使用的地址。链接器的任务之一就是为函数调用找到匹配的函数的可执行代码的位置。

在C语言中插入汇编代码有两种方法。一种方法是用汇编代码编写整个函数，在链接阶段把它们和C函数组合起来。另一种方法是利用GCC的支持，直接在C程序中嵌入汇编代码。

> 我们的表述是ATT格式的汇编代码，这是GCC，OBJDUMP和其他一些我们使用的工具的默认格式。使用如下命令`gcc -Og -S -masm=intel mstore.c`可以生成Intel格式的代码如下：
```
	.file	"mstore.c"
	.intel_syntax noprefix
	.text
	.globl	multstore
	.type	multstore, @function
multstore:
.LFB0:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	mov	rbx, rdx
	call	mult2@PLT
	mov	QWORD PTR [rbx], rax
	pop	rbx
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	multstore, .-multstore
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```
区别在于： 1. Intel代码省略了指示大小的后缀。2. Intel代码省略了寄存器名字前面的“%”符号。3. Intel 代码用不同的方式来描述内存中的位置。例如`QWORD PTR [rbx]`而不是`[%rbx]`。


## 数据格式

由于是从16位体系结构扩展成32位的，Intel用术语“字（word）”表示16位数据类型。下图给出了C语言基本数据类型对应的x86-64表示<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-1.png)<br/>如图所示，大多数GCC生成的汇编指令都有一个字符的后缀，表明操作数的大小。例如数据传送指令有4个变种：`movb(传送字节),movw(传送字),movl(传送双字),movq(传送四字)`


## 访问信息

一个x86-64的中央处理单元包含一组16个存储64位值的**通用目的寄存器**。这些寄存器用来存储整数数据和指针。如图所示：<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-2.png)<br/>从图中可以得到，指令可以对这16个寄存器的低位字节中存放的不同大小的数据进行操作。字阶级操作可以访问最低的字节，16位操作可以访问最低的2个字节，32位操作可以访问最低的4个字节，而64位操作可以访问整个寄存器。

大多数指令都有一个或多个**操作数**，指示出执行一个操作中要使用的源数据值，以及放置结果的目的位置。源数据值可以以常数形式给出，或是从寄存器或内存中读出。结果可以存放在寄存器或内存中。

各种不同的操作数的可能性可以被分为三种类型。第一种类型是**立即数**，用来表示常数值。在ATT格式的汇编代码中，立即数的书写方式是“$”后面跟着一个用标准C表示法表示的整数，比如`$-577`。**不同的指令允许的立即数值范围不同，汇编器会自动选择最紧凑的方式进行数值编码**。第二种类型就是**寄存器**，它表示某个寄存器的内容，16个寄存器的低位1字节，2字节，4字节或8字节中的一个作为操作数，这些字节数分别对应于8位，16位，32位或64位。第三类操作数是**内存引用**，它会根据计算出来的地址访问某个内存位置。

如下图所示，有多种不同的**寻址模式**，允许不同形式的内存引用。表中底部用于法$Imm(r_b,r_i,s)$是最常用的形式。这样的引用有四个组成部分：一个立即数偏移Imm，一个基址寄存器$r_b$，一个变址寄存器$r_i$和一个比例因子s，这里s必须是1，2，4，或者8。基址和变址寄存器都必须是64位寄存器。有效地址被计算为$$Imm+R[r_b]+R[r_i]*s$$。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-3.png)

最频繁使用的指令是将数据从一个位置复制到另一个位置的指令。操作数表示的通用性使得一条简单的数据传送传送指令能够完成在许多机器中要好几条不同指令才能够完成的功能。

**下图列出的是最简单形式的数据传送指令----MOV类**。这些指令把数据从源位置复制到目的位置，不做任何变化。MOV类由四条指令组成：`movb,movw,movl,movq`。这些指令执行同样的操作；主要区别在于它们操作的数据大小不同：分别是1，2，4和8字节<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-4.png)

源操作数指定的值是一个立即数，存储在寄存器或内存中。目的操作数指定了一个位置，寄存器或者内存地址。x86_64加了一条限制，传送指令的两个操作数不能都指向内存位置。例如将一个值从一个内存位置复制到另一个内存位置需要两条指令----第一条指令将源值加载到寄存器中，第二条将该寄存器值写入目的地址。

这些指令的寄存器操作数可以是16个寄存器有标号部分中的任意一个，寄存器部分的大小必须与指令最后一个字符（“b”，”w”，“l”或“q”）指定的大小匹配。大多数情况下，MOV指令只会更新目的操作数指定的那些寄存器字节或内存位置。唯一的例外是movl指令以寄存器为目的时，它会把该寄存器的高位4字节设置为0。如下所示：
```
movabsq $0x0011223344556677, %rax ; %rax=0011223344556677
movb $-1, %al ; %rax=00112233445566FF
movw $-1, %ax ; %rax=001122334455FFFF
movl $-1, %eax ; %rax=00000000FFFFFFFF
movq $-1, %rax ; %rax=FFFFFFFFFFFFFFFF
```

**MOVZ**类中的指令把目的中剩余的字节填充为0，而**MOVS**类中的指令通过符号扩展来填充，把源操作的最高位进行复制。如下所示：
```
movabsq $0x0011223344556677, %rax; %rax=0011223344556677
movb $0xAA, %dl;%dl=AA
movb %dl, %al; %rax=00112233445566AA
movsbq %dl, %rax; %rax=FFFFFFFFFFFFFFAA
movzbq %dl, %rax; %rax=00000000000000AA
```

数据传送示例如下，`exchange.c`：
```cpp
long exchange(long *xp, long y){
    long x=*xp;
    *xp=y;
    return x;
}
```
汇编代码如下，`exchange.s`：
```
	.file	"exchange.c"
	.text
	.globl	exchange
	.type	exchange, @function
exchange:
.LFB0:
	.cfi_startproc
	movq	(%rdi), %rax
	movq	%rsi, (%rdi)
	ret
	.cfi_endproc
.LFE0:
	.size	exchange, .-exchange
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```

当过程开始执行时，过程参数xp和y分别存储在寄存器%rdi和%rsi中。然后movq指令从`(%rdi)`中读取x放置到`%rax`中作为返回值。

首先我们看到C语言中所谓的“指针”其实就是地址。间接引用指针就是将该指针放在以个寄存器中，然后在内存引用中使用这个寄存器。

最后两个数据传送操作可以将数据压入程序栈中，以及从从程序栈中弹出数据。通过`push操作把数据压入栈中，通过`pop`操作删除数据；它具有一个属性：弹出的值永远是最近被压入而且仍然在栈中的值。在x86-64中，程序栈存放在内存中某个区域。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-8.png)

`pushq`指令的功能是把数据压入栈中，而`popq`指令是弹出数据。这些指令都只有一个操作数----压入的数据源和弹出的数据目的。

`%rsp`保存栈顶元素指针，压栈和出栈操作如下图：<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-9.png)

因为栈和程序代码以及其他形式的程序数据都是存放在同一内存中，所以程序可以用标准的内存寻址方法访问栈内的任意位置。例如，假设栈顶元素是四字，指令`movq 8(%rsp), %rdx`会将第二个四字从栈中复制到寄存器`%rdx`。


## 算术和逻辑操作

大多数操作都分成了指令类，这些指令类有各种带不同大小操作数的变种（只有`leaq`没有其他大小的变种）。

**加载有效地址**指令`leaq`实际上是`movq`指令的变形。它的指令形式是从内存读数据到寄存器，但实际上它根本就没有引用内存。它的第一个操作数看上去是一个内存引用，但该指令并不是从指定的位置读取数据，而是将有效地址写入到目的操作数。目的操作数必须是一个寄存器。
```cpp
long scale(long x, long y, long z){
    long t=x+4*y+12*z;
    return t;
}
```
生成的汇编代码如下：
```
	.file	"scale.c"
	.text
	.globl	scale
	.type	scale, @function
scale:
.LFB0:
	.cfi_startproc
	leaq	(%rdi,%rsi,4), %rax ;x+4*y
	leaq	(%rdx,%rdx,2), %rcx ;z+2*z=3*z
	leaq	0(,%rcx,4), %rdx    ;4*3*z=12*z
	addq	%rdx, %rax          ;x+4*y+12*z
	ret
	.cfi_endproc
.LFE0:
	.size	scale, .-scale
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```

由此可见，`leaq`指令能执行加法和有限形式的乘法。

移位操作，先给出移位量，然后第二项给出的是要移位的数。可以进行算术和逻辑右移。移位量可以是一个立即数，或者放在单字节寄存器`%cl`中。原则上来说，1个字节的移位量使得移位量的编码范围可以达到$2^{8}-1=255$。 x86-64中，移位操作对w位字长的数据值进行操作，移位量是由`%cl`寄存器的低m为决定，这里$2^{m}=w$。高位会被忽略。

左移指令有两个名`SAL,SHL`，效果是一样的，都是将右边补0。右移指令不同，SAR执行算术移位，而SHR执行逻辑移位。移位操作的目的操作数可以是一个寄存器或是一个内存位置。

两个64位有符号或无符号整数相乘得到的乘积需要128位来表示。x86-64指令集对128位数的操作提供有限的支持，Intel将16字节的数称为**八字**。支持产生两个64位数字的全128位乘积以及除法的指令，如下图所示：<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-12.png)

`imulq`指令有两种不同的形式。其中一种是IMUL指令类中的一种。这种形式的`imulq`指令是一个“双操作数”乘法指令。它从两个64位操作数产生一个64位乘积，实现了$$*_{64}^{u}$$和$$*_{64}^{t}$$运算。另外一种是“单操作数”乘法指令，以计算两个64位值的全128位乘积，要求一个参数必须在寄存器`%rax`中，而另一个作为源操作数给出。然后乘积存放在寄存器`%rdx`（高64位）`%rax`（低64位）。
```cpp
#include <inttypes.h>

typedef unsigned __int128 uint128_t;

void store_uprod(uint128_t *dest, uint64_t x, uint64_t y ){
    *dest=x*(uint128_t) y;
}
```
汇编代码如下：
```
	.file	"mulq128.c"
	.text
	.globl	store_uprod
	.type	store_uprod, @function
store_uprod:
.LFB4:
	.cfi_startproc
	movq	%rsi, %rax ;Copy x to multiplicand
	mulq	%rdx ; Multiply by y
	movq	%rax, (%rdi) ; Store lower 8 bytes at dest
	movq	%rdx, 8(%rdi) ; Store upper 8 bytes at dest+8
	ret
	.cfi_endproc
.LFE4:
	.size	store_uprod, .-store_uprod
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```
从上面的代码可以看出，`dest in %rdi,x in %rsi,y in %rdx`，存储乘积需要两个`movq`指令：一个存储低8个字节，一个存储高8个字节。由于生成这段代码针对是小端法机器，所以高位字节存储在大地址。

由符号除法指令`idivl`将寄存器`%rdx`（高64位）和`%rax`（低64位）中的128位作为被除数，而除数作为指令的操作数给出。指令将商存储在寄存器`%rax`中，将余数存储在寄存器`%rdx`。

对于大多数64位除法应用来说，被除数也常常是一个64位的值。这个值应该存放在`%rax`中，`%rdx`的位应该设置位全0（无符号除法）或者`%rax`的符号位（有符号数除法）。这个操作可以用`cqto`指令来完成。这条指令不需要操作数----它隐含读出`%rax`的符号位，并将它复制到`%rdx`的所有位。
```cpp
void remdiv(long x, long y, long *qp, long *rp){
    long q=x/y;
    long r=x%y;
    *qp=q;
    *rp=r;
}
```
汇编结果如下：
```
	.file	"remdiv.c"
	.text
	.globl	remdiv
	.type	remdiv, @function
remdiv:
.LFB0:
	.cfi_startproc ; x in %rdi, y in %rsi, qp in %rdx, rp in %rcx
	movq	%rdi, %rax ; Move x to lower 8 bytes of dividend
	movq	%rdx, %rdi ; Move qp to %rdi
	cqto               ; Sign-extend to upper 8 bytes of dividend
	idivq	%rsi       ; Divide by y
	movq	%rax, (%rdi) ; Store quotient at qp
	movq	%rdx, (%rcx) ; Store remainder at rp
	ret
	.cfi_endproc
.LFE0:
	.size	remdiv, .-remdiv
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```
在上面的代码中，首先准备被除数，并且符号扩展x，然后将qp保存在`%rdi`中，执行除法之后，将商保存在qp，将余数保存在rp中。

## 控制

机器代码提供两种基本的低级机制来实现有条件的行为：测试数据值，然后根据测试的结果改变控制流或者数据流

用`jump`指令可以改变一组机器代码指令的执行顺序，`jump`指令指定控制应该被传递到程序的某个其他部分，可能是依赖于某个测试的结果。

除了整数寄存器，CPU还维护这一组单个位的**条件码**寄存器，它们描述了最近的算术或逻辑操作的属性。可以检测这些寄存器来执行条件分支指令。

CF：进位标志。最近的操作使最高位产生了进位。可用来检查无符号数操作的溢出

ZF：零标志。最近的操作得出的结果是0。

SF： 符号标志。最近的操作得到的结果为负数。

OF：溢出标志。最近的操作导致一个补码溢出---正溢出或负溢出。

`leaq`指令不改变任何条件码，因为它是用来进行地址计算的。

`CMP`指令根据两个操作数之差来设置条件码，除了只设置条件码而不更新目的寄存器之外，`CMP`和`SUB`指令的结果时一样的。同样的指令还有`TEST`和`AND`。

条件码通常不会直接读取，常用的方法有三种：1.可以根据条件码的某种组合，将一个字节设置为0或者1，2.可以条件跳转到程序的某个其他的部分，3.可以有条件地传送数据。

如下图所示，根据条件码的某种组合，将一个字节设置为0或者1。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-14.png)我们将这一类指令称为`SET`指令；它们之间的区别就在于它们考虑的条件码的组合是什么，这些指令名字的不同后缀指明了它们所考虑条件码的组合。

一个计算C语言表达式`a<b`的典型指令序列如下所示：
``` 
; a in %rdi, b in %rsi
cmpq %rsi, %rdi ;Compare a:b
setl %al ; Set low-order of %eax to 0 or 1
movzbl %al, %eax ; Clear rest of %eax (and rest of %rax)
ret
```

大多数情况下，机器代码对于有符号和无符号两种情况都使用一样的指令，这是因为许多算术运算对无符号和补码算术都有一样的位级行为。


正常情况下，指令按照它们出现的顺序一条一条地执行。**跳转**指令会导致执行切换到程序中一个全新的位置。在汇编代码中，这些跳转的目的地通常用一个**标号**（label）指明。示例如下：
```
    movq $0, %rax ;Set %rax to 0
    jmp .L1 ;Goto .L1
    movq (%rax), %rdx ;Null pointer derefence (skipped)
.L1:
    popq %rdx ;Jump target
```
指令`jmp .L1`会导致程序跳过`movq`指令，而从`popq`指令开始执行。在产生目标代码文件时，汇编器会确定所有带标号指令的地址，并将跳转目标编码为跳转指令的一部分。

`jmp`指令时无条件跳转。它可以是直接跳转，即跳转目标是作为指令的一部分编码的；也可以是间接跳转，即跳转目标是从寄存器或内存位置中读出的。在汇编语言中，直接跳转是给出一个标号作为跳转目标的。间接跳转的写法是“*”后面跟一个操作数指示符。例如`jmp *%rax or jmp *(%rax)`

如图所示都是一些跳转指令<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-15.png)表中所示的其他跳转指令都是有条件的---它们根据条件码的某种组合，或者跳转，或者继续执行代码序列中下一条指令。

在汇编代码中，跳转目标用符号标号书写。汇编器，以及后来的链接器，会产生跳转目标跳转目标适当的编码。跳转指令有几种不同的编码，但是最常用都是PC相对的。也就是，它们会将目标指令的地址与紧跟在跳转指令后面那条指令的地址之间的差作为编码。这些地址偏移量可以编码为1，2，4个字节。第二种编码方法是给出绝对地址，用4个字节直接制定目标。

当执行PC相对寻址时，程序计数器的值时跳转指令后面那条指令的地址，而不是跳转指令本身的地址。

当条件表达式和语句从C语言翻译成机器代码，最常用的方式是结合有条件安和无条件跳转。

C语言中的`if-else`语句的通用形式模板如下：
```cpp
if(test-expr)
    then-statement
else
    else-statement
```
这里的test-expr是一个整数表达式，它的取值为0或者非0，两个分支语句中只会执行一个。对于这种通用形式，汇编语言通常会使用下面这种形式，这里，我们用C语法来描述控制流：
```cpp
    t=test-expr;
    if(!t)
        goto false;
    then-statement
    goto done;
false:
    else-statement
done:
```
也就是说，汇编器为`then-statement`和`else-statement`产生各自的代码块。它会插入条件分支和无条件分支，以保证执行正确的代码块。

**实现条件操作的传统方法是通过使用控制的条件转移**。当条件满足时，程序沿着一条执行路径执行，而当条件不满足时，就走另一条路径。

一种代替的策略是使用**数据的条件转移**。这种方法计算一个条件操作的两种结果，然后在根据条件是否满足在从中选取一个。只有在一些受限制的情况中，这种策略才可性，但是如果可行，就可以用一条简单的条件传送指令来实现它，条件传送指令更符合现代处理器的性能特性。

**为什么基于条件数据传送的代码会比基于条件控制转移的代码性能要好？**，处理器通过使用流水线来获得高性能，在流水线中，一条指令的处理要经过一系列的阶段，每个阶段执行所需操作的一小部分（例如，从内存取指令，确定指令类型，从内存中读数据，执行算术单元，向内存写数据，以及更新程序计数器）。**这种方法通过重叠连续指令的步骤来获得高性能**，例如，在取一条指令的同时，执行它前面一条指令的算术运算。要做到这一点，要求能够事先确定要执行的指令序列，这样才能保持流水线中充满待执行的指令。当机器遇到条件跳转时，只有当分支条件求值完成后，才能决定分支往哪边走。处理采用非常精密的分支预测逻辑来猜测每条跳转指令是否会执行。只要它的猜测还算可靠，指令流水线中就会充满这指令。另一方面，错误预测一个跳转，要求处理器丢掉它为该跳转指令后所有指令已做的工作，然后在开始用正确位置处起始指令去填充流水线。这样一个错误预测会招致很严重的惩罚，导致程序性能严重下降。

**如何确定分支预测错误的处罚**

假设预测错误的概率时$p$，如果没有预测错误，执行代码的时间是$T_{OK}$，而预测错误的处罚是$T_{MP}$。那么，作为$p$的一个函数，执行代码的平均时间是$$T_{avg}(p)=(1-p)T_{OK}+p(T_{OK}+T_{MP})=T_{OK}+pT_{MP}$$。如果已知$T_{OK}$和$T_{ran}$（当$p=0.5$时的平均时间），要确定$T_{MP}$。将参数带入公式，我们有$T_{ran}=T_{avg}(0.5)=T_{OK}+0.5T_{MP}$，所以有$T_{MP}=2(T_{ran}-T_{OK})$。

下图是x86-64上一些可用的条件传送指令。每条指令都有两个操作数：源寄存器或者内存地址S，和目的寄存器R。源值可以从内存或者源寄存器中读取，但是只有在指定的条件满足时，才会被复制到目的寄存器中。源和目的值可以时16位，32位，64位长。不支持单字节的条件传送。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-18.png)

考虑下面的表达式`v=test-expr?then-expr:else-expr`，用条件控制转移的标准方法来编译这个表达式会得到如下形式：
```cpp
    if(!test-expr)
        goto false;
    v=then-expr
    goto done;
false:
    v=else-expr;
done:
```

基于条件传送的代码，会对`then-expr`和`else-expr`都求值，最终值的选择基于对`test-expr`的求值，抽象代码如下：
```cpp
v=then-expr;
ve=else-expr;
t=test-expr;
if(!t) v=ve;
```
这个序列中的最后一条语句使用条件传送实现---只有当测试条件t满足时，vt的值才会被复制到v中。

**不是所有的条件表达式都可以用条件传送来编译**。最重要的是，无论测试结果如何，我们给出的抽象代码会对`then-expr`和`else-expr`都求值，如果这两个表达式中任意一个可能产生错误或者副作用，就会导致非法行为。如下示例：
```cpp
long cread(long *xp){
    return (xp?*xp:0);
}
```
这段代码如果编译成条件传送，当指针为空是获取`*xp`是非法行为。


C 语言提供了多种循环结构，即`do-while,while,for`。汇编中没有相应的指令存在，可以用条件测试和跳转组合起来实现循环的效果。

`do-while`循环：该语句的通用形式如下
```cpp
do
    body-statement
    while(test-expr);
```
这个循环的效果就是重复执行`body-statement`，对`test-expr`求值，如果求值的结果为非零，就继续循环。可以看到`body-statement`至少执行一次。这种通用性时可以被翻译为如下所示的条件和`goto`语句：
```cpp
loop:
    body-statement
    t=test-expr;
    if(t)
        goto loop;
```

`while`循环，该语句通用形式如下：
```cpp
while(test-expr)
    body-statement;
```
GCC在代码生成中使用两种方法翻译，第一种翻译方法，我们称之为**跳转到中间**，它执行一个无条件跳转跳到循环结尾出的测试，以此来执行初始的测试。可以用以下模板来表达这种方法：
```cpp
    goto test;
loop:
    body-statement
test:
    t=test-expr;
    if(t)
        goto loop;
```

第二种翻译方法，称之为`guarded-do`，首先用条件分支，如果初始条件不成立就跳过循环，把代码变换为`do-while`循环。当时用较高优化等级编译时，例如使用命令行选项-O1,GCC会采用这种策略。
```cpp
t=test-expr;
if(!t)
    goto done;
do 
    body-statement
    while(test-expr);
done:
```

`for`循环，通用形式如下：
```cpp
for(init-expr;test-expr;update-expr)
    body-statemen
```
程序首先对`init-expr`进行求值，然后进入循环；在循环中它先对测试条件`test-expr`求值，如果测试结果为“假”，就会退出，否则执行循环体`body-statement`；最后对更新表达式`update-expr`求值。

GCC为for循环产生的代码是while循环的两种翻译之一，这取决于优化的等级。也就是说，跳转到中间策略会得到如下的goto代码：
```cpp
    init-expr;
    goto test;
loop:
    body-statement
    update-expr
test:
    t=test-expr;
    if(t)
        goto loop;
```

`guarded-do`策略得到：
```cpp
    init-expr;
    t=test-expr;
    if(!t)
        goto done;
loop:
    body-statement
    update-expr;
    t=test-expr;
    if(t)
        goto loop;
done:
```

`switch`语句可以根据一个整数索引值进行多重分支。在处理具有多种可能结果的测试时，这种语句比较有用。它们不仅提高了C代码的可读性，而且通过使用**跳转表**这种数据结构时的实现更加高校。

跳转表是一个数组，表项i是一个代码的地址，这个代码段实现当开关索引值为i时程序应该采取的动作。程序代码用开关索引值来执行一个跳转表内的数组引用，确定跳转指令的目标。和使用一组很长的`if-else`语句相比，使用跳转表的优点是执行开关语句的时间与开关情况的数量无关。

**当开关情况数量比较多，并且值的跨度范围比较小时，就会使用跳转表**
```cpp
void switch_eg(long x, long n, long *dest){
    long val=x;
    
    switch(n){
        case 100:
                val*=13;
                break;
        case 102:
                val+=10;
        case 103:
                val+=11;
                break;
        case 104:
        case 106:
                val*=val;
                break;
        default:
                val=0;
    }
    *dest=val;
}
```
汇编代码如下：
```
	.file	"switch_eg.c"
	.text
	.globl	switch_eg
	.type	switch_eg, @function
switch_eg:
.LFB0:
	.cfi_startproc
	subq	$100, %rsi          ;n in %rsi，计算n=n-100，n的取值范围为0～6
	cmpq	$6, %rsi            ;比较n和6
	ja	.L8                     ;if n>6，跳转到.L8
	leaq	.L4(%rip), %rcx     ;%rip是指令指针寄存器，存放的是下一条指令的地址。所以%rcx中保存的是.L4的地址
	movslq	(%rcx,%rsi,4), %rax ;（.L4的地址）+4*n
	addq	%rcx, %rax          ;计算索引值
	jmp	*%rax                   ;跳转到索引
	.section	.rodata
	.align 4
	.align 4
.L4:                            ;跳转表
	.long	.L3-.L4             ;case 100
	.long	.L8-.L4             ;case 101
	.long	.L5-.L4             ;case 102
	.long	.L6-.L4             ;case 103
	.long	.L7-.L4             ;case 104
	.long	.L8-.L4             ;case 105
	.long	.L7-.L4             ;case 106
	.text
.L3:                            ;case 100
	leaq	(%rdi,%rdi,2), %rax ;val in %rdi
	leaq	(%rdi,%rax,4), %rdi
	jmp	.L2
.L5:                            ;case 102
	addq	$10, %rdi
.L6:                            ;case 103
	addq	$11, %rdi
.L2:                            ;结尾执行*dest=val
	movq	%rdi, (%rdx)        
	ret
.L7:                            ;case 104和106
	imulq	%rdi, %rdi
	jmp	.L2
.L8:                            ;default
	movl	$0, %edi
	jmp	.L2
	.cfi_endproc
.LFE0:
	.size	switch_eg, .-switch_eg
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```

## 过程

过程是软件中一种很重要的抽象。它提供了一种封装代码的方式，用一组指定的参数和一个可选的返回值实现了某种功能。

要提供对过程的机器级支持，必须要处理许多不同的属性。假设过程P调用过程Q，Q执行后返回到P。这些动作包括下面一个或多个机制：

**传递控制**。在进入过程Q的时候，程序计数器必须被设置Q的代码的起始地址，然后在返回时，要把程序计数器设置为P中调用Q那条指令的地址。

**传递数据**。P必须能够向Q提供一个或多个参数，Q必须能够向P返回一个值。

**分配和释放内存**。在开始时，Q可能需要为局部变量分配空间，而在返回前，又必须释放这些存储空间。

C语言过程调用机制的一个关键特性在于使用了栈数据结构提供的后进先出的内存管理原则。<br/>![]({{site_url}}//assets/blog/csapp/ch3/3-25.png)

x86-64的栈向低地址方向增长，而栈指针%rsp指向栈顶元素。可以用pushq和popq指令将数据存入栈中或是从栈中取出。

当x86-64过程需要的存储空间超出寄存器能够存放的大小时，就会在栈上分配空间。这个部分称为过程的栈帧。


将控制从函数P转移到函数Q只需要简单地把程序计数器设置为Q的代码的起始位置。不过，当稍后从Q返回的时候，处理器必须记录好它需要继续P的执行的代码位置。在x86-64中，这个信息是用指令`call Q`调用过程Q来记录的。该指令会把地址A压入栈中，并将PC设置为Q的起始地址。压入的地址A被称为返回地址，是紧跟在`call`指令后面的那条指令的地址。对应的`ret`指令会从栈中弹出地址A，并把PC重新设置为A。

| 指令 | 描述 |
|------|------|
| call Label | 过程调用 |
| call \*Operand | 过程调用 |
| ret | 从过程调用返回 |

`call`指令后面的q只是为强调这是x86-64的。`call`指令有一个目标，即指明被调用过程起始的指令地址。


当调用一个过程时，除了要把控制传递给它并在过程返回时在传递回来之外，过程调用还可能包括把数据作为参数传递，而把过程返回还有可能包括返回一个值。x86-64中，大部分过程间的数据传送是通过寄存器实现的。可以通过寄存器最多传递6个整形参数。寄存器的使用是有特殊顺序的，寄存器使用的名字取决于要传递的数据类型的大小。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-28.png)

如果一个函数有大于6个整型参数，超出6个的部分就要通过栈来传递。假设过程P调用过程Q，有n个整型参数，且$n>6$。那么P的代码分配的栈帧必须要能够容纳7到n号参数的存储空间。将参数1~6复制到对应的寄存器上，把参数7~n放到栈上，参数7在栈顶。


到目前为止我们看到的大多数过程示例都不需要超出寄存器大小的本地存储区域。不过有些时候，局部数据必须存放在内存中，常见的情况包括：

寄存器不够存放所有的本地数据。

对于一个局部变量使用地址运算符“&”，因此必须能够为它产生一个地址。

某些局部变量是数组或结构，因此必须能够通过数组或结构引用被访问到。

一般来说，过程通过减小栈指针在栈上分配空间。分配的结果作为栈帧的一部分，标号为“局部变量”。
```cpp
long swap_add(long *xp, long *yp){
    long x=*xp;
    long y=*yp;
    *xp=y;
    *yp=x;
    return x+y;
}

long caller(){
    long arg1=534;
    long arg2=1057;
    long sum=swap_add(&arg1,&arg2);
    long diff=arg1-arg2;
    return sum*diff;
}
```
汇编代码如下：
```
;long caller()
caller:
    subq $16, %rsp      ;给栈指针减去16个字节，分配16个字节的存储空间
    movq $534, (%rsp)   ;将arg1保存在栈顶位置
    movq $1057, 8(%rsp) ;将arg2保存在%rsp+8的位置
    leaq 8(%rsp), %rsi  ;将arg2的地址保存在%rsi寄存器中，作为第二个参数
    movq %rsp, %rdi     ;将arg1的地址保存在%rdi寄存器中，作为第一个参数
    call swap_add       ;调用swap_add
    movq (%rsp), %rdx   ;通过间接寻址，获取arg1，保存在%rdx中
    subq 8(%rsp), %rdx  ;通过间接寻址，获取arg2，并计算arg1-arg2保存在%rdx中
    imulq %rdx, %rax    ;计算diff*sum，并保存在%rax
    addq $16, %rsp      ;释放分配的栈内存
    ret
```
下面是`call_proc`
```cpp
long call_proc(){
    long x1=1;
    int x2=2;
    short x3=3;
    char x4=4;

    proc(x1,&x1,x2,&x2,x3,&x3,x4,&x4);
    return (x1+x2)*(x3-x4);
}
```
相应的汇编代码如下：
```
;long call_proc()
call_proc:
    subq $32, %rsp          ;在栈上分配32个字节的局部存储空间，将栈寄存器%rsp-32
    movq $1, 24(%rsp)       ;将x1保存在地址为%rsp+24上
    movl $2, 20(%rsp)       ;将x2保存在地址为%rsp+20上，int占用4个字节的地址21~24
    movw $3, 18(%rsp)       ;将x3保存在地址为%rsp+18上，short占用2个字节19~20
    movb $4, 17(%rsp)       ;将x4保存在地址为%rsp+17上，char占用1个字节18
    leaq 17(%rsp), %rax     ;计算&x4并保存在%rax中
    movq %rax, 8(%rsp)      ;将&x4保存在栈中，%rsp+8 参数8
    movl $4, (%rsp)         ;将x4保存在栈顶%rsp，参数7

    leaq 18(%rsp), %r9      ;保存&x3到%r9，参数6
    movl $3, %r8d           ;保存x3到%r8，参数5
    leaq 20(%rsp), %rcx     ;保存&x2到%rcx，参数4
    movl $2, %edx           ;保存x2到%rdx，参数3
    leaq 24(%rsp), %rsi     ;保存&x1到%rsi，参数2
    movl $1, %edi           ;保存x1到%rdi，参数1
    
    call proc
    
    movsql 20(%rsp), %rdx   ;获取x2并且转换为long
    addq 24(%rsp), %rdx     ;获取x1并且计算x2+x1
    movswl 18(%rsp), %eax   ;获取x3并且转换为int
    movsbl 17(%rsp), %ecx   ;获取x4并且转换为int
    subl %ecx, %eax         ;计算x3-x4
    cltq                    ;将%eax转化为long
    imulq %rdx, %rax        ;计算(x1+x2)*(x3-x4)
    addq $32, %rsp          ;释放展空间
    ret
```
栈中分布如下图所示：<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-33.png)

**寄存器组是唯一被所有过程共享的资源**。虽然在给定时刻只有一个过程是活动的，我们仍然必须确保当一个过程调用另一个过程时，被调用者不会覆盖调用者稍后会使用的寄存器值。为此，x86-64采用了一组统一的寄存器使用惯例，所有的过程都必须遵循。

根据惯例，寄存器`%rbx,%rbp`和`%r12~%r15`被划分为被调用者保存寄存器。当过程P调用过程Q时，Q必须保存这些寄存器的值，保证它们的值在Q返回到P时和Q被调用时是一样的。过程Q保存一个寄存器的值不变，要么根本不去改变它，要么就是将原始值压栈，改变寄存器的值，然后在返回前从栈中弹出旧值。

所有其他的寄存器，除了栈指针%rsp，都分类为调用者保存寄存器。


每个过程调用在栈中都有它自己的私有空间，因此多个未完成调用的局部变量不会相互影响。此外栈的原则很自然就提供了适当的策略，当过程被调用的时后分配局部存储，当返回时释放存储。
```cpp
long rfact(long n){
    long result;
    if(n<=1){
        result=1;
    }else{
        result=n*rfact(n-1);
    }
    return result;
}
```
汇编代码如下：
```
;long rfact(long n)
;n in %rdi
rfact:
    pushq %rbx
    movq %rdi, %rbx     ;将局部变量n保存在%rbx中
    movl $1, %eax       ;设置返回值为1
    cmpq $1, %rdi       ;比较n和1
    jle  .L35
    leaq -1(%rdi), %rdi ;计算n-1
    call rfact
    imulq %rbx, %rax
.L35:
    popq %rbx
    ret
```

## 数组分配和访问

C语言中的数组是一种将标量数据聚集成更大数据类型的方式。C语言的一个不同寻常的特点是可以产生指向数组中元素的指针，并对这些指针进行运算。在机器代码中，这些指针会被翻译成地址计算。

对于数据类型T和整型常数N，声明如下：
```
T A[N]
```
其实位置表示为$x_A$。这个声明有两个效果。首先，它在内存中分配一个$L\*N$字节的连续区域，这里的L是数据类型T的大小（单位是字节）。其次，它引入了标识符A，可以用A来作为指向数组开头的元素，这个指针的值就是$x_A$。可以用$0$~$N-1$的整数索引来访问该数组元素。数组元素i会被存放在地址为$x_A+L\*i$的地方。

x86-64的内存引用指令可以用来简化数组访问。假设E是一个int型的数组，而我们想计算E[i]，在此，E的地址存放在寄存器%rdx中，而i存放在寄存器%rcx中，然后指令`movl (%rdx,%rcx,4), %eax`会执行地址计算$x_E+4i$，读取这个内存位置的值，并将结果存放在寄存器%eax中。


C语言允许对指针进行运算，而计算出来的值会根据该指针引用的数据类型的大小进行伸缩。也就是说，如果p是一个指向类型为T的数据的指针，p的值为$x_p$，那么表达式$p+i$的值为$x_p+L*i$，这里L是数据类型T的大小。

但操作数操作符“&”和“*”可以产生指针和间接引用指针。


要访问多维数组的元素，编译器会以数组起始为基地址，偏移量为索引，产生计算期望的元素的偏移量，然后使用某种MOV指令。通常来说，对于一个生命如下的数组： 
```
T D[R][C]
```
它的数组元素`D[i][j]`的内存地址为$\&D[i][j]=x_D+L(C*i+j)$。L是数据类型T以字节为单位的大小。

ISO C99引入了一种功能，允许数据的维度是表达式，在数组被分配的时候才计算出来。在变长数组的C版本中，我们可以将一个数组声明如下：
```
int A[expr1][expr2]
```
它可以作为一个局部变量，也可以作为一个函数的参数，然后在遇到这个声明的时候，通过对表达式expr1和expr2求值来确定数组的维度。

## 异质的数据结构

C语言提供两种将不同类型的对象组合到一起创建数据类型的机制：**结构**，用关键字`struct`来声明，将多个对象集中到一个单位中；**联合**，用关键字`union`来声明，允许用几种不同的类型来引用一个对象。

C语言的struct声明创建一个数据类型，将可能不同类型的对象聚合到一个对象中。用名字来引用结构中的各个组成部分。类似于数组的实现，结构的所有组成部分都存放在内存中一段连续的区域内，而指向结构的指针就是结构第一个字节的地址。**编译器维护关于每个结构的类型信息，指示每个字段的字节偏移。它以这些偏移作为内存引用指令中的位移，从而产生对结构元素的引用。**

要产生一个指向结构内部对象的指针，我们只需将结构的地址加上该字段的偏移量。

综上所述，结构的各个字段的选取完全是在编译时处理的。机器代码不包含关于字段声明或字段名字的信息。

联合提供了一种方式，能够规避C语言的类型系统，允许以多种类型来引用一个对象。联合声明的语法和结构的语法一样，只不过语义相差比较大。他们是用不同字段来引用相同的内存块。示例如下：
```cpp
struct S3{
    char c;
    int i[2];
    double v;
};
union U3{
    char c;
    int i[2];
    double v;
}
```
在一台x86-64的Linux机器上编译时，字段的偏移量、数据类型S3和U3的完整大小如下：

| 类型 | c | i | v | 大小 |
|:-----|:--|:--|:--|:-----|
| S3 | 0 | 4 | 16 | 24 |
| U3 | 0 | 0 | 0 | 8 |

联合的一种应用情况，我们事先知道对一个数据结构中的两个不同字段的使用是互斥的，那么将这两个字段声明为联合的一部分，而不是结构的一部分，会减少分配空间的总量。

联合还可以用来访问不同数据类型的位模式。例如，假设我们使用强制类型转换将一个double类型的值d转换为unsigned long类型的值u：
```cpp
unsigned long u = (unsigned long) d;
```
值u会是d的整数表示。除了d的值为0.0的情况以外，u的位表示会与d的很不一样。下面的代码从一个double产生一个unsigned long类型的值：
```cpp
unsigned long double2bits(double d){
    union {
        double d;
        unsigned long u;
    }temp;
    temp.d=d;
    return temp.u;
}
```
我们以一种数据类型来存储联合中的参数，又以另一种数据类型来访问它。

**当用联合将不同大小的数据结合到一起时，字节顺序问题就会变得非常重要**
```cpp
double uu2double(unsigned word0,unsigned word1){
    union{
        double d;
        unsigned u[2];
    }temp;
    temp.u[0]=word0;
    temp.u[1]=word1;
    return temp.d;
}
```
在小端法机器上，参数word0是d的低位4字节，而word1是高位4字节。大端法刚好相反。


**许多计算机系统对基本数据类型的合法地址做出了一些限制，要求某种类型对象的地址必须是某个值K的倍数。**这种对齐限制简化了形成处理器和内存系统之间的接口的硬件设计。

无论数据是否对齐，x86-64硬件都能正确工作。对齐原则是任何K字节的基本对象的地址都必须是K的倍数。如下表所示：

| K | 类型 |
|:--|:-----|
| 1 | char |
| 2 | short|
| 4 | int, float |
| 8 | long, double, char * |

确保每种数据类型都是按照指定方式来组织和分配，即每种类型的对象都满足它的对齐限制，就可保证实施对齐。

`.align 8`这就保证了它后面的数据的其实地址是8的倍数。因为每个表项长8个字节，后面的元素都会遵守8字节对齐的限制。

对于包含结构的代码，编译器可能需要在字段分配中插入间隙，以保证每个结构元素都能够满足它的对齐要求。结构本身对它的起始地址也有一些对齐要求。
```cpp
struct S1{
    int i; //偏移为0，满足4字节对齐要求
    char c;//偏移为5，满足1字节对齐要求
    int j; //需要在之前插入3个字节，达到偏移为8，满足4字节对齐要求
};//总共占用4+1+3+4=12字节的空间
```

另外，结构的末尾可能也需要一些填充，这样结构数组中每个元素都会满足它的对齐要求。
```cpp
struct S2{
    int i;//4字节
    int j;//4字节
    char c;//1字节+3字节填充满足数组对齐要求
}
```

## 在机器级程序中将控制与数据结合起来

指针是C语言的一个核心特色。它们以一种统一的方式，对不同数据结构中的元素产生引用。

**每个指针都对应一个类型**。这个类型表明该指针指向的是哪一类对象。

**每个指针都有一个值**。这个值是某个指定类型的对象的地址。特殊的NULL（0）值表示该指针没有指向任何位置。

**指针用“&”运算符创建**。这个运算符可以应用到任何lvalue类的C表达式上，lvalue意指可以出现在赋值语句左侧的表达式。

**“\*”操作符用于间接操作指针**。其结果是一个值，它的类型与该指针的类型一致。间接引用是用内存引用来实现的，要么是存储到一个指定的地址，要么是从指定的地址读取。

**将指针从一种类型强制转换成另一种类型，只改变它的类型，而不改变它的值**。强制类型转换的一个效果是改变指针运算的伸缩。

**指针也可以指向函数**。这提供了一个很强大的存储和向代码传递引用的功能，这些引用可以被程序的某个其他部分调用。
```cpp
int fun(int x, int *p);//声明一个函数

int (*fp)(int,int*);//声明一个指针
fp=fun;//将函数的地址赋值给指针
```

C对于数组引用步进行任何边界检查，而且局部变量和状态信息都存放在栈中。这两种情况结合到一起就能导致严重的程序错误，对越界的数组元素的写操作会破坏存储在栈中的状态信息。

一种常见的状态破坏是缓冲区溢出。
```cpp
char *gets(char *s){
    int c;
    char *dest=s;
    while((c=getchar())!='\n'&&c!=EOF){
        *dest++=c;
    }
    if(c==EOF&&dest==s)
        return NULL;

    *dest++='\0';
    return s;
}

void echo(){
    char buf[8];
    gets(buf);
    puts(buf);
}
```
echo的汇编代码如下：
```
;void echo()
echo:
    subq $24,%rsp
    movq %rsp,%rdi
    call gets
    movq %rsp,%rdi
    call puts
    addq $24,%rsp
    ret
```

| 输入的字符数量 | 附加被破坏的状态 |
|:---------------|:-----------------|
| 0～7 | 无 |
| 8～23 | 未被使用的栈空间 |
| 24～31 | 返回地址 |
| 32+ | caller中保存的状态 |

字符串到23个字符以后，返回指针的值以及更多可能保存的状态会被破坏。如果存储的返回地址的值被破坏了，那么ret指令会导致程序跳转到一个完全意想不到的位置。

缓冲区溢出一个更加致命的使用就是让程序执行它本来不愿意执行的函数。这是一种最常见的通过计算机网络攻击系统安全的方法。


**现代的编译器和操作系统实现了很多机制，以避免遭受缓冲区溢出攻击，限制入侵者通过缓冲区溢出攻击获得系统控制的方式。**

**栈随机化**的思想使得栈的位置在程序每次运行时都有变化。实现的方式是：程序开始时，在栈上分配一段0~n字节之间的随机大小的空间。程序不适用这段空间，但是它会导致程序每次执行时后续的栈位置发生了变化。分配的n必须足够大，才能获得足够多的栈地址变化，但是也要比较小，不至于浪费程序太多的空间。

下面的代码是一种确定“典型的”栈地址的方法：
```cpp
int main(){
    long local;
    printf("local at %p\n",&local);
    return 0;
}
```
在64位Linux机器上运行10000次，这个地址变化范围为0x7fff0001b698到0x7ffffffaa4a8，返回大小约为$2^{32}$。

在Linux系统中，栈随机化已经变成了标准行为。它是地址空间布局随机化ASLR的一种。

**计算机的第二道防线是能够检测到合适栈已经被破坏**。最近的GCC版本在产生的代码中加入了一种**栈保护者**机制，来检测缓冲区越界。其思想是在栈帧中任何局部缓冲区与栈状之间存储一个特殊的**金丝雀**值。在恢复寄存器状态和从函数返回之前，程序检查这个金丝雀值是被该函数的某个操作或者该函数调用的某个函数的某个操作改变了。如果是的，那么程序异常终止。

**最后一招是消除攻击者向系统中插入可执行代码的能力**。一种方法是限制那些内存区域能够存放可执行代码。在典型的程序中，只有保存编译器产生的代码的那部分内存才需要是可执行的。其他部分可以被限制为只允许读和写。


## 浮点代码
**书中的代码和使用gcc version 7.5.0 (Ubuntu 7.5.0-3ubuntu1~18.04) 环境编译生成的代码结果不一致**

处理器的**浮点体系结构**包括多个方面，会影响对浮点数数据操作的程序如何被映射到机器上，包括：

如何存储和访问浮点数值。通常是通过某种寄存器方式来完成。

对浮点数据操作的指令。

向函数传递浮点数参数和从函数返回浮点数结果的规则。

函数调用过程中保存寄存器的规则。

AVX浮点体系结构允许数据存储在16个YMM寄存器中，它们的名字为`%ymm0~%ymm15`。每个YMM寄存器都是256位32字节。当对标量数据操作时，这些寄存器只保存浮点数，而且只使用低32位（对于float）或64位（对于double）。汇编代码用寄存器的SSE XMM寄存器名字`%xmm0~%xmm15`来引用它们，每个XMM寄存器都是对应的YMM寄存器的低128位16字节。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-45.png)

引用内存的指令是标量指令，意味着它们只对单个而不是一组封装好的数据值进行操作。数据要么保存在内存中（由表中的$M_32$和$M_64$致命），要么保存在XMM寄存器中（在表中用X表示）。无论数据对齐与否，这些指令都能正确执行，不过代码优化规则建议32位内存数据满足4字节对齐，64位数据满足8字节对齐。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-46.png)

GCC只用标量传送操作从内存传送数据到XMM寄存器或从XMM寄存器传送数据到内存。对于在两个XMM寄存器之间传送数据，GCC会使用两种指令之一，即用`vmovaps`传送单精度数，用`vmovapd`传送双精度数。对于这些情况，程序复制整个寄存器还是只复制低位值不会影响程序功能，也不会影响执行速度，所以使用这些指令还是针对标量数据的指令没有实质上的区别。
```cpp
float float_mov(float v1, float *src, float *dst){
    float v2= *src;
    *dst=v1;
    return v2;
}
```
AT&T格式的x86-64汇编代码如下：
```
;float float_mov(float v1, float *src, float *dst)
;v1 in %xmm0, src in %rdi, dst in %rsi
float_mov:
    vmovaps %xmm0, %xmm1    ;复制v1
    vmovss (%rdi), %xmm0    ;从src读取到v2，从内存复制到xmm寄存器
    xmovss %xmm1, (%rsi)    ;写v1到dst
    ret
```

下图给出在浮点数和整数数据之间以及不同浮点格式之间进行转换的指令集合。这些都是对单个数据值进行操作的标量指令。

浮点数转换为整数，下图中的指令把一个从XMM寄存器或内存中读出的浮点值进行转换，并将结果写入一个通用寄存器。把浮点值转换成整数时，指令会执行截断，把值向0进行舍入。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-47.png)

整数转换为浮点数，下图中的指令使用的是不太常见的三操作数格式，有两个源和一个目的。第一个操作数读自于内存或者一个通用目的寄存器。这里可以忽略第二个操作数，因为它的值只会影响结果的高位字节。而我们的目标是XMM寄存器。在最常见的使用场景中，第二个源和目的操作数都是一样的。<br/>![]({{site_url}}/assets/blog/csapp/ch3/3-48.png)
```
vcvtsi2sdq %rax, %xmm1, %xmm1
```
这条指令从寄存器%rax读取一个长整数，把它转换成数据类型double，并把结果存放进XMM寄存器%xmm1的低字节中。

把单精度数转换成双精度数，GCC生成的代码如下
```
;Conversion from single to double precision
vunpcklps %xmm0, %xmm0, %xmm0 
vcvtps2pd %xmm0, %xmm0
```

`vunpcklps`指令通常用来交叉放置来自两个XMM寄存器的值，把它们存储到第三个寄存器中。也就是说，如果一个源寄存器的内容为字$[s_3,s_2,s_1,s_0]$，另一个源寄存器为字$[d_3,d_2,d_1,d_0]$，那么目的寄存器的值会是$[s_1,d_1,s_0,d_0]$。

`vcvtps2pd`指令会把源XMM寄存器中的两个低位单精度值扩展成目的XMM寄存器中的两个双精度值。

对于把双精度转换成成单精度，GCC会产生类似的代码：
```
;Convertsion from double to single precision
vmovddup %xmm0, %xmm0
vcvtpd2psx %xmm0, %xmm0
```
假设上面这些指令执行前寄存器%xmm0保存这两个双精度值$[x_1,x_0]$。然后`vmovddup`指令把它设置为$[x_0,x_0]$。`vcvtpd2psx`指令把这两个值转换成单精度，再存放到该寄存器的低位一半中，并将高位一半设置为0，得到结果$[0.0, 0.0, x_0, x_0]$。

```cpp
fcvt.c:
double fcvt(int i, float *fp, double *dp, long *lp){
    float f=*fp; double d=*dp; long l=*lp;
    *lp=(long)d;
    *fp=(float)i;
    *dp=(double)l;
    return (double)f;
}
```
汇编代码如下:
```
	.file	"fcvt.c"
	.text
	.globl	fcvt
	.type	fcvt, @function
fcvt:
.LFB0:
	.cfi_startproc
	movss	(%rsi), %xmm0
	movq	(%rcx), %rax
	cvttsd2siq	(%rdx), %r8
	movq	%r8, (%rcx)
	pxor	%xmm1, %xmm1
	cvtsi2ss	%edi, %xmm1
	movss	%xmm1, (%rsi)
	pxor	%xmm1, %xmm1
	cvtsi2sdq	%rax, %xmm1
	movsd	%xmm1, (%rdx)
	cvtss2sd	%xmm0, %xmm0
	ret
	.cfi_endproc
.LFE0:
	.size	fcvt, .-fcvt
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
```


在x86-64中，XMM寄存器用来向函数传递浮点参数，以及从函数返回浮点值。

> XMM寄存器%xmm0~%xmm7最多可以传递8个浮点参数。按照参数列出的顺序使用这些寄存器。可以通过栈传递额外的浮点参数。

> 函数使用寄存器%xmm0返回浮点值

> 所有的XMM寄存器都是调用者保存的。被调用者可以不用保存就覆盖这些寄存器中的任意一个。

当函数包含指针，整数和浮点数混合的参数时，指针和整数通过通用寄存器传递，而浮点值通过XMM寄存器传递。


