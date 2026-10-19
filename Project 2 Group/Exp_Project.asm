// Transfer 10 bytes from external memory 8000h to 9000h
ORG		0000H
MOV DPTR, #8000H   ; Source start address
MOV R2, #0AH       ; Counter for 10 bytes

MOV R3, #90H       ; Destination high byte (9000H)
MOV R4, #00H       ; Destination low byte

LOOP:
	MOVX A, @DPTR     ; Read byte from source (8000H+)
	
	; Set DPTR to destination address before writing
	MOV DPL, R4       ; Destination low byte
	MOV DPH, R3       ; Destination high byte
	MOVX @DPTR, A     ; Write byte to destination (9000H+)
	
	; Restore DPTR to point to next source location
	MOV DPTR, #8000H  ; Reload base address
	ADD A, R2         ; Adjust for loop count (optional improvement: use another register to hold offset)
	; Instead, better approach:
	INC DPTR          ; Move to next source address

	INC R4            ; Move to next destination address
	DJNZ R2, LOOP     ; Repeat 10 times

END
