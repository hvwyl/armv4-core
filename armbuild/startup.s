	.syntax unified
	.arch armv4
	.fpu softvfp
	.text
	.align	2
	.global	Reset_Handler
	.arm
	.type Reset_Handler, %function
Reset_Handler:
	ldr sp, =0x10000
	mov fp, sp
	b	main
	