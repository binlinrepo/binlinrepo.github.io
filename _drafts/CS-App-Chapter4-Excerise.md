---
title: 处理器体系结构（4）---习题解答
category: CS-APP
tags CS-APP 习题解答
---

* 4.1 
```
.pos 0x100 # Start code at address 0x100
    irmovq $15, %rbx
    rrmovq %rbx, %rcx
loop:
    rrmovq %rcx, -3(%rbx)
    addq %rbx, %rcx
    jmp loop
```
