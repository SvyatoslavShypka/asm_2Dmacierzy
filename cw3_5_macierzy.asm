.data
	RAM: .space 4096 # zakładamy, że twoja tablica nie
			 # przekroczy rozmiaru 4096 bajtów
    prompt_rows: .asciiz "Podaj liczbę wierszy: "
    prompt_cols: .asciiz "Podaj liczbę kolumn: "
    prompt_element: .asciiz "Podaj element macierzy: "
    matrix_output: .asciiz "Macierz:\n"
    new_line: .asciiz "\n"
    separator_symbol: .asciiz " "
    prompt3: .asciiz "  Wybierz operację (0 - zapis, 1 - odczyt): "
    prompt4: .asciiz "Podaj indeks wiersza: "
    prompt5: .asciiz "Podaj indeks kolumny: "
    prompt6: .asciiz "Podaj wartość do wpisania: "
    prompt7: .asciiz "  Wartość wybranego elementu: "

.text
.globl main

main:
    # Wczytanie liczby wierszy
    li $v0, 4
    la $a0, prompt_rows #"Podaj liczbę wierszy: "
    syscall

    li $v0, 5
    syscall
    move $t0, $v0    # $t0 przechowuje liczbę wierszy

    # Wczytanie liczby kolumn
    li $v0, 4
    la $a0, prompt_cols #"Podaj liczbę kolumn: "
    syscall

    li $v0, 5
    syscall
    move $t1, $v0    # $t1 przechowuje liczbę kolumn

    # Alokacja pamięci dla tablicy adresów wierszy
    li $v0, 9
    mul $a0, $t0, 4  # $a0 przechowuje rozmiar tablicy adresów (liczba wierszy * 4 bajty)
    syscall
    move $t2, $v0    # $t2 przechowuje adres tablicy adresów wierszy

    # Inicjalizacja liczników pętli
    li $t3, 0        # $t3 przechowuje indeks aktualnego wiersza /i/
    li $t4, 0        # $t4 przechowuje indeks aktualnej kolumny /j/

    # Pętla wczytująca macierz
load_matrix_elements_i:
#    # Wczytanie elementu macierzy
#    li $v0, 4
#    la $a0, prompt_element # "Podaj element macierzy: "
#    syscall
#
#    li $v0, 5
#    syscall

    # Alokacja pamięci dla wiersza
    li $v0, 9
    mul $a0, $t1, 4  # $a0 przechowuje rozmiar wiersza (liczba kolumn * 4 bajty)
    syscall
    move $t6, $v0    # $t6 przechowuje adres początku wiersza
    # Zapisanie adresu początku wiersza w tablicy adresów
    sll $t7, $t3, 2  # Przesunięcie indeksu wiersza o 2 bity w lewo (mnożenie przez 4) /i*4 - offset/
    add $t8, $t2, $t7  # $t8 przechowuje adres komórki tablicy adresów /i*4 + $t2-adres /
    sw $t6, ($t8)    # Zapisanie adresu początku wiersza w tablicy adresów

load_matrix_elements_j:    
    addi $t5, $t4, 1    # /j+1/
    mul $t9, $t3, 100   # /i*100/
    add $t5, $t5, $t9   # /i*100 + j+1/
    
    # Zapisanie elementu do macierzy
    sw $t5, ($t6)

    # Zwiększenie liczników
    addi $t4, $t4, 1 # /j+1/
    addi $t6, $t6, 4 # /adres początku wiersza zwiększamy na 4bajty, aby tam zapisać następną liczbę/

    # Sprawdzenie warunku zakończenia aktualnego wiersza
    bne $t4, $t1, load_matrix_elements_j # /j=liczba kolumn - koniec cyklu/

    # Zwiększenie liczników
    addi $t3, $t3, 1 # /i+1/
    li $t4, 0	     # /wyzerowanie j=0/

    # Sprawdzenie warunku zakończenia wczytywania macierzy
    bne $t3, $t0, load_matrix_elements_i # /i=liczba wierszy - koniec cyklu/

    # Wyświetlanie macierzy
    li $v0, 4
    la $a0, matrix_output # "Macierz:\n"
    syscall

    # Inicjalizacja liczników pętli wyświetlającej macierz
    li $t3, 0    # $t3 przechowuje indeks aktualnego wiersza /i=0/

print_matrix_elements:
    sll $t7, $t3, 2    # Przesunięcie indeksu wiersza o 2 bity w lewo (mnożenie przez 4)
    add $t8, $t2, $t7  # $t8 przechowuje adres początku wiersza

    # Inicjalizacja liczników pętli wyświetlającej elementy wiersza
    li $t4, 0    # $t4 przechowuje indeks aktualnej kolumny /j=0/
    # Wydruk nowej linii
    li $v0, 4
    la $a0, new_line #"\n"
    syscall
print_row_elements:
    lw $t9, ($t8)	# $t9 przechowuje adres do wiersza
    mul $t7, $t4, 4 	# offset po j
    add $t9, $t9, $t7   # $t9 przechowuje adres do wiersza z elementem
    lw $t6, ($t9)    	# $t6 przechowuje wartość elementa

    # Wyświetlenie wartości elementu
    li $v0, 1
    move $a0, $t6
    syscall
    # Wydruk separatora
    li $v0, 4
    la $a0, separator_symbol #" "
    syscall

    # Zwiększenie liczników
    addi $t4, $t4, 1 	# /j+1/
    

    # Sprawdzenie warunku zakończenia wyświetlania elementów wiersza
    bne $t4, $t1, print_row_elements # /j=liczba kolumn - koniec cyklu/
    addi $t8, $t8, 4 	# /adres wiersza przesuwamy na 4 bajty/
    # Nowa linia
    li $v0, 4
    la $a0, new_line
    syscall

    # Zwiększenie liczników
    addi $t3, $t3, 1

    # Sprawdzenie warunku zakończenia wyświetlania macierzy
    bne $t3, $t0, print_matrix_elements # /i=liczba wierszy - koniec cyklu/

        
        # Pętla zapisu/odczytu
    loop:
        # Wybór operacji
        li $v0, 4
        la $a0, prompt3 # "  Wybierz operację (0 - zapis, 1 - odczyt): "
        syscall

        li $v0, 5
        syscall
        move $t8, $v0   # Wybrana operacja (0 - zapis, 1 - odczyt)

        # Wprowadzanie indeksu wiersza
        li $v0, 4
        la $a0, prompt4 # "Podaj indeks wiersza: "
        syscall

        li $v0, 5
        syscall
        move $t6, $v0   # Wybrany indeks wiersza /i/

        # Wprowadzanie indeksu kolumny
        li $v0, 4
        la $a0, prompt5 # "Podaj indeks kolumny: "
        syscall

        li $v0, 5
        syscall
        move $t7, $v0   # Wybrany indeks kolumny /j/
	
	mul $t5, $t6, 4	  # offset po i
    	add $t5, $t5, $t2 # $t5 przechowuje adres początku wiersza
    	mul $t3, $t7, 4	  # offset po j
    	lw $t5, ($t5)
    	add $t5, $t5, $t3 # adres komórki do zmiany/odczytu
    	
        beq $t8, 0, write_value   # Jeśli wybrano zapis, przejdź do wpisywania wartości

        # Wybrano odczyt
        li $v0, 4
        la $a0, prompt7 # "  Wartość wybranego elementu: "
        syscall
        
	lw $t9, ($t5)
	
        li $v0, 1
        move $a0, $t9
        syscall

        j loop   # Powrót do pętli zapisu/odczytu

    write_value:
    	li $v0, 4
        la $a0, prompt6 # "Podaj wartość do wpisania: "
        syscall

        li $v0, 5
        syscall
        move $t9, $v0   # Wartość do zapisu
        
        sw $t9, ($t5)

        j loop   # Powrót do pętli zapisu/odczytu

    # Koniec programu
    li $v0, 10
    syscall