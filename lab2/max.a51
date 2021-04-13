ljmp start
org 0100h
	start:
	;program znajdujacy maksimum
    ;tablicy 1-wymiarowej rozpoczynajacej sie od adresu 8000H pamieci zewnetrznej danych (XRAM)
    ;i obejmujacej 16 kolejnych komórek tej tablicy.
	
	mov r0,#10h			; r0 = liczba elementow do sprawdzenia 0x10 = 16
	mov dptr, #8000h	; dptr wskazuje na pierwsza interesujaca komorke pamieci zewnetrznej
	
	
	;zaladowanie danych testowych (wartosci od 1 do 16) [4,2,6,8,10,12,14,16,1,3,5,7,9,11,13,15]
	
	mov a, #04h			
	movx @dptr, a
	
	inc dptr
	mov a, #02h
	movx @dptr, a
	
	inc dptr
	mov a, #06h
	movx @dptr, a
	
	inc dptr
	mov a, #08h
	movx @dptr, a
	
	inc dptr
	mov a, #0Ah
	movx @dptr, a
	
	inc dptr
	mov a, #0Ch
	movx @dptr, a
	
	inc dptr
	mov a, #0Eh
	movx @dptr, a
	
	inc dptr
	mov a, #10h
	movx @dptr, a
	
	inc dptr
	mov a, #01h
	movx @dptr, a
	
	inc dptr
	mov a, #03h
	movx @dptr, a
	
	inc dptr
	mov a, #05h
	movx @dptr, a
	
	inc dptr
	mov a, #07h
	movx @dptr, a
	
	inc dptr
	mov a, #09h
	movx @dptr, a
	
	inc dptr
	mov a, #0Bh
	movx @dptr, a
	
	inc dptr
	mov a, #0Dh
	movx @dptr, a
	
	inc dptr
	mov a, #0Fh
	movx @dptr, a
	

	mov dptr, #8000h ; po inkrementacji dptr powrot do pierwszej komorki
	movx a, @dptr
	mov r1, a	;przypisanie wartosci pierwszej komorki pamieci zewnetrznej XRAM do r1,
	;po wykonaniu programu w r1 bedzie znajdowac sie najwyzsza wartosc sposrod komorek X: 0x8000 - 0x800F
	
	
	loop:
	inc dptr
	movx a, @dptr
	mov r2, a
	subb a, r1 
	jc loop2 ;jesli a jest mniejsze od r1 flaga cy zostanie ustawiona na 1 po operacji odejmowania -> przeskocz do loop2 nie nadpisujac rejestru r1
			
	mov a ,r2 ;jesli a jest wieksze wykona sie ten kod programu i wartosc r1 zostanie nadpisana wartoscia wieksza
	mov r1, a
	
	
	loop2:
	inc dptr
	dec r0
	mov a, r0
	jz exit ;exit jesli a == 0 (jesli r0 == 0), kiedy sprawdzone zostaly wszystkie interesujace nas komorki
	ljmp loop
	
	
	exit:
	nop
	nop
	nop
	jmp $
	end start