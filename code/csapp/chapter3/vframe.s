	.file	"vframe.c"
	.text
	.globl	vframe
	.type	vframe, @function
vframe:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$72, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -56(%rbp)
	movq	%rsi, -64(%rbp)
	movq	%rdx, -72(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	movq	%rsp, %rax
	movq	%rax, %rsi
	movq	-56(%rbp), %rax
	leaq	-1(%rax), %rdx
	movq	%rdx, -40(%rbp)
	movq	%rax, %rdx
	movq	%rdx, %r8
	movl	$0, %r9d
	movq	%rax, %rdx
	movq	%rdx, %rcx
	movl	$0, %ebx
	salq	$3, %rax
	leaq	7(%rax), %rdx
	movl	$16, %eax
	subq	$1, %rax
	addq	%rdx, %rax
	movl	$16, %edi
	movl	$0, %edx
	divq	%rdi
	imulq	$16, %rax, %rax
	subq	%rax, %rsp
	movq	%rsp, %rax
	addq	$7, %rax
	shrq	$3, %rax
	salq	$3, %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	leaq	-48(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	$0, -48(%rbp)
	jmp	.L2
.L3:
	movq	-48(%rbp), %rdx
	movq	-32(%rbp), %rax
	movq	-72(%rbp), %rcx
	movq	%rcx, (%rax,%rdx,8)
	movq	-48(%rbp), %rax
	addq	$1, %rax
	movq	%rax, -48(%rbp)
.L2:
	movq	-48(%rbp), %rax
	cmpq	%rax, -56(%rbp)
	jg	.L3
	movq	-32(%rbp), %rax
	movq	-64(%rbp), %rdx
	movq	(%rax,%rdx,8), %rax
	movq	%rsi, %rsp
	movq	-24(%rbp), %rbx
	xorq	%fs:40, %rbx
	je	.L5
	call	__stack_chk_fail@PLT
.L5:
	movq	-8(%rbp), %rbx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	vframe, .-vframe
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
