;zobrazi hodnotu z ADC (potenciometr 1) na 7seg
    list	p=16F1508
    #include    "p16F1508.inc"

   
    __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _BOREN_OFF & _CLKOUTEN_OFF & _IESO_OFF & _FCMEN_OFF

    __CONFIG _CONFIG2, _WRT_OFF & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

;VARIABLE DEFINITIONS
;COMMON RAM 0x70 to 0x7F
    CBLOCK	0x70
	cnt1
        cnt2
	
	num7S			;cislo pro zobrazeni, dalsi 3B budou displeje!
	dispL			;levy 7seg
	dispM			;prostredni 7seg
	dispR			;pravy 7seg
    ENDC
    
;**********************************************************************
	ORG     0x00
  	goto    Start
	
	ORG     0x04
	nop
  	retfie
	
	
Start	movlb	.1		;Banka1
	movlw	b'01101000'	;4MHz Medium
	movwf	OSCCON		;nastaveni hodin

	call	Config_IOs
	call	Config_SPI
	
	;config ADC
	movlb	.1		;Banka1 s ADC
	movlw	b'00011000'	;P1 = AN6
	movwf	ADCON0
	movlw	b'01110000'	;leftAlig, FRC, VDD
	movwf	ADCON1
	clrf	ADCON2		;single conv.
	bsf	ADCON0,ADON	;zapnout ADC


	
Loop	movlb	.1		;Banka1 s ADC
	bsf     ADCON0,GO       ;start A/D prevodu
        btfsc   ADCON0,GO 	;A/D prevod skoncen?
        goto    $-1             ;pokud ne, navrat o radek vyse
	
	movf    ADRESH,W	;nacte nejvyssich 8 bit? vysledku
	movwf	num7S		;zapsani cisla pro zobrazeni
        call    Bin2Bcd		;z num7S udela BCD cisla v dispL-dispM-dispR
	
	movf	dispL,W
        call    Byte2Seg	;4bit. cislo ve W zmeni na segment pro zobrazeni
	movwf	dispL
	
	movf	dispM,W
        call    Byte2Seg	;4bit. cislo ve W zmeni na segment pro zobrazeni
	movwf	dispM
	
	movf	dispR,W
        call    Byte2Seg	;4bit. cislo ve W zmeni na segment pro zobrazeni
	movwf	dispR	
        call    SendByte7S	;odesle W vzdy do leveho displeje (posun ostat.)
	movf	dispM,W
	call    SendByte7S	;odesle W vzdy do leveho displeje (posun ostat.)
	movf	dispL,W
	call    SendByte7S	;odesle W vzdy do leveho displeje (posun ostat.)
	
	
        call	Delay100	;jen aby u 7seg nesvitily i nepouzite segmenty
       	
        goto    Loop
	
	
	
	
Delay100			;zpozdeni 100 ms
        movlw   .100
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

		
		
		


