msecondl equ 20h
msecondh equ 21h

secondl equ 22h
secondh equ 23h
minutel equ 24h
minuteh equ 25h
hourl	equ 26h
hourh	equ 27h

fnkey 	equ 28h
pluskey	equ 29h
flage	equ 30h
	
	org 00h
	ajmp main
	org 000bh
	ajmp int_t0
	org 001bh
	ajmp int_t1
	org 80h
main:
	mov sp,#70h
	mov p3,#6
	mov r0,#msecondl
	mov @r0,#8
	inc r0
	mov @r0,#2
	inc r0
	mov @r0,#8
	inc r0
	mov @r0,#5
	inc r0
	mov @r0,#9
	inc r0
	mov @r0,#5
	inc r0
	mov @r0,#3
	inc r0
	mov @r0,#2

	mov tmod,#16h				;t1  t0
	mov th1,#0d8h		   		;12MHZ 10ms
	mov tl1,#0f0h
	setb tr1
	setb et1
	mov th0,#0f0h
	mov tl0,#0f0h
	setb tr0
	setb et0

	setb ea
	mov fnkey,#0
	mov pluskey,#0
	mov flage,#0

ll:
	;mov r0,#hourh
	;mov r0,#minuteh
	;call display_led
	call keyprocess
	jmp ll
	jmp $

keyscan_down:
	mov a,flage
	jz kd1
	mov r0,#minuteh
	ajmp kd2
kd1:
	mov r0,#hourh
kd2:
	call display_led
	mov P3,#0ffh
	mov a,P3
	setb acc.6
	cpl a
	jz keyscan_down	
	ret
keyscan_up:
	mov a,flage
	jz ku1
	mov r0,#minuteh
	ajmp ku2
ku1:
	mov r0,#hourh
ku2:
	call display_led
	mov P3,#0ffh
	mov a,P3
	setb acc.6
	cpl a	
	ret

keyprocess:
	call keyscan_down
	jz return
	call delay1_1ms
	jnb acc.3,keyplus	 
k1:	call delay1_1ms
	call keyscan_up
    jnz k1
				  		;keyfn
	mov flage,#0
	mov a,fnkey
	inc a
	inc a
	mov fnkey,a
	clr c
	subb a,#8
	jc kk1
	mov fnkey,a
kk1:
	ajmp return
keyplus:
	 jnb acc.7,keyf
k2:	 call delay1_1ms
	 call keyscan_up
     jnz k2			    ;keyplus
	 
	 mov pluskey,#1
	 mov a,fnkey		
	 jnz kkk1
	 mov a,flage	   ;;fn no enter
	 cpl a
	 mov flage,a
kkk1: 

	 ajmp return
keyf:
	jnb acc.4,return
k3: call delay1_1ms
	call keyscan_up
	jnz k3
						 ;keyf
	ajmp return
return:
	mov a,fnkey
	jz kp1
	mov a,pluskey
	jz kp1
	clr c
	mov a,#28h
	subb a,fnkey
	mov r0,a
	inc @r0
	mov pluskey,#0
kp1:

	;jz kp2

;kp2:

	ret


;r0 witch to display
display_led:
	;mov r0,#hourh
	;mov r0,#minuteh
	mov dptr,#ledcode
	mov r1,#0	;count
d1:
	;mov p1,#0ffh
	mov p3,#6
	mov a,@r0
	movc a,@a+dptr
	mov p1,a
	mov a,r1
	orl a,#0f8h
	mov p3,a
	call delay_1ms
	inc r1
	dec r0
	cjne r1,#6,d1
	ret

ajust_led:
	clr c
	mov a,msecondl
	subb a,#10
	jc a1
  	mov msecondl,a
	inc msecondh
a1:
	clr c
	mov a,msecondh
	subb a,#9
	jc a2
	mov  msecondh,a
	inc secondl
a2:
	clr c			 ;second
	mov a,secondl
	subb a,#10
	jc a3
   	mov secondl,a
	inc secondh
a3:
	clr c
	mov a,secondh
	subb a,#6
	jc a4
   	mov secondh,a
	inc minutel
a4:
	clr c			;minute
	mov a,minutel
	subb a,#10
	jc a5
	mov minutel,a
	inc minuteh
a5:
	clr c
	mov a,minuteh
	subb a,#6
	jc a6
	mov minuteh,a
	inc hourl
a6:
	clr c		   ;hour
	mov a,hourl
	subb a,#10
	jc a7
	mov hourl,a
	inc hourh
a7:
	clr c
	mov a,hourh
	subb a,#2
	jc a8
   	clr c
	mov a,hourl
	subb a,#4
	jc a8
	mov hourh,#0
	mov hourl,#0
a8:
	ajmp aend


aend:
	ret

int_t1:
	push acc
	push psw
	mov acc,r0
	push acc
	mov acc,r1
	push acc

	mov r0,#msecondh
	mov a,@r0
	add a,#1
	mov @r0,a
	

	;mov p3,#6
	mov p1,#00
	call ajust_led
	
	pop acc
	mov r1,acc
	pop acc
	mov r0,acc
	pop psw
	pop acc
	reti
int_t0:
	push acc
	push psw
	mov acc,r0
	push acc
	mov acc,r1
	push acc
	
	;call ajust_led
	
	pop acc
	mov r1,acc
	pop acc
	mov r0,acc
	pop psw
	pop acc
	reti
	reti


delay_1ms:
	mov r7,#250
dly:
	nop		;1us 12MHZ
	nop		;1us 12MHZ 
	djnz r7,dly ;2us 12MHZ
	ret

delay1_1ms:
	mov r7,#01fh
dly1:
	nop		;1us 12MHZ
	nop		;1us 12MHZ 
	djnz r7,dly ;2us 12MHZ
	ret

ledcode: db 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh,0ffh
	end