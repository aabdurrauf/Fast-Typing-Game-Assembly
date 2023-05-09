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
.CODE
    MOV AX, @DATA
    MOV DS, AX
    MOV DI, 500h
    MOV DH, 1
    
    ; load address of msg array into SI
    LEA SI, arr
    
    save_words:
    ; save words in array to specific memory locations
    MOV DL, [SI]
    CMP DL, 10
    JE next_word ; if '#' next to new word and new address location
    CMP DL, '$'
    JE print_word
    MOV [DI], DL
    INC SI ; increment index to next character
    INC DI ; increment index of array
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
    
    print_word:
    JMP random_num	; getting a random number from 1 - 9
    cont_after_rand:	; and then store it in DL register.
    XOR AX, AX		;
    MOV AL, DL		; 
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
    MOV AH, 00h  ; interrupts to get system time        
    INT 1AH      ; CX:DX now hold number of clock ticks since midnight
    MOV AX, DX
    XOR DX, DX
    MOV CX, 10    
    DIV CX      ; here dx contains the remainder of the division - from 0 to 9
    JMP cont_after_rand
    
    counter_321:
    MOV DL, 10		; entering a new line
    MOV AH, 02h
    INT 21h
    MOV DL, 13		; set back the starting point to the beginning
    INT 21h
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
    MOV DL, 13
    MOV AH, 02h
    INT 21h
    DEC c1
    POP CX
    LOOP count
    
    ; starting the timer
    
    
END 