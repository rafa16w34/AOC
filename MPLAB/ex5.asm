; ==========================================
; Trabalho de Laboratório de Arquitetura de Computadores
; Integrantes:
; - Rafael Alves Faria
; - Gabriel Alves Faria
; =========================
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    TIMER DE SEGUNDOS - EX5                      *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERSÃO: 1.0                             DATA: 30/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRIÇÃO DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  TIMER DECRESCENTE EM SEGUNDOS. O VALOR INICIAL É DETERMINADO   *
;*  PELA CONSTANTE V_INICIO E PODE ESTAR ENTRE 1 E 9 SEGUNDOS.     *
;*  O BOTÃO 1 DISPARA O TIMER, MOSTRANDO O TEMPO RESTANTE NO       *
;*  DISPLAY. O BOTÃO 2 PARALIZA O TIMER. O LED É UTILIZADO PARA    *
;* INDICAR O ESTADO ATUAL DO TIMER: ACESO=RODANDO E APAGADO=PARADO *
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
		TEMPO		;ARMAZENA O VALOR DO TEMPO
		FLAGS		;ARMAZENA OS FLAGS DE CONTROLE
		TEMP1		;REGISTRADORES AUXILIARES
		TEMP2
		FILTRO1		;FILTROS DOS BOTÕES
		FILTRO2	
		SEGUNDOS

	ENDC			;FIM DO BLOCO DE MEMÓRIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE	F_FIM	FLAGS,0		;FLAG DE FIM DE TEMPO
#DEFINE	ST_BT1	FLAGS,1		;STATUS DO BOTÃO 1
#DEFINE	ST_BT2	FLAGS,2		;STATUS DO BOTÃO 2

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

V_INICIO	EQU	.0	;VALOR INICIAL DO TIMER (1 A 15 SEG.)
T_FILTRO	EQU	.255	;VALOR DO FILTRO DOS BOTÕES
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	BOTAO1	PORTA,1	;PORTA DO BOTÃO
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

#DEFINE	BOTAO2	PORTA,2	;PORTA DO BOTÃO
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	LED	PORTA,3	;LED
			;0 -> DESLIGADO
			;1 -> LIGADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00	;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; UTILIZAREMOS SOMENTE A INTERRUÇÃO DE TMR0, MAS EFETUAREMOS O TESTE
; PARA TERMOS CERTEZA DE QUE NENHUM PROBLEMA ACONTECEU. É NECESSÁRIO
; SALVAR E RECUPERAR OS VALOR DE W E STATUS.

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;SALVA W EM W_TEMP
	SWAPF	STATUS,W	
	MOVWF	STATUS_TEMP	;SALVA STATUS EM STATUS_TEMP

	BTFSS	INTCON,T0IF	;É INTERRUPÇÃO DE TMR0?
	GOTO	SAI_INT		;NÃO, SAI SE AÇÃO	
				;SIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              TRATAMENTO DA INTERRUPÇÃO DE TMR0                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA IRÁ CONTAR O TEMPO, E QUANDO PASSAR 1 SEGUNDO, A VARI-
; ÁVEL "TEMPO" SERÁ DECREMENTADA.
; 1 SEGUNDO = 64us (PRESCALER) X 125 (TMR0) X 125 (TEMP1)

	BCF INTCON,T0IF
	MOVLW .256-.125
	MOVWF TMR0
	
	DECFSZ TEMP1,F
	GOTO SAI_INT
	
	BTFSC PORTA,3
	GOTO LED_OFF
	
	BSF PORTA,3
	GOTO LED_FIM
	
	LED_OFF:
	BCF PORTA,3
	
	LED_FIM:
	
	MOVLW .125
	MOVWF TEMP1
	
	DECFSZ SEGUNDOS,F
	GOTO SAI_INT
	
	MOVLW .60
	MOVWF SEGUNDOS
	
	BTFSC F_FIM
	GOTO SAI_INT
	
	INCFSZ TEMPO,F
	GOTO SAI_INT
	
	BSF F_FIM
	GOTO SAI_INT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;RECUPERA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;RECUPERA W
	RETFIE			;RETORNA DA INTERRUPÇÃO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE CONVERSÃO BINÁRIO -> DISPLAY          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA IRÁ RETORNAR EM W, O SIMBOLO CORRETO QUE DEVE SER
; MOSTRADO NO DISPLAY PARA CADA VALOR DE CONTADOR. O RETORNO JÁ ESTÁ
; FORMATADO PARA AS CONDIÇÕES DE LIGAÇÃO DO DISPLAY AO PORTB.
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

CONVERTE
	MOVF	TEMPO,W		;COLOCA CONTADOR EM W
	ANDLW	B'00001111'	;MASCARA VALOR DE CONTADOR
				;CONSIDERAR SOMENTE ATÉ 15
	ADDWF	PCL,F

;		B'EDC.BAFG'	; POSIÇÃO CORRETA DOS SEGUIMENTOS
	RETLW	B'11101110'	; 00 - RETORNA SÍMBOLO CORRETO 0
	RETLW	B'00101000'	; 01 - RETORNA SÍMBOLO CORRETO 1
	RETLW	B'11001101'	; 02 - RETORNA SÍMBOLO CORRETO 2
	RETLW	B'01101101'	; 03 - RETORNA SÍMBOLO CORRETO 3
	RETLW	B'00101011'	; 04 - RETORNA SÍMBOLO CORRETO 4	
	RETLW	B'01100111'	; 05 - RETORNA SÍMBOLO CORRETO 5	
	RETLW	B'11100111'	; 06 - RETORNA SÍMBOLO CORRETO 6	
	RETLW	B'00101100'	; 07 - RETORNA SÍMBOLO CORRETO 7	
	RETLW	B'11101111'	; 08 - RETORNA SÍMBOLO CORRETO 8	
	RETLW	B'01101111'	; 09 - RETORNA SÍMBOLO CORRETO 9	
	RETLW	B'10101111'	; 10 - RETORNA SÍMBOLO CORRETO A	
	RETLW	B'11100011'	; 11 - RETORNA SÍMBOLO CORRETO b	
	RETLW	B'11000110'	; 12 - RETORNA SÍMBOLO CORRETO C	
	RETLW	B'11101001'	; 13 - RETORNA SÍMBOLO CORRETO d	
	RETLW	B'11000111'	; 14 - RETORNA SÍMBOLO CORRETO E	
	RETLW	B'10000111'	; 15 - RETORNA SÍMBOLO CORRETO F	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE ATUALIZAÇÃO DO DISPLAY                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA CONVERTE O VALOR DE TEMPO ATRAVÉS DA ROTINA CONVERTE
; E ATUALIZA O PORTB PARA ACENDER O DISPLAY CORRETAMENTE

ATUALIZA
	CALL	CONVERTE	;CONVERTE CONTADOR NO NÚMERO DO
				;DISPLAY
	MOVWF	PORTB		;ATUALIZA O PORTB PARA
				;VISUALIZARMOS O VALOR DE CONTADOR
				;NO DISPLAY
	RETURN			;NÃO, RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE DESLIGAR O TIMER                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA EXECUTA AS AÇÕES NECESSÁRIAS PARA DESLIGAR O TIMER

DESL_TIMER
	BCF	INTCON,GIE	;DESLIGA CHAVE GERAL DE INT.
	BCF	LED		;APAGA O LED
	RETURN			;RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE LIGAR O TIMER                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA EXECUTA AS AÇÕES NECESSÁRIAS PARA LIGAR O TIMER

LIGA_TIMER
	BTFSC	INTCON,GIE	;TIMER JÁ ESTA LIGADO?
	RETURN			;SIM, RETORNA DIRETO
				;NÃO
	BCF	INTCON,T0IF	;LIMPA FLAG DE INT. DE TMR0
	MOVLW	.256-.125
	MOVWF	TMR0		;INICIA TMR0 CORRETAMENTE
	MOVLW	.125
	MOVWF	TEMP1		;INICIA TEMP1 CORRETAMENTE
	BSF	INTCON,GIE	;LIGA CHAVE GERAL DE INTERRUPÇÕES
	BSF	LED		;ACENDE O LED
	RETURN			;RETORNA

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
	MOVLW	B'10000101'
	MOVWF	OPTION_REG	;PRESCALER 1:64 NO TMR0
				;PULL-UPS DESABILITADOS
				;AS DEMAIS CONFG. SÃO IRRELEVANTES
	MOVLW	B'00100000'
	MOVWF	INTCON		;HABILITADA SOMENTE A INTERRUPÇÃO TMR0
				;CHAVE GERAL DAS INTERRUÇÕES DESLIGADAS
	BANK0			;RETORNA PARA O BANCO 0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


	CLRF PORTA
	CLRF PORTB
	CLRF FLAGS
	
	MOVLW V_INICIO
	MOVWF TEMPO
	
	MOVLW .60
	MOVWF SEGUNDOS
	
	CALL ATUALIZA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	BTFSC	F_FIM		;CHEGOU AO FIM?
	CALL	DESL_TIMER	;SIM, ENTÃO DESLIGA O TIMER
				;NÃO
	CALL	ATUALIZA	;ATUALIZA O DISPLAY
	MOVLW	T_FILTRO
	MOVWF	FILTRO1		;INICIALIZA FILTRO1 = T_FILTRO
	MOVWF	FILTRO2		;INICIALIZA FILTRO2 = T_FILTRO

CHECA_BT1
	BTFSC	BOTAO1		;O BOTÃO 1 ESTÁ PRESSIONADO?
	GOTO	BT1_LIB		;NÃO, ENTÃO TRATA COMO LIBERADO
				;SIM
	DECFSZ	FILTRO1,F	;DECREMENTA O FILTRO DO BOTÃO
				;TERMINOU?
	GOTO	CHECA_BT1	;NÃO, CONTINUA ESPERANDO
				;SIM
	BTFSS	ST_BT1		;BOTÃO JÁ ESTAVA PRESSIONADO?
	GOTO	ACAO_BT1	;NÃO, EXECUTA AÇÃO DO BOTÃO
	GOTO	CHECA_BT2	;SIM, CHECA BOTÃO 2

BT1_LIB
	BCF	ST_BT1		;MARCA BOTÃO 1 COMO LIBERADO

CHECA_BT2
	BTFSC	BOTAO2		;O BOTÃO 2 ESTÁ PRESSIONADO?
	GOTO	BT2_LIB		;NÃO, ENTÃO TRATA COMO LIBERADO
				;SIM
	DECFSZ	FILTRO2,F	;DECREMENTA O FILTRO DO BOTÃO
				;TERMINOU?
	GOTO	CHECA_BT2	;NÃO, CONTINUA ESPERANDO
				;SIM
	BTFSS	ST_BT2		;BOTÃO JÁ ESTAVA PRESSIONADO?
	GOTO	ACAO_BT2	;NÃO, EXECUTA AÇÃO DO BOTÃO
	GOTO	MAIN		;SIM, VOLTA AO LOOPING

BT2_LIB
	BCF	ST_BT2		;MARCA BOTÃO 2 COMO LIBERADO
	GOTO	MAIN		;RETORNA AO LOOPING

ACAO_BT1			;AÇÃO PARA O BOTÃO 1
	BSF	ST_BT1		;MARCA BOTÃO 1 COMO JÁ PRESSIONADO
	CALL	LIGA_TIMER	;LIGA O TIMER
	GOTO	MAIN

ACAO_BT2			;AÇÃO PARA O BOTÃO 2
	BSF	ST_BT2		;MARCA BOTÃO 2 COMO JÁ PRESSIONADO
	CALL	DESL_TIMER	;DESLIGA O TIMER
	GOTO	MAIN		;NÃO, VOLTA AO LOOP PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGATÓRIO

