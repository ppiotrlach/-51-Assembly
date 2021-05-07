## Podstawy Techniki Mikroprocesorowej - Sprawozdanie

##### Czwartek 11.15 TP Grupa B 
##### Piotr Łach 256761
##### Jakub Szpak 252782

#### Temat: Klawiatura

### Zadanie 1

Zadanie pierwsze polegało na napisaniu programu umożliwiającego wybór i przypisanie do klawiszy klawiatury trzech zestawów symboli, w zależności od kliknięcia przycisku wybranego symbolu specjalnego tzn.:
- przycisk * - małe litery od a do m

| a | b | c | d |
|---|---|---|---|
| e | f | g | h |
| i | j | k | l |
| * | m | # | D |

- przycisk # - duże litery od a do m

| A | B | C | D |
|---|---|---|---|
| E | F | G | H |
| I | J | K | L |
| * | M | # | D |

- przycisk D - standardowy układ klawiatury - cyfry od 0 do 9 oraz znaki A, B, C

| 1 | 2 | 3 | A |
|---|---|---|---|
| 4 | 5 | 6 | B |
| 7 | 8 | 9 | C |
| * | 0 | # | D |

Znaki specjalne nie są wyświetlane tak jak na przykład klawisz Caps Lock. 

```assembly

//kody skaningowe znakow specjalnych
#define ASTERISK 0xE7
#define HASH 0xED
#define LETTER_D 0xEE

...

// tablica przekodowania klawiszy - ASCII w XRAM
smallletters: ;po kliknieciu * - male litery od a do m
			mov dptr, #8077H
			mov a, #"a"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"b"
			movx @dptr, a
			
...

greatletters:;po kliknieciu # duze litery od A do M		
			mov dptr, #8077H
			mov a, #"A"
			movx @dptr, a
			
			mov dptr, #807BH
			mov a, #"B"
			movx @dptr, a
			

...

keyascii:	;po kliknieciu D - cyfry 0-9 oraz znaki A, B, C
			mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"1"
			movx @dptr, a
		
...

// program glówny
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
			
...
			
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
```

### Zadanie 2

W zadaniu drugim należało przygotować program automatycznie przechodzący do drugiej linii po zapełnieniu pierwszej z nich. Następnie w przypadku zapełnienia linii drugiej zawartość wyświetlacza jest czyszczona - tekst wypisywany jest ponownie w pierwszej.

Znaki podawane są przez użytkownika z klawiatury o standardowym formacie:

| 1 | 2 | 3 | A |
|---|---|---|---|
| 4 | 5 | 6 | B |
| 7 | 8 | 9 | C |
| * | 0 | # | D |

<br>
Niezwykle pomocnym okazał się program napisany na poprzednie laboratoria (3) - program drugi, realizujący wyświetlanie na ekranie LCD łańcucha znaków znacząco przekraczającego 16 symboli.

<br> 

W dyrektywie putstrLCD zamieniliśmy wypisanie symbolu z wcześniej zdefiniowanego ciągu znaków umieszczonego w pamięci programu na wypisywanie symbolu z klawiatury.

<br>

```assembly	
...
	mov  83h, 05h			; DPH - 83h, r5 - 05h czyli MOV DPH, R5
	mov  82h, 06h			; DPL - 82h, r6 - 06h czyli MOV DPL, R6 ; – wskazuje gotowosc LCD
	;symulacja wyswietlacza w pamieci XRAM pod adresem X: 0FF30H
	  
    ;MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
	;powyzsza linijka zakomentowana, program jest symulacja wyswietlania na wyswietlaczu LCD
...

keyascii:	mov dptr, #80EBH
			mov a, #"0"
			movx @dptr, a
			
			mov dptr, #8077H
			mov a, #"1"
			movx @dptr, a

...

// program glówny
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
			
	...
			
	checkpoint:
		jmp putstrLCD
			
	...
			
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
            
...
```
Warto zaznaczyć, że bazą napisanych przez nas programów są programy omawiane przez prowadzącego na laboratoriach.
