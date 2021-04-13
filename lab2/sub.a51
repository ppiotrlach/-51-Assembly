ljmp start
			
org 0100h
	start:
	;1 liczba = 8 starszych bitow w r0, 8 mlodszych bity w r1 np 0x4321
	;2 liczba = 8 starszych bitow w r2, 8 mlodszych bitow w r3 np 0x1234
	;wynik w r4 (8 starszych bitow), r5 (8 mlodszych bitow)
	
	mov r0, #43h
	mov r1, #21h
	
	mov r2, #12h
	mov r3, #34h
	
	mov a, r1
	subb a, r3          ;A ? A - R3 - CY, A=R1, CY = 0, po wykonaniu tego rozkazu flaga CY = 1 
                        ;(0x21-0x34, odejmujemy wieksza liczbe od mniejszej)
	mov r5, a           ;wynik zapisz w r5
	
	mov a, r0
	subb a, r2          ;A ? A - R2 - CY,A = R0 CY = 1
	mov r4, a           ;wynik zapisz w r4
	
	
	nop
	nop
	nop
	jmp $
	end start