ljmp start

org 0100h
	start:	
	
	mov p1, a               	;zgaszenie wszystkich diod
	
	mov a, #01h

	frst_sequence:
	mov b, #02h
	mov p1, a
	mul ab                  	;pierwsza sekwencja to podanie na p1 ciagu [1,2,4,8,16,32,64,128], 
                                ;efektem jest zapalanie sie diod od prawej do lewej strony
	
	jz scnd_sequence_init   	;skok jesli a = 0, rozkaz wykona sie po przemnozeniu przez 2 a = 0x80 
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
	div ab                  	;druga sekwencja to podanie na p1 ciagu [64,32,16,8,4,2,1], nie podajemy 128, 
                                ;poniewaz to ostatnia wartosc podana w sekwencji pierwszej
	
	jz thrd_sequence_init   	;skok po podzieleniu przez 2 ostatniej wartosci sekwencji, tj. 1, 
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
	div ab                    	  ;w trzeciej sekwencji pomocne byly rejestry r0 i r1, r0 w kazdej iteracji petli 
                                  ;jest mnozony przez 2 od wartosci poczatkowej 0x01, r1 z kolei dzielony od 
                                  ;wartosci 0x80 (128), dzieki sumowaniu tych wartosci i podawaniu ich na p1
                                  ;osiagnelismy efekt zbiegania sie diod od lewej i prawej strony, a nastepnie
                                  ;ich wyminiecie ***mnozenie, dzielenie i sumowanie rejestrow odbylo sie 
                                  ;oczywiscie z wykorzystaniem akumulatora

                                  ;trzecia sekwencja to podanie na p1 ciagu [129, 66, 36, 24, 24, 36, 66, 129] 
	
	
	mov r1, a
	add a, r0
	
	jz frst_sequence_init     ;powrot do pierwszej sekwencji gdy a = 0
	jmp thrd_sequence
	
	
	
	
			
	
	nop
	nop
	nop
	jmp $
	end start