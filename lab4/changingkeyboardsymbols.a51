ljmp start

P5 equ 0F8H
P7 equ 0DBH
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

//kody skaningowe znakow specjalnych
#define ASTERISK 0xE7
#define HASH 0xED
#define LETTER_D 0xEE

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
                            ; � wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
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

// tablica przekodowania klawisze - ASCII w XRAM
smallletters: ;po kliknieciu * - male litery od a do m
			mov dptr, #8077H
			mov a, #"a"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"b"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"c"
			movx @dptr, a
			
			mov dptr, #807EH
			mov a, #"d"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"e"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"f"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"g"
			movx @dptr, a
			
			mov dptr, #80BEH
			mov a, #"h"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"i"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"j"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"k"
			movx @dptr, a
			
			mov dptr, #80DEH
			mov a, #"l"
			movx @dptr, a
			
			mov dptr, #80EBH
			mov a, #"m"
			movx @dptr, a
		
			ret

greatletters:;po kliknieciu # duze litery od A do M		
			mov dptr, #8077H
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"B"
			movx @dptr, a
			
			mov dptr, #807DH
			mov a, #"C"
			movx @dptr, a
			
			mov dptr, #807EH
			mov a, #"D"
			movx @dptr, a
			
			mov dptr, #80B7H
			mov a, #"E"
			movx @dptr, a
			
			mov dptr, #80BBH
			mov a, #"F"
			movx @dptr, a
			
			mov dptr, #80BDH
			mov a, #"G"
			movx @dptr, a
			
			mov dptr, #80BEH
			mov a, #"H"
			movx @dptr, a
			
			mov dptr, #80D7H
			mov a, #"I"
			movx @dptr, a
			
			mov dptr, #80DBH
			mov a, #"J"
			movx @dptr, a
			
			mov dptr, #80DDH
			mov a, #"K"
			movx @dptr, a
			
			mov dptr, #80DEH
			mov a, #"L"
			movx @dptr, a
			
			mov dptr, #80EBH
			mov a, #"M"
			movx @dptr, a
		
			ret



keyascii:	;po kliknieciu D - cyfry 0-9 oraz znaki A, B, C
			mov dptr, #80EBH
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
			
			ret
 
// program gl�wny
    start:  init_LCD
	
	callkeyascii:
			acall keyascii
			jmp key_1
			
	callsmallletters:
			acall smallletters
			jmp key_1
	
	callgreatletters:
			acall greatletters
			
			
			
	
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
			acall putcharLCD
			;acall delay
			
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
			acall putcharLCD
			;acall delay
			
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
			acall putcharLCD
			;acall delay
			
	key_4:	mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			mov r2, a
			clr c
			subb a, r0
			jz key_1 ;skok jesli nie kliknieto nic
			
			;sprawdzenie czy kliknieto "*", kod skaningowy = 0xE7
			mov a, r2
			clr c
			subb a, #ASTERISK
			jz callsmallletters
			
			;sprawdzenie czy kliknieto "#", kod skaningowy = 0xED
			mov a, r2
			clr c
			subb a, #HASH
			jz callgreatletters
			
			;sprawdzenie czy kliknieto "D", kod skaningowy = 0xEE
			mov a, r2
			clr c
			subb a, #LETTER_D
			jz callkeyascii
			
			
			;ostatni przypadek to wyswietlenie znaku niefunkcjonalnego
			mov a, r2
			mov dph, #80h
			mov dpl, a
			movx a,@dptr
			mov P1, a
			
			acall putcharLCD
			
			jmp key_1
            
          
 
    nop
    nop
    nop
    jmp $
    end start