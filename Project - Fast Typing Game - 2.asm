#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

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
    arr DB 'microchip$', 10
        DB 'algorithm$', 10
        DB 'database$', 10
        DB 'programmer$', 10
        DB 'compiler$', 10
        DB 'keyboard$', 10
        DB 'network$', 10
        DB 'peripheral$', 10
        DB 'processor$', 10
        DB 'software$', '%'
        
    c1  DB '3'
    c2  DB '1'
    ply DB 'Player $'
    pnt DB ' point: $'
    win_txt DB ' won the game!$'
    tie_txt DB 'Game ended with no winner$'
    win DB ?

.CODE    
    MOV AX, @DATA
    MOV DS, AX
    MOV DI, 500h
    MOV DH, 1
    MOV [1000h], 0h	; to store the input key from players
    
    ;JMP start_game 	; uncomment this when you start game  again
    
    LEA SI, arr		; load address of msg array into SI
    
    save_words:		; save words in array to specific memory locations
    MOV DL, [SI]
    CMP DL, 10
    JE next_word 	; if '#' next to new word and new address location
    CMP DL, '%'
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
    
    next_player:
    CALL game
    CMP DI, 6		; if 3 players had played the game, stop
    JNE next_player	; and show the result. if not then continue to play
    
    MOV CL, 0		; player number
    MOV DI, 0		; memory pointer
    check_result:
    XOR AX, AX
    MOV AL, 10h
    MUL CL
    MOV DI, AX
    MOV AL, [DI+600h]	; DI+600h store the answer key pointer
    INC DI		; inc DI to the next keyboard input
    
    MOV DL, 010h
    MUL DL		; multiply key pointer with 10d
    MOV BX, AX		; use BX to increment
    
    check_loop:
    MOV DL, [BX+500h]	; DL will be used to store the answer key
    MOV AL, [DI+600h]	; AL will be used to take and control the input
    INC BX
    INC DI
    CMP DL, '$'
    JE  input_true
    CMP AL, DL
    JNE input_wrong
    JMP check_loop
    
    input_wrong:	; store FFFF to the memory location which the input is wrong
    PUSH DI
    MOV AL, 02h
    MUL CL
    MOV DI, AX
    MOV [DI+800h], 0FFFFh
    POP DI
    
    input_true:    
    INC CL
    CMP CL, 3h
    JL check_result
    
    SUB c2, 3h		; "Player (1, 2, 3)"
    MOV DI, 0
    MOV SI, 1h		; to store max point
    MOV win, 1h		; to store the player that won
     
    print_points:	; print every player points
    CALL new_line	;
    LEA DX, ply		;
    MOV AH, 09h		;
    INT 21h		; print "Player "
    MOV DL, c2		;
    MOV AH, 02h		;
    INT 21h		; print players number
    LEA DX, pnt		;
    MOV AH, 09h		;
    INT 21h		; print ' points: '
    
    MOV DX, 0ffffh
    MOV AL, [DI+800h]
    INC DI
    MOV AH, [DI+800h]
    INC DI
    SUB DX, AX
    CMP DX, 0h
    JE transnorm_BCD
    SUB DX, 0F82Fh	; subtract point by F82Fh to fit the max division of
    			; 8 bits number. so the maximum point will be 2000
    
    CMP SI, DX		;
    JG dont_swap	;
    MOV SI, DX		; store the max value
    MOV CL, c2
    MOV win, CL
    dont_swap:
    INC [902h]
    transnorm_BCD:
    MOV CX, 4 		;
    loop1:
      CALL ascii_transform
      PUSH AX		; 2000h:0250h adresine sirali yerlestirmek
      LOOP loop1	; icin once stak'a eklenir
    MOV CX, 4
    loop2:		; reverse order
      POP DX		; stacktan en son giren deger cektirilip
      MOV AH, 02h	; print to screen
      INT 21h		;
      LOOP loop2 artirilir
    
    INC c2
    CMP c2, '4'
    JNE print_points

    print_winner:
    LEA BX, win
    CMP SI, 1h
    JE print_tie
    
    CALL new_line	; print "Player "
    LEA DX, ply
    MOV AH, 09h
    INT 21h
    
    MOV DL, [BX]	; print the number of player that have won
    MOV AH, 02h
    INT 21h
    
    LEA DX, win_txt	; print " won the game!"
    MOV AH, 09h
    INT 21h
    
    JMP end_of_code
    
    print_tie:
    CALL new_line	; print "Player "
    LEA DX, tie_txt
    MOV AH, 09h
    INT 21h
    
    end_of_code:
RET
    
    
    game PROC
    CALL new_line
    
    LEA DX, ply
    MOV AH, 09h
    INT 21h		; print "Player ..." (1, 2, 3)
    MOV DL, c2
    MOV AH, 02h
    INT 21h
    INC c2
    CALL new_line    
    
    print_word:
    
    ; GENERATE RANDOM NUMBER
    MOV AH, 00h  	; interrupts to get system time        
    INT 1AH      	; CX:DX now hold number of clock ticks since midnight
    MOV AX, DX
    XOR DX, DX
    MOV CX, 10    
    DIV CX       	; here DX contains the remainder of the division - from 0 to 9
    MOV [700h],DX	; save the random number to memory for later use
    
    XOR AX, AX		;
    MOV AL, DL		;
    MOV BL, 10h		;
    MUL BL		; accessing the word that randomly chosen
    
    MOV DX, 500h	; print the word to be typed
    ADD DX, AX
    MOV AH, 09h	
    INT 21h
    ; COUNT 3.. 2.. 1..
    CALL new_line	; call new line proc
    
    MOV BL, c1
    MOV CX, 3
    count:
    PUSH CX
    MOV DL, BL
    MOV AH, 02h
    INT 21h		; 3... 2... 1...
    MOV DL, 13		; 
    MOV AH, 02h		;
    INT 21h		; set back pointer text to beginning
    DEC BL
    MOV CX, 0Fh		; set interval 1 second
    MOV DX, 4240h	;
    MOV AH, 86h		;
    INT 15h		
    POP CX
    LOOP count
    
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    
    CALL new_line
    XOR AX, AX
    
    MOV AH, 00h  	; starting the timer       
    INT 1AH		; interrupts to get system time
    PUSH DX		; save the system time to stack
    
    ; initialize starting pointer for memory
    MOV BX, [1000h]
    MOV CL, [700h]
    MOV [BX+600h], CL
    INC BX
    keyboard_in:
    MOV AH, 0
    INT 16h		; taking the input key
    CMP AL, 13		; if the player hit 'Enter' button then next player plays
    JE stop_input	;
    CMP BX, 0Eh		; or if the input number is more than 14 then next player plays	
    JE stop_input	;
    MOV AH, 0Eh		; print the key
    INT 10h		;
    MOV [BX+600h], AL	; store the input key to memory location
    INC BX
    JMP keyboard_in
    
    stop_input:
    MOV [BX+600h], '$'
    INC BX
    MOV AH, 00h  	; interrupts to get system time        
    INT 1AH

    POP AX
    SUB DX, AX		; sub to get the interval time
    MOV [DI+800h], DL	; save time to memory address to be compared later
    INC DI
    MOV [DI+800h], DH
    INC DI
 
    MOV AL, 08h
    MUL DI
    MOV BX, AX		; set the input pointer for the next player
    MOV [1000h], BL	; update the starting pointer for the next player
    CALL new_line
    RET
    game ENDP
 
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
    
    ascii_transform PROC
    PUSH CX
    MOV AX, DX		; 
    MOV BL, 0Ah		; 0AH = 10d (decimal)
    DIV BL		; divide value in the AX reg by 10
    MOV CL, AH		; store the remainder to CX reg
    XOR DX, DX		; clean the DX reg
    MOV DL, AL		; store the div result in DX reg
    ADD CL, 030h	; transform the value inside the CX to correspondent ASCII number
    MOV AX, CX
    POP CX
    ret
    ascii_transform ENDP
    
END 