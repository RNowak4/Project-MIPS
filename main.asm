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
msg1:	.asciiz "Wpisz nazwe pliku, ktory chcesz przeksztalcic\nNowy plik bedzie mial nazwe, taka jak podasz z dopiskiem: *-edited.bmp"
msg2:	.asciiz "Podaj parametry przeksztalcenie: a,b,c,d (wpisz liczbe -> enter - pojedynczo)\n"
fname:	.space 80 #miejsce na pobrana nazwe pliku

	.text
main:
	