ljmp start

P5 equ 0F8H
P7 equ 0DBH
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

// linie klawiatury - sterowanie na port P5
#define LINE_1		0x7f	// 0111 1111
#define LINE_2		0xbf	// 1011 1111
#define	LINE_3		0xdf	// 1101 1111
#define LINE_4		0xef	// 1110 1111
#define ALL_LINES	0x0f	// 0000 1111

org 0100H
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x � parametr wywolania macra � bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powt�rzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra�bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD � zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powt�rzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
	  
	  
	  
      mov  83h, 05h			; DPH - 83h, r5 - 05h czyli MOV DPH, R5
	  mov  82h, 06h			; DPL - 82h, r6 - 06h czyli MOV DPL, R6 ; � wskazuje gotowosc LCD
	  ; symulacja wyswietlacza w pamieci XRAM pod adresem X: 0FF30H
	  
      ; MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
	  ; powyzsza linijka zakomentowana, program jest symulacja wyswietlania na wyswietlaczu LCD
	  
	  
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD � znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza � bez parametr�w
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR � inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR � czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR � konfiguracja kursora
         ENDM

// funkcja op�znienia

	delay:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
		ret

	

keyascii:	mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"1"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"2"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"3"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"4"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"5"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"6"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"7"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"8"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"9"
			movx @dptr, a
			
			mov dptr, #807EH
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #80BEH
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #80DEH
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #80EEH
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80E7H
			mov a, #"*"
			movx @dptr, a
			
			mov dptr, #80EDH
			mov a, #"#"
			movx @dptr, a
			
			ret
			
// program gl�wny
    start:  init_LCD
	
		acall keyascii
		
		putstrLCD:
	
		mov r5, #0FFH ; adres LCDdataWR equ 0FF0H jest w parze r5-r6
		mov r6, #30H 
		LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		mov r4, #1H ; r4 jest miernikiem czy "petla" nextword wykonuje sie po raz pierwszy czy drugi
		; jesli jest to pierwsze przejscie, na pierwszej linijce wyswietlacza to w r4 jest wartosc 1 i po operacji djnz r4 putstrLCD(ktora dekrementuje r4 przed porownaniem)
		; nie wykona sie skok do putstrLCD i nastapia operacje przenoszace wskaznik w wyswietlaczu na druga linie oraz wypisanie na niej kolejnych 16B tekstu
		; ponowne dojscie programu do linii djnz r4, putstrLCD wykona skok do putstrLCD
	nextword:
		mov r7, #10H ; licznik r7 odlicza 16 bajtow czyli tyle ile miescie sie w jednej linii na wyswietlaczu
	nextchar:
		clr a
		
	key_1:	mov r0, #LINE_1 ;0111 1111 sterowanie na p5
			mov	a, r0
			mov	P5, a ;linia 1 na p5
			mov a, P7 ;wartosc p7 do a
			anl a, r0 ;and p7 i p5
			mov r2, a ;wynik do r2 na pozniej
			clr c
			subb a, r0 ;sprawdzenie czy cokolwiek bylo klikniete
			jz key_2 ;jesli nie skocz do key2
			mov a, r2 ;jesli tak przywroc wartosc do a
			mov dph, #80h 
			mov dpl, a ;dpl = kod skaningowy klawisza
			movx a,@dptr ; ascii klawisza do a
			mov P1, a ; wyswietl na p1
			jmp print
			
	key_2:	mov r0, #LINE_2
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_3
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			jmp print
			
	checkpoint:
		jmp putstrLCD
			
	key_3:	mov r0, #LINE_3
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_4
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			jmp print
			
	key_4:	mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_1
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			jmp print
			
			jmp key_1
			
		print:
			
		acall putcharLCD ; wypisanie jednej literki
		inc r6 ; inkrementacja miejsca w ktore wpisujemy tekst
		djnz r7, nextchar ; jesli wskaznik doszedl od 16 do 0 to znaczy ze nalezy zmienic linie
		
		djnz r4, checkpoint ; ta petla zostala wytlumaczona nad dyrektywa nextword:
		LCDcntrlWR #HOM2 ; przeskok do nowej linii
		; acall delay
		sjmp nextword
            
          
	koniec:
    nop
    nop
    nop
    jmp $
    end start