default rel
global _diff_asm
global diff_asm

section .data

alpha0: db 	0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00
alpha1: db 	0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF,	0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

forma0: db  0x02, 0x00, 0x01, 0x03,		0x06, 0x04, 0x05, 0x07,		0x0A, 0x08, 0x09, 0x0B,		0x0E, 0x0C, 0x0D, 0x0F
forma1: db  0x01, 0x02, 0x00, 0x03,  	0x05, 0x06, 0x04, 0x07,     0x09, 0x0A, 0x08, 0x0B,    	0x0D, 0x0E, 0x0C, 0x0F



section .text
;void diff_asm    (
	;unsigned char *src,
    ;unsigned char *src2,
	;unsigned char *dst,
	;int filas,
	;int cols)

_diff_asm:
diff_asm:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	sub rsp, 8
	
	;RDI puntero a img1
	;RSI puntero a img2
	;RDX puntero a destino
	;RCX filas
	;R8 cols
	
	;en r15 guardo el puntero al destino
	mov r15, rdx
	mov r14, rdi ;r14 = img1
	mov r13, rsi ;r13 = img2
	
	pxor xmm0, xmm0
	pxor xmm1, xmm1
	pxor xmm2, xmm2
	pxor xmm3, xmm3
	
	mov rax, rcx
	mul r8
	
	
	movdqu xmm4 ,[forma0]
	movdqu xmm5 ,[forma1]
	
	
	movdqu xmm7,[alpha0]
	movdqu xmm8,[alpha1]	
	
	
	
	.ciclo:
		
		movdqu xmm0, [r14]
		movdqu xmm1, [r13]
		
		movdqu xmm2, xmm0
		pmaxub xmm2, xmm1
		pminub xmm0, xmm1
		
		psubusb xmm2, xmm0
		

		pand xmm2,xmm7
		
		
		movdqu xmm0 ,xmm2
		movdqu xmm1 ,xmm2
		movdqu xmm3 ,xmm2
		
		
		pshufb xmm0, xmm4
		pshufb xmm1, xmm5
		
		
		pmaxub xmm0,xmm1
		pmaxub xmm0,xmm2
		pmaxub xmm0,xmm3
		
		por xmm0, xmm8
		
		movdqu [r15], xmm0
		
		
		add r13, 0x10
		add r14, 0x10
		add r15, 0x10
		
		sub rax, 4
		cmp rax, 0
		jne .ciclo
		
	
	add rsp, 8
	pop r13
	pop r14
	pop r15
	pop rbp
    ret
