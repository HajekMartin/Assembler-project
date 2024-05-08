;RS-KO pomoci preruseni pozitivni hrana na BT1 (SET) a negativni hrana na BT2 (RST)
    list	p=16F1508
    #include    "p16F1508.inc"

    #define	LED1	PORTC,5
    
   
    __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _BOREN_OFF & _CLKOUTEN_OFF & _IESO_OFF & _FCMEN_OFF

    __CONFIG _CONFIG2, _WRT_OFF & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

;VARIABLE DEFINITIONS
;COMMON RAM 0x70 to 0x7F
    CBLOCK	0x70
	tmp
    ENDC
    
;**********************************************************************
	ORG     0x00
  	goto    Start
	
	ORG     0x04
	movlb	.7		;Banka7 s IOC
	btfss	IOCAF,4		;preruseni od BT1(RA4)?
	goto	BT2Int		;je to tedy od BT2...
	bcf	IOCAF,4		;vynulovat priznak od BT1(RA4)
	movlb	.0		;Banka0 s PORT
	bsf	LED1
  	retfie
	
BT2Int	bcf	IOCAF,5		;vynulovat priznak od BT2(RA5)
	movlb	.0		;Banka0 s PORT
	bcf	LED1
	retfie
	
	
	
	
	
	
Start	movlb	.1		;Banka1
	movlw	b'01101000'	;4MHz Medium
	movwf	OSCCON		;nastaveni hodin

	call	Config_IOs
	
	;nastaveni preruseni
	movlb	.7		;Banka7 s IOC
	bsf	IOCAP,4		;BT1(RA4) nastavena detekce pozitivni hrany P-Positive hrana
	bsf	IOCAN,5		;BT2(RA5) nastavena detekce negativni hrany N-Negative hrana
	clrf	IOCAF		;smazat priznak doted detekovanych hran
	
	bsf	INTCON,IOCIE	;povolit preruseni od IOC
	bsf	INTCON,GIE	;povolit preruseni jako takove	
	
	movlb	.0		;Banka0 s PORT
	
	
Main	goto    $		;stale opakovat smycku (jakoby while(1))
	
	
    #include	"Config_IOs.inc"
    
		
	END

		
		
		


