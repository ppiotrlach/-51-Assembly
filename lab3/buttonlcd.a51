ljmp start

LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF3DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to first line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	
	;deklaracje tekstów
	text1:  db "AAAAAAAAAA",00
	text2:	db "BBBBBBBBBB",00
	text3:	db "CCCCCCCCCC",00
	text4: 	db "DDDDDDDDDD",00
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x – parametr wywolania macra – bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra–bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
							
							
							
	  mov  83h, 06h			; DPH - 83h, r6 - 06h czyli MOV DPH, R6
	  mov  82h, 07h			; DPL - 82h, r7 - 07h czyli MOV DPL, R7
	  ;symulacja wyswietlacza w pamieci XRAM pod adresem X: 0FF30H
	 
      ;MOV  DPTR,#LCDdataWR ; DPTR zaladowany adresem do podania bajtu sterujacega
	  ;program jest symulacja wyswietlania na wyswietlaczu LCD
	  
	  
	  
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD – znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR – konfiguracja kursora
         ENDM

// funkcja opóznienia
	delay:	mov r0, #15H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			djnz r0, one
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret
			
//funkcja wypisania lancucha znaków		
putstrLCD:  mov r7, #30h	; DPL ustawiony tak by byl w DPRT adres FF30H
// -> DPH o DPL
nextchar:	clr a
			movc a, @a+dptr
			jz koniec
			push dph
			push dpl
			acall putcharLCD
			pop dpl
			pop dph
			inc r7			; dzieki temu mozliwa inkrementacja DPTR
			inc dptr
			sjmp nextchar
	koniec: ret

	;kod powyzej to wlasnosc prowadzacego

	start:	
	//init_LCD

	
	;LCDcntrlWR #CLEAR ;wyczysc zawartosc wyswietlacza
	;LCDcntrlWR #HOME ;ustaw kursor na pierwsza linie wyswietlacza
	
	clr p3.2 ;ustaw p3.2 na 0
	clr p3.3
	clr p3.4
	clr p3.5
	
	
	wait_for_input:
	;acall delay
	mov r6, #0FFH	; adres LCDdataWR equ 0FF30H jest w parze R6-R7
	mov r7, #30H
	
	
	jb p3.2, print_text1 ;jesli bit p3.2 ustawiony na 1 przejdz do print_text1
	jb p3.3, print_text2 
	jb p3.4, print_text3 
	jb p3.5, print_text4 
	sjmp wait_for_input
	
	
print_text4:
	mov dptr, #text4 ;wskaz dptr text4
	acall putstrLCD ;wywolaj putstrLCD
	;acall delay
	ljmp wait_for_input ;skocz do start
	
print_text3:
	mov dptr, #text3 
	acall putstrLCD 
	;acall delay
	ljmp wait_for_input	
	
print_text2:
	mov dptr, #text2 
	acall putstrLCD 
	;acall delay
	ljmp wait_for_input
	
print_text1:
	jb p3.5, exit ;jesli p3.5 (rowniez p3.2) ustawiony na 1, zakoncz program
	mov dptr, #text1 
	acall putstrLCD 
	;acall delay
	ljmp wait_for_input		
	
	


exit:	
	nop
	nop
	nop
	jmp $
	end start