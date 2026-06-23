.8086
.model small
.stack 100h

.data
	semilla_random db 0
;==========================MUESTREO MENU=========================
	titulo_menu db"===============[BLACK JACK]================",0ah,0dh,24h
	menu_1		db "1- Nueva Partida",0ah,0dh,24h
	menu_2		db "2- Reglas",0ah,0dh,24h
	menu_3		db "3- Salir",0ah,0dh,24h
	select		db "seleccione una opcion: ",0ah,0dh,24h
;================================================================

	carta_1 db  0c9h,0cdh,0cdh,0cdh,0cdh,0cdh,0bbh,0ah,0dh		;╔═════╗
	carta_2 db 0bah,20h,20h,20h,20h,20h,0bah,0ah,0dh			;║A    ║ [bx + 1]=valor A
	carta_3 db 0bah,20h,20h,03h,20h,20h,0bah,0ah,0dh			;║  ♥  ║ [bx + 2]=simbolo ♥
	carta_4 db 0bah,20h,20h,20h,20h,20h,0bah,0ah,0dh			;║    A║ [bx + 3]=valor A
	carta_5 db  0c8h,0cdh,0cdh,0cdh,0cdh,0cdh,0bch,0ah,0dh,24h	;╚═════╝

	opcion db 00h,24h

	colorCarta db 00h

	puntos_jugador db 00
	puntos_jugador_ascii db "00",24h

	puntos_crupier db 00
	puntos_crupier_ascii db "00",24h

	pregunta_ace db "Queres que el As valga a)1 o b)11", 0dh, 0ah, 24h

	txt_win_jugador 		db "GANA EL JUGADOR",24h
	txt_win_crupier 		db "GANA EL CRUPIER",24h
	txt_empate 				db "EMPATE: GANA EL CRUPIER",24h
	txt_empate_sin_ganador 	db "SE PASAN: NADIE GANA",24h
.code

public imprimir_c
public valor
public simbolos
public carta
public CartaAColor
public CartaAColorCrupier
public imprimir_puntos_jugador
public imprimir_puntos_crupier
public obtener_pts_crupier
public menu_interactivo
public reiniciar_puntos
public espera_tick 
public Decide_ganador

carta proc
	xor ax, ax

	call valor
	xor ax, ax
	call simbolos

	lea bx,carta_1
	call imprimir_c

	ret
carta endp

imprimir_c proc
	push dx
	push ax
	push bx
		mov dx, bx
		mov ah, 9
		int 21h
	pop bx
	pop ax
	pop dx
	ret
imprimir_c endp

menu_interactivo proc
	;mov bh,0Ah ; verde claro sobre negro
	;mov bh,0Ch ; rojo claro sobre negro
	;mov bh,0Eh ; amarillo sobre negro
	;mov bh,0Fh ; blanco brillante sobre negro
	;mov bh,1Fh ; blanco sobre azul
	;mov bh,4Fh ; blanco sobre rojo
	push bx
	push dx

	dibujar_menu:
		mov ax,0003h
		int 10h

		mov ax,0600h
		mov bh,0Ch
		mov ch,0
		mov cl,0
		mov dh,24
		mov dl,79
		int 10h

;====BLACK JACK====
		mov ah,02h
		mov bh,0
		mov dh,5
		mov dl,19
		int 10h

		lea bx,titulo_menu
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,8
		mov dl,25
		int 10h

		lea bx,menu_1
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,9
		mov dl,25
		int 10h

		lea bx,menu_2
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,10
		mov dl,25
		int 10h

		lea bx,menu_3
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,13
		mov dl,25
		int 10h

		lea bx,select
		call imprimir_c

	leer_menu:
		mov ah,00h
		int 16h

		cmp al,'1'
		je fin_menu

		cmp al,'2'
		je fin_menu

		cmp al,'3'
		je fin_menu

		jmp leer_menu

	fin_menu:
		pop dx
		pop bx
		ret
menu_interactivo endp

;=======================================================================
; PROCESO ALEATORIO - Devuelve en AL un número del 0 al 9 usando los 
; milisegundos del la función TIME$
;=======================================================================
;CH= hora, CL=minutos, DH=segundos, DL= milisegundos
;devuelve la decena del milisegundo en al, milisec= 45, al=4
random proc
	push cx
	push dx
	mov ah,2ch
	int 21h
	xor ax,ax
	mov al,dl
	add al,semilla_random
	inc semilla_random
	mov cl,0ah
	div cl
	mov al,ah
	xor ah,ah
	pop dx
	pop cx
	ret
random endp

;CH= hora, CL=minutos, DH=segundos, DL= milisegundos
;devuelve pod al el valor del segundo de menor peso, ej 17, al=7
random2 proc
	push cx
	push dx
	mov ah,2ch
	int 21h
	xor ax,ax
	mov al,dh
	add al,semilla_random
	inc semilla_random
	mov cl,0ah
	div cl
	mov al,ah
	xor ah,ah
	pop dx
	pop cx
	ret
random2 endp

;devuelve por al la el valor de menos peso del milisegundo, milisec = 45, al=5
random3 proc
	push cx
	push dx
	mov ah,2ch
	int 21h
	xor ax,ax
	mov al,dl
	add al,semilla_random
	inc semilla_random
	mov cl,0ah
	div cl
	mov al,ah
	xor ah,ah
	pop dx
	pop cx
	ret
random3 endp

valor proc
	
	push ax
	push bx
	push si
	
	lea bx, carta_2
	lea si, carta_5
	
	call random
	xor ah,ah
	add al, 30h
	
	cmp al, 30h
	je es0
	cmp al, 31h
	je esA
	jmp segui
	esA:
		mov al, "A"
		jmp segui
	es0:
		xor ax, ax
		call random2
		cmp al, 1	;0-1 10
		jbe diez
	
		cmp al, 3	;2-3 J
		jbe jota
	
		cmp al, 5	;4-5 Q
		jbe ku
	
		cmp al, 7	;6-7 K
		jbe ka
	
		cmp al, 9	;8-9 reroll
		jbe reroll10
		jmp reroll10
	
	reroll10:
		call random2
		jmp es0
	
	diez:
		mov al, 44h ; D
		jmp segui
	
	jota:
		mov al, 4ah
		jmp segui
	
	ku:
		mov al,51h
		jmp segui
	
	ka:
		mov al, 4bh
		jmp segui
	
	segui:
		mov [bx + 1], al
		mov [si - 4], al
	
		pop si
		pop bx
		pop ax
		ret
valor endp

simbolos proc
	push ax
	push bx
	push si

	lea si, carta_3

	xor ah,ah

	call random3

	signo:
		cmp al, 1
		jbe cora

		cmp al, 3
		jbe diamante

		cmp al, 5
		jbe tre

		cmp al, 7
		jbe pica

		cmp al, 9
		jbe reroll
		jmp reroll

	reroll:
		call random3
		jmp signo

	cora:
		mov ah, 03h
		mov colorCarta,0f4h
		jmp finsimbolo

	diamante:
		mov ah, 04h
		mov colorCarta,0f4h
		jmp finsimbolo

	tre:
		mov ah, 05h
		mov colorCarta,0f0h
		jmp finsimbolo

	pica:
		mov ah, 06h
		mov colorCarta,0f0h
		jmp finsimbolo

	finsimbolo:
		mov [si + 3], ah
	
	pop si
	pop bx
	pop ax
	ret
simbolos endp

CartaAColor proc

	push ax
	push bx
	push si
	push di
	push cx
	
	call valor
	call simbolos

	call sumar_puntos_jugador

    lea si, carta_1

    recorro:
    	mov al, [si]
    	cmp al, 24h
    	je termino

    	cmp al, 0dh
    	je especial

    	cmp al, 0ah
    	je incremento

    	cmp al, 20h
    	je espacio

    	cmp al, 0bah
    	jae paredes

    	cmp al, 30h
    	jae valorC

    	cmp al, 06h
    	jbe simbolo

    incremento:
    	inc si
    	jmp recorro

    paredes:
    	mov ah,0f1h
    	mov es:[di], ax

    	add di,2
    	jmp incremento

    espacio:
    	mov ah, 0f1h
    	mov es:[di], ax  ;colorcaracter  0f1 20h

    	add di, 2
    	jmp incremento

    valorC:
    	mov ah, colorCarta
    	mov es:[di],ax

    	add di, 2
    	jmp incremento

    simbolo:
    	mov ah, colorCarta
    	mov es:[di],ax

    	add di, 2
    	jmp incremento

    especial:
    	add di, 160
    	sub di, 14

    	jmp incremento

    termino:

    pop cx
    pop di
    pop si
    pop bx
    pop ax
    ret
CartaAColor endp

CartaAColorCrupier proc

	push ax
	push bx
	push si
	push di
	push cx
	
	call valor
	call simbolos

	call sumar_puntos_crupier

    lea si, carta_1

    recorro_cr:
    	mov al, [si]
    	cmp al, 24h
    	je termino_cr

    	cmp al, 0dh
    	je especial_cr

    	cmp al, 0ah
    	je incremento_cr

    	cmp al, 20h
    	je espacio_cr

    	cmp al, 0bah
    	jae paredes_cr

    	cmp al, 30h
    	jae valorC_cr

    	cmp al, 06h
    	jbe simbolo_cr

    incremento_cr:
    	inc si
    	jmp recorro_cr

    paredes_cr:
    	mov ah,0f1h
    	mov es:[di], ax

    	add di,2
    	jmp incremento_cr

    espacio_cr:
    	mov ah, 0f1h
    	mov es:[di], ax

    	add di, 2
    	jmp incremento_cr

    valorC_cr:
    	mov ah, colorCarta
    	mov es:[di],ax

    	add di, 2
    	jmp incremento_cr

    simbolo_cr:
    	mov ah, colorCarta
    	mov es:[di],ax

    	add di, 2
    	jmp incremento_cr

    especial_cr:
    	add di, 160
    	sub di, 14

    	jmp incremento_cr

    termino_cr:

    pop cx
    pop di
    pop si
    pop bx
    pop ax
    ret
CartaAColorCrupier endp

obtener_pts_crupier proc
	mov al,puntos_crupier
    ret
obtener_pts_crupier endp

sumar_puntos_jugador proc
	push bx
	push ax
	push si

	lea si, puntos_jugador

	lea bx, carta_2

	mov al, [bx + 1]

	cmp al, 39h
	jbe numero_normal

	cmp al, 41h
	ja el_diego

	cmp al, 41h
	je ace

	jmp final_puntos

	numero_normal:

		sub al, 30h
		add [si], al
		jmp final_puntos

	el_diego:
		add byte ptr[si], 10
		jmp final_puntos

	ace:
		push bx
		push ax


		mov ah,02h
		mov bh,0
		mov dh,7
		mov dl,0
		int 10h

		lea bx, pregunta_ace


		call imprimir_c



		pop ax
		pop bx

		mov ah, 1
		int 21h

		cmp al,'a'
		je vale_1

		cmp al,'b'
		je vale_11

		jmp ace

	vale_1:
	
		mov ax,0600h
		mov bh,40h
		mov ch,7
		mov cl,0
		mov dh,8
		mov dl,79
		int 10h

		add byte ptr[si], 1
		jmp final_puntos

	vale_11:

		mov ax,0600h
		mov bh,40h
		mov ch,7
		mov cl,0
		mov dh,8
		mov dl,79
		int 10h

		add byte ptr[si], 11
		jmp final_puntos

	final_puntos:

	pop si
	pop ax
	pop bx
	ret
sumar_puntos_jugador endp 

sumar_puntos_crupier proc
	    push bx
	    push ax
	    push si

	    lea si,puntos_crupier
	    lea bx,carta_2

	    mov al,[bx + 1]

	    cmp al,39h
	    jbe numero_normal_crupier

	    cmp al,41h
	    ja el_diego_crupier

	    cmp al,41h
	    je ace_crupier

	    jmp final_puntos_crupier

	numero_normal_crupier:
	    sub al,30h
	    add [si],al
	    jmp final_puntos_crupier

	el_diego_crupier:
	    add byte ptr [si],10
	    jmp final_puntos_crupier

	ace_crupier:
	    add byte ptr [si],11
	    jmp final_puntos_crupier

	final_puntos_crupier:
	    pop si
	    pop ax
	    pop bx
	    ret
sumar_puntos_crupier endp 

imprimir_puntos_jugador proc
	push ax
	push bx
	push si
	push dx

	lea bx, puntos_jugador

	mov al,[bx]

	lea si, puntos_jugador_ascii

	mov byte ptr [si],30h
	mov byte ptr [si + 1],30h

			xor ah, ah
			mov dl, 10
			div dl
	
			add [si] , al
	
			add [si + 1], ah

	lea bx, puntos_jugador_ascii

	call imprimir_c
	
	pop dx
	pop si
	pop bx
	pop ax	
	ret 
imprimir_puntos_jugador endp

imprimir_puntos_crupier proc
	push ax
	push bx
	push si
	push dx

	lea bx, puntos_crupier

	mov al,[bx]

	lea si, puntos_crupier_ascii

	mov byte ptr [si],30h
	mov byte ptr [si + 1],30h

			xor ah, ah
			mov dl, 10
			div dl
	
			add [si] , al
	
			add [si + 1], ah

	lea bx, puntos_crupier_ascii

	call imprimir_c
	
	pop dx
	pop si
	pop bx
	pop ax	
	ret 
imprimir_puntos_crupier endp

reiniciar_puntos proc
	push ax

	mov puntos_jugador,0
	mov puntos_crupier,0

	mov puntos_jugador_ascii,30h
	mov puntos_jugador_ascii+1,30h

	mov puntos_crupier_ascii,30h
	mov puntos_crupier_ascii+1,30h

	pop ax
	ret
reiniciar_puntos endp

espera_tick proc
		push ax
		push bx
		push dx

		mov ah,2ch   			;es una funcion del DOSBOX para obtener la hora del sistema
		int 21h     			;ch=hora,  cl=mins, dh=seg , dl=centesimas  
		mov bl,dl       		;guarda las centesimas en bl 

	espera_tick_loop:
		mov ah,2ch
		int 21h
		cmp dl,bl  				;compara las centesimas
		je espera_tick_loop		;si son iguales no paso un tick

		pop dx	
		pop bx
		pop ax
		ret
espera_tick endp

Decide_ganador proc far

		push ax
		push bx
		push si

		cmp cl,1
		je medio

		mov al,puntos_jugador
		mov bl,puntos_crupier

	;==================== PRIMERO: AMBOS SE PASAN ====================

		cmp al,21
		jbe jugador_no_pasado

		cmp bl,21
		ja ambos_pasados

		jmp win_crupier

	jugador_no_pasado:
		cmp bl,21
		ja win_jugador

	;==================== NINGUNO SE PASO ====================

		cmp al,21
		je posible_21_jugador

		cmp bl,21
		je win_crupier

		cmp al,bl
		ja win_jugador

		cmp al,bl
		jb win_crupier

		jmp empate_crupier

	;==================== CASO 21 ====================

	posible_21_jugador:
		cmp bl,21
		je empate_crupier

		jmp win_jugador

	;==================== GANADORES ====================
	medio:
		jmp no_pide_mas

	win_jugador:
		push bx
		lea bx,txt_win_jugador
		call imprimir_c
		pop bx
		jmp salir

	win_crupier:
		push bx
		lea bx,txt_win_crupier
		call imprimir_c
		pop bx
		jmp salir

	;==================== EMPATE NORMAL ====================

	empate_crupier:
		push ax
		push bx
		push dx

		mov ah,02h
		mov bh,0
		mov dh,11
		mov dl,27
		int 10h

		pop dx
		pop bx
		pop ax

		push bx
		lea bx,txt_empate
		call imprimir_c
		pop bx
		jmp salir

	;==================== AMBOS PASADOS ====================

	ambos_pasados:
		push ax
		push bx
		push dx

		mov ah,02h
		mov bh,0
		mov dh,11
		mov dl,27
		int 10h

		pop dx
		pop bx
		pop ax

		push bx
		lea bx,txt_empate_sin_ganador
		call imprimir_c
		pop bx
		jmp salir

	;==================== CONTROL DURANTE TURNO JUGADOR ====================

	no_pide_mas:
		mov al,puntos_jugador

		cmp al,21
		jae forzar_plantarse

		jmp salir

	forzar_plantarse:
		mov ch,1

	salir:
		pop si
		pop bx
		pop ax
		iret
Decide_ganador endp

end