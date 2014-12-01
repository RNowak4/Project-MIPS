# Radosław Nowak
# CORDIC
# xxxx.<...>
	.data
# tablica dla atan(1,1/2,1/4 ...)
atab:	.word 0x0c90fd7e 0x076b1a2a 0x03eb6f19 0x01fd5bab 0x00ffaadb 0x7ff54d 0x3ffea3 0x1fffd5 0xffffa 0x7fffe
PI:	.word 0x3243f6a8
HPI:	.word 0x1921fb52
PHASE:	.word 0x9b74ff8 # faza wyliczona przez funkcje getPhase
Pow:	.asciiz "Wpisz liczbe w stopniach: "
Sin:	.asciiz "Sinx = "
Cos:	.asciiz "\nCosx = "

	.text
main:	
	la $a0, Pow
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	wczytPetla:
	#tutaj bawimy sie w redukcje liczbe do przedzialu od -180 do 180 stopni(zeby zaoszczedzic na dokladnosci przy dzieleniu)
	bgt $v0, 180, wczytWieksza
	blt $v0, -180, wczytMniejsza
	j koniec_wczytywania
	
	wczytWieksza:
		sub $v0, $v0, 360
		b wczytPetla		
		
	wczytMniejsza:
		add $v0, $v0, 360
		b wczytPetla

	koniec_wczytywania:	
	#tutaj przeksztalcamy podana liczbe na liczbe
	#z ulamkiem na 22 pozycji, nastepnie dzielimy przez PI
	#i mamy liczbe w radach.
	move $t9, $v0
	lw $t0, PI
	li $t1, 180
	sll $t9, $t9, 22
	div $t9, $t1
	mflo $t9
	sll $t9, $t9, 6
	##########################################
	
	move $t5, $t9
	lw $t6, PI
	jal mnoz
	move $t9, $t7
		
	jal getSinCos
	
	li $v0, 4
	la $a0, Sin
	syscall
	
	move $a0, $s0
	li $v0, 34
	syscall
	
	li $v0, 4
	la $a0, Cos
	syscall
	
	move $a0, $s1
	li $v0, 34
	syscall

	li $v0, 10
	syscall

# Funkcja, ktora mnozy. argument w t5 i t6, wart zwracana w t7
mnoz:
	mult $t5, $t6
	mfhi $t5
	mflo $t6
	sll $t5, $t5, 4
	srl $t6, $t6, 28
	or $t7, $t5, $t6
	jr $ra
	
# w s0 liczba przesuniec
# argument w t6
# wynik t t7
szMnoz:
	move $t8, $s0
	petla_sz:
		beqz $t8, koniec_petli_sz
		sub $t8, $t8, 1
		sra $t6, $t6, 1
		b petla_sz
	koniec_petli_sz:
	move $t7, $t6
	jr $ra	
	
#funkcja, ktora liczy sin i cos
# 1 argument w t9 to kat, ktorego sin i cos chcemy policzyc. W RADACH!!
# w s0 zwracam sin
# w s1 zwracam cos
getSinCos:
	lw $t0, HPI
	neg $t1, $t0 # $t1 = -$t0
	add  $t1, $t1, 1 #jw...
	
	bgt $t9, $t0, lab_greater
	blt $t9, $t1, lab_lower
		li $s5, 0x10000000
		li $s6, 0x00000000
		li $t0, 0x00000000
		j kon_war
		
	lab_greater:
		li $s5, 0x00000000
		li $s6, 0x10000000
		lw $t0, HPI
		j kon_war
	
	lab_lower:
		li $s5, 0x00000000
		li $s6, -0x10000000
		move $t0, $t1 # t0 = -hpi
		j kon_war
	
	kon_war:
	
	li $s4, 0x00000000 #phase_rads
	li $s0, 0 #licznik petli
	la $s1, atab #adres na tablice
	li $s2, 0x00000000 #tmp_I
	move $t1, $ra #backup $ra
	
	petla_2:
		beq $s0, 10, koniec_petli_2
		lw $s4, ($s1) #ladujemy z tablicy atan
		#add $s0, $s0, 1 #inkrementacja licznika petli
		add $s1, $s1, 4 #przesuniecie adresu o 4
		move $s2, $s5 # tmp_I = I		
		bgt $t0, $t9, mniejsze
		
		#wykonujemy mnozenie
		move $t6, $s6
		jal szMnoz
		sub $s5, $s5, $t7 # I -= Q * K
		
		move $t6, $s2
		jal szMnoz
		add $s6, $s6, $t7 # Q += tmp_I * K
		add $t0, $t0, $s4
		add $s0, $s0, 1
		b petla_2		
		
		mniejsze:
		#wykonujemy mnozenie
		move $t6, $s6
		jal szMnoz
		add $s5, $s5, $t7 # I += Q * K
		
		move $t6, $s2
		jal szMnoz
		sub $s6, $s6, $t7 # Q -= tmp_I * K
		sub $t0, $t0, $s4
		add $s0, $s0, 1
		b petla_2		
		
	koniec_petli_2:
	lw $t0, PHASE
	
	move $t5, $s5
	move $t6, $t0
	jal mnoz
	move $s1, $t7
	
	move $t5, $s6
	move $t6, $t0
	jal mnoz
	move $s0, $t7
	
	move $ra, $t1
	jr $ra #return

#funkcja, ktora pobiera faze
#uzywa rejestrow grupy s
#wynik w s7
getPhase: #dziala!
	li $s5, 0x10000000 #I
	li $s6, 0x00000000 #Q
	li $s4, 0x00000000 #phase_rads
	li $s0, 0 #licznik petli
	la $s1, atab #adres na tablice
	li $s2, 0x00000000 #tmp_I
	li $t0, 0x00000000 # acc_phase_rads
	move $t1, $ra 
	
	petla:
		beq $s0, 7, koniec_petli
		lw $s4, ($s1) #ladujemy z tablicy atan
		add $s0, $s0, 1 #inkrementacja licznika petli
		add $s1, $s1, 4 #przesuniecie adresu o 4
		move $s2, $s5 # tmp_I = I
		
		bge $s6, 0x00000000, wieksze
		#wykonujemy mnozenie
		move $t6, $s6
		jal szMnoz
		sub $s5, $s5, $t7 # I -= Q * K
		
		move $t6, $s2
		jal szMnoz
		add $s6, $s6, $t7 # Q += tmp_I * K
		add $t0, $t0, $s4
		b petla		
		
		wieksze:
		#wykonujemy mnozenie
		move $t6, $s6
		jal szMnoz
		add $s5, $s5, $t7 # I += Q * K
		
		move $t6, $s2
		jal szMnoz
		sub $s6, $s6, $t7 # Q -= tmp_I * K
		sub $t0, $t0, $s4
		b petla		
		
	koniec_petli:
	move $s7, $s5 # p_mag = I * 1.0
	move $ra, $t1
	jr $ra #return