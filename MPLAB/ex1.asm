; ==========================================
; Trabalho de Laboratório de Arquitetura de Computadores
; Integrantes:
; - Rafael Alves Faria
; - Gabriel Alves Faria
; ==========================================
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       BOT?O E LED - EX1                         *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERS?O: 1.0                             DATA: 10/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRI??O DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  SISTEMA MUITO SIMPLES PARA REPRESENTAR O ESTADO DE             *
;*  UM BOT?O ATRAV?S DE UM LED.                                    *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI??ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>		;ARQUIVO PADR?O MICROCHIP PARA 16F628A
	__CONFIG  _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _XT_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA??O DE MEM?RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI??O DE COMANDOS DE USU?RIO PARA ALTERA??O DA P?GINA DE MEM?RIA

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM?RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM?RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI?VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI??O DOS NOMES E ENDERE?OS DE TODAS AS VARI?VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20		;ENDERE?O INICIAL DA MEM?RIA DE
				;USU?RIO

		W_TEMP		;REGISTRADORES TEMPOR?RIOS PARA
		STATUS_TEMP	;INTERRUP??ES
				;ESTAS VARI?VEIS NEM SER?O UTI-
				;LIZADAS
	ENDC			;FIM DO BLOCO DE MEM?RIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI??O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI??O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI??O DE TODOS OS PINOS QUE SER?O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB?M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	BOTAO	PORTA,2	;PORTA DO BOT?O
#DEFINE	BOTAO1	PORTA,3	
#DEFINE BOTAO2  PORTA,4
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA?DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI??O DE TODOS OS PINOS QUE SER?O UTILIZADOS COMO SA?DA
; RECOMENDAMOS TAMB?M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	LED	PORTB,0	;PORTA DO LED
#DEFINE	LED1 PORTB,1
#DEFINE LED2 PORTB,2
			

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00	;ENDERE?O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN?CIO DA INTERRUP??O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AS INTERRUP??ES N?O SER?O UTILIZADAS, POR ISSO PODEMOS SUBSTITUIR
; TODO O SISTEMA EXISTENTE NO ARQUIVO MODELO PELO APRESENTADO ABAIXO
; ESTE SISTEMA N?O ? OBRIGAT?RIO, MAS PODE EVITAR PROBLEMAS FUTUROS

	ORG	0x04		;ENDERE?O INICIAL DA INTERRUP??O
	RETFIE			;RETORNA DA INTERRUP??O

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK0			;ALTERA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA??O DO COMPARADOR ANAL?GICO

	CLRF	PORTA		;LIMPA O PORTA
	CLRF	PORTB		;LIMPA O PORTB


	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00011100'
	MOVWF	TRISA		;DEFINE RA2 COMO ENTRADA E DEMAIS
				;COMO SA?DAS
	MOVLW	B'00000000'
	MOVWF	TRISB		;DEFINE TODO O PORTB COMO SA?DA
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;PRESCALER 1:2 NO TMR0
				;PULL-UPS DESABILITADOS
				;AS DEMAIS CONFG. S?O IRRELEVANTES
	MOVLW	B'00000000'
	MOVWF	INTCON		;TODAS AS INTERRUP??ES DESLIGADAS
	BANK0			;RETORNA PARA O BANCO 0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA??O DAS VARI?VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	BTFSC	BOTAO		;O BOT?O EST? PRESSIONADO?
	GOTO	BOTAO_LIB	;N?O, ENT?O TRATA BOT?O LIBERADO
	GOTO	BOTAO_PRES	;SIM, ENT?O TRATA BOT?O PRESSIONADO

BOTAO_LIB
	BCF	LED		;APAGA O LED
	GOTO 	LOOP2		;RETORNA AO LOOP PRINCIPAL

BOTAO_PRES
	BSF	LED		;ACENDE O LED
	GOTO 	LOOP2		;RETORNA AO LOOP PRINCIPAL

;*********************************************************************************
;BOTAO 1 (APAGA O LED1 AO PRESSIONAR)

LOOP2

	BTFSC	BOTAO1		;O BOT?O EST? PRESSIONADO?
	GOTO	BOTAO1_LIB	;N?O, ENT?O TRATA BOT?O LIBERADO
	GOTO	BOTAO1_PRES	;SIM, ENT?O TRATA BOT?O PRESSIONADO

BOTAO1_LIB
	BCF	LED1		;APAGA O LED
	GOTO 	LOOP3		;RETORNA AO LOOP PRINCIPAL

BOTAO1_PRES
	BSF	LED1		;ACENDE O LED
	GOTO 	LOOP3		;RETORNA AO LOOP PRINCIPAL

;*********************************************************************************
;BOTAO 2 (ACENDE O LED2 AO PRESSIONAR)

LOOP3

	BTFSC	BOTAO2		;O BOT?O EST? PRESSIONADO?
	GOTO	BOTAO2_LIB	;N?O, ENT?O TRATA BOT?O LIBERADO
	GOTO	BOTAO2_PRES	;SIM, ENT?O TRATA BOT?O PRESSIONADO

BOTAO2_LIB
	BSF	LED2		;ACENDE O LED
	GOTO 	MAIN		;RETORNA AO LOOP PRINCIPAL

BOTAO2_PRES
	BCF	LED2		;APAGA O LED
	GOTO 	MAIN		;RETORNA AO LOOP PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGAT?RIO
