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

* 3.16
    * A.
    ```cpp
    void cond(long a, long *p){
        if(p==0)
            goto done;
        if(*p>a)
            goto done;
    done:
        return;
        
    }
    ```
    * B. 第一个条件分支是&&表达式的一部分，如果对p为非空的测试失败，代码就会跳过`a>*p`的测试

* 3.17 
    * A.
    ```cpp
    long gotodiff_se(long x, long y){
        long result;
        if(x<y)
            goto x_le_y;
        ge_cnt++;
        result=y-x;
        return result;
    x_le_y:
        ln_cnt++;
        result=y-x;
        return result;
    }
    ```
    * B. 在大多数情况下，可以在两种方式中任意选择。但是原来的方法对常见的没有`else`语句的情况更好一些。对于这种情况，我们只能简单的将翻译规则修改如下：
    ```cpp
    t=test-expr;
    if(!t)
        goto done;
    then-statement
    done:
    ```
    所以基于这种代替规则的翻译更麻烦一些。

* 3.18
    ```cpp
    long test(long x, long y, long z){
        long val=x+y+z;
        if(x<-3){
            if(y<z){
                val=x*y;
            }else{
                val=y*z;
            }
        }else if(x>2){
            val=x*z;    
        }
        return val;
    }
    ```

* 3.19
    * A. $T_{MP}=2(31-16)=30$
    * B. $T_{MP}+T_{OK}=30+16=46$
    
* 3.20 
    * A. `#define OP /`
    * B. 
    ```
    ;long arith(long x)
    ;x in %rdi
    arith:
        leaq 7(%rdi), %rax  ;将x+7保存在%rax
        testq %rdi, %rdi    ;测试x是正数，负数或0
        cmovns %rdi, %rax   ;如果x是非负数，将x保存在%rax
        sarq $3, %rax       ;将x算术右移3位。这个是作除法运算，当x为负数时，7为偏置量。
        ret
    ```

* 3.21
```cpp
long test(long x,long y){
    long val=x*8;
    if(y>0){
        if(x>=y){
            val=x&y;
        }else
            val=y-x;
    }else if(y<=-2){
        val=x+y;
    }
    return val;
}

* 3.22
    * A. `n=13`时会发生溢出，最大的n值为12
    * B. long型，`n=20`才会发生溢出，最大的n值为19

* 3.21
    * A. `x in %rdi, y in %rcx, n in %rdx`
    * B. 编译器认为指针p总是指向x，因此表达式`(*p)++`就能够实现x+1。代码`leap 1(%rcx,%rdi), %rax`，把这个加1和加y组合起来。
    * C. 
    ```
    ;long dw_loop(long x)
    ;x initially in %rdi
    dw_loop:
        movq %rdi, %rax     ;将x保存在%rax中
        movq %rdi, %rcx     ;将x保存在%rcx中
        imulq %rdi, %rcx    ;计算x*x保存在%rcx中，即y
        leaq (%rdi,%rdi), %rdx  ;计算x+x保存在%rdx中，即n
    .L2:
        leaq 1(%rcx,%rax), %rax ;计算x+y+1保存在%rax中
        subq $1, %rdx           ;n-1
        testq %rdx, %rdx        ;检测n是否大于0
        jg .L2                  ;n>0时跳转到L2
        rep; ret
    ```

* 3.24
```cpp
long loop_while(long a, long b){
    long result=1;
    while(a<b){
        result*=(a+b);
        a++;
    }
    return result
}
```

* 3.25
```cpp
long loop_while2(long a,long b){
    long result=b;
    while(b>0){
        result=result*a;
        b=b-a;
    }
    return result;
}
```

* 3.26
    * A. 可以看到这段代码使用的时跳转到中间翻译方法，在第3行使用无条件跳转指令`jmp`
    * B. 下面是原始的C代码：
    ```cpp
    long func_a(unsigned long x){
        long val=0;
        while(x!=0){
            val=val^x;
            x>>=1;
        }
        return val&0x1;
    }
    ```
    * C. 这个代码计算参数x的奇偶性。也就是，如果x中有奇数个1，就返回1，如果由偶数个1，就返回0。

* 3.27
```cpp
long fact_for_while(long n){
    long i=2;
    long result=1;
    while(i<=n){
        result*=i;
        i++;
    }
    return result;
}

long fact_for_guarded_do(long n){
    long i=2;
    long result=1;
    if(i>n)
        goto done;
loop:
    result*=i;
    i++;
    if(i<=n)
        goto loop;
done:
    return result;
}
```

* 3.28
    * A.
    ```cpp
    long fun_b(unsigned long x){
        long val=0;
        long i;
        for(i=64;i!=0;i--){
            val=(val<<1)|(x&0x1);
            x>>=1;
        }
    }
    ```
    * B. 这段代码使用guarded-do变换生成的，但是编译器发现因为i初始化成了64，所以一定会满足测试`i!=0`，因此初始的测试是没有必要的。
    * C. 这段代码把x中的位反过来，创造一个镜像。实现的方法是：将x的位从左向右移，然后在填入这些位，就像是把val从右向作移。

* 3.29
    * A. 这段代码是死循环
    * B. 

* 3.30
    * A. 标号为-1，0，1，2，4，5，7
    ```
    .L4:
        .quad   .L9 -1
        .quad   .L5 0
        .quad   .L6 1
        .quad   .L7 2
        .quad   .L2 3
        .quad   .L7 4
        .quad   .L8 5
        .quad   .L2 6
        .quad   .L5 7
    ```
    * B. 目标为.L5的清卡ung标号为0和7，目标为.L7的标号为2和4。

* 3.31
```cpp
void switcher(long a, long b, long c, long *dest){
    long val;
    switch(a){
        case 5:
            c=b^0x15;
        case 0:
            a=c+112;
            break;
        case 2:
        case 7:
            a=(c+b)<<4;
            break;
        case 4:
            *dest=a;
            break;
        default: 
            val=b;
    }
    *dest=val;
}
```

* 3.32

| 标号 | PC | 指令 | %rdi | %rsi | %rax | %rsp | \*%rsp | 描述 |
| M1 | 0x400560 | callq | 10 | - | - | 0x7fffffffe820 | - | 调用`first(10)` |
| F1 | 0x400548 | lea | 10 | - | - | 0x7fffffffe818 | 0x400565 | 进入`first` |
| F2 | 0x40054c | sub | 10 | 11 | - | 0x7fffffffe818 | 0x400565 |  |
| F3 | 0x400550 | call | 9 | 11 | - | 0x7fffffffe818 | 0x400565 | 调用`last(9,11)` |
| L1 | 0x400540 | mov | 9 | 11 | - | 0x7fffffffe810 | 0x400555 | 进入`last` |
| L2 | 0x400543 | imul | 9 | 11 | 9 | 0x7fffffffe810 | 0x400555 | |
| L3 | 0x400547 | ret | 9 | 11 | 99 | 0x7fffffffe810 | 0x400555 | 从`last`返回99 |
| F4 | 0x400555 | ret | 9 | 11 | 99 | 0x7fffffffe818 | 0x400565 | 从`first`返回99 |
| M2 | 0x400565 | mov | 9 | 11 | 99 | 0x7fffffffe820 | - | 继续执行main|

* 3.33  `a,b,u,v`或`b,a,v,u`

* 3.14
    * A. 可以看到第9～14行将局部值a0～a5分别保存在被调用者保存寄存器%rbx，%r15，%r14，%r13，%12和%rbp。
    * B. 局部值a6和a7存放在栈上相对于栈指针偏移量为0和8的地方。
    * C. 在存储完6个局部变量之后，这个程序用完了所有的被调用者保存寄存器，所以剩下的两个值保存在栈上。

* 3.35
    * A. 寄存器%rbx中保存参数x的值，所以它可以被用来计算结果表达式。
    * B.
    ```cpp
    long rfun(unsinged long x){
        if(x==0)
            return 0;
        unsigned long nx=x>>4;
        long rv=rfun(nx);
        return x+rv;
    }
    ```

* 3.36

| 数组 | 元素大小 | 整个数组的大小 | 起始地址 | 元素i |
|:-----|:---------|:---------------|:---------|:------|
| S | 2 | 14 | $x_S$ | $x_s + 2i$ |
| T | 8 | 24 | $x_T$ | $x_T + 8i$ |
| U | 8 | 48 | $x_U$ | $x_U + 8i$ |
| V | 4 | 32 | $x_V$ | $x_V + 4i$ |
| W | 8 | 32 | $x_W$ | $x_W + 8i$ |

* 3.37

| 表达式 | 类型 | 值 | 汇编代码 |
|:-------|:-----|:---|:---------|
| `S+1` | short\* | $x_S+2$ | `leaq 2(%rdx), %rax` |
| `S[3]` | short | $M[x_S+6]$ | `movw 6(%rdx), %rax` |
| `&S[i]` | short\* | $x_S+2i$ | `leaq (%rdx,%rcx,2), %rax` |
| `S[4*i+1]` | short | $x_S+8\*i+2$ | `movw 2(%rdx,%rcx, 8), %ax`|
| `S+i-5` | short\* | $x_s+2i-10$ | `leaq -10(%rdx,%rcx,2), %rax` |

* 3.38 对矩阵P的引用是在字节偏移$8\*(7i+j)$，而对矩阵Q的引用是在字节偏移$8\*(i+5j)$。由此可以确定P有7列，而Q由5列，得到M=5和N=7。

* 3.39 这些计算是公式（3.1）的直接应用：
    * 对于L=4，C=16和j=0，指针Aptr等于$x_A+4\*(16i+0)=x_A+64i$;
    * 对于L=4，C=16，i=0，j=k，指针Bptr等于$x_B+4\*(16*0+k)=x_B+4k$;
    * 对于L=4，C=16，i=16和j=k，Bend等于$x_B+4\*(16\*16+k)=x_B+1024+4k$。

* 3.40
```cpp
void fix_set_diag_opt(fix_matrix A, int val){
    int *Aptr=&A[0][0];
    int *Bend=&A[N][N];
    while(Aptr!=Bend){
        *Aptr=val;
        Aptr++;
        Aptr+=N;
    }
}
```
或者
```cpp
void fix_set_diag_opt(fix_matrix A, int val){
    int *Abase=&A[0][0];
    long i=0;
    long iend = N*(N+1);
    do{
        Abase[i]=val;
        i+=N+1;
    }while(i!=iend);
}
```

* 3.41
    * A. 

    | 名称 | 偏移量 |
    |:-----|:------|
    | p | 0 |
    | s.x | 8 |
    | s.y | 12 |
    | next | 16 |
    * B. 这个结构总共需要24个字节
    * C. 
    ```cpp
    void sp_init(struct prob *sp){
        sp->s.x=sp->s.y;
        sp->p=&(sp->s.x);
        sp->next=sp->p;
    }
    ```

* 3.42
    * A. 
    ```cpp
    struct ELE{
        long v;
        struct ELE *p;
    }
    long fun(struct ELE * ptr){
        long ret=0;
        if(prt!=NULL){
            ret+=ptr->v;
            ptr=ptr->p;
        }
        return ret;
    }
    ```
    * B. 该结构事项的数据结构是链表，fun按顺序返回链表所有值得和。

* 3.43

| expr | type | 代码 |
|:-----|:-----|:---- |
| up->t1.u | long | `movq (%rdi),%rax`<br/>`movq %rax,(%rsi)` |
| up->t1.v | short | `movw 8(%rdi),%ax`<br/>`movw %ax,(%rsi)` |
| &up->t1.w | char* | `leaq 10(%rdi),(%rsi)` |
| up->t2.a | int* | `leaq (%rdi), (%rsi)` |
| up->t2.a[up->t1.u] | int | `movq (%rdi),%rax`<br/>`movl (%rdi,%rax,4), %eax`<br/>`movl %eax, (%rsi)` |
| *up->t2.p | char | `movq 8(%rdi), %rax`<br/>`movb (%rax), %al`<br/>`movb %al,(%rsi)` |

* 3.44
    * A.

    | i | c | j | d | 总字节 | 对齐字节 |
    |:--|:--|:--|:--|:------|:---------|
    | 0 | 4 | 8 | 12 | 16 | 4 |
    * B.

    | i | c | d | j | 总字节 | 对齐字节 |
    |:--|:--|:--|:--|:------|:---------|
    | 0 | 4 | 5 | 8 | 16 | 8 |

    * C.
    | w | c | 总字节 | 对齐字节 |
    |:--|:--|:-------|:---------|
    | 0 | 6 | 10 | 2 |
    * D.

    | w | c | 总字节 | 对齐字节 |
    |:--|:--|:------|:---------|
    | 0 | 16 | 40 | 8 |
    * E.
    
    | a | t | 总字节 | 对齐字节 |
    |:--|:--|:-------|:--------|
    | 0 | 24 | 40 | 8 |

* 3.45
    * A. 

    | a | b | c | d | e | f | g | h |
    |:--|:--|:--|:--|:--|:--|:--|:--|
    | 0 | 8 | 16 | 24 | 28 | 32 | 40 | 48 |
    * B. 56字节
    * C. 
    ```cpp
    struct {
        char *a; //0
        char d; //8
        char f; //9
        short b; //10
        float e; //12
        double c; //16
        long g; //24
        int h; //32
    }rec; //总字节数40
    ```
