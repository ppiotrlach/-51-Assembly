## Podstawy Techniki Mikroprocesorowej - Sprawozdanie

##### Czwartek 11.15 TP Grupa B 
##### Piotr Łach 256761
##### Jakub Szpak 252782

#### Temat: Wyświetlacz LCD

### Zadanie 1

Zadanie pierwsze polegało na napisaniu programu wiążącego guziki przypięte do P3 z wyświetlaczem LCD, ponieważ nie mamy fizycznego dostępu do układu ZD537 linie kodu operujące na nim są w programie zakomentowane, a program symuluje wyświetlanie w pamięci XRAM. Po naciśnięciu jednego z przycisków wyświetla się przypisany do niego tekst (4 przyciski - 4 różne teksty). Naciśnięcie dwóch skrajnych przycisków oznacza wyjście z programu. Warto zaznaczyć, że w programie symulacja naciskania przycisku odbywa się przez przypisanie na odpowiedni adres bitu 1 (Peripherals -> I/O-Ports -> Port 3), a większa część programu to kod prowadzącego. 

```assembly

	;deklaracje tekstów
	text1:  db "AAAAAAAAAA",00
	text2:	db "BBBBBBBBBB",00
	text3:	db "CCCCCCCCCC",00
	text4: 	db "DDDDDDDDDD",00


	...

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
	
	...
```

### Zadanie 2

W zadaniu drugim należało przygotować program realizujący wyświetlanie na ekranie LCD łańcucha znaków znacząco przekraczającego 16 symboli. Tekst jest kolejno:
- wyświetlany w pierwszej linii (16 znaków)
- wyświetlany w drugiej linii (kolejne 16 znaków)
- delay
- kasowanie zawartości wyświetlacza
- wróć do podpunktu 1 z pozostałymi znakami (niewyświetlonymi wcześniej)

Program ma się zakończyć w momencie wyświetlenia wszystkich znaków zdefiniowanego łańcucha.

Jak w zadaniu pierwszym program jest symulacją, kod operujący na samym wyświetlaczu oczywiście jest zawarty w programach (i zakomentowany), ale nie mieliśmy szansy sprawdzić czy wykona on się poprawnie na realnym sprzęcie.

W tym programie kluczową instrukcją jest
 ```assembly
 djnz r4, putstrLCD 
 ```
 która sprawdza czy ostatnio wypisywana linia była w pierwszym czy drugim rzędzie wyświetlacza i na tej podstawie wykonuje odpowiedni skok.

```assembly	
	// deklaracje tekstów
	text1:  db "Pszczolka Maja sobie lata oh oh oh zbiera nektar gdzies na kwiatach a tam Gucio w tulipanie czeka sobie na sniadanie",00

	...

	mov  83h, 05h			; DPH - 83h, r5 - 05h czyli MOV DPH, R5
	mov  82h, 06h			; DPL - 82h, r6 - 06h czyli MOV DPL, R6 ; – wskazuje gotowosc LCD
	  ; symulacja wyswietlacza w pamieci XRAM pod adresem X: 0FF30H
	  
      ; MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
	  ; powyzsza linijka zakomentowana, program jest symulacja wyswietlania na wyswietlaczu LCD

	...

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

```
