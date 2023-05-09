; Fast Typing Game

; this code generates a random word from array
; and your task is to type the word that pop up on
; the screen as fast as possible. the faster you
; type the higher score you will get. good luck!

; Marmara University - Faculty of Technology
; Computer Engineering
; author	: Ammar Abdurrauf
; student no	: 170421930

#make_COM#
ORG 100h

.DATA
    arr DB 'microchip%', 10
        DB 'algorithm%', 10
        DB 'database%', 10
        DB 'programmer%', 10
        DB 'compiler%', 10
        DB 'keyboard%', 10
        DB 'network%', 10
        DB 'peripheral%', 10
        DB 'processor%', 10
        DB 'software%', '$'
    c1  DB '3'
    ply DB 'Player '
.CODE    
    MOV AX, @DATA
    MOV DS, AX
    MOV DI, 500h
    MOV DH, 1
    
    LEA SI, arr		; load address of msg array into SI
    
    save_words:		; save words in array to specific memory locations
    MOV DL, [SI]
    CMP DL, 10
    JE next_word 	; if '#' next to new word and new address location
    CMP DL, '$'
    JE start_game
    MOV [DI], DL
    INC SI 		; increment index to next character
    INC DI 		; increment index of array
    JMP save_words
    
    next_word:
    INC SI
    MOV AL, DH
    MOV BL, 10h
    MUL BL
    MOV DI, 500h
    ADD DI, AX
    INC DH
    JMP save_words
    
    start_game:
    MOV DI, 0		; player turn (0-2)
    MOV BX, 0		; to print 'Player '
    print_ply:
    LEA SI, ply
    MOV DL, [SI+BX]
    MOV AH, 02h
    INT 21h		; print "Player ..." (1, 2, 3)
    CMP [SI+BX], ' '
    JE end_print_ply:
    INC BX
    LOOP print_ply
    
    end_print_ply:
    MOV CX, DI
    ADD CL, '1'
    MOV DL, CL
    MOV AH, 02h
    INT 21h
    INC DI
    CALL new_line    
    
    print_word:
    JMP random_num	; getting a random number from 1 - 9
    cont_after_rand:	; and then store it in DL register.
    XOR AX, AX		;
    MOV AL, DL		;
    MOV [700h],DX	; save the random number to memory for later use
    MOV BL, 10h		;
    MUL BL		; accessing the word that randomly chosen
    MOV SI, AX		;
    ADD SI, 500h 	;
    MOV CX, 16		;
    print_loop:		; printing the randomly chosen word
    MOV DL, [SI]	;
    CMP DL, '%'		; check if the word is completely printed
    JE counter_321	;
    MOV AH, 02h		;
    INT 21h
    INC SI
    LOOP print_loop
    
    random_num:
    MOV AH, 00h  	; interrupts to get system time        
    INT 1AH      	; CX:DX now hold number of clock ticks since midnight
    MOV AX, DX
    XOR DX, DX
    MOV CX, 10    
    DIV CX       	; here DX contains the remainder of the division - from 0 to 9
    JMP cont_after_rand
    
    counter_321:
    CALL new_line	; call new line proc
    MOV CX, 3
    count:
    PUSH CX
    MOV CX, 0Fh
    MOV DX, 4240h
    MOV AH, 86h
    INT 15h
    MOV DL, c1
    MOV AH, 02h
    INT 21h		; 3... 2... 1...
    MOV DL, 13		; 
    MOV AH, 02h		;
    INT 21h		; set back pointer text to beginning
    DEC c1
    POP CX
    LOOP count
    
    CALL new_line
    XOR AX, AX
    
    MOV BX, 0		; 
    MOV AH, 00h  	; starting the timer       
    INT 1AH		; interrupts to get system time
    PUSH DX
    wait_keyboard_in:
    
    MOV AH, 1
    INT 16h
    JZ  wait_keyboard_in
    
    MOV AH, 0
    INT 16h		; taking the input key
    MOV AH, 0Eh		; print the key
    INT 10h		
    CALL check_word
    JNE game_over
    INC BX		; forward to the next char
    CMP [SI+BX], '%'
    JE you_won
    JMP wait_keyboard_in
    
    game_over:
    MOV AX, 1234h
    
    you_won:
    MOV AH, 00h  	; interrupts to get system time        
    INT 1AH
    POP AX
    SUB DX, AX		; contains microseconds time
    
    MOV [DI+800h], DX	; save the time
    
    CMP DI, 3		; if 3 players had played the game stop
    JNE start_game	; and show the result. if not then continue to play
    ; error too far jump
    
    
    
 RET
 
    ; check the input with the word
    check_word PROC
    XOR DX, DX
    MOV DL, AL
    MOV AL, [700h]	; store the random number
    MOV CL, 10h
    MUL CL
    MOV SI, 500h
    ADD SI, AX
    CMP DL, [SI+BX]	; compare if the input is same with the character i'th in the word
    RET
    check_word ENDP
    
    ; procedure to set the pointer to the next line
    new_line PROC
    XOR AX, AX
    XOR DX, DX
    MOV DL, 10		; entering a new line
    MOV AH, 02h
    INT 21h
    MOV DL, 13		; set back the starting point to the beginning
    INT 21h
    RET
    new_line ENDP
    
END 