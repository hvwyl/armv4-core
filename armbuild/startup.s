	.syntax unified
	.arch armv4
	.fpu softvfp
	.text
	.align	2
	.global	_start
	.arm
_start:
	b		Reset_Handler
	b		IRQ_Handler

	.type Reset_Handler, %function
Reset_Handler:
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
@ Enable interrupt request
	mrs		r0, CPSR
	bic 	r0, #0x80
	msr		CPSR, r0
@ Branch to main()
	bl		main
loop:
	b		loop

	.type IRQ_Handler, %function
IRQ_Handler:
	stmfd	sp!, {lr}
@ Branch to irq_main(int irq_r0)
	bl		irq_main
	ldmfd	sp!, {pc}^
	