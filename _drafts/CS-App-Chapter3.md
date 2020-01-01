---
title: 程序的机器级表示（3）
category: CS-APP
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

