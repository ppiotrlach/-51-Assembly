## Podstawy Techniki Mikroprocesorowej - Sprawozdanie

##### Czwartek 11.15 TP Grupa B 
##### Piotr Łach 256761
##### Jakub Szpak 252782

#### Temat: Arytmetyka, logika, pamięć, diody i brzęczyki

### Zadanie 1

Zadanie pierwsze polegało na napisaniu programu odejmującego dwie liczby 16-bitowe. Bliźniaczy program (dodający dwie liczby 16-bitowe) przedstawił nam na laboratoriach prowadzący, stąd wykonanie tego zadania nie stanowiło dla nas problemu. 

```assembly
    
    ;1 liczba = 8 starszych bitow w r0, 8 mlodszych bity w r1 np 0x4321
	;2 liczba = 8 starszych bitow w r2, 8 mlodszych bitow w r3 np 0x1234
	;wynik w r4 (8 starszych bitow), r5 (8 mlodszych bitow)
	
	mov r0, #43h
	mov r1, #21h
	
	mov r2, #12h
	mov r3, #34h
	
	mov a, r1
	subb a, r3          ;A ← A − R3 − CY, A=R1, CY = 0, po wykonaniu tego rozkazu flaga CY = 1 
                        ;(0x21-0x34, odejmujemy większą liczbę od mniejszej)
	mov r5, a           ;wynik zapisz w r5
	
	mov a, r0
	subb a, r2          ;A ← A − R2 − CY,A = R0 CY = 1
	mov r4, a           ;wynik zapisz w r4
```

Rezultat wykonania powyższego fragmentu kodu:
r4 = 0x30
r5 = 0xed

0x4321 - 0x1234 = 0x30ed

### Zadanie 2

W zadaniu drugim należało przygotować program realizujący sortowanie bąbelkowe lub znajdujący minimum albo maksimum tablicy 1-wymiarowej rozpoczynającej się od adresu 8000H pamięci zewnętrznej danych (XRAM) i obejmującej 16 kolejnych komórek tej tablicy. Wybraliśmy wariant znajdujący maksimum.

```assembly	
	dane: db 4,2,6,8,10,12,14,16,1,3,5,7,9,11,13,15,00	
	start:	
	
	mov dptr, #8000h	; wskazanie dptr pierwszej interesujacej nas komorki pamieci
	
	;zaladowanie danych testowych (wartosci od 1 do 16) [4,2,6,8,10,12,14,16,1,3,5,7,9,11,13,15]
	
	push dph			; zapisanie aktualnej wartosci wskaznika dptr na stosie
	push dpl			; -- || --
	mov a, #00h
	mov r0, #00h
	load:
	mov dptr, #dane		; ustawienie dptr na pierwsza wartosc tablicy w pamieci kodu
	mov a, r0
	movc a, @a+dptr		; przeniesienie wartosci z pamieci kodu do akumulatora przesuniete o wartosc a
	jz init				; skok jesli a == 0, ostatnia wartosc tablicy musi byc 0 (gwarancja)
	
	pop dpl				; zdjecie wskaznika dptr ze stosu
	pop dph				; -- || --
	movx @dptr, a		; wpisanie wartosci akumulatora do XRAM
	inc dptr			
	push dph
	push dpl
	inc r0
	sjmp load			
	
	init:
	mov dptr, #8000h    ;po inkrementacjach dptr powrot do pierwszej komorki
	movx a, @dptr
	mov r1, a	        ;przypisanie wartosci pierwszej komorki pamieci zewnetrznej XRAM do r1,
	                    ;po wykonaniu programu w r1 bedzie znajdowac sie najwyzsza wartosc 
                        ;sposrod komorek X: 0x8000 - 0x800F
	
	
	mov r0,#10h			;r0 = liczba elementow do sprawdzenia 0x10 = 16
	loop:
	inc dptr
	movx a, @dptr
	mov r2, a
	subb a, r1 
	jc loop_continue    ;jesli a jest mniejsze od r1 flaga cy zostanie ustawiona na 1 po operacji 
                        ;odejmowania -> przeskocz do loop2 nie nadpisujac rejestru r1
			
	mov a ,r2           ;jesli a jest wieksze wykona sie ten kod programu 
	mov r1, a           ;i wartosc r1 zostanie nadpisana wartoscia wieksza
	
	loop_continue:
	dec r0
	mov a, r0
	jz exit              ;zakoncz program jesli a == 0 (jesli r0 == 0), kiedy sprawdzone
                         ;zostaly wszystkie interesujace nas komorki
	ljmp loop
	
			exit:
```

Rezultatem wykonania powyższego fragmentu kodu jest umiejscowienie najwyższej wartości spośród komórek X: 0x8000 - 0x800F w rejestrze r1. Dla danych testowych [4,2,6,8,10,12,14,16,1,3,5,7,9,11,13,15] jest to oczywiście 16, czyli 0x10.


### Zadanie 3

Ostatnie z zadań to przygotowanie programu realizującego ciekawe zapalanie/gaszenie diód podłączonych do portu P1.

```assembly	
    mov p1, a           ;zgaszenie wszystkich diod
	
	mov a, #01h

	frst_sequence:
	mov b, #02h
	mov p1, a
	mul ab                  ;pierwsza sekwencja to podanie na p1 ciagu [1,2,4,8,16,32,64,128], 
                            ;efektem jest zapalanie sie diod od prawej do lewej strony
	
	jz scnd_sequence_init   ;skok jesli a = 0, rozkaz wykona sie po przemnozeniu przez 2 a = 0x80 
                            ;(czyli 128, ostatniej interesujacej nas wartosci w sekwencji), 
                            ;akumulator ma pojemnosc 8 bitow stad wyzerowanie akumulatora
                            ;i ustawienie na 1 flagi OV
	jmp frst_sequence
	
	frst_sequence_init:
	mov a, #02h
	jmp frst_sequence
	
	scnd_sequence_init:
	mov a, #40h
	
	scnd_sequence:
	mov p1, a 
	mov b, #02h 
	div ab                  ;druga sekwencja to podanie na p1 ciagu [64,32,16,8,4,2,1], nie podajemy 128, 
							;poniewaz to ostatnia wartosc podana w sekwencji pierwszej
	
	jz thrd_sequence_init   ;skok po podzieleniu przez 2 ostatniej wartosci sekwencji, tj. 1, 
							;przy okazji zmiana stanu flagi parzystosci p
	jmp scnd_sequence
	
	thrd_sequence_init:
	mov r0, #01h
	mov r1, #80h
	
	mov a, r1
	add a, r0
	thrd_sequence:
	mov p1, a
	mov b, #02h;
	mov a, r0
	mul ab
	mov r0,a
	
	mov b, #02h
	mov a, r1
	div ab                  ;w trzeciej sekwencji pomocne byly rejestry r0 i r1, r0 w kazdej iteracji petli 
                            ;jest mnozony przez 2 od wartosci poczatkowej 0x01, r1 z kolei dzielony od 
                            ;wartosci 0x80 (128), dzieki sumowaniu tych wartosci i podawaniu ich na p1
							;osiagnelismy efekt zbiegania sie diod od lewej i prawej strony, a nastepnie
                            ;ich wyminiecie ***mnozenie, dzielenie i sumowanie rejestrow odbylo sie 
                            ;oczywiscie z wykorzystaniem akumulatora

                            ;trzecia sekwencja to podanie na p1 ciagu [129, 66, 36, 24, 24, 36, 66, 129] 
	
	
	mov r1, a
	add a, r0
	
	jz frst_sequence_init   ;powrot do pierwszej sekwencji gdy a = 0
	jmp thrd_sequence
```

Rezultat działania programu to wyświetlenia następującej sekwencji:



|   |   |   |   |   |   |   | x |
|---|---|---|---|---|---|---|---|
|   |   |   |   |   |   | x |   |
|   |   |   |   |   | x |   |   |
|   |   |   |   | x |   |   |   |
|   |   |   | x |   |   |   |   |
|   |   | x |   |   |   |   |   |
|   | x |   |   |   |   |   |   |
| x |   |   |   |   |   |   |   |
|   | x |   |   |   |   |   |   |
|   |   | x |   |   |   |   |   |
|   |   |   | x |   |   |   |   |
|   |   |   |   | x |   |   |   |
|   |   |   |   |   | x |   |   |
|   |   |   |   |   |   | x |   |
|   |   |   |   |   |   |   | x |
| x |   |   |   |   |   |   | x |
|   | x |   |   |   |   | x |   |
|   |   | x |   |   | x |   |   |
|   |   |   | x | x |   |   |   |
|   |   |   | x | x |   |   |   |
|   |   | x |   |   | x |   |   |
|   | x |   |   |   |   | x |   |
| x |   |   |   |   |   |   | x |
