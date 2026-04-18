	ORG 0X00
	GOTO INICIO
	ORG 0x4
	RETFIE
INICIO:
	        CLRW
	        MOVLW b'00001000' ; valor 8
	        MOVWF 0x06f
	LOOP:
	        DECFSZ 0x06f,1 ; decrementa até zero
	        GOTO SOMA
			GOTO FINAL
	SOMA:
			ADDWF 0x06f,0
			GOTO LOOP
	FINAL:
			GOTO FINAL
	        END


