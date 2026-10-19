ORG 0000H         ; Start of code memory

START:
    MOV R0, #00H  ; R0 will be used as offset (0 to 9)
    MOV R2, #0AH  ; R2 = 10 bytes to copy

TRANSFER_LOOP:
    ; Load source address = 8000H + R0
    MOV DPH, #08H   ; Load DPH for source address (high byte 0800H to 0809H)
    MOV DPL, R0     ; Load DPL with the R0 value (0 to 9 for 8000H to 8009H)
    MOVX A, @DPTR   ; Read from external memory at 8000H + offset
    MOV R3, A       ; Save data temporarily in R3

    ; Load destination address = 9000H + R0
    MOV DPH, #09H   ; Load DPH for destination address (9000H to 9009H)
    MOV DPL, R0     ; Load DPL with the R0 value (0 to 9 for 9000H to 9009H)
    MOV A, R3       ; Load A with the data read from source memory
    MOVX @DPTR, A   ; Write data to external memory at 9000H + offset

    INC R0          ; Move to the next byte (increment R0)
    DJNZ R2, TRANSFER_LOOP  ; Decrement R2, loop until 10 bytes are copied

    SJMP $          ; Infinite loop to stop program here

END                 ; End of program
