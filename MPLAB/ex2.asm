; ==========================================
; Trabalho de Laboratório de Arquitetura de Computadores
; Integrantes:
; - Rafael Alves Faria
; - Gabriel Alves Faria
; =========================
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  CONTADOR SIMPLIFICADO - EX2                    *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERSAO: 1.0                             DATA: 30/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRICAO DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  SISTEMA MUITO SIMPLES PARA INCREMENTAR ATE UM DETERMINADO      *
;*  VALOR (MAX) DE DEPOIS DECREMENTAR ATE OUTRO (MIN).             *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINICOES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>		;ARQUIVO PADRAO MICROCHIP PARA 16F628A
	__CONFIG  _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _XT_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINACAO DE MEMORIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINICAO DE COMANDOS DE USUARIO PARA ALTERACAO DA PAGINA DE MEMORIA

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMORIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MEMORIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIAVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINICAO DOS NOMES E ENDERECOS DE TODAS AS VARIAVEIS UTILIZADAS
; PELO SISTEMA

	CBLOCK	0x20		;ENDERECO INICIAL DA MEMORIA DE
				;USUARIO

		W_TEMP		;REGISTRADORES TEMPORARIOS PARA
		STATUS_TEMP	;INTERRUPCOES
				;ESTAS VARIAVEIS NEM SERAO UTI-
				;LIZADAS
		CONTADOR	;ARMAZENA O VALOR DA CONTAGEM
		FILTRO		;FILTRAGEM PARA O BOTAO

	ENDC			;FIM DO BLOCO DE MEMORIA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINICAO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

MIN		EQU	.10	;VALOR MINIMO PARA O CONTADOR
MAX		EQU	.30	;VALOR MAXIMO PARA O CONTADOR
T_FILTRO	EQU	.230	;FILTRO PARA BOTAO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINICAO DE TODOS OS PINOS QUE SERAO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBEM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	BOTAO	PORTA,2	;PORTA DO BOTAO

#DEFINE BOTAO1 PORTA,1

			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAIDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINICAO DE TODOS OS PINOS QUE SERAO UTILIZADOS COMO SAIDA
; RECOMENDAMOS TAMBEM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00	;ENDERECO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INICIO DA INTERRUPCAO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AS INTERRUPCOES NAO SERAO UTILIZADAS, POR ISSO PODEMOS SUBSTITUIR
; TODO O SISTEMA EXISTENTE NO ARQUIVO MODELO PELO APRESENTADO ABAIXO
; ESTE SISTEMA NAO E OBRIGATORIO, MAS PODE EVITAR PROBLEMAS FUTUROS

	ORG	0x04		;ENDERECO INICIAL DA INTERRUPCAO
	RETFIE			;RETORNA DA INTERRUPCAO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000110'
	MOVWF	TRISA		;DEFINE RA1 E RA2 COMO ENTRADA E DEMAIS
				;COMO SAIDAS
	MOVLW	B'00000000'
	MOVWF	TRISB		;DEFINE TODO O PORTB COMO SAIDA
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;PRESCALER 1:2 NO TMR0
				;PULL-UPS DESABILITADOS
				;AS DEMAIS CONFIG. SAO IRRELEVANTES
	MOVLW	B'00000000'
	MOVWF	INTCON		;TODAS AS INTERRUPCOES DESLIGADAS
	BANK0			;RETORNA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERACAO DO COMPARADOR ANALOGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZACAO DAS VARIAVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CLRF	PORTA		;LIMPA O PORTA
	CLRF	PORTB		;LIMPA O PORTB
	MOVLW	MIN
	MOVWF	CONTADOR	;INICIA CONTADOR = MIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW	T_FILTRO
	MOVWF	FILTRO		;INICIALIZA FILTRO = T_FILTRO
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
	MOVWF	PORTB		;EXIBE VALOR ANTES DE CHECAR BOTAO


CHECA_BT
	BTFSC	BOTAO		;O BOTAO ESTA PRESSIONADO?
	GOTO	CHECA_BT1	;NAO, ENTAO VERIFICA BOTAO1
				;SIM
	DECFSZ	FILTRO,F	;DECREMENTA O FILTRO DO BOTAO
				;TERMINOU?
	GOTO	CHECA_BT	;NAO, CONTINUA ESPERANDO
				;SIM
	GOTO	SOMA


CHECA_BT1
	MOVLW	T_FILTRO	;REINICIA FILTRO PARA BOTAO1
	MOVWF	FILTRO
	BTFSC	BOTAO1		;O BOTAO1 ESTA PRESSIONADO?
	GOTO	MAIN		;NAO, ENTAO VOLTA AO LOOP PRINCIPAL
				;SIM
	DECFSZ	FILTRO,F	;DECREMENTA O FILTRO DO BOTAO
				;TERMINOU?
	GOTO	CHECA_BT1	;NAO, CONTINUA ESPERANDO
				;SIM
	GOTO	SUBTRAI

SUBTRAI
	DECF	CONTADOR,F	;DECREMENTA O CONTADOR

	MOVLW	MIN		;MOVE O VALOR MINIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI MIN DE CONTADOR
	BTFSC	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	ATUALIZA	;NAO, ENTAO CONTADOR >= MIN
				;SIM, ENTAO CONTADOR < MIN

	INCF	CONTADOR,F	;INCREMENTA CONTADOR NOVAMENTE
				;POIS PASSOU DO LIMITE

	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL

SOMA
	INCF	CONTADOR,F	;INCREMENTA O CONTADOR

	MOVLW	MAX		;MOVE O VALOR MAXIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI MAX DE CONTADOR
	BTFSS	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	ATUALIZA	;SIM, ENTAO CONTADOR < MAX
				;NAO, ENTAO CONTADOR >= MAX

	DECF	CONTADOR,F	;DECREMENTA CONTADOR NOVAMENTE
				;POIS PASSOU DO LIMITE
	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL

ATUALIZA
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
	MOVWF	PORTB		;ATUALIZA O PORTB PARA
				;VISUALIZARMOS O VALOR DE CONTADOR

ESPERA				;O BOTAO CONTINUA PRESSIONADO?
	BTFSS	BOTAO
	GOTO	ESPERA		;SIM, ENTAO ESPERA LIBERACAO

	BTFSS	BOTAO1
	GOTO	ESPERA		;SIM, ENTAO ESPERA LIBERACAO
				;QUE O CONTADOR NAO DISPARE
	GOTO	MAIN		;NAO, VOLTA AO LOOP PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGATORIO
