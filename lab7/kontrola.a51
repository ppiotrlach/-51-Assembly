ljmp start
	
LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

RTCxs equ 0FF00H	; seconds
RTCsx equ 0FF01H
RTCxm equ 0FF02H	; minutes
RTCmx equ 0FF03H
RTCxh equ 0FF04H	; hours
RTChx equ 0FF05H
RTCxd equ 0FF06H	; day
RTCdx equ 0FF07H
RTCxn equ 0FF08H	; month
RTCnx equ 0FF09H
RTCxy equ 0FF0AH	; year
RTCyx equ 0FF0BH
RTCdw equ 0FF0CH	; day of week
RTCpf equ 0FF0FH

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	Czas: db "13:40:00"
	Dzien: db "29:05:2021*4"
	Month: db "JanFebMarAprMayJunJulAugSepOctNovDec"
	Week: db "SunMonTueWedThuFriSat"
	TwentyH: db 02
	TwentyL: db 00
		
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

// macro do wypisywania polowki wskazania pozycji czasu lub daty
disp_nibble MACRO
	movx A,@DPTR
	anl A,#0Fh	; select 4-bits
	orl A,#30H	; change to ASCII
	call putcharLCD
	ENDM

// funkcja wypisywania znaku na LCD
putcharLCD:	LCDcharWR
			ret
		 
// wypisywanie czasu
disp_time:
		LCDcntrlWR #HOME
		mov DPTR,#RTChx	; get hours from RTC (higher nibble)
		disp_nibble
		mov DPTR,#RTCxh	; get hours from RTC (lower nibble)
		disp_nibble
		mov A,#':'
		call putcharLCD
		mov DPTR,#RTCmx	; get minutes from RTC (higher nibble)
		disp_nibble
		mov DPTR,#RTCxm	; get minutes from RTC (lower nibble)
		disp_nibble
		mov A,#':'
		call putcharLCD;
		mov DPTR,#RTCsx	; get seconds from RTC (higher nibble)
		disp_nibble
		mov DPTR,#RTCxs	; get seconds from RTC (lower nibble)
		disp_nibble
		RET

// wypisywanie dnia tygodnia slownie
week_word:
		mov DPTR,#RTCdw	; get day of week from RTC
		movx a, @DPTR
		anl a, #0FH
		mov b, #03
		mul ab
		mov r7,a
		mov DPTR,#Week
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		acall putcharLCD
		ret
		
// wypisywanie nazwy miesiaca slownie
month_word:
		mov DPTR,#RTCnx	; get month from RTC (higher nibble)
		movx a, @DPTR
		anl a, #0FH
		mov b, #10
		mul ab
		mov r7,a
		mov DPTR,#RTCxn	; get month from RTC (lower nibble)
		movx a, @DPTR
		anl a, #0FH
		add a,r7
		clr c
		subb a, #01
		mov b, #03
		mul ab
		mov r7,a
		mov DPTR,#Month
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		push dph
		push dpl
		acall putcharLCD
		pop dpl
		pop dph
		inc dptr
		mov a,r7
		movc a,@a+dptr
		acall putcharLCD
		ret

// wypisywanie daty
disp_date:
	LCDcntrlWR #HOM2
	mov DPTR,#RTCdx	; get day from RTC (higher nibble)
	disp_nibble
	mov DPTR,#RTCxd	; get day from RTC (lower nibble)
	disp_nibble
	mov A,#'-'
	call putcharLCD
	acall month_word
	mov A,#'-'
	call putcharLCD;
	mov DPTR,#TwentyH
	disp_nibble
	mov DPTR,#TwentyL
	disp_nibble
	mov DPTR,#RTCyx	; get year from RTC (higher nibble)
	disp_nibble
	mov DPTR,#RTCxy	; get year from RTC (lower nibble)
	disp_nibble
	mov A,#" "
	call putcharLCD;
	acall week_word
	RET

// inicjalizacja czasu
czas_start:
		mov DPTR, #RTCpf ; 24h zegar
		movx a, @DPTR
		orl a, #04H
		movx @DPTR, a
		clr c
		clr a
		mov dptr, #Czas
		movc a, @a+dptr	; dziesiatki godzin
		subb a, #30h
		clr P1.1


		cjne a, #2h, sprawdz_czy_liczba_dziesiatek_godziny_wieksza_czy_mniejsza_2
		setb P1.1
		sjmp wypisywanie_jednosci_godziny
sprawdz_czy_liczba_dziesiatek_godziny_wieksza_czy_mniejsza_2:
	jc wypisywanie_dziesiatek_godziny
	mov a, #0h
	
	
wypisywanie_dziesiatek_godziny:
		clr P1.1
		push dph
		push dpl
		mov dptr, #RTCdx
		movx @dptr, a
		pop dpl
		pop dph
wypisywanie_jednosci_godziny:
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci dni
		subb a, #30h
		JNB P1.1, dalej_godziny
		cjne a, #3h, sprawdz_czy_liczba_jednosci_godziny_wieksza_czy_mniejsza_3
		dec dpl ; lepsze byloby dec dptr
		mov a, #2h
		sjmp wypisywanie_dziesiatek_godziny
sprawdz_czy_liczba_jednosci_godziny_wieksza_czy_mniejsza_3:
		jc liczba_jednosci_godziny_mniejsza_niz_3
		dec dpl ; lepsze byloby dec dptr
		mov a, #0h
		sjmp wypisywanie_dziesiatek_godziny
liczba_jednosci_godziny_mniejsza_niz_3:
		dec dpl ; lepsze byloby dec dptr
		mov a, #2h
		sjmp wypisywanie_dziesiatek_godziny
		
dalej_godziny:	
		push dph
		push dpl
		mov dptr, #RTChx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci godzin
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCxh
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		
		
		; minuty
		movc a, @a+dptr	; dziesiatki minut
		subb a, #30h
		cjne a, #5, potencjalnie_za_duzo_minut
		sjmp dalsze_wypisywanie_minut
potencjalnie_za_duzo_minut:
		; jesli c = 1, liczba dziesiatek minut < 5, mozna przejsc dalej
		jc dalsze_wypisywanie_minut
		; jesli kursor w tym miejsce to a > 5
		mov a, #0h
dalsze_wypisywanie_minut:
		push dph
		push dpl
		mov dptr, #RTCmx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci minut
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCxm
		movx @dptr, a
		pop dpl
		pop dph		
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		
		
		; sekundy
		movc a, @a+dptr	; dziesiatki sekund
		subb a, #30h
		cjne a, #5, potencjalnie_za_duzo_sekund
		sjmp dalsze_wypisywanie_sekund
potencjalnie_za_duzo_sekund:
		; jesli c = 1, liczba dziesiatek sekund < 5, mozna przejsc dalej
		jc dalsze_wypisywanie_sekund
		; jesli kursor w tym miejsce to a > 5
		mov a, #0h
dalsze_wypisywanie_sekund:
		push dph
		push dpl
		mov dptr, #RTCsx
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci sekund
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCxs
		movx @dptr, a
		pop dpl
		pop dph
		ret

// inicjalizacja daty
data_start:	clr c
		clr a
		mov dptr, #Dzien
		movc a, @a+dptr	; dziesiatki dni
		subb a, #30h
		clr P1.1 ; zmienna bool, okreslajaca czy liczba jest na granicy poprawnego zapisania czy juz wystepuje zagrozenie nadmiaru
		cjne a, #3h, sprawdz_czy_liczba_dziesiatek_dni_wieksza_czy_mniejsza_3
		setb P1.1
		sjmp wypisywanie_jednosci_dni
		;jesli trafimy na 2 lub mniej - jest ok - przechodzimy do wypisywania dziesiatek
		;jesli trafimy na 3 - P1.1 = true, skok do wypisywanie jednosci, gdzie sprawdzona zostanie czy liczba jednosci dni wychodzi poza nadmiar
		;jesli trafimy na 4 lub wiecej, a = 0 i wypiszemy je w miejsce dziesiatek
sprawdz_czy_liczba_dziesiatek_dni_wieksza_czy_mniejsza_3:
	; jesli a nie rowna sie 3 to sprawdz czy bylo wieksze czy mniejsze
	jc wypisywanie_dziesiatek_dni
	; jest wieksza niz 3
	mov a, #0h
	
wypisywanie_dziesiatek_dni:
		;jest mniejsze niz 3
		; P1.1 = false
		clr P1.1
		push dph
		push dpl
		mov dptr, #RTCdx
		movx @dptr, a
		pop dpl
		pop dph
wypisywanie_jednosci_dni:
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci dni
		subb a, #30h
		; jesli P1.1 == true, dec dptr i dzien > 1  => a = 0, powrot do wypisywania dziesiatek
		; jesli P1.1 == true, dec dptr i dzien <= 1 => a = 3 , powrot do wypisywania dziesiatek
		JNB P1.1, dalej_dni
		; kursor w tym miejsce oznacza ze P1.1 = true
		cjne a, #1h, sprawdz_czy_jednosci_dni_mniejsze_czy_wieksze_niz_1
		dec dpl ; lepsze byloby dec dptr
		mov a, #3h
		sjmp wypisywanie_dziesiatek_dni
sprawdz_czy_jednosci_dni_mniejsze_czy_wieksze_niz_1:
		jc liczba_jednosci_dni_mniejsza_niz_1
		dec dpl ; lepsze byloby dec dptr
		mov a, #0h
		sjmp wypisywanie_dziesiatek_dni
liczba_jednosci_dni_mniejsza_niz_1:
		dec dpl ; lepsze byloby dec dptr
		mov a, #3h
		sjmp wypisywanie_dziesiatek_dni	
		
dalej_dni:
		push dph
		push dpl
		mov dptr, #RTCxd
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		
		; miesiace
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr	; dziesiatki miesiaca
		subb a, #30h
		clr P1.1
		cjne a, #1h, sprawdz_czy_liczba_dziesiatek_miesiecy_wieksza_czy_mniejsza_1
		setb P1.1
		sjmp wypisywanie_jednosci_miesiaca
sprawdz_czy_liczba_dziesiatek_miesiecy_wieksza_czy_mniejsza_1:
	jc wypisywanie_dziesiatek_miesiaca
	mov a, #0h
	
wypisywanie_dziesiatek_miesiaca:
		clr P1.1
		push dph
		push dpl
		mov dptr, #RTCdx
		movx @dptr, a
		pop dpl
		pop dph
wypisywanie_jednosci_miesiaca:
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci dni
		subb a, #30h
		JNB P1.1, dalej_miesiac
		cjne a, #2h, sprawdz_czy_liczba_jednosci_miesiecy_wieksza_czy_mniejsza_2
		dec dpl ; lepsze byloby dec dptr
		mov a, #1h
		sjmp wypisywanie_dziesiatek_miesiaca
sprawdz_czy_liczba_jednosci_miesiecy_wieksza_czy_mniejsza_2:
		jc liczba_jednosci_miesiecy_mniejsza_niz_2
		dec dpl ; lepsze byloby dec dptr
		mov a, #0h
		sjmp wypisywanie_dziesiatek_miesiaca
liczba_jednosci_miesiecy_mniejsza_niz_2:
		dec dpl ; lepsze byloby dec dptr
		mov a, #1h
		sjmp wypisywanie_dziesiatek_miesiaca
		
		
dalej_miesiac:
		push dph
		push dpl
		mov dptr, #RTCxn
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr ; cyfra tysiecy roku
		inc dptr
		clr a
		movc a, @a+dptr ; cyfra setek roku
		inc dptr
		clr a
		movc a, @a+dptr	; dziesiatki roku
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCyx
		movx @dptr, a
		pop dpl
		pop dph		
		inc dptr
		clr a
		movc a, @a+dptr	; jednosci roku
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCxy
		movx @dptr, a
		pop dpl
		pop dph
		inc dptr
		clr a
		movc a, @a+dptr ; separator
		inc dptr
		clr a
		movc a, @a+dptr	; dzien tygodnia
		subb a, #30h
		push dph
		push dpl
		mov dptr, #RTCdw
		movx @dptr, a
		pop dpl
		pop dph	
		ret


        ; program glówny
start:	init_LCD

		acall czas_start
		acall data_start

		
czas_plynie:	acall disp_time
				acall disp_date
				sjmp czas_plynie
		NOP
		NOP
		NOP
		JMP $
END START