; -----------------------------------------------------------------------------
; Pong Game in Assembly Language
; -----------------------------------------------------------------------------


[org 0x100] 
jmp start ; Jump to the start of the program


; Data Section
PADDLE_WIDTH: dw 20              ; Width of the paddles in characters
P1_POSITION:  dw 30*2            ; Initial memory address for Player 1's paddle (30 characters * 2 bytes/character)
P2_POSITION:  dw (160*23) + 30*2 ; Initial memory address for Player 2's paddle
BALL_POSITION:dw (160*22) + 40*2 ; Initial memory address for the ball
RIGHT_WALL_POSITIONS:        dw 0x0000, 0x00A0, 0x0140, 0x01E0, 0x0280, 0x0320, 0x03C0, 0x0460, 0x0500, 0x05A0, 0x0640, 0x06E0, 0x0780, 0x0820, 0x08C0, 0x0960, 0x0A00, 0x0AA0, 0x0B40, 0x0BE0, 0x0C80, 0x0D20, 0x0DC0, 0x0E60, 0x0F00 ; Memory addresses representing the right wall
CURRENT_PLAYER:              dw 0x0000                                                                                                                                                                                                 ; 0 for Player 1, 1 for Player 2
BALL_DIRECTION:              dw 0x0000                                                                                                                                                                                                 ; 0: Up-Right, 1: Down-Left, 2: Down-Right, 3: Up-Left
PADDLE_COLLISION:            dw 0x0000                                                                                                                                                                                                 ; Flag indicating a paddle collision (0: no collision, 1: collision)
PLAYER1_SCORE:               dw 0x0000                                                                                                                                                                                                 ; Player 1's score
PLAYER2_SCORE:               dw 0x0000                                                                                                                                                                                                 ; Player 2's score
WINNER:                      dw 0x0002                                                                                                                                                                                                 ; 0: Player 1 wins, 1: Player 2 wins, 2: Game in progress
WINNING_SCORE:               dw 0x0005                                                                                                                                                                                                 ; Score needed to win the game
replay_msg:                  db 'PRESS R TO REPLAY'
quit_msg:                    db 'PRESS Q TO QUIT'
P1_WON:                      db 'PLAYER ONE WON THE GAME'
P2_WON:                      db 'PLAYER TWO WON THE GAME'
PRESS_KEY_TO_START           db '[PRESS ANY KEY TO START THE GAME]'
ORIGINAL_TIMER_ISR:          dd 0                                                                                                                                                                                                      ; Stores the original address of the timer ISR
ORIGINAL_KBISR:              dd 0                                                                                                                                                                                                      ; Stores the original address of the keyboard ISR
QUIT_FLAG:                   db 0x00                                                                                                                                                                                                   ; Flag to signal game quit (0: not quit, 1: quit)
REPLAY_FLAG:                 db 0x00                                                                                                                                                                                                   ; Flag to signal game replay (0: no replay, 1: replay)
GAME_FLAG:                   db 0x00                                                                                                                                                                                                   ; Flag to signal game start (0: not started, 1: started)
black_bg_color_offset_array: db 0x08, 0x0c, 0x0a, 0x0e, 0x09, 0x0d, 0x0b, 0x0f                                                                                                                                                         ; Array of color attributes for background
wm_1:                        db '__________ .__                   __________                          '                                                                                                                                ; Part of the welcome message
wm_2:                        db '\______   \|__|  ____     ____   \______   \  ____    ____     ____  '                                                                                                                                ; Part of the welcome message
wm_3:                        db ' |     ___/|  | /    \   / ___\   |     ___/ /  _ \  /    \   / ___\ '                                                                                                                                ; Part of the welcome message
wm_4:                        db ' |    |    |  ||   |  \ / /_/  >  |    |    (  <_> )|   |  \ / /_/  >'                                                                                                                                ; Part of the welcome message
wm_5:                        db ' |____|    |__||___|  / \___  /   |____|     \____/ |___|  / \___  / '                                                                                                                                ; Part of the welcome message
wm_6:                        db '                    \/ /_____/                           \/ /_____/  '                                                                                                                                ; Part of the welcome message
go_1:                        db '  ________                        ________                     '                                                                                                                                      ; Part of the game over message
go_2:                        db ' /  _____/_____    _____   ____   \_____  \___  __ ___________ '                                                                                                                                      ; Part of the game over message
go_3:                        db '/   \  ___\__  \  /     \_/ __ \   /   |   \  \/ // __ \_  __ \'                                                                                                                                      ; Part of the game over message
go_4:                        db '\    \_\  \/ __ \|  Y Y  \  ___/  /    |    \   /\  ___/|  | \/'                                                                                                                                      ; Part of the game over message
go_5:                        db ' \______  (____  /__|_|  /\___  > \_______  /\_/  \___  >__|   '                                                                                                                                      ; Part of the game over message
go_6:                        db '        \/     \/      \/     \/          \/          \/       '                                                                                                                                      ; Part of the game over message


; -----------------------------------------------------------------------------
; Welcome Screen
; -----------------------------------------------------------------------------
welcome_screen: 
    pusha            ; Push all registers onto the stack
    mov   si, 0      ; Initialize loop counter
    mov   bx, 0x0004 ; Initialize X coordinate
    mov   dx, 1      ; Increment for X coordinate
printing:
    push 5                                    ; Push string length
    push bx                                   ; Push X coordinate
    push word[black_bg_color_offset_array+si] ; Push background color attribute
    push wm_1                                 ; Push message address
    push 69                                   ; Push Y coordinate
    call printstr                             ; Call print string subroutine

    push 5                                    ; Push string length
    add  bx, dx                               ; Increment X coordinate
    push bx                                   ; Push updated X coordinate
    push word[black_bg_color_offset_array+si] ; Push background color attribute
    push wm_2                                 ; Push message address
    push 69                                   ; Push Y coordinate
    call printstr                             ; Call print string subroutine

    push 5                                    ; Push string length
    add  bx, dx                               ; Increment X coordinate
    push bx                                   ; Push updated X coordinate
    push word[black_bg_color_offset_array+si] ; Push background color attribute
    push wm_3                                 ; Push message address
    push 69                                   ; Push Y coordinate
    call printstr                             ; Call print string subroutine

    push 5                                    ; Push string length
    add  bx, dx                               ; Increment X coordinate
    push bx                                   ; Push updated X coordinate
    push word[black_bg_color_offset_array+si] ; Push background color attribute
    push wm_4                                 ; Push message address
    push 69                                   ; Push Y coordinate
    call printstr                             ; Call print string subroutine

    push 5                                    ; Push string length
    add  bx, dx                               ; Increment X coordinate
    push bx                                   ; Push updated X coordinate
    push word[black_bg_color_offset_array+si] ; Push background color attribute
    push wm_5                                 ; Push message address
    push 69                                   ; Push Y coordinate
    call printstr                             ; Call print string subroutine

    push 5                                    ; Push string length
    add  bx, dx                               ; Increment X coordinate
    push bx                                   ; Push updated X coordinate
    push word[black_bg_color_offset_array+si] ; Push background color attribute
    push wm_6                                 ; Push message address
    push 69                                   ; Push Y coordinate
    call printstr                             ; Call print string subroutine

    push 23                                   ; Push string length
    push 23                                   ; Push Y coordinate
    push word[black_bg_color_offset_array+si] ; Push background color attribute
    push PRESS_KEY_TO_START                   ; Push message address
    push 33                                   ; Push X coordinate
    call printstr                             ; Call print string subroutine

    cmp bx, 0x0004 ; Compare X coordinate
    je  change_val ; Jump if equal
    change_val: 
        call DELAY_FUNCTION ; Call delay function
        add  bx, 0x0005     ; Increment X coordinate
        jmp  cont_this      ; Jump to cont_this

cont_this: 
    add si,              1    ; Increment loop counter
    cmp si,              7    ; Compare loop counter
    je  reset_si              ; Jump if equal
    cmp byte[GAME_FLAG], 0x01 ; Check if game started
    jnz printing              ; Jump if not started
    jmp ending                ; Jump to ending

    reset_si: 
        mov si,              0    ; Reset loop counter
        cmp byte[GAME_FLAG], 0x01 ; Check if game started
        jnz printing              ; Jump if not started
ending: 
    popa ; Pop all registers from the stack
    ret; ; Return from subroutine


; -----------------------------------------------------------------------------
; Draw Player 1's Paddle
; -----------------------------------------------------------------------------
DRAW_PADDLE_P1: 
    pusha; ; Push registers
    push 0xb800             ; Push video memory segment
    pop  es                 ; Pop segment into es
    mov  cx, [PADDLE_WIDTH] ; Move paddle width into cx (loop counter)
    mov  si, [P1_POSITION]  ; Move paddle's starting memory address into si
DRAW_PADDLE_P1_LOOP:
    mov  word[es:si], 0x3F20 ; Write paddle character and attribute to video memory
    add  si,          2      ; Increment memory address to the next character
    loop DRAW_PADDLE_P1_LOOP ; Loop until cx is 0
popa ; Pop registers
ret  ; Return


; -----------------------------------------------------------------------------
; Draw Player 2's Paddle
; -----------------------------------------------------------------------------
DRAW_PADDLE_P2: 
    pusha; ; Push registers
    push 0xb800             ; Push video memory segment
    pop  es                 ; Pop segment into es
    mov  cx, [PADDLE_WIDTH] ; Move paddle width into cx (loop counter)
    mov  si, [P2_POSITION]  ; Move paddle's starting memory address into si
DRAW_PADDLE_P2_LOOP: 
    mov  word[es:si], 0x5f20 ; Write paddle character and attribute to video memory
    add  si,          2      ; Increment memory address to the next character
    loop DRAW_PADDLE_P2_LOOP ; Loop until cx is 0
    popa                     ; Pop registers
ret ; Return


; -----------------------------------------------------------------------------
; Move the Ball
; -----------------------------------------------------------------------------
MOVE_BALL:
    pusha                                           ; Push registers
    push  0xb800                                    ; Push video memory segment
    pop   es                                        ; Pop segment into es
    ;DELETE THE OLD BALL
    mov   si,                   word[BALL_POSITION] ; Move ball's memory address into si
    mov   word[es:si],          0x0720              ; Erase the ball by writing a space
    ;UPDATE POSITION BASED ON DIRECTION
    cmp   word[BALL_DIRECTION], 0x0000              ; Compare ball direction
    je    MOVE_UP_RIGHT                             ; Jump if Up-Right
    cmp   word[BALL_DIRECTION], 0x0001              ; Compare ball direction
    je    MOVE_DOWN_LEFT                            ; Jump if Down-Left
    cmp   word[BALL_DIRECTION], 0x0002              ; Compare ball direction
    je    MOVE_DOWN_RIGHT                           ; Jump if Down-Right
    cmp   word[BALL_DIRECTION], 0x0003              ; Compare ball direction
    je    MOVE_UP_LEFT                              ; Jump if Up-Left

MOVE_UP_LEFT: 
    sub word[BALL_POSITION], 160 ; Move ball up one line
    sub word[BALL_POSITION], 2   ; Move ball left one character
    jmp DRAW_NEW_BALL            ; Jump to draw new ball
MOVE_UP_RIGHT: 
    sub word[BALL_POSITION], 160 ; Move ball up one line
    add word[BALL_POSITION], 2   ; Move ball right one character
    jmp DRAW_NEW_BALL            ; Jump to draw new ball
MOVE_DOWN_LEFT:
    add word[BALL_POSITION], 160 ; Move ball down one line
    sub word[BALL_POSITION], 2   ; Move ball left one character
    jmp DRAW_NEW_BALL            ; Jump to draw new ball
MOVE_DOWN_RIGHT: 
    add word[BALL_POSITION], 160 ; Move ball down one line
    add word[BALL_POSITION], 2   ; Move ball right one character
DRAW_NEW_BALL: 
    mov si,          [BALL_POSITION] ; Move new ball's memory address into si
    mov word[es:si], 0x072A          ; Draw the ball at the new position

popa ; Pop registers
ret  ; Return


; -----------------------------------------------------------------------------
; Collision Check
; -----------------------------------------------------------------------------
COLLISION_CHECK: 
    pusha; ; Push registers
    mov ax, [BALL_POSITION] ; Move ball's memory address into ax

    mov cx, 23 ; Initialize loop counter
    mov si, 0  ; Initialize array index
RIGHT_COLLISION_LOOP: 
    cmp  ax, [RIGHT_WALL_POSITIONS + si] ; Compare ball position to right wall positions
    je   LEFT_COLLIDE                    ; Jump if collision detected
    add  si, 2                           ; Increment array index
    loop RIGHT_COLLISION_LOOP            ; Loop until cx is 0

    mov cx, 23 ; Initialize loop counter
    mov si, 0  ; Initialize array index

LEFT_COLLISION_LOOP:
    mov  bx, [RIGHT_WALL_POSITIONS + si] ; Move right wall position into bx
    add  bx, 2                           ; Increment right wall position by one character
    cmp  ax, bx                          ; Compare ball position to left wall position
    je   RIGHT_COLLIDE                   ; Jump if collision detected
    add  si, 2                           ; Increment array index
    loop LEFT_COLLISION_LOOP             ; Loop until cx is 0

    cmp word[PADDLE_COLLISION], 0x0001 ; Check if paddle collision occurred
    je  IGNORE_CHECKS                  ; Jump if paddle collision

    cmp ax, 160      ; Check for top wall collision
    jle TOP_WALL_HIT ; Jump if top wall collision

    cmp ax, 23*160      ; Check for bottom wall collision
    jge BOTTOM_WALL_HIT ; Jump if bottom wall collision

IGNORE_CHECKS:
    popa ; Pop registers
    ret; ; Return

TOP_WALL_HIT:
    inc  word[PLAYER2_SCORE]                    ; Increment Player 2's score
    mov  ax,                  word[P2_POSITION] ; Move Player 2's paddle address into ax
    sub  ax,                  160               ; Move the ball above the paddle
    add  ax,                  20                ; Adjust position slightly
    push word[BALL_POSITION]                    ; Push the old ball position onto the stack
    mov  word[BALL_POSITION], ax                ; Update the ball's position
    pop  bx                                     ; Pop the old ball position from the stack into bx
    push 0xb800                                 ; Push video memory segment
    pop  es                                     ; Pop segment into es
    mov  word[es:bx],         0x0720            ; Erase old ball position
    jmp  DRAW_NEW_BALL_COLLISION                ; Jump to draw the ball at new position

BOTTOM_WALL_HIT:
    inc  word[PLAYER1_SCORE]                    ; Increment Player 1's score
    mov  ax,                  word[P1_POSITION] ; Move Player 1's paddle address into ax
    add  ax,                  160+20            ; Move the ball below the paddle
    push word[BALL_POSITION]                    ; Push the old ball position onto the stack
    mov  word[BALL_POSITION], ax                ; Update the ball's position
    pop  bx                                     ; Pop the old ball position from the stack into bx
    push 0xb800                                 ; Push video memory segment
    pop  es                                     ; Pop segment into es
    mov  word[es:bx],         0x0720            ; Erase old ball position
    jmp  DRAW_NEW_BALL_COLLISION                ; Jump to draw the ball at new position

LEFT_COLLIDE: 
    mov  word[BALL_DIRECTION], 0x0001 ; Change ball direction
    popa                              ; Pop registers
    ret; ; Return
RIGHT_COLLIDE: 
    mov word[BALL_DIRECTION], 0x0000 ; Change ball direction
    popa; ; Pop registers
    ret; ; Return
    
DRAW_NEW_BALL_COLLISION: 
    mov si,          [BALL_POSITION] ; Move ball's memory address into si
    mov word[es:si], 0x072A          ; Draw the ball at the new position

    popa ; Pop registers
    ret  ; Return

; -----------------------------------------------------------------------------
; Paddle Collision Check
; -----------------------------------------------------------------------------
PADDLE_COLLISION_CHECK:
    pusha                     ; Push registers
    mov   ax, [BALL_POSITION] ; Move ball position into ax

; ------- P1 SECTION -------
    mov bx, [P1_POSITION]  ; Move Player 1's paddle position into bx
    cmp ax, bx             ; Compare ball position to Player 1's paddle position
    jle continue_checking  ; Jump if ball is above the paddle
    add bx, 40             ; Add paddle width to bx
    cmp ax, bx             ; Compare ball position to Player 1's paddle position + width
    jle PADDLE_COLLIDED_P1 ; Jump if collision detected
continue_checking: 
; -------- P2 SECTION --------
    mov bx, [P2_POSITION]  ; Move Player 2's paddle position into bx
    cmp ax, bx             ; Compare ball position to Player 2's paddle position
    jle NO_COLLISION       ; Jump if ball is above the paddle
    add bx, 40             ; Add paddle width to bx
    cmp ax, bx             ; Compare ball position to Player 2's paddle position + width
    jle PADDLE_COLLIDED_P2 ; Jump if collision detected
    NO_COLLISION:
        mov  word[PADDLE_COLLISION], 0x0000 ; Reset paddle collision flag
        popa                                ; Pop registers
        ret; ; Return
PADDLE_COLLIDED_P1:
    mov word[CURRENT_PLAYER],   0x0001 ; Set current player to Player 2
    mov word[PADDLE_COLLISION], 0x0001 ; Set paddle collision flag
    cmp word[BALL_DIRECTION],   0x0000 ; Check ball direction
    je  move_dl                        ; Jump if Up-Right
    cmp word[BALL_DIRECTION],   0x0003 ; Check ball direction
    je  move_dr                        ; Jump if Up-Left
    jmp enditp1                        ; Jump to enditp1
    move_dr: 
        mov word[BALL_DIRECTION], 0x0001 ; Change ball direction to Down-Left
        jmp enditp1                      ; Jump to enditp1
    move_dl:
        mov word[BALL_DIRECTION], 0x0002 ; Change ball direction to Down-Right
enditp1:
    popa ; Pop registers
    ret  ; Return
PADDLE_COLLIDED_P2:
    mov word[CURRENT_PLAYER],   0x0000 ; Set current player to Player 1
    mov word[PADDLE_COLLISION], 0x0001 ; Set paddle collision flag
    cmp word[BALL_DIRECTION],   0x0001 ; Check ball direction
    je  move_ul                        ; Jump if Down-Left
    cmp word[BALL_DIRECTION],   0x0002 ; Check ball direction
    je  move_ur                        ; Jump if Down-Right
    jmp enditp2                        ; Jump to enditp2
    move_ur: 
        mov word[BALL_DIRECTION], 0x0000 ; Change ball direction to Up-Right
        jmp enditp2                      ; Jump to enditp2
    move_ul: 
        mov word[BALL_DIRECTION], 0x0003 ; Change ball direction to Up-Left
    enditp2:  
        popa ; Pop registers
        ret  ; Return


; -----------------------------------------------------------------------------
; Draw the Ball
; -----------------------------------------------------------------------------
DRAW_BALL: 
    pusha; ; Push registers
    push 0xb800                       ; Push video memory segment
    pop  es                           ; Pop segment into es
    mov  si,          [BALL_POSITION] ; Move ball's memory address into si
    mov  word[es:si], 0x072A          ; Draw the ball
    popa                              ; Pop registers
ret ; Return


; -----------------------------------------------------------------------------
; Clear the Screen
; -----------------------------------------------------------------------------
clear_screen: 
    pusha; ; Push registers
    push 0xb800     ; Push video memory segment
    pop  es         ; Pop segment into es
    mov  cx, 25*80  ; Initialize loop counter (number of characters on screen)
    mov  ax, 0x0720 ; Create a space character with attribute
    mov  si, 0      ; Initialize memory address
    clear_screen_loop: 
        mov  [es:si], ax       ; Write space character to video memory
        add  si,      2        ; Increment memory address
        loop clear_screen_loop ; Loop until cx is 0
    popa ; Pop registers
    ret  ; Return

; -----------------------------------------------------------------------------
; Delay Function
; -----------------------------------------------------------------------------
DELAY_FUNCTION: 
    pusha        ; Push registers
    mov   bp, sp ; Move stack pointer into bp
    mov   cx, 2  ; Initialize outer loop counter
delay_loop1:
    push cx         ; Push outer loop counter
    mov  cx, 0xFFFF ; Initialize inner loop counter
delay_loop2:
    loop delay_loop2 ; Inner loop, decrements cx until 0
    pop  cx          ; Pop outer loop counter
    loop delay_loop1 ; Outer loop, decrements cx until 0
    popa             ; Pop registers
ret ; Return

; -----------------------------------------------------------------------------
; Move Player 1's Paddle Left
; -----------------------------------------------------------------------------
MOVE_PADDLE_P1_LEFT: 
    pusha; ; Push registers
    mov  ax,                [P1_POSITION] ; Move Player 1's paddle position into ax
    sub  ax,                2             ; Decrement position by 2 bytes (one character)
    cmp  ax,                0             ; Compare position to 0
    jl   do_nothing                       ; Jump if less than 0 (at left edge)
    mov  ax,                [P1_POSITION] ; Move Player 1's paddle position into ax
    add  ax,                20*2          ; Calculate memory address of last character of the paddle
    mov  si,                ax            ; Move the address into si
    push 0xb800                           ; Push video memory segment
    pop  es                               ; Pop segment into es
    mov  word[es:si],       0x0720        ; Erase the last character of the paddle
    sub  word[P1_POSITION], 2             ; Decrement the paddle's position
    do_nothing:
    popa                                  ; Pop registers
    ret                                   ; Return

; -----------------------------------------------------------------------------
; Move Player 2's Paddle Left
; -----------------------------------------------------------------------------
MOVE_PADDLE_P2_LEFT: 
    pusha; ; Push registers
    mov  ax,                [P2_POSITION] ; Move Player 2's paddle position into ax
    sub  ax,                2             ; Decrement position by 2 bytes (one character)
    cmp  ax,                (160*23)      ; Compare position to the bottom edge
    jl   do_nothing                       ; Jump if less than 0 (at left edge)
    mov  ax,                [P2_POSITION] ; Move Player 2's paddle position into ax
    add  ax,                20*2          ; Calculate memory address of last character of the paddle
    mov  si,                ax            ; Move the address into si
    push 0xb800                           ; Push video memory segment
    pop  es                               ; Pop segment into es
    mov  word[es:si],       0x0720        ; Erase the last character of the paddle
    sub  word[P2_POSITION], 2             ; Decrement the paddle's position
    popa                                  ; Pop registers
    ret                                   ; Return

; -----------------------------------------------------------------------------
; Move Player 1's Paddle Right
; -----------------------------------------------------------------------------
MOVE_PADDLE_P1_RIGHT: 
    pusha                                  ; Push registers
    mov   ax,                [P1_POSITION] ; Move Player 1's paddle position into ax
    add   ax,                40            ; Add paddle width
    add   ax,                2             ; Increment position by 2 bytes (one character)
    cmp   ax,                160           ; Compare position to the right edge
    jg    do_nothing                       ; Jump if greater than 160
    mov   ax,                [P1_POSITION] ; Move Player 1's paddle position into ax
    mov   si,                ax            ; Move the address into si
    push  0xb800                           ; Push video memory segment
    pop   es                               ; Pop segment into es
    mov   word[es:si],       0x0720        ; Erase the first character of the paddle
    add   word[P1_POSITION], 2             ; Increment the paddle's position
    popa                                   ; Pop registers
    ret                                    ; Return

; -----------------------------------------------------------------------------
; Move Player 2's Paddle Right
; -----------------------------------------------------------------------------
MOVE_PADDLE_P2_RIGHT: 
    pusha                                  ; Push registers
    mov   ax,                [P2_POSITION] ; Move Player 2's paddle position into ax
    add   ax,                40            ; Add paddle width
    add   ax,                2             ; Increment position by 2 bytes (one character)
    cmp   ax,                24*160        ; Compare position to the right edge
    jg    do_nothing                       ; Jump if greater than 24*160
    mov   ax,                [P2_POSITION] ; Move Player 2's paddle position into ax
    mov   si,                ax            ; Move the address into si
    push  0xb800                           ; Push video memory segment
    pop   es                               ; Pop segment into es
    mov   word[es:si],       0x0720        ; Erase the first character of the paddle
    add   word[P2_POSITION], 2             ; Increment the paddle's position
    popa                                   ; Pop registers
    ret                                    ; Return

; -----------------------------------------------------------------------------
; Check Score and Determine Winner
; -----------------------------------------------------------------------------
CHECK_SCORE:
    pusha                                      ; Push registers
    mov   ax,                  [WINNING_SCORE] ; Move winning score into ax
    cmp   word[PLAYER1_SCORE], ax              ; Compare Player 1's score to winning score
    je    P1_wins                              ; Jump if Player 1 wins
    push  0x000B                               ; Push attribute for Player 1's score
    push  24*160                               ; Push Y coordinate for Player 1's score
    push  word[PLAYER1_SCORE]                  ; Push Player 1's score
    call  printnum                             ; Call print number subroutine
    cmp   word[PLAYER2_SCORE], ax              ; Compare Player 2's score to winning score
    je    P2_wins                              ; Jump if Player 2 wins
    push  0x000D                               ; Push attribute for Player 2's score
    push  24*160 + 79*2                        ; Push Y coordinate for Player 2's score
    push  word[PLAYER2_SCORE]                  ; Push Player 2's score
    call  printnum                             ; Call print number subroutine
    NO_ONE_WON: 
        popa ; Pop registers
        ret  ; Return
P1_wins: 
    mov  word[WINNER], 0x0000 ; Set winner to Player 1
    popa                      ; Pop registers
    ret                       ; Return
P2_wins:
    mov  word[WINNER], 0x0001 ; Set winner to Player 2
    popa                      ; Pop registers
    ret; ; Return


; -----------------------------------------------------------------------------
; Timer Interrupt Service Routine (ISR)
; -----------------------------------------------------------------------------
TIMER_ISR: 
    pusha                        ; Push registers
    call  PADDLE_COLLISION_CHECK ; Check for paddle collisions
    call  COLLISION_CHECK        ; Check for wall collisions
    call  MOVE_BALL              ; Move the ball
    call  DRAW_PADDLE_P1         ; Draw Player 1's paddle
    call  DRAW_PADDLE_P2         ; Draw Player 2's paddle
    call  CHECK_SCORE            ; Check the score
    mov   al,   0x20             ; Send EOI (End of Interrupt) signal to the 8259A PIC
    out   0x20, al               ; Send EOI signal
    popa                         ; Pop registers
    iret; ; Return from interrupt


; -----------------------------------------------------------------------------
; Keyboard ISR for Start Screen
; -----------------------------------------------------------------------------
KBISR_FOR_START_SCREEN: 
    pusha            ; Push registers
    in    al, 0x60   ; Read keyboard scancode from port 60h
    jnz   start_game ; Jump if a key was pressed
    jmp   nfatall    ; Jump to nfatall
start_game: 
    mov byte[GAME_FLAG], 0x01 ; Set game started flag
nfatall: 
    mov  al,   0x20 ; Send EOI (End of Interrupt) signal to the 8259A PIC
    out  0x20, al   ; Send EOI signal
    popa            ; Pop registers
iret ; Return from interrupt



; -----------------------------------------------------------------------------
; Keyboard ISR for Gameplay
; -----------------------------------------------------------------------------
KBISR_FOR_GAMEPLAY: 
    pusha          ; Push registers
    in    al, 0x60 ; Read keyboard scancode from port 60h

    cmp word[CURRENT_PLAYER], 0x0000 ; Check whose turn it is
    je  FIRST_PLAYER                 ; Jump if it is Player 1's turn
    jmp SECOND_PLAYER                ; Jump if it is Player 2's turn

FIRST_PLAYER:
    cmp  al, 0x4B            ; Check for left arrow key press
    jne  move_right_p1       ; Jump if not left arrow key
    call MOVE_PADDLE_P1_LEFT ; Move Player 1's paddle left
    move_right_p1: 
        cmp  al, 0x4D             ; Check for right arrow key press
        jne  not_found            ; Jump if not right arrow key
        call MOVE_PADDLE_P1_RIGHT ; Move Player 1's paddle right
    jmp not_found ; Jump to not_found
SECOND_PLAYER:
    cmp  al, 0x4B            ; Check for left arrow key press
    jne  move_right_p2       ; Jump if not left arrow key
    call MOVE_PADDLE_P2_LEFT ; Move Player 2's paddle left
    move_right_p2:
        cmp  al, 0x4D             ; Check for right arrow key press
        jne  not_found            ; Jump if not right arrow key
        call MOVE_PADDLE_P2_RIGHT ; Move Player 2's paddle right
not_found:
    mov  al,   0x20 ; Send EOI (End of Interrupt) signal to the 8259A PIC
    out  0x20, al   ; Send EOI signal
    popa            ; Pop registers
iret ; Return from interrupt


; -----------------------------------------------------------------------------
; Keyboard ISR for Game Over Screen
; -----------------------------------------------------------------------------
KBISR_FOR_GAME_OVER_SCREEN: 
    pusha          ; Push registers
    in    al, 0x60 ; Read keyboard scancode from port 60h
    cmp   al, 0x10 ; Check for 'Q' key press
    je    QUIT     ; Jump if 'Q' key pressed
    cmp   al, 0x13 ; Check for 'R' key press
    je    REPLAY   ; Jump if 'R' key pressed
    jmp   nf       ; Jump to nf
QUIT: 
    mov byte[QUIT_FLAG], 0x01 ; Set quit flag
    jmp nf                    ; Jump to nf
REPLAY: 
    mov byte[REPLAY_FLAG], 0x01 ; Set replay flag
    jmp nf                      ; Jump to nf
nf: 
    mov  al,   0x20 ; Send EOI (End of Interrupt) signal to the 8259A PIC
    out  0x20, al   ; Send EOI signal
    popa            ; Pop registers
    iret            ; Return from interrupt

; -----------------------------------------------------------------------------
; Program Start
; -----------------------------------------------------------------------------
start: 
    xor  ax,                     ax                     ; Clear ax register
    mov  es,                     ax                     ; Set es segment to 0 (data segment)
    cli                                                 ; Disable interrupts
    mov  ax,                     word[es:8*4]           ; Get the address of the original timer ISR
    mov  [ORIGINAL_TIMER_ISR],   ax                     ; Store the original timer ISR address
    mov  ax,                     word[es:8*4+2]         ; Get the segment of the original timer ISR
    mov  [ORIGINAL_TIMER_ISR+2], ax                     ; Store the segment of the original timer ISR address
    mov  ax,                     word[es:0x09*4]        ; Get the address of the original keyboard ISR
    mov  [ORIGINAL_KBISR],       ax                     ; Store the original keyboard ISR address
    mov  ax,                     word[es:0x09*4+2]      ; Get the segment of the original keyboard ISR
    mov  [ORIGINAL_KBISR+2],     ax                     ; Store the segment of the original keyboard ISR address
    mov  word[es:0x09*4],        KBISR_FOR_START_SCREEN ; Set the new keyboard ISR address
    mov  [es:0x09*4+2],          cs                     ; Set the new keyboard ISR segment
    sti                                                 ; Enable interrupts
    call clear_screen                                   ; Clear the screen
    call welcome_screen                                 ; Display the welcome screen
    call clear_screen                                   ; Clear the screen
    xor  ax,                     ax                     ; Clear ax register
    mov  es,                     ax                     ; Set es segment to 0 (data segment)
    cli                                                 ;

        mov word[es:0x08*4], TIMER_ISR ; Set the new timer ISR address
    mov word[es:0x08*4+2], cs                 ; Set the new timer ISR segment
    mov word[es:0x09*4],   KBISR_FOR_GAMEPLAY ; Set the new keyboard ISR address for gameplay
    mov word[es:0x09*4+2], cs                 ; Set the new keyboard ISR segment for gameplay
    sti                                       ; Enable interrupts

inf_loop: 
    cmp word[WINNER], 0x0000 ; Check if Player 1 has won
    jne CHECK_TWO            ; Jump if Player 1 has not won
    jmp game_over_screen     ; Jump to game over screen
    CHECK_TWO: 
    cmp word[WINNER], 0x0001 ; Check if Player 2 has won
    je  game_over_screen     ; Jump to game over screen if Player 2 has won
    jmp inf_loop             ; Jump back to inf_loop if no one has won


; -----------------------------------------------------------------------------
; Restore Timer ISR
; -----------------------------------------------------------------------------
restore_timer: 
    pusha                                            ; Push registers
    xor   ax,             ax                         ; Clear ax register
    mov   es,             ax                         ; Set es segment to 0 (data segment)
    cli                                              ; Disable interrupts
    mov   ax,             word[ORIGINAL_TIMER_ISR]   ; Restore the original timer ISR address
    mov   word[es:8*4],   ax                         ; Write the original timer ISR address to the interrupt vector table
    mov   ax,             word[ORIGINAL_TIMER_ISR+2] ; Restore the original timer ISR segment
    mov   word[es:8*4+2], ax                         ; Write the original timer ISR segment to the interrupt vector table
    sti                                              ; Enable interrupts
    popa                                             ; Pop registers
    ret; ; Return


; -----------------------------------------------------------------------------
; Restore Keyboard ISR
; -----------------------------------------------------------------------------
restore_kb: 
    pusha                                        ; Push registers
    xor   ax,             ax                     ; Clear ax register
    mov   es,             ax                     ; Set es segment to 0 (data segment)
    cli                                          ; Disable interrupts
    mov   ax,             word[ORIGINAL_KBISR]   ; Restore the original keyboard ISR address
    mov   word[es:9*4],   ax                     ; Write the original keyboard ISR address to the interrupt vector table
    mov   ax,             word[ORIGINAL_KBISR+2] ; Restore the original keyboard ISR segment
    mov   word[es:9*4+2], ax                     ; Write the original keyboard ISR segment to the interrupt vector table
    sti                                          ; Enable interrupts
    popa                                         ; Pop registers
    ret; ; Return


; -----------------------------------------------------------------------------
; Print Number Subroutine
; -----------------------------------------------------------------------------
printnum:    
    push bp         ; Push bp onto the stack
    mov  bp, sp     ; Move sp into bp (stack frame setup)
    push es         ; Push es onto the stack
    push ax         ; Push ax onto the stack
    push bx         ; Push bx onto the stack
    push cx         ; Push cx onto the stack
    push dx         ; Push dx onto the stack
    push di         ; Push di onto the stack
    mov  ax, 0xb800 ; Set ax to video memory segment
    mov  es, ax     ; Move ax into es
    mov  ax, [bp+4] ; Load number to be printed into ax
    mov  bx, 10     ; Set bx to 10 (base 10 for division)
    mov  cx, 0      ; Initialize digit counter


nextdigit: 
    mov  dx,      0      ; Clear dx (high word of dividend)
    div  bx              ; Divide ax by bx (ax = quotient, dx = remainder)
    add  dl,      0x30   ; Convert remainder (digit) to ASCII
    push dx              ; Push ASCII digit onto the stack
    inc  cx              ; Increment digit counter
    cmp  ax,      0      ; Compare quotient to 0
    jnz  nextdigit       ; Jump if quotient is not 0 (more digits to process)
    mov  di,      [bp+6] ; Move screen position into di
    nextpos:      
    pop  dx              ; Pop ASCII digit from the stack
    mov  dh,      [bp+8] ; Get attribute from stack
    mov  [es:di], dx     ; Write character and attribute to video memory
    add  di,      2      ; Move to the next screen position
    loop nextpos         ; Loop until cx is 0
    pop  di              ; Pop di from stack
    pop  dx              ; Pop dx from stack
    pop  cx              ; Pop cx from stack
    pop  bx              ; Pop bx from stack
    pop  ax              ; Pop ax from stack
    pop  es              ; Pop es from stack
    pop  bp              ; Pop bp from stack
ret 6 ; Return from subroutine, removing parameters from stack


; -----------------------------------------------------------------------------
; Game Over Screen
; -----------------------------------------------------------------------------
game_over_screen:
    pusha; ; Push registers
    push 0xb800     ; Push video memory segment
    pop  es         ; Pop segment into es
    mov  cx, 25*80  ; Initialize loop counter (number of characters on screen)
    mov  ax, 0x6020 ; Create a space character with attribute
    mov  si, 0      ; Initialize memory address
    cls:
        mov  [es:si], ax ; Write space character to video memory
        add  si,      2  ; Increment memory address
        loop cls         ; Loop until cx is 0
    popa ; Pop registers

    call restore_timer ; Restore timer ISR
    call restore_kb    ; Restore keyboard ISR
    
    cmp word[WINNER], 0x0000 ; Check if Player 1 won
    je  DISPLAY_P1_won       ; Jump if Player 1 won
    jmp DISPLAY_P2_won       ; Jump if Player 2 won

DISPLAY_P1_won: 
    push 26         ; Push string length
    push 11         ; Push Y coordinate
    push 0x0067     ; Push attribute
    push P1_WON     ; Push message address
    push 23         ; Push X coordinate
    call printstr   ; Call print string subroutine
    jmp  OTHER_INFO ; Jump to OTHER_INFO

DISPLAY_P2_won:
    push 26       ; Push string length
    push 11       ; Push Y coordinate
    push 0x0067   ; Push attribute
    push P2_WON   ; Push message address
    push 23       ; Push X coordinate
    call printstr ; Call print string subroutine

OTHER_INFO:
; ----- PRINTING OTHER INFO -----
    push 29         ; Push string length
    push 12         ; Push Y coordinate
    push 0x0067     ; Push attribute
    push replay_msg ; Push message address
    push 17         ; Push X coordinate
    call printstr   ; Call print string subroutine

    push 29       ; Push string length
    push 13       ; Push Y coordinate
    push 0x0067   ; Push attribute
    push quit_msg ; Push message address
    push 15       ; Push X coordinate
    call printstr ; Call print string subroutine
    
    push 10*160 + 24*2 ; Push memory address for lines
    call print_lines   ; Call print lines subroutine

    cli                                            ; Disable interrupts
    xor ax,             ax                         ; Clear ax register
    mov es,             ax                         ; Set es segment to 0 (data segment)
    mov word[es:9*4],   KBISR_FOR_GAME_OVER_SCREEN ; Set keyboard ISR for game over screen
    mov word[es:9*4+2], cs                         ; Set segment for keyboard ISR
    sti                                            ; Enable interrupts


    push 5        ; Push string length
    push 4        ; Push Y coordinate
    push 0x00ec   ; Push attribute
    push go_1     ; Push message address
    push 63       ; Push X coordinate
    call printstr ; Call print string subroutine

    push 5        ; Push string length
    push 5        ; Push Y coordinate
    push 0x00ec   ; Push attribute
    push go_2     ; Push message address
    push 63       ; Push X coordinate
    call printstr ; Call print string subroutine

    push 5        ; Push string length
    push 6        ; Push Y coordinate
    push 0x00ec   ; Push attribute
    push go_3     ; Push message address
    push 63       ; Push X coordinate
    call printstr ; Call print string subroutine

    push 5        ; Push string length
    push 7        ; Push Y coordinate
    push 0x00ec   ; Push attribute
    push go_4     ; Push message address
    push 63       ; Push X coordinate
    call printstr ; Call print string subroutine

    push 5        ; Push string length
    push 8        ; Push Y coordinate
    push 0x00ec   ; Push attribute
    push go_5     ; Push message address
    push 63       ; Push X coordinate
    call printstr ; Call print string subroutine

    push 5        ; Push string length
    push 9        ; Push Y coordinate
    push 0x00ec   ; Push attribute
    push go_6     ; Push message address
    push 63       ; Push X coordinate
    call printstr ; Call print string subroutine

never_ending_check_loop:
    cmp byte[QUIT_FLAG],   0x01 ; Check if quit flag is set
    je  quit_game               ; Jump to quit_game if quit flag is set
    cmp byte[REPLAY_FLAG], 0x01 ; Check if replay flag is set
    je  replay_game             ; Jump to replay_game if replay flag is set
    jmp never_ending_check_loop ; Jump back to never_ending_check_loop


quit_game: 
    call restore_timer ; Restore timer ISR
    call restore_kb    ; Restore keyboard ISR
    call clear_screen  ; Clear the screen
    mov  ax, 0x4c00    ; DOS function to exit program
    int  0x21          ; Call DOS interrupt

replay_game: 
    call restore_timer                           ; Restore timer ISR
    call restore_kb                              ; Restore keyboard ISR
    mov  word[P1_POSITION],      30*2            ; Reset Player 1's paddle position
    mov  word[P2_POSITION],      (160*23) + 30*2 ; Reset Player 2's paddle position
    mov  word[BALL_POSITION],    (160*22) + 40*2 ; Reset ball position
    mov  word[CURRENT_PLAYER],   0x0000          ; Reset current player
    mov  word[BALL_DIRECTION],   0x0000          ; Reset ball direction
    mov  word[PADDLE_COLLISION], 0x0000          ; Reset paddle collision flag
    mov  word[PLAYER1_SCORE],    0x0000          ; Reset Player 1's score
    mov  word[PLAYER2_SCORE],    0x0000          ; Reset Player 2's score
    mov  word[WINNER],           0x0002          ; Reset winner
    mov  byte[QUIT_FLAG],        0x00            ; Reset quit flag
    mov  byte[REPLAY_FLAG],      0x00            ; Reset replay flag
    jmp  start                                   ; Jump to start


; -----------------------------------------------------------------------------
; Print String Subroutine
; -----------------------------------------------------------------------------
printstr:    
    push bp           ; Push bp onto the stack
    mov  bp, sp       ; Move sp into bp (stack frame setup)
    push es           ; Push es onto the stack
    push ax           ; Push ax onto the stack
    push cx           ; Push cx onto the stack
    push si           ; Push si onto the stack
    push di           ; Push di onto the stack
    mov  ax, 0xb800   ; Set ax to video memory segment
    mov  es, ax       ; Move ax into es
    mov  al, 80       ; Load number of columns per row into al
    mul  byte [bp+10] ; Multiply al by y coordinate (Y*80)
    add  ax, [bp+12]  ; Add x coordinate to ax
    shl  ax, 1        ; Multiply ax by 2 (bytes per character)
    mov  di, ax       ; Move result into di (destination address)
    mov  si, [bp+6]   ; Move string address into si (source address)
    mov  cx, [bp+4]   ; Move string length into cx
    mov  ah, [bp+8]   ; Move attribute into ah
    cld               ; Clear direction flag (auto-increment mode)
nextchar: 
    lodsb          ; Load next character from si into al
    stosw          ; Store al and ah (character and attribute) to es:di
    loop  nextchar ; Loop until cx is 0
    pop   di       ; Pop di from stack
    pop   si       ; Pop si from stack
    pop   cx       ; Pop cx from stack
    pop   ax       ; Pop ax from stack
    pop   es       ; Pop es from stack
    pop   bp       ; Pop bp from stack
    ret   10       ; Return from subroutine, removing parameters from stack


; -----------------------------------------------------------------------------
; Print Horizontal Lines Subroutine
; -----------------------------------------------------------------------------
print_lines:
    pusha                       ; Push registers
    mov   bp, sp                ; Move sp into bp (stack frame setup)
    push  0xb800                ; Push video memory segment
    pop   es                    ; Pop segment into es
    mov   si, 14*160 + 25*2 - 2 ; Calculate starting address for upper line
    mov   di, 10*160 + 25*2 - 2 ; Calculate starting address for lower line
    mov   cx, 27                ; Set loop counter (number of lines)
    print_loop_hl: 
        mov word[es:si], 0x672d ; Write character and attribute to video memory for upper line
        mov word[es:di], 0x672d ; Write character and attribute to video memory for lower line
        add di,          2      ; Increment lower line address
        add si,          2      ; Increment upper line address
        sub cx,          1      ; Decrement loop counter
        cmp cx,          0      ; Compare loop counter to 0
        jle end_it              ; Jump if less than or equal to 0 (loop finished)
        jmp print_loop_hl       ; Jump back to print_loop_hl
    end_it: 
    popa ; Pop registers
ret; ; Return