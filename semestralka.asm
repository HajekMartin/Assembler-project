; Tlacitko 2 zobrazim potik 2
    list	p=16F1508
    #include    "p16F1508.inc"

    #define	BT1	PORTA,4
    
    
    __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _BOREN_OFF & _CLKOUTEN_OFF & _IESO_OFF & _FCMEN_OFF

    __CONFIG _CONFIG2, _WRT_OFF & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

;VARIABLE DEFINITIONS
;COMMON RAM 0x70 to 0x7F
    CBLOCK	0x70
	cnt1
        cnt2
	pot
	
	state			; aktualni stav jaky segment je zobrazen
	speed			; aktualni rychlost
	rotation		; smer otaceni
	
	num7S			;cislo pro zobrazeni, dalsi 3B budou displeje!
	dispL			;levy 7seg
	dispM			;prostredni 7seg
	dispR			;pravy 7seg
    ENDC
    
;**********************************************************************
	ORG     0x00
  	goto    Start
	
	ORG     0x04
	movlb	.7		;Banka7 s IOC
	btfsc	IOCAF,4		;preruseni od BT1(RA4) -> pokud je od BT1 tak p?eskakovat nechci.
	call	SpeedChange	;je to tedy od BT2...
	btfsc	IOCAF,5		;presuseni od BT2 -> chci preskakovat pokud je preruseni od BT1
	call	RotationChange	
	
	
	bcf	IOCAF,4		;vynulovat priznak od BT1(RA4)
	bcf	IOCAF,5
	
	movlb	.1
	movwf	ADCON0
	
	movlb	.0		;Banka0 s PORT
  	retfie	
	
	
Start	movlb	.1		;Bank1
	movlw	b'01101000'	;4MHz Medium
	movwf	OSCCON		;nastaveni hodin

	call	Config_IOs	;vola nastaveni pinu
	call	Config_SPI
	
	;nastaveni preruseni
	movlb	.7		;Banka7 s IOC
	bsf	IOCAN,4		;BT1(RA4) nastavena detekce pozitivni hrany
	bsf	IOCAN,5		;BT2(RA5) nastavena detekce negativni hrany
	clrf	IOCAF		;smazat priznak doted detekovanych hran
	
	bsf	INTCON,IOCIE	;povolit preruseni od IOC
	bsf	INTCON,GIE	;povolit preruseni jako takove	
	
	; DEFAULT NASTAVENI SATVU PO ZAPNUTI STAVU
	movlb	.1
	movlw	b'00000000'
	movwf	state	
	; DEFAULT NASTAVENI RYCHLOSTI PO ZAPNUTI 
	movlw	b'11110010' ; rychlost 50 ms
	movwf	speed
	; DEFAULTNI NASTVANEI ROTACE
	movlw	b'00000000' 
	movwf	rotation
	

Main	movlb	.1	
	
	call	Display
	call	Delay100
	
	btfsc	rotation, 0
	call IncrementState
	btfss	rotation, 0
	call DecrementState

	
	goto	Main
	
IncrementState:
    incf	state	    ; inkrementuju stav aby se tocil
    ; zjistim zda nejsem ve stavu 10 tzn zpatky do 0
    movlw   b'00001010' 
    subwf	state,W		
    btfsc	STATUS, Z
    call	ZeroState
    return
	
ZeroState:
    movlw   b'00000000'
    movwf   state
    return
    
DecrementState:
    decf    state
    movlw   b'11111111' 
    subwf	state,W		
    btfsc	STATUS, Z
    call	ZeroState2
    return
    
ZeroState2:
    movlw   b'00001001'
    movwf   state
    return
    
SpeedChange:
    movlw   b'01000000'
    addwf   speed, speed
    movwf   speed
    return
    
RotationChange:
    incf rotation
    return

Display:
	; VYMAZU HODNOTY V DISPLEJICH
	movf	dispL,W
	movlw   b'00000000'
	movwf	dispL
	
	movf	dispM,W
	movlw	b'00000000'
	movwf	dispM
	
	movf	dispR,W
	movlw	b'00000000'
	movwf	dispR	

	; PODLE AKTUALNIHO STAVU NASTAVIM
	;STAV 0
	movlw	b'00000000'
	subwf	state,W		
	btfsc	STATUS, Z
	call	State0
	;STAV 1
	movlw	b'00000001'
	subwf	state,W		
	btfsc	STATUS, Z
	call	State1
	;STAV 2
	movlw	b'00000010'
	subwf	state,W		
	btfsc	STATUS, Z
	call	State2
	;STAV 3
	movlw	b'00000011'
	subwf	state,W		
	btfsc	STATUS, Z
	call	State3
	;STAV 4
	movlw	b'00000100'
	subwf	state,W		
	btfsc	STATUS, Z
	call State4
	;STAV 5
	movlw	b'00000101'
	subwf	state,W		
	btfsc	STATUS, Z
	call State5
	;STAV 6
	movlw	b'00000110'
	subwf	state,W		
	btfsc	STATUS, Z
	call State6
	;STAV 7
	movlw	b'00000111'
	subwf	state,W		
	btfsc	STATUS, Z
	call State7
	;STAV 8
	movlw	b'00001000'
	subwf	state,W		
	btfsc	STATUS, Z
	call State8
	;STAV 9
	movlw	b'00001001'
	subwf	state,W		
	btfsc	STATUS, Z
	call State9
	
	; ZAPISU DO DISPLEJE
	movf	dispR,W
        call    SendByte7S	;odesle W vzdy do leveho displeje (posun ostat.)
	movf	dispM,W
	call    SendByte7S	;odesle W vzdy do leveho displeje (posun ostat.)
	movf	dispL,W
	call    SendByte7S	;odesle W vzdy do leveho displeje (posun ostat.)
	
	return
	
State0:	; PRAVY DISPLEJ
    movf	dispR,W
    movlw	b'10000000'
    movwf	dispR	
    return
State1:	; PRAVY DISPLEJ
    movf	dispR,W
    movlw	b'01000000'
    movwf	dispR	
    return
State2:	; PRAVY DISPLEJ
    movf	dispR,W
    movlw	b'00100000'
    movwf	dispR	
    return
State3:	; PRAVY DISPLEJ
    movf	dispR,W
    movlw	b'00010000'
    movwf	dispR	
    return
State4:	; PROSTREDNI DISPLEJ
    movf	dispM,W
    movlw	b'00010000'
    movwf	dispM	
    return
State5:	; LEVY DISPLEJ
    movf	dispL,W
    movlw	b'00010000'
    movwf	dispL	
    return
State6:	; LEVY DISPLEJ
    movf	dispL,W
    movlw	b'00001000'
    movwf	dispL	
    return
State7:	; LEVY DISPLEJ
    movf	dispL,W
    movlw	b'00000100'
    movwf	dispL	
    return
State8:	; LEVY DISPLEJ
    movf	dispL,W
    movlw	b'10000000'
    movwf	dispL	
    return
State9:	; PROSTREDNI DISPLEJ
    movf	dispM,W
    movlw	b'10000000'
    movwf	dispM	
    return
	
Delay100			;zpozdeni 250 ms
        movf	speed, W
Delay_ms
        movwf	cnt2		
OutLp	movlw	.249		
	movwf	cnt1		
	nop			
	decfsz	cnt1,F
        goto	$-2		
	decfsz	cnt2,F
	goto	OutLp
	return	

	
	
    #include	"Config_IOs.inc"
    
    #include	"Display.inc"
		
	END
