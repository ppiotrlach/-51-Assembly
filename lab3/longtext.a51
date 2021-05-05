ljmp start

LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	
// deklaracje tekstów
	text1:  db "Pszczolka Maja sobie lata oh oh oh zbiera nektar gdzies na kwiatach a tam Gucio w tulipanie czeka sobie na sniadanie",00
		
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
	  
	  
	  
      mov  83h, 05h			; DPH - 83h, r5 - 05h czyli MOV DPH, R5
	  mov  82h, 06h			; DPL - 82h, r6 - 06h czyli MOV DPL, R6 ; – wskazuje gotowosc LCD
	  ; symulacja wyswietlacza w pamieci XRAM pod adresem X: 0FF30H
	  
      ; MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
	  ; powyzsza linijka zakomentowana, program jest symulacja wyswietlania na wyswietlaczu LCD
	  
	  
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
			
//funkcja wypisania lancucha znaków dowlonej dlugosci w pamieci XRAM na 32 bajtach zaczynajac od adresu 0FF30h
putstrLCD:
		mov r5, #0FFH ; adres LCDdataWR equ 0FF0H jest w parze r5-r6
		mov r6, #30H 
		push dph
		push dpl ; odlozenie wskaznika dptr na stos przed uzyciem MACRO
		LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		pop dpl 
		pop dph ; zdjecie ze stosu wskaznika dptr
		mov r4, #1H ; r4 jest miernikiem czy "petla" nextword wykonuje sie po raz pierwszy czy drugi
		; jesli jest to pierwsze przejscie, na pierwszej linijce wyswietlacza to w r4 jest wartosc 1 i po operacji djnz r4 putstrLCD(ktora dekrementuje r4 przed porownaniem)
		; nie wykona sie skok do putstrLCD i nastapia operacje przenoszace wskaznik w wyswietlaczu na druga linie oraz wypisanie na niej kolejnych 16B tekstu
		; ponowne dojscie programu do linii djnz r4, putstrLCD wykona skok do putstrLCD
nextword:
		mov r7, #10H ; licznik r7 odlicza 16 bajtow czyli tyle ile miescie sie w jednej linii na wyswietlaczu
nextchar:
		clr a
		movc a, @a+dptr
		jz koniec ; skok do konca jesli wskaznik doszedl do 0 konczacego tekst
		push dph
		push dpl
		acall putcharLCD ; wypisanie jednej literki
		pop dpl
		pop dph
		inc r6 ; inkrementacja miejsca w ktore wpisujemy tekst
		inc dptr ; inkrementacja wskaznika na aktualnie wypisywana litere w slowie 
		djnz r7, nextchar ; jesli wskaznik doszedl od 16 do 0 to znaczy ze nalezy zmienic linie
		djnz r4, putstrLCD ; ta petla zostala wytlumaczona nad dyrektywa nextword:
		push dph
		push dpl
		LCDcntrlWR #HOM2 ; przeskok do nowej linii
		pop dpl
		pop dph
		; acall delay
		sjmp nextword
	koniec: ret

// program glówny
	start:	init_LCD
	
		mov dptr, #text1
		acall putstrLCD
		; acall delay
			
	nop
	nop
	nop
	jmp $
	end start