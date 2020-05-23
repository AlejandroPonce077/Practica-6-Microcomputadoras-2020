; PROGRAMA QUE COMPARA LOS VOLTAJES DE TRES POTENCIOMETROS CONECTADOS A LOS 
; CANALES A0, A1, A2 RESPECTIVAMENTE CON LAS SALIDAS ENE EL PUERTO B QUE SE
; MUESTRAN:

;  _________________________________________________
;
;    SEÑAL                  PB2     PB1     PB1
;  ------------------- -   ------- ------  ---------
;  VAR1 > VAR2  Y VAR3        0      0        1
;  VAR2 > VAR1  Y VAR3        0      1        1
;  VAR3 > VAR1  Y VAR2        1      1        1
;  _________________________________________________

processor 16F877A
include <p16F877A.inc>


PDel0 EQU 0X23
PDel1 EQU 0X24

VAR1 EQU 0X25
VAR2 EQU 0X26
VAR3 EQU 0X27		;Variables para almacenar los resultados de CAD


	ORG 0000H
	GOTO INICIO
	ORG 0005H
	
INICIO 
	CLRF PORTA 		;(1)LIMPIO EL PUERTO A.
	BSF STATUS,RP0  ;(2) Cambiar al banco 1.
	CLRF ADCON1		;(3) CONFIGURA EL PUERTO A COMO ENTRADAS ANALOGICAS
	CLRF TRISB		; PUERTO B COMO SALIDAS
	BCF STATUS,RP0
	MOVLW B'110000001'
	MOVWF ADCON0	;4. Realizar la configuracion de la fuente de reloj, el canal de entrada y prender al convertidor de AD , en el registro ADCON0.

	
LOOP
	BCF ADCON0,3
	BCF ADCON0,4
	CALL DELAY_20MS	;ESPERO 20 MILISEGUNDOS
	CALL DELAY_20MS
	BSF ADCON0,2 	;5. Iniciar la conversion colocando un 1 en la bandera GO/DONE#
					;6. Generar un tiempo de retardo de 20 microsegundos.

ESPERA
	BTFSC ADCON0,2
	GOTO ESPERA 	;7.Esperar a que GO/DONE# sea igual a cero, lo que indica que ha concluido el proceso de conversion.
	MOVF ADRESH,W 	;8.Leer el resultado de la conversion del registro ADRESH
	MOVWF VAR1
	BSF ADCON0,3
	CALL DELAY_20MS
	CALL DELAY_20MS
	BSF ADCON0,2	; GO COMIENZA LA CONVERSION AD
	
ESPERA2
	BTFSC ADCON0,2
	GOTO ESPERA2 	;7.Esperar a que GO/DONE# sea igual a cero, lo que indica que ha concluido el proceso de conversion.
	MOVF ADRESH,W 	;8.Leer el resultado de la conversion del registro ADRESH
	MOVWF VAR2
	BCF ADCON0,3
	BSF ADCON0,4
	CALL DELAY_20MS
	CALL DELAY_20MS
	BSF ADCON0,2	; GO COMIENZA LA CONVERSION AD
	
ESPERA3
	BTFSC ADCON0,2	; ESPERAR A QUE TERMINE LA CONVERSION
	GOTO ESPERA3 	
	MOVF ADRESH,W 	
	MOVWF VAR3		;GUARDA EL VALOR EN VAR 3
	MOVF VAR2,W
	SUBWF VAR1,W	;W=VAR1-VAR2
	BTFSS STATUS,C	;¿ VAR1>=VAR2?,¿C=1?
	GOTO _V2_V3_	;NO
	MOVF VAR3,W		;SI
	SUBWF VAR1,W		;W=VAR1-VAR3
	BTFSS STATUS,C 	;¿VAR1>=VAR3?,¿C=1?
	GOTO W_ES_7		;NO
	MOVLW 1			;SI
	GOTO ENVIA


_V2_V3_
	MOVF VAR3,W
	SUBWF VAR2,2 	;W=VAR2-VAR3
	BTFSS STATUS,C	;¿VAR2>=VAR3?,¿C=1?
	GOTO W_ES_7		;NO
	MOVLW 3			;SI
	GOTO ENVIA


W_ES_7
	MOVLW 7

ENVIA
	MOVWF PORTB
	CALL DELAY_20MS
	CALL DELAY_20MS
	CALL DELAY_20MS
	CALL DELAY_20MS
	GOTO LOOP

;SUBRUTINA DE RETARDO DE 20 MICROSEGUNDOS

DELAY_20MS
	MOVLW .23		; 1 set numero de repeticion
    MOVWF PDel1		; 1 |
 
PLOOP0
	CLRWDT 				; 1 clear watchdog
	DECFSZ PDel1, 1 	; 1 + (1) es el tiempo 0 ?
	GOTO PLOOP0			; 2 no, loop
	
PDelL1
	goto PDelL2			; 2 ciclos delay

PDelL2
	CLRWDT 				; 1 ciclo delay
	RETURN				; 2+2 Fin.
	
	END



	END



