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


//kody skaningowe znakow specjalnych
#define LETTER_A 0x7E
#define LETTER_D 0xEE

#define START_STATE 0x01 ; decydujaca czy program rozpoczyna sie z wlaczonym czasomierzem


ORG 000BH     				; obsluga przerwania
	MOV TH0, #3CH 			; przeladowanie
	MOV TL0, #0B0H 			; stalej timera na 50ms
	DEC R0        			; korekta licznika
	RETI          			; powrót z przerwania

org 0100H
		
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
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD – znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR – konfiguracja kursora
         ENDM
		 
// funkcja wypisania liczby dla potrzeb zegara
putdigitLCD:	mov b, #10
				div ab				; uzyskanie cyfry dziesiatek
				add a, #30H			; konwersja cyfry na kod ASCII
				acall putcharLCD
				mov a, b			; ladowanie cyfry jednosci
				add a, #30H			; konwersja na LCD
				acall putcharLCD
				ret

// funkcaj wypisywania znaku na LCD
putcharLCD:	;LCDcharWR
			ret
		 

// wyznaczanie biezacej wartosci zegara i jego wyswietlanie na LCD
ZEGAR:		INC R7				; licznik sekund
			MOV A, R7			; obsluga sekund
			CLR C
			SUBB A, #60			; przepelnienie sekund
			JZ MINUTY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
			JMP FINAL
MINUTY:		MOV R7, #00H		; zerowanie sekund
			INC R6				; licznik minut
			MOV A, R6			; obsluga minut
			CLR C
			SUBB A, #60			; przepelnienie minut
			JZ GODZINY
			LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
			JMP FINAL
GODZINY:	MOV R6, #00H		; zerowanie minut
			INC R5				; licznik godzin
			MOV A, R5
			CLR C
			SUBB A, #24			; przepelenienie godzin - doba
			JNZ EKRAN
			MOV R5, #00H		; zerowanie godzin
EKRAN:		LCDcntrlWR #HOME	; wyswietlenie calego zegara
			MOV A, R5			; godziny
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R6			; minuty
			ACALL putdigitLCD
			MOV A, #":"			; separator
			ACALL putcharLCD
			MOV A, R7			; sekundy
			ACALL putdigitLCD
FINAL:		RET
	


        ; program glówny
START:	init_LCD
		MOV r1, #START_STATE 	; zmienna stala zdefiniowana na gorze, decydujaca czy program rozpoczyna sie z wlaczonym czasomierzem
		MOV TMOD, #01H 			; konfiguracja timera
		MOV TH0, #3CH 			; ladowanie
		MOV TL0, #0B0H 			; stalej timera na 50ms
		SETB TR0      			; timer start
		MOV IE, #82H  			; przerwania wlacz
		MOV R5, #00H			; inicjacja zegara
		MOV R6, #00H
		MOV R7, #0FFH
		ACALL ZEGAR			; wyswietlenie zainicjowanego zegara
		MOV A, #0FH
		MOV P1, A    			; zapalenie diód
		MOV R0, #20 			; licznik odmierzen 20 x 50ms
CZEKAM: MOV A, R0   			; czekam, a timer
		;JNZ CZEKAM   			; mierzy laczny czas 1s
		DJNZ R0, CZEKAM   		; na potrzebe testowania zmienilismy te linijke, aby oprocz skoku warunkowego, dekrementowala R0
		MOV R0, #20				; po zgloszeniu przerwania - ustawiam na nowo licznik odmierzen 20 x 50ms
		ACALL ZEGAR				; uruchomienie procedury oblugi i wyswietlenia zegara
		MOV A, P1  				; zmiana
		CPL A       			; swiecenia
		MOV P1, A    			; diód
		
		;----------------------------
		
	; zmienna r1 swiadczy o tym czy program aktualnie dziala w stanie START czy STOP
	; init: r1 -> 1 zegar chodzi
	; D: r1 -> 0 zegar stop
	; A: r1 -> 1 zegar start
		
	
	key_1:
			mov r0, #LINE_1 ;0111 1111 sterowanie na p5
			mov	a, r0
			mov	P5, a ;linia 1 na p5
			mov a, P7 ;wartosc p7 do a
			anl a, r0 ;and p7 i p5
			
			;sprawdzenie czy kliknieto "A", kod skaningowy = 0x7E
			clr c
			subb a, #LETTER_A
			jz key_4
			
			; jesli nie wcisnieto przycisku A sprawdz czy program nie jest w stanie zegara STOP (0)
			; jesli r1 rowne zero - zegar stop - petla powraca do key_1
			mov a, r1
			jz key_1
			;acall delay		

			
	key_4:	mov r1, #01 ; jesli program kiedykolwiek dochodzi do tej linijki oznacza to, ze przycisk STOP nie byl klikniety ani razu
						; lub ze petla w key_1 zostala przerwana wcisnieciem A -> wtedy ustawiamy r1 zeby wskazywalo na stan zegara - START (1)
			mov r0, #LINE_4
			mov	a, r0
			mov	P5, a
			mov a, P7
			anl a, r0
			
			;sprawdzenie czy kliknieto "D", kod skaningowy = 0xEE
			clr c
			subb a, #LETTER_D	
			jnz CZEKAM ; jesli nie wcisnieto przycisku to skocz do aktualizacji zegara
			; jesli wcisnieto przycisk D to ustaw stan zegara r1 na STOP (0) i wykonuj petle key_1 do momentu wcisniecia przycisku A
			MOV r1, #00
			jmp key_1	
		;----------------------------		
		
		
		
		NOP
		NOP
		NOP
		JMP $
END START