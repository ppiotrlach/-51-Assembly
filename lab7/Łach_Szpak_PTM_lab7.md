# Podstawy Techniki Mikroprocesorowej - Sprawozdanie

### Czwartek 11.15 TP Grupa B 
### Piotr Łach 256761
### Jakub Szpak 252782

<br>

## Temat: RTC i inne atrakcje

<br>

## Zadanie 1



Zadanie polegało na rozbudowaniu finalnej postaci programu zaprezentowanego na zajęciach o mechanizmy kontroli zakresu wpisanych danych w inicjujący łańcuch ASCII. Dopuszczalne zakresy: 
- sekundy i minuty: 00-59,
- godziny: 00-23,
- dni: 01-31,
- miesiące: 01-12.

Zadanie rozpoczęliśmy od napisania pseudokodu kontrolera dla dni. 

p1.1 - zmienna bool, okreslajaca czy liczba jest na granicy poprawnego zapisania czy juz wystepuje zagrozenie nadmiaru

Jeśli:
  - a <= 2 skocz do wypisywanie_dziesiątek_dni,
  - a == 3 ustaw p1.1 na 1 i skocz do wypisywanie_jedności_dni, gdzie sprawdzona zostanie czy liczba jednosci dni wychodzi poza nadmiar,
  - a > 3 wyzeruj a i idź dalej.
  <br>

- wypisywanie_dziesiątek_dni:
  wyzeruj p1.1
   
   <br>

- liczba_jedności_dni:
    - p1.1 == 1 i a >1  ustaw a = 0, dekrementuj dpl, skocz do wypisywanie_dziesiatek_dni i , 
    - p1.1 == 1 i a <= 1 ustaw a = 3, skocz do wypisywanie_dziesiatek_dni i dekrementuj dpl

- wypisywanie_jedności_dni



Pozostałe kontrolery działają bardzo podobnie - godziny, dni i miesiące. Natomiast jeśli chodzi o sekundy i minuty to jedno porównanie jest wystarczające (liczby dziesiątek z "5"). Dogłębny opis znajduje sie w samym programie. 

Ku naszemu zdziwieniu nie istnieje instrukcja
```
dec dptr
```
Korzystamy więc z 
```
dec dpl
```
która powinna poradzić sobie w większości przypadków, aczkolwiek może zdarzyć się sytuacja, w której dpl będzie 0 a w dph będzie wartość. Wtedy dojdzie do błędu. 

W naszym programie kontrola poprawności odbywa się poprzez sprawdzenie liczby dziesiątek i ewentualne sprawdzenie liczby jedności. Jeżeli nie są spełnione warunki poprawności zerowana jest <b>tylko liczba dziesiątek</b>.

np. dla sekund:
- 69 -> 09 
- 32 -> 32
- 94 -> 04
- 60 -> 00
- 59 -> 59

```assembly
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
```