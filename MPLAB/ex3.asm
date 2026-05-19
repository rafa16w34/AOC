; ==========================================
; Trabalho de Laboratório de Arquitetura de Computadores
; Integrantes:
; - Rafael Alves Faria
; - Gabriel Alves Faria
; =========================
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       PISCA-PISCA - EX3                         *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERSÃO: 1.0                             DATA: 30/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRIÇÃO DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  PISCA-PISCA VARIÁVEL PARA DEMONSTRAR A IMPLEMENTAÇÃO DE        *
;*  DELAYS E A INVERSÃO DE PORTAS.                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>		;ARQUIVO PADRÃO MICROCHIP PARA 16F628A
	__CONFIG  _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _XT_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20		;ENDEREÇO INICIAL DA MEMÓRIA DE
				;USUÁRIO

		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA
		STATUS_TEMP	;INTERRUPÇÕES
				;ESTAS VARIÁVEIS NEM SERÃO UTI-
				;LIZADAS
		CONTADOR	;BASE DE TEMPO PARA A PISCADA
		FILTRO		;FILTRAGEM PARA O BOTÃO
		TEMPO1		;REGISTRADORES AUXILIARES DE TEMPO
		TEMPO2
		TEMPO3

	ENDC			;FIM DO BLOCO DE MEMÓRIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

MIN		EQU	.30 
MAX		EQU	.200 
STEP		EQU	.20
MULTIPLO	EQU	.5

;A CONSTANTE DISPLAY REPRESENTA O SÍMBOLO QUE APARECERÁ PISCANDO NO
;DISPLAY. 1=LED LIGADO E 0=LED DESLIGADO. A RELAÇÃO ENTRE BITS E
;SEGMENTOS É A SEGUINTE: 'EDC.BAFG'
;	   a
;     **********
;     *        *
;   f *        * b
;     *    g   *
;     **********
;     *        *
;   e *        * c
;     *    d   *
;     **********  *.

DISPLAY		EQU	B'10101011' ;(LETRA H)
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	BT1	PORTA,1	;BOTÃO 1 - INCREMENTA
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

#DEFINE	BT2	PORTA,2	;BOTÃO 2 - DECREMENTA
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00	;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AS INTERRUPÇÕES NÃO SERÃO UTILIZADAS, POR ISSO PODEMOS SUBSTITUIR
; TODO O SISTEMA EXISTENTE NO ARQUIVO MODELO PELO APRESENTADO ABAIXO
; ESTE SISTEMA NÃO É OBRIGATÓRIO, MAS PODE EVITAR PROBLEMAS FUTUROS

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
	RETFIE			;RETORNA DA INTERRUPÇÃO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        ROTINA DE DELAY                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA AGUARDA TANTOS MILISEGUNDOS QUANTO O VALOR PASSADO
; POR W. POR EXEMPLO, SE W = .200, ELA AGUARDARÁ 200 MILISEGUNDOS.
;
; O DELAY PRINCIPAL DURA 1ms, POIS POSSUI 5 INSTRUÇÕES (5us) E É
; RODADO 200 VEZES (TEMPO1). PORTANTO 200 * 5us = 1ms.
; O DELAY PRINCIPAL É RODADO TANTAS VEZES QUANTO FOR O VALOR DE
; TEMPO2, O QUAL É INICIADO COM O VALOR PASSADO EM W.


DELAY
	MOVWF	TEMPO2		;INICIA TEMPO 2 COM O VALOR
				;PASSADO EM W
DL1	
	MOVLW	.200
	MOVWF	TEMPO1

DL2				;ESTE DELAY DURA 1ms (5*200)
	NOP
	NOP
	DECFSZ	TEMPO1,F	;DECREMENTA TEMPO1. ACABOU?
	GOTO	DL2		;NÃO, CONTINUA AGUARDANDO
				;SIM

	DECFSZ	TEMPO2,F	;DECREMENTA TEMPO2. ACABOU?
	GOTO	DL1		;NÃO, CONTINUA AGUARDANDO
				;SIM
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK0			;ALTERA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000110'
	MOVWF	TRISA		;DEFINE RA1 E 2 COMO ENTRADA E DEMAIS
				;COMO SAÍDAS
	MOVLW	B'00000000'
	MOVWF	TRISB		;DEFINE TODO O PORTB COMO SAÍDA
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;PRESCALER 1:2 NO TMR0
				;PULL-UPS DESABILITADOS
				;AS DEMAIS CONFG. SÃO IRRELEVANTES
	MOVLW	B'00000000'
	MOVWF	INTCON		;TODAS AS INTERRUPÇÕES DESLIGADAS
	BANK0			;RETORNA PARA O BANCO 0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CLRF	PORTA		;LIMPA O PORTA
	MOVLW	DISPLAY
	MOVWF	PORTB		;ACENDE O VALOR CERTO NO DISPLAY
	MOVLW	MIN
	MOVWF	CONTADOR	;INICIA CONTADOR COM VALOR MIN.


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW	MULTIPLO
	MOVWF	TEMPO3		;INICIA COMTADOR DE MULTIPLICAÇÃO,
				;POIS OS TEMPOS GERADOS POR DELAY
				;SÃO MUITO PEQUENOS, GERANDO FREQ.
				;MUITO ALTAS PARA A VISUALIZAÇÃO.
MAIN1
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
				;PARA CHAMAR A ROTINA DE DELAY
	CALL	DELAY		;CHAMA ROTINA DE DELAY

	BTFSS	BT1		;BOTÃO 1 PRESSIONADO?
	GOTO	INCREMENTA	;SIM, DEVE INCREMENTAR
				;NÃO

	BTFSS	BT2		;BOTÃO 2 PRESSIONADO?
	GOTO	DECREMENTA	;SIM, DEVE DECREMENTAR
				;NÃO

	DECFSZ	TEMPO3,F	;DECREMENTA CONTADOR DE MULT. ACABOU?
	GOTO	MAIN1		;NÃO, CONTINUA AGUARDANDO
				;SIM	

	MOVLW	DISPLAY		;APÓS TRANSCORRIDO O TEMPO, IRÁ
				;INVERTER OS LEDS CORRETOS ATRAVÉS
				;DA MÁSCARA "DISPLAY" E DA OPERAÇÃO
				;XOR
	XORWF	PORTB,F		;INVERTE LEDS -> PISCA

	GOTO	MAIN		;COMEÇA NOVAMENTE


DECREMENTA
	MOVLW	STEP
	SUBWF	CONTADOR,F	;DECREMENTA O CONTADOR EM STEP

	MOVLW	MIN		;MOVE O VALOR MÍNIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI O VALOR DE W (MIN) DE CONTADOR
	BTFSC	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	MAIN		;NÃO, ENTÃO CONTA >= MIN
				;SIM, ENTÃO CONTA < MIN

	MOVLW	MIN
	MOVWF	CONTADOR	;ACERTA CONTADOR NO MÍNIMO, POIS
				;PASSOU DO VALOR

	BTFSS	BT2		;BOTÃO 2 CONTINUA PRESSIONADO?
	GOTO	$-1		;SIM, AGUARDA LIBERAÇÃO
				;NÃO
	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL

INCREMENTA
	MOVLW	STEP
	ADDWF	CONTADOR,F	;INCREMENTA O CONTADOR EM STEP

	MOVLW	MAX		;MOVE O VALOR MÁXIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI O VALOR DE W (MIN) DE CONTADOR
	BTFSS	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	MAIN		;SIM, ENTÃO CONTA < MAX
				;NÃO, ENTÃO CONTA >= MAX
	MOVLW	MAX
	MOVWF	CONTADOR	;ACERTA CONTADOR NO MÁXIMO, POIS
				;PASSOU DO VALOR
	BTFSS	BT1		;BOTÃO 1 CONTINUA PRESSIONADO?
	GOTO	$-1		;SIM, AGUARDA LIBERAÇÃO
				;NÃO
	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGATÓRIO

