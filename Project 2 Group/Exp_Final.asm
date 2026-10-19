// Transfer 10 bytes from external memory 8000h to 9000h
ORG     0000H            ; Program start

MOV DPTR, #8000H        ; Source start address (8000H)
MOV R2, #0AH            ; Counter for 10 bytes (10 bytes to transfer)

MOV R3, #90H            ; Destination high byte (9000H)
MOV R4, #00H            ; Destination low byte (starting from 9000H)

LOOP:
    MOVX A, @DPTR       ; Read byte from source (8000H + offset)

    ; Set DPTR to the destination address (9000H + offset)
    MOV DPL, R4         ; Destination low byte (incrementing from 00H upwards)
    MOV DPH, R3         ; Destination high byte (always 90H)

    MOVX @DPTR, A       ; Write byte to destination (9000H + offset)

    INC DPTR            ; Move to next source address (incrementing from 8000H upwards)

    INC R4              ; Move to next destination address (9000H, 9001H, etc.)
    DJNZ R2, LOOP       ; Repeat for 10 bytes (decrease R2 by 1 and repeat if not zero)

END

