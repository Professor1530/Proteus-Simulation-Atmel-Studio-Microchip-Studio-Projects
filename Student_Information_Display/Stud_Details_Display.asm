ORG 000H

; LCD Control Pins
RS EQU P3.0
EN EQU P3.1

; Keypad Pins
ROW1 EQU P2.0
ROW2 EQU P2.1
ROW3 EQU P2.2
ROW4 EQU P2.3
COL1 EQU P2.4
COL2 EQU P2.5
COL3 EQU P2.6

; Variables
LAST_KEY 	EQU 30H        
PRESS_COUNT EQU 31H     
TIMER 		EQU 32H           
CURSOR_POS 	EQU 33H      
ALPHA_MODE 	EQU 20H.0    

MAIN:
    MOV PRESS_COUNT, #0
    MOV LAST_KEY, #0FFH  
    MOV CURSOR_POS, #0
    CLR ALPHA_MODE       
    CALL LCD_INIT
    CALL CLEAR_LCD
    MOV DPTR, #WELCOME_MSG
    CALL LCD_DISPLAY_STRING

LOOP:
    CALL KEYPAD_SCAN
    CALL CHECK_TIMER     
    JMP LOOP


CHECK_TIMER:
    INC TIMER
    MOV A, TIMER
    CJNE A, #50, TIMER_NOT_EXPIRED  
    
 
    MOV PRESS_COUNT, #0
    MOV LAST_KEY, #0FFH
    MOV TIMER, #0

TIMER_NOT_EXPIRED:
    RET

LCD_INIT:
    MOV A, #38H          
    CALL LCD_CMD
    MOV A, #0CH          
    CALL LCD_CMD
    MOV A, #06H          
    CALL LCD_CMD
    RET

LCD_CMD:
    MOV P1, A
    CLR RS
    SETB EN
    CALL DELAY_SHORT
    CLR EN
    CALL DELAY_SHORT
    RET

LCD_DATA:
    MOV P1, A
    SETB RS
    SETB EN
    CALL DELAY_SHORT
    CLR EN
    CALL DELAY_SHORT
    
    ; Update cursor position
    INC CURSOR_POS
    MOV A, CURSOR_POS
    CJNE A, #16, NO_NEWLINE
    MOV A, #0C0H         ; Move to second line
    CALL LCD_CMD
NO_NEWLINE:
    RET

CLEAR_LCD:
    MOV A, #01H
    CALL LCD_CMD
    MOV CURSOR_POS, #0
    CALL DELAY_200MS
    RET

LCD_DISPLAY_STRING:
    CLR A
    MOVC A, @A+DPTR
    JZ STRING_END
    CALL LCD_DATA
    INC DPTR
    SJMP LCD_DISPLAY_STRING
STRING_END:
    RET


KEYPAD_SCAN:
    ; Scan Column 1
    CLR COL1
    SETB COL2
    SETB COL3
    CALL CHECK_COL1
    SETB COL1
    
    ; Scan Column 2
    SETB COL1
    CLR COL2
    SETB COL3
    CALL CHECK_COL2
    SETB COL2
    
    ; Scan Column 3
    SETB COL1
    SETB COL2
    CLR COL3
    CALL CHECK_COL3
    SETB COL3
    RET

CHECK_COL1:
    JB ROW1, SKIP_ROW1_C1
    CALL DELAY_20MS
    JB ROW1, SKIP_ROW1_C1
    MOV A, #1
    CALL PROCESS_KEY
    JNB ROW1, $
SKIP_ROW1_C1:

    JB ROW2, SKIP_ROW2_C1
    CALL DELAY_20MS
    JB ROW2, SKIP_ROW2_C1
    MOV A, #4
    CALL PROCESS_KEY
    JNB ROW2, $
SKIP_ROW2_C1:

    JB ROW3, SKIP_ROW3_C1
    CALL DELAY_20MS
    JB ROW3, SKIP_ROW3_C1
    MOV A, #7
    CALL PROCESS_KEY
    JNB ROW3, $
SKIP_ROW3_C1:

    JB ROW4, SKIP_ROW4_C1
    CALL DELAY_20MS
    JB ROW4, SKIP_ROW4_C1
    
    SETB ALPHA_MODE
    CALL CLEAR_LCD
    MOV DPTR, #ALPHA_MSG
    CALL LCD_DISPLAY_STRING
    JNB ROW4, $
SKIP_ROW4_C1:
    RET

CHECK_COL2:
    JB ROW1, SKIP_ROW1_C2
    CALL DELAY_20MS
    JB ROW1, SKIP_ROW1_C2
    MOV A, #2
    CALL PROCESS_KEY
    JNB ROW1, $
SKIP_ROW1_C2:

    JB ROW2, SKIP_ROW2_C2
    CALL DELAY_20MS
    JB ROW2, SKIP_ROW2_C2
    MOV A, #5
    CALL PROCESS_KEY
    JNB ROW2, $
SKIP_ROW2_C2:

    JB ROW3, SKIP_ROW3_C2
    CALL DELAY_20MS
    JB ROW3, SKIP_ROW3_C2
    MOV A, #8
    CALL PROCESS_KEY
    JNB ROW3, $
SKIP_ROW3_C2:

    JB ROW4, SKIP_ROW4_C2
    CALL DELAY_20MS
    JB ROW4, SKIP_ROW4_C2
    MOV A, #0
    CALL PROCESS_KEY
    JNB ROW4, $
SKIP_ROW4_C2:
    RET

CHECK_COL3:
    JB ROW1, SKIP_ROW1_C3
    CALL DELAY_20MS
    JB ROW1, SKIP_ROW1_C3
    MOV A, #3
    CALL PROCESS_KEY
    JNB ROW1, $
SKIP_ROW1_C3:

    JB ROW2, SKIP_ROW2_C3
    CALL DELAY_20MS
    JB ROW2, SKIP_ROW2_C3
    MOV A, #6
    CALL PROCESS_KEY
    JNB ROW2, $
SKIP_ROW2_C3:

    JB ROW3, SKIP_ROW3_C3
    CALL DELAY_20MS
    JB ROW3, SKIP_ROW3_C3
    MOV A, #9
    CALL PROCESS_KEY
    JNB ROW3, $
SKIP_ROW3_C3:

    JB ROW4, SKIP_ROW4_C3
    CALL DELAY_20MS
    JB ROW4, SKIP_ROW4_C3
    ; '#' key pressed - return to number mode
    CLR ALPHA_MODE
    CALL CLEAR_LCD
    MOV DPTR, #NUMBER_MSG
    CALL LCD_DISPLAY_STRING
    JNB ROW4, $
SKIP_ROW4_C3:
    RET

; ========== KEY PROCESSING ==========
PROCESS_KEY:
    ; A contains key number (0-9)
    CJNE A, LAST_KEY, NEW_KEY
    
    ; Same key pressed again - only process in alphabet mode
    JB ALPHA_MODE, PROCESS_ALPHA_REPEAT
    
    ; In number mode, just display the number again
    MOV A, LAST_KEY
    ADD A, #'0'          ; Convert to ASCII
    CALL LCD_DATA
    JMP KEY_PROCESS_DONE

PROCESS_ALPHA_REPEAT:
    ; Only in alphabet mode - handle multi-tap
    INC PRESS_COUNT
    MOV TIMER, #0
    
    ; Delete previous character
    MOV A, #10H          ; Backspace command
    CALL LCD_CMD
    DEC CURSOR_POS
    
    ; Get the new character to display
    MOV A, LAST_KEY
    CALL GET_ALPHA_CHAR
    CALL LCD_DATA
    JMP KEY_PROCESS_DONE

NEW_KEY:
    ; Different key pressed
    MOV PRESS_COUNT, #1
    MOV LAST_KEY, A
    MOV TIMER, #0
    
    ; Check if we're in alphabet mode
    JB ALPHA_MODE, PROCESS_ALPHA_NEW
    
    ; Number mode processing - just display the number
    MOV A, LAST_KEY
    ADD A, #'0'          ; Convert to ASCII
    CALL LCD_DATA
    JMP KEY_PROCESS_DONE

PROCESS_ALPHA_NEW:
    ; New key pressed in alphabet mode
    MOV A, LAST_KEY
    CALL GET_ALPHA_CHAR
    CALL LCD_DATA

KEY_PROCESS_DONE:
    RET

; ========== ALPHABET CHARACTER SELECTION ==========
GET_ALPHA_CHAR:
    ; Input: A = key number (0-9)
    ; Output: A = character to display
    
    ; Key 0 - space in alphabet mode, '0' in number mode
    CJNE A, #0, NOT_KEY0_ALPHA
    MOV A, #' '          ; Space character
    RET

NOT_KEY0_ALPHA:
    ; Key 1 - not used in alphabet mode
    CJNE A, #1, NOT_KEY1_ALPHA
    MOV A, #0            ; Null character (won't be displayed)
    RET

NOT_KEY1_ALPHA:
    ; Key 2 (ABC)
    CJNE A, #2, NOT_KEY2_ALPHA
    MOV DPTR, #KEY2_CHARS
    SJMP GET_CHAR_FROM_TABLE

NOT_KEY2_ALPHA:
    ; Key 3 (DEF)
    CJNE A, #3, NOT_KEY3_ALPHA
    MOV DPTR, #KEY3_CHARS
    SJMP GET_CHAR_FROM_TABLE

NOT_KEY3_ALPHA:
    ; Key 4 (GHI)
    CJNE A, #4, NOT_KEY4_ALPHA
    MOV DPTR, #KEY4_CHARS
    SJMP GET_CHAR_FROM_TABLE

NOT_KEY4_ALPHA:
    ; Key 5 (JKL)
    CJNE A, #5, NOT_KEY5_ALPHA
    MOV DPTR, #KEY5_CHARS
    SJMP GET_CHAR_FROM_TABLE

NOT_KEY5_ALPHA:
    ; Key 6 (MNO)
    CJNE A, #6, NOT_KEY6_ALPHA
    MOV DPTR, #KEY6_CHARS
    SJMP GET_CHAR_FROM_TABLE

NOT_KEY6_ALPHA:
    ; Key 7 (PQRS)
    CJNE A, #7, NOT_KEY7_ALPHA
    MOV DPTR, #KEY7_CHARS
    SJMP GET_CHAR_FROM_TABLE

NOT_KEY7_ALPHA:
    ; Key 8 (TUV)
    CJNE A, #8, NOT_KEY8_ALPHA
    MOV DPTR, #KEY8_CHARS
    SJMP GET_CHAR_FROM_TABLE

NOT_KEY8_ALPHA:
    ; Key 9 (WXYZ)
    MOV DPTR, #KEY9_CHARS

GET_CHAR_FROM_TABLE:
    ; Calculate which character to show based on press count
    MOV A, PRESS_COUNT
    DEC A                ; Adjust for 0-based index
    
    ; Handle wrap-around for each key
    MOV R7, A            ; Save press count
    
    ; Get max presses for this key
    MOV A, LAST_KEY
    CJNE A, #7, CHECK_KEY9
    MOV A, #4            ; Key 7 has 4 letters (PQRS)
    SJMP SET_MAX_PRESSES
CHECK_KEY9:
    CJNE A, #9, DEFAULT_MAX
    MOV A, #4            ; Key 9 has 4 letters (WXYZ)
    SJMP SET_MAX_PRESSES
DEFAULT_MAX:
    MOV A, #3            ; Other keys have 3 letters
SET_MAX_PRESSES:
    MOV B, A
    
    
    MOV A, R7
    DIV AB              
    MOV A, B             
    ; Get the character
    MOVC A, @A+DPTR
    RET


DELAY_SHORT:
    MOV R0, #10
    DJNZ R0, $
    RET

DELAY_20MS:
    MOV R1, #40
DELAY_20MS_LOOP:
    MOV R0, #250
    DJNZ R0, $
    DJNZ R1, DELAY_20MS_LOOP
    RET

DELAY_200MS:
    MOV R2, #50
DELAY_200MS_LOOP:
    CALL DELAY_20MS
    DJNZ R2, DELAY_200MS_LOOP
    RET

WELCOME_MSG: DB "Fill Stud Details (*)",0
NUMBER_MSG: DB "Enter Stud No:",0
ALPHA_MSG: DB "Enter Surname:",0
PROMPT4: DB "Enter Sub Code:",0
		
KEY2_CHARS: DB 'A','B','C'
KEY3_CHARS: DB 'D','E','F'
KEY4_CHARS: DB 'G','H','I'
KEY5_CHARS: DB 'J','K','L'
KEY6_CHARS: DB 'M','N','O'
KEY7_CHARS: DB 'P','Q','R','S'
KEY8_CHARS: DB 'T','U','V'
KEY9_CHARS: DB 'W','X','Y','Z'

END