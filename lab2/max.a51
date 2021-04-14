ljmp start

org 0100h
	
	dane: db 4,2,6,8,10,12,14,16,1,3,5,7,9,11,13,15,00
	
	start:	
	
	
	mov dptr, #8000h	        ; wskazanie dptr pierwszej interesujacej nas komorki pamieci
	
	
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
	
	mov dptr, #8000h        ;po inkrementacjach dptr powrot do pierwszej komorki
	movx a, @dptr
	mov r1, a	        ;przypisanie wartosci pierwszej komorki pamieci zewnetrznej XRAM do r1,
	                        ;po wykonaniu programu w r1 bedzie znajdowac sie najwyzsza wartosc 
                                ;sposrod komorek X: 0x8000 - 0x800F
	
	
	mov r0,#10h			; r0 = liczba elementow do sprawdzenia 0x10 = 16
	loop:
	inc dptr
	movx a, @dptr
	mov r2, a
	subb a, r1 
	jc loop_continue                ;jesli a jest mniejsze od r1 flaga cy zostanie ustawiona na 1 po operacji 
                                ;odejmowania -> przeskocz do loop2 nie nadpisujac rejestru r1
			
	mov a ,r2               ;jesli a jest wieksze wykona sie ten kod programu 
	mov r1, a               ;i wartosc r1 zostanie nadpisana wartoscia wieksza
	
	
	loop_continue:
	dec r0
	mov a, r0
	jz exit                 ;zakoncz program jesli a == 0 (jesli r0 == 0), kiedy sprawdzone
                                ;zostaly wszystkie interesujace nas komorki
	ljmp loop
	
	
	
	
			
			exit:
	nop
	nop
	nop
	jmp $
	end start