	.syntax unified
	.arch armv4
	.fpu softvfp
	.text
	.align	2
	.global	_start
	.arm
_start:
@ Clear .bss segment
	ldr 	r0, =__bss_start
	ldr 	r1, =__bss_end
	mov 	r2, #0
	b		.Lclrbss_entry
.Lclrbss_loop:
	stmia	r0!, {r2}
.Lclrbss_entry:
	cmp		r0, r1
	bne		.Lclrbss_loop
@ Initialize stack frame
	ldr		sp, =__stack_top
	mov		fp, sp
@ Branch to main()
	bl		main
loop:
	b		loop
	