# Program realizujacy przeksztalcenie afiniczne.
# Zadania rejestrow
# $t0
# $t1
# $t2
# 
#
# $t6 
# $t7 
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
readb:	.space 256
writeb:	.space 256
read:	.space 1048576
write:	.space 1048576
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
	
	li $v0, 10 # szybko konczmy program.
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
	
	li $v0, 10
	syscall
	 
# F-cja, ktora mnozy 2 wordy. Argumenty sa niszczone!
mnoz:
	mult $t5, $t6
	mfhi $t5
	mflo $t6
	rol $t5, $t5, 16
	ror $t6, $t6, 16
	or $t7, $t5, $t6
	jr $ra

# F-cja, ktora wczytuje. Argument t5 - adres stringu nazwy pliku, t6 - adres pamieci do zapisu
wczytaj:
	li $v0, 13
	move $a0, $t5
	li $a1, 0
	li $a2, 0
	
	move $t5, $v0 # Deskryptor pliku jest w $t5
	
petla:
	# zrobic tak, ze wczytujemy paczke bajtow i od razu obliczamy wspolrzedne, gdzie co ma pojsc.
	# wtedy nie trzeba wczytywac do pamieci i jest gitez. Nalezy tez pewnie wyzerowac przestrzen
	# zarezerwowana dla pliku wyjsciowego. Tutaj nie da sie od tak tego zapisac, bo nalezy miec
	# dotesp do kazdego pixela w dowolnym momenecie.