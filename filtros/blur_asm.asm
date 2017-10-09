default rel
global _blur_asm
global blur_asm
extern matriz
extern free

section .data
	alpha0: db 	0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00
	alpha1: db 	0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF,	0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF
	alphaBorde0: db 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	alphaBorde1: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF,	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	masKer: db 0x00, 0x01, 0x02, 0x03, 0x00, 0x01, 0x02, 0x03, 0x00, 0x01, 0x02, 0x03, 0x00, 0x01, 0x02, 0x03
	

section .text
;void blur_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
    ;float sigma,
    ;int radius)

_blur_asm:
blur_asm:
	;rdi = source
	;rsi = dest
	;rdx = filas
	;rcx = columnas
	;r8  = radius
	;xmm0 = sigma
	
	push rbp
	mov rbp, rsp
	sub rsp,8
	push r12
	push r13
	push r14
	push r15
	push rbx
	
	xor r14, r14
	xor r15, r15
	xor rbx, rbx
	mov r12, rdi;guarda src
	mov r13, rsi;guarda dest
	mov r14d, edx;guarda filas
	mov r15d, ecx;guarda columnas
	mov ebx, r8d ;guarda el radius
	
	mov rdi, r8
	call matriz
	mov r8, rax
	
	mov rax, rbx ;rad
	xor rdx, rdx
	mov rdx, 2
	mul rdx ; rad*2
	mov r9, rax
	
	mov rdx, rax
	inc rdx
	mov rdi, r14
	sub rdi, rdx
	mov rax, rdi
	xor r10, r10
	mov r10, 4
	mul r10
	mov rdi, rax ;desplazamiento termino fila kernel (fila - 2*rad+1)*4
	
	mov rax, r9
	mov rsi, r14 ;filas
	sub rsi, rax ;filas - 2*rad
	mov r9, r15 ;columnas
	sub r9, rax ;columnas - 2*rad
	mov rax, r9
	mul rsi 	;(columnas-2*rad)*(filas-2*rad)
	mov rsi, rax ;tamaño img a modificar
	
	mov r9, rbx
	sal r9,1
	inc r9
	mov rax, r9
	mul r9
	mov r9, rax;tamaño matriz kernel
	
	pxor xmm0, xmm0
	pxor xmm1, xmm1
	pxor xmm2, xmm2
	pxor xmm3, xmm3
	pxor xmm4, xmm4
	pxor xmm5, xmm5
	pxor xmm8, xmm8
	pxor xmm9, xmm9
	pxor xmm10, xmm10

	movdqu xmm8, [alpha0]
	movdqu xmm9, [alpha1]
	
	
	pxor xmm13, xmm13
	pxor xmm14, xmm14
	movdqu xmm13, [alphaBorde1]
	movdqu xmm14, [alphaBorde0]
	movdqu xmm15, [masKer]
	
	xor r10,r10
	mov rax, rbx
	xor rdx, rdx
	mov rdx, 2
	mul rdx
	mov r10, r15
	sub r10, rax ;todo esto genera col-2*rad
	
	xor r11, r11
	mov r11, r10
	
	mov rax, rbx
	xor rdx, rdx
	mov rdx, 4
	mul rdx; rax tiene rad*4
	add r12, rax; paro a la img despues del rad
	add r13, rax
	mul r15 ; multipico rax por las columnas
	add r12, rax; la img queda en la seccion que queremos modificar (comienzo+ rad*anchoCol*4+rad*4)
	add r13, rax; dejo al dest en el mismo lugar
		
	.ciclo:		
		pxor xmm6, xmm6
		pxor xmm7, xmm7
		pxor xmm11, xmm11
		pxor xmm12, xmm12
		cvtdq2ps xmm6, xmm6
		cvtdq2ps xmm7, xmm7
		cvtdq2ps xmm11, xmm11
		cvtdq2ps xmm12, xmm12
		;dejo los reg acumuladores en 0 en float
		
		movdqu xmm0, [r12]
		movdqu xmm4, xmm0
		pand xmm4, xmm9 ;xmm4 tiene todo en 0 y los alpha en su valor original
		
		mov rcx, r12
		mov rax, rbx
		xor rdx, rdx
		mov rdx, 4
		mul rdx; rax tiene rad*4
		sub rcx, rax
		mul r15 ; multipico rax por las columnas
		sub rcx, rax ;estoy parada en el primer vecino (rcx - rad*cols*4 -rad*4)
		;busque la posicion de los vecinos
		
		mov rax, r9 ;la cantidad de pixeles en kernel
		mov rdx, r8 ;la posicion de memoria de kernel
		
		mov r14, rbx
		add r14, r14
		inc r14
		
		sub r10,4
		cmp r10,0
		jl .entraConBorde
		
		.ker:
			cmp r14, 0
			je .kerFinFila
			
			movdqu xmm0, [rcx]
			pand xmm0, xmm8
			;me traigo los vecinos
			
			movdqu xmm3, xmm0
			punpcklbw xmm3, xmm10
			punpckhbw xmm0, xmm10
			
			movdqu xmm1, xmm0
			punpcklwd xmm1, xmm10
			punpckhwd xmm0, xmm10
			movdqu xmm2, xmm3
			punpckhwd xmm2, xmm10
			punpcklwd xmm3, xmm10
			;paso los bytes a 4 bytes 
			
			cvtdq2ps xmm0, xmm0
			cvtdq2ps xmm1, xmm1
			cvtdq2ps xmm2, xmm2
			cvtdq2ps xmm3, xmm3
			;Hasta aca en cada xmm tengo un pixel con componentes en float
			
			movd xmm5, [rdx]
			pshufb xmm5, xmm15
			;en xmm5 esta repetido 4 veces el numero de la matriz para multiplicar
			
			mulps xmm0, xmm5
			mulps xmm1, xmm5
			mulps xmm2, xmm5
			mulps xmm3, xmm5
			addps xmm6, xmm0
			addps xmm7, xmm1
			addps xmm11, xmm2
			addps xmm12, xmm3
			;multiplico y se lo sumo a lo anterior
			
			add rcx, 4
			dec rax
			add rdx, 4
			dec r14
			cmp rax, 0
			jne .ker
			;[Xmm6;Xmm7;xmm11,xmm12] tenes el resultado de la matriz de convolucion con los vecinos
			 
		CVTPS2DQ xmm0, xmm6
		CVTPS2DQ xmm1, xmm7
		CVTPS2DQ xmm2, xmm11
		CVTPS2DQ xmm3, xmm12;convierto todos los resultados a enteros
		
		packusdw xmm1,xmm0
		packusdw xmm3,xmm2
		packuswb xmm3,xmm1 ;empaquetamos todo en xmm3
		movdqu xmm0, xmm3
	
		por xmm0, xmm4 ;pongo los alpha originales
		
		movdqu [r13], xmm0
		
		;incremento las posiciones de memoria y decremento la cantidad de pixeles que modifique
		add r12, 16
		add r13, 16
		sub rsi, 4
		cmp r10, 0
		je .entraJusto
		jmp .ciclo
		
		
		.entraJusto:
			mov r10, r11 ;restauro la cantidad de pixeles por fila
			cmp rsi, 0
			je .termine
			lea r12, [r12 + 8*rbx]
			lea r13, [r13 + 8*rbx] ;agrego 2*rad*4
			jmp .ciclo
		
		.kerFinFila:
			add rcx, rdi
			mov r14, rbx
			add r14, r14
			inc r14
			jmp .ker
			
		.kerBordeFinFila:
			add rcx, rdi
			mov r14, rbx
			add r14, r14
			inc r14
			jmp .kerBorde
		
		.entraConBorde:	
			sub rcx, 8 
			;asi cuando me traigo a los vecinos que quedan los que quiero en la parte baja del xmm para no pasarme del tamaño de la img
			mov r10, r11 ;restauro la cantidad de pixeles por fila
			movdqu xmm4, xmm0
			pand xmm4, xmm13 ;Me quedo con todos los alpha originales y el borde original
			
			.kerBorde:
				cmp r14, 0
				je .kerBordeFinFila
				
				movdqu xmm0, [rcx]
				pand xmm0, xmm8
				;me traigo los vecinos

				punpcklbw xmm0, xmm10
				movdqu xmm1, xmm0
				punpcklwd xmm1, xmm10
				punpckhwd xmm0, xmm10
				;paso los bytes a 4 bytes
				
				cvtdq2ps xmm0, xmm0
				cvtdq2ps xmm1, xmm1 ; paso los enteros a float
				
				movd xmm5, [rdx]
				pshufb xmm5, xmm15 ;el valor de kernal repetido 4 veces
				
				mulps xmm0, xmm5
				mulps xmm1, xmm5
				addps xmm6,xmm0
				addps xmm7,xmm1
				;multiplico y agrego a los anterior
				
				add rcx, 4
				dec rax
				add rdx, 4
				dec r14
				cmp rax, 0
				jne .kerBorde
			 
			CVTPS2DQ xmm0, xmm6
			CVTPS2DQ xmm1, xmm7 ;convierto los float en enteros
			packusdw xmm0, xmm1
			packuswb xmm0, xmm3 ;los dejo todos enla parte alta de xmm0
			pand xmm0, xmm14 ;dejo en 0 la parte baja de xmm0
			por xmm0, xmm4 ;traigo el borde y los alpha originales
			
			movdqu [r13], xmm0
			
			sub rsi, 2
			cmp rsi, 0
			jl .termine
			
			add r12, 8
			add r13, 8
			lea r12, [r12 + 8*rbx]
			lea r13, [r13 + 8*rbx] ;agrego 2*rad*4
			jmp .ciclo
		
		
	.termine:
		mov rdi, r8
		call free
		pop rbx
		pop r15
		pop r14
		pop r13
		pop r12
		add rsp, 8
		pop rbp
		ret
