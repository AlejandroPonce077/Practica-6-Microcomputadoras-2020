
;	programa que representa por un puertto paralelo el resultado de la conversion del canala AD seleccionado

;	para este proposito se seguira el siguiente algoritmo para el uso del convertidor AD con una resolucion de 8 bits.

;	1. Estando en el banco cero, limpiar el puerto A, usando CLRF PORTA.
;	2. Cambiar al banco 1.
;	3. Configurar el puerto A como entradas analogicas, escribir 00h al registro ADCON1.
;	4. Realizar la configuracion de las fuentes de reloj, el canal de entrada y prender al convertidor AD, en el registro ADCON0.
;	5. Inciar la conversion colocando un 1 en la bandera GO/DONE#.
;	6. Generar un tiempo de retardo de 20 microsegundos.
;	7. Esperar a que GO/DONE# sea igual a cero, lo que indica que a concluido el proceso de conversion.
;	8. Leer el resultado de la conversion del registro ADRESH.


processor 16F877A
include <p16F877A.inc>

;definicion de los registros para la subrutina de retardo
PDel0 EQU 80H

;Valor temporal
ENTRADA EQU 20H


	ORG 0
	GOTO INICIO
	ORG 5
INICIO 
	BCF STATUS,RP0
	BCF STATUS,RP1
	CLRF PORTA 		;1. Estando en el banco 0, lipiar el puerto A, usando CLRF PORTA.
	BSF STATUS,RP0  ;2. Cambiar al banco 1.
	MOVLW B'01001110'
	MOVWF ADCON1    ;3. Cconfigurar el puerto A como entradas analogicas, escribir 00h al registro
	MOVLW 3FH
	MOVWF TRISA
	CLRF TRISB
	BCF STATUS,RP0
	MOVLW B'110000001'
	MOVWF ADCON0	;4. Realizar la configuracion de la fuente de reloj, el canal de entrada y prender al convertidor de AD , en el registro ADCON0.
	CLRF PORTB
	CALL DELAY_20MS
	
PRINCIPAL
	
	BSF ADCON0,2 	;5. Iniciar la conversion colocando un 1 en la bandera GO/DONE#
					;6. Generar un tiempo de retardo de 20 microsegundos.

ESPERA
	BTFSC ADCON0,2
	GOTO ESPERA 	;7.Esperar a que GO/DONE# sea igual a cero, lo que indica que ha concluido el proceso de conversion.
	MOVF ADRESH,W 	;8.Leer el resultado de la conversion del registro ADRESH
	MOVWF ENTRADA
	
	SUBLW .190		; 2/3 del desplazamiento angular del potenciometro
	BTFSS STATUS,C
	GOTO DESP_2_3
	
	MOVF ENTRADA,W
	SUBLW .85		;1/3 del desplazamiento angular del potenciometro
	BTFSS STATUS,C
	GOTO DESP_1_2
	

DESP_0_1:
	MOVLW 0X01
	MOVWF PORTB
	GOTO FINALIZA

DESP_1_2:
	MOVLW 0X03
	MOVWF PORTB
	GOTO FINALIZA


DESP_2_3:
	MOVLW 0X07
	MOVWF PORTB

FINALIZA:
	CALL DELAY_20MS
	CALL DELAY_20MS
	CALL DELAY_20MS
	GOTO PRINCIPAL


DELAY_20MS
	MOVLW .23		; 1 set numero de repeticion
    MOVWF PDel0		; 1 |
 
PLOOP0
	CLRWDT 				; 1 clear watchdog
	DECFSZ PDel0, 1 	; 1 + (1) es el tiempo 0 ?
	GOTO PLOOP0			; 2 no, loop
	
PDelL1
	goto PDelL2			; 2 ciclos delay

PDelL2
	CLRWDT 				; 1 ciclo delay
	RETURN				; 2+2 Fin.
	
	END



