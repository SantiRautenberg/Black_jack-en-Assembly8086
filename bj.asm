;TP:BLACKJACK
;Integrantes:
;-Lautaro Lopez
;-Nicolas Penna
;-Santiago Rautenberg
.8086
.model small
.stack 100h

.data
;=============== REGLAS DEL BLACKJACK ===============
	puntos_p 	db "[P] JUGADOR: ",24h
	puntos_c 	db "[P] CRUPIER: ",24H
	jugar_otra  db "[O] Para volver a jugar", 24h
	instrucciones db "[C] Pedir carta    [S] Plantarse", 24h


	OBJ	db "[x] Objetivo:",0dh,0ah
		db "[-] Obtener una suma de cartas cercana a 21.",0dh,0ah
		db "[-] No superar los 21 puntos.",0dh,0ah,24h

	VL 	db "[x] Valor de las cartas:",0dh,0ah
		db "[-] Cartas del 2 al 10: valen su numero.",0dh,0ah
		db "[-] J,Q,K: valen 10 puntos",0dh,0ah
		db "[-] As: vale 1 u 11 puntos.",0dh,0ah,24h

	DES db "[x] Desarrollo:",0dh,0ah
		db "[-] C - Pedir una carta / S - Plantarse.",0dh,0ah
		db "[-] Si supera 21 puntos, pierde.",0dh,0ah,24h

	WIN db "[x] Ganador:",0dh,0ah
		db "[-] Gana quien tenga mas puntos sin pasar 21.",0dh,0ah,24h

	BJ  db "[x] Blackjack:",0dh,0ah
		db "[-] Un As y una carta de valor 10.",0dh,0ah
		db "[-] Debe ocurrir en las dos primeras cartas.",0dh,0ah,24h
;====================================================
	salto 		db	0dh,0ah,24h
	jugador_tag db "JUGADOR: ",24h
	crupier_tag db "CRUPIER: ",24h
.code
;------publicaciones-------------------
	extrn imprimir_c:proc
	extrn carta:proc
	extrn CartaAColor:proc
	extrn CartaAColorCrupier:proc
	extrn imprimir_puntos_jugador:proc
	extrn imprimir_puntos_crupier:proc
	extrn menu_interactivo:proc
	extrn obtener_pts_crupier:proc
	extrn reiniciar_puntos:proc
	extrn espera_tick:proc
	extrn Decide_ganador:proc

main proc

	mov dx, offset Decide_ganador
	mov ax, seg Decide_ganador
	mov ds, ax
	mov ah, 25h
	mov al, 67h
	int 21h

	mov ax,@data
	mov ds,ax

	mov ax,0003h		;prepara la pantalla para el menu
	int 10h    			;ah,00h es cambiar el modo de video

	mov ax,0b800h
	mov es,ax

	jmp ElMenu

;===================== MENU PRINCIPAL =====================
	;pega saltos intermedios porque a medida que
	;agrandaba el codigo quedaba lejos el salto
	ElMenu:
		call menu_interactivo 

		cmp al,'1'
		je va_nueva_ck

		cmp al,'2'
		je va_reglas_ck

		cmp al,'3'
		je va_salir_ck

		jmp ElMenu

;===================== REGLAS =====================

	reglas:
		mov ax,0003h
		int 10h
 							;[ambas se repiten para cada regla]
		mov ah,02h			;estas 5 lineas sirven para ir reiniciando la pantalla
		mov bh,0
		mov dh,1
		mov dl,5    
		int 10h

		mov ax,0600h		;estos sirven par limpiar la zona del cursor, y pinta el titulo 
		mov bh,09h
		mov ch,1
		mov cl,0
		mov dh,1
		mov dl,79
		int 10h


		lea bx,OBJ
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,5
		mov dl,5
		int 10h


		mov ax,0600h
		mov bh,09h
		mov ch,5
		mov cl,0
		mov dh,5
		mov dl,79
		int 10h

		lea bx,VL
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,10
		mov dl,5
		int 10h


		mov ax,0600h
		mov bh,09h
		mov ch,10
		mov cl,0
		mov dh,10
		mov dl,79
		int 10h

		lea bx,DES
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,16
		mov dl,5
		int 10h

		jmp ignorar_ck
		va_reglas_ck:
		jmp va_reglas

		va_nueva_ck:
		jmp va_nueva
		va_salir_ck:
		jmp va_salir

		ignorar_ck:

		mov ax,0600h
		mov bh,09h
		mov ch,16
		mov cl,0
		mov dh,16
		mov dl,79
		int 10h

		lea bx,WIN
		call imprimir_c

		mov ah,02h
		mov bh,0
		mov dh,20
		mov dl,5
		int 10h


		mov ax,0600h
		mov bh,09h
		mov ch,20
		mov cl,0
		mov dh,20
		mov dl,79
		int 10h

		lea bx,BJ
		call imprimir_c

		mov ah,00h
		int 16h

		jmp ElMenu
;=====================SALTOS INTERMEDIOS==================
	va_nueva:
		jmp nueva_partida

	va_reglas:
		jmp reglas

	va_salir:
		jmp salir

;===================== NUEVA PARTIDA =====================

	nueva_partida:
		call reiniciar_puntos

		mov ax,0003h
		int 10h

		mov ax,0b800h   	;sirve para escribir en pantalla
		mov es,ax

		mov ax,1003h
		mov bx,0000h
		int 10h

;===================== PINTA TABLERO =====================
                    	; 	[xh=filas]
	pinta_tablero:  	; 	[xl=colunas]
		mov ax,0600h
		mov bh,40h    	;color rojo

		mov ch,0    	;fila inicial 		= 0
		mov cl,0  		;columna inicial 	= 0

		mov dh,24  		;fila final 		= 24
		mov dl,79   	;columna final 		= 79

		int 10h

	franja_azul:        ;aplica lo mismo pero para la franja azul del tablero
		mov ax,0600h  
		mov bh,10h

		mov ch,11
		mov cl,0

		mov dh,11
		mov dl,79

		int 10h

		mov ah, 02h    ;la 02 de la int 10h posiciona el cursor 
		mov bh, 0
		mov dh, 24
		mov dl, 46
		int 10h

		lea bx, instrucciones
		call imprimir_c

	tag_jugador:      	;este bloque ointa e imprime el cartel del jugador

		mov ah,02h
		mov bh,0
		mov dh,0
		mov dl,0
		int 10h

		lea bx, jugador_tag

		mov dx, bx
		mov ah, 9
		int 21h

		mov ah,02h
		mov bh,0
		mov dh,9
		mov dl,0
		int 10h

		lea bx,puntos_p
		call imprimir_c
		call imprimir_puntos_jugador


	tag_crupier: 		;este bloque ointa e imprime el cartel del crupier

		mov ah,02h
		mov bh,0
		mov dh,12 
		mov dl,0
		int 10h

		lea bx, crupier_tag

		mov dx, bx
		mov ah, 9
		int 21h

		mov ah,02h
		mov bh,0
		mov dh,7
		mov dl,0
		int 10h

		xor si,si
		mov di,320

		jmp otra

;===================== PEDIR OTRA CARTA =====================
	menu_intermedio:
		jmp ElMenu

	opciones_intermedio:
		jmp opciones

	pre_otra:     		
		xor ax,ax
		mov ah,00h
		mov al,16
		inc si
		add di,ax

		mov ah,02h       ;funcion del DOSBOX, para traer la hora del sistema
		mov bh,0
		mov dh,7
		mov dl,0
		int 10h

		mov ax,0600h
		mov bh,40h

		mov ch,7
		mov cl,0

		mov dh,8
		mov dl,79

		int 10h

		push cx
		xor cx,cx

		mov cl, 1
		int 67h    		;[nuestra interrupcion propia]

		cmp ch, 1
		jne salgo

		pop cx

		jmp quedarse

	salgo:
		pop cx

	otra:
		call CartaAColor

		mov ah,02h
		mov bh,0
		mov dh,9
		mov dl,0
		int 10h

		lea bx,puntos_p
		call imprimir_c
		call imprimir_puntos_jugador

;===================== CICLO DE JUEGO =====================

	juego:
		opciones:					;compara al con la letra pedida
			mov ah,00h    			;para plantarse y quedarse
			int 16h

			cmp al,'c'
			je pre_otra

			cmp al,'C'
			je pre_otra

			cmp al,'s'
			je quedarse

			cmp al,'S'
			je quedarse

			cmp al,'m'
			je menu_intermedio

			cmp al,'M'
			je menu_intermedio

			jmp opciones_intermedio

		;===================== PLANTARSE =====================

	quedarse:
		mov ax,0600h
		mov bh,40h

		mov ch,7
		mov cl,0

		mov dh,8
		mov dl,79

		int 10h

		mov ah,02h
		mov bh,0
		mov dh,9
		mov dl,0
		int 10h

		lea bx,puntos_p
		call imprimir_c

		call imprimir_puntos_jugador

		jmp turno_crupier
		turno_crupier:
			mov di,2240

		crupier_pide:
			call espera_tick    		;esta funcion solucina el error de que el crupier saque todas cartas iguales
			call CartaAColorCrupier
			call obtener_pts_crupier

			cmp al,17
			jb pide_otra
			jmp fin_turno_crupier

		pide_otra:
			add di,16
			jmp crupier_pide

		fin_turno_crupier:
			mov ah,02h
			mov bh,0
			mov dh,21
			mov dl,0
			int 10h

			lea bx,puntos_c
			call imprimir_c

			call imprimir_puntos_crupier


			mov ax,0600h
			mov bh,20h

			mov ch,11
			mov cl,25

			mov dh,11
			mov dl,50

			int 10h

			mov ah,02h
			mov bh,0
			mov dh,11
			mov dl,30
			int 10h

			xor cx,cx
			int 67h

			mov ah, 02h
			mov bh, 0
			mov dh, 24
			mov dl, 20
			int 10h

			lea bx, jugar_otra
			call imprimir_c


			mov ah, 02h
			mov bh, 0
			mov dh, 24
			mov dl, 79
			int 10h

			xor ax, ax

			mov ah, 1 
			int 21h
			cmp al,'o'
			je se_juega_otra
			cmp al, 'O'
			je se_juega_otra
			jmp ElMenu

			se_juega_otra:
			jmp nueva_partida

;===================== SALIR =====================

	salir:
		mov ax,4c00h
		int 21h

main endp
end main