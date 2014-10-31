# Program realizujacy przeksztalcenie afiniczne.
# Zadania rejestrow
# $t0
# $t1
# $t2
# 
#
# $t6 - przechowywanie deskryptora pliku czytanego
# $t7 - przechowywanie deskryptora pliku do zapisu
#
# Uwaga - program nie jest idioto-odporny.
	
	.data
msg1:	.asciiz "Wpisz nazwe pliku, ktory chcesz przeksztalcic\n"
msg2:	.asciiz "Wpisz nazwe pliku wyjsciowego\n"
msg3:	.asciiz "Podaj parametry przeksztalcenie: a,b,c,d (wpisz liczbe -> enter - pojedynczo)\n"
msg4:	.asciiz "Podaj kolejny parametr\n"
finame:	.space 80 #miejsce na pobrana nazwe pliku
foname:	.space 80
cin:	.space 80
data:	.space 16 #miejsce na parametry
datast:	.space 4 #miejsce na stan danych pobranyh( 0 - liczba, 1 - sinx, 2 - siny, 3 - cosx, 4 - cos y )
		 # Jesli 1 | 2, to wtedy nie pobieramy nic z "data", a liczymy po prostu.

	.text
main:
	 li $v0, 4
	 la $a0, msg1
	 syscall
	 
	 li $v0, 8
	 la $a0, finame
	 li $a0, 80
	 syscall
	 
	 li $v0, 4
	 la $a0, msg2
	 syscall
	 
	 li $v0, 8
	 la $a0, foname
	 li $a0, 80
	 syscall
	 
	 li $v0, 4
	 la $a0, msg3
	 syscall
	 
	 #t1 - licznik petli
	 li $t1, 4
	 la $t3, data
	 la $t4, datast
	 jal parsuj
	
	
	
	
parsuj:
	beqz $t1, powrot
	li $v0, 4
	la $a0, msg4
	syscall
	
	li $v0, 8
	la $a0, cin
	li $a1, 80
	syscall
	
	#sprawdzamy, co to jest
	la $t2, cin
	lb $t0, ($t2)
	ble $t0, '9', laduj_liczbe
	beq $t0, 's', laduj_sin
	beq $t0, 'c', laduj_cos
	# w innym wypadku bedzie blad, ale zakladamy, ze uzytkownik podaje poprawne dane
	
laduj_liczbe:
	li $t0, 0
	sb $t0, ($t4)
	
	lw $t0, ($t2)
	sw $t0, ($t3)
	b dalej_parsuj
	
laduj_sin:
	add $t2, $t2, 3 #sprawdzamy 3-ci znak - czy to x czy y
	lb $t0, ($t2)
	beq $t2, 'y', siny
	li $t0, 1
	sb $t0, ($t4)
	b dalej_parsuj
siny:	
	li $t0, 2
	sb $t0, ($t4)
	b dalej_parsuj
	
laduj_cos:
	add $t2, $t2, 3 #sprawdzamy 3-ci znak - czy to x czy y
	lb $t0, ($t2)
	beq $t2, 'y', siny
	li $t0, 3
	sb $t0, ($t4)
	b dalej_parsuj
cosy:	
	li $t0, 4
	sb $t0, ($t4)
	b dalej_parsuj
	
dalej_parsuj:
	add $t3, $t3, 4
	add $t4, $t4, 1
	sub $t1, $t1, 1
	b parsuj
	
powrot:
	jr $ra
