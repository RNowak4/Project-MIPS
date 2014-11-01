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
#
# Argumenty wywolania f-cji przekazujemy w $t5 i $6
# wynik natomiast zwracany jest w $t7
#

	
	.data
msg1:	.asciiz "Wpisz nazwe pliku, ktory chcesz przeksztalcic\n"
msg2:	.asciiz "Wpisz nazwe pliku wyjsciowego\n"
finame:	.space 80 #miejsce na pobrana nazwe pliku
foname:	.space 80
# Parametry przeksztalcenia: a,b,c,d. Przecinek umiejscowiony jest po srodku 
# word'a, gdyz nie jest wymagana jakas wielka precyzja, a tak jest dosc wygodnie.
A:	.word 0x0002c000
B:	.word 0x00018000
C:	.word 0x00000000
D:	.word 0x00000000

	.text	
main:
	lw $t5, A
	lw $t6, B
	
	jal mnoz
	
	li $v0, 10
	syscall
	
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
	 
# F-cja, ktora mnozy 2 wordy
mnoz:
	mult $t5, $t6
	mfhi $t5
	mflo $t6
	rol $t5, $t5, 16
	ror $t6, $t6, 16
	or $t7, $t5, $t6
	jr $ra