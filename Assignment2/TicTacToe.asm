#while printing current status :
#	s0 -> i
#	t0 -> offset
#	t1 -> Player1vsPlayer2
#while checking :
#	s1 -> base of the matrix that we have to check
#	t0, t1, t2 -> Three entries of the matrix
#	t3 -> and of the three inputs
#
#In main :
#	s2 -> Input number (Index)
#	t6 -> s2<<2 (While initializing)  or (Index+1) & 1 (Which Player's Turn while inputting)
#	s3 -> Input given (Position)
#
#
#		-------------------------
#		|   1   |   2   |   3   |
#		-------------------------
#		|   4   |   5   |   6   |
#		-------------------------
#		|   7   |   8   |   9   |
#		-------------------------
#
#Print lines required:
#
#Registers Required:-
#Player 1:
#	Initialize all with 0s. Store in the following registers:
#	Win if ((1&2&3)|(4&5&6)|(7&8&9)|(1&4&7)|(2&5&8)|(3&6&9)|(1&5&9)|(3&5&7)): Terminate Player 1 wins
#
#Similarly repeat for player 2
#
#Handle: Invalid number given as input
#
#Matrix1: Player1's 1-0 matrix
#Matrix2: Player2's 1-0 matrix
#Matrix3: Player1vsPlayer2 matrix
#
#while win combination not found
#	search for it for player 1 or for player 2
#	depending upon whose chance it was if found then that player wins the game
#	if this was the last chance then
#
#
#####################################################
#		Assignment2
# Entry no 1: Diwakar Prajapati (2018CS10330)
# Entry no 2: Satwik Banchhor (2018CS10385)
#####################################################

.globl main	# The label declares that main is the global function from where the program starts
.data		# Data is the memory to store data values
	base1: .space 36	# This is the base address for Matrix 1
	base2: .space 36	# This is the base address for Matrix 2
	base3: .space 36	# This is the base address for Matrix 2
	horizontal_partition: .asciiz "-------------------------------\n"
	vertical_partition: .asciiz "|"
	newline: .asciiz "\n"
	tab: .asciiz "    "
	o: .asciiz "O"
	x: .asciiz "X"
	invalid: .asciiz "Invalid Input Enter choice again:\t"
	ip1: .asciiz "Player 1('O')'s Turn:\n\tEnter Choice:\t"
	ip2: .asciiz "Player 2('X')'s Turn:\n\tEnter Choice:\t"
	win1: .asciiz "Player 1 - 'O' Wins\n"
	win2: .asciiz "Player 2 - 'X' Wins\n"
	draw: .asciiz "Its a Draw\n"
	input_string: .asciiz ":\t"

.text
main:
	move $s2, $zero
	jal initialize
	jal current_status
	move $s2, $zero
	jal input
	b print_draw

	print_draw:
	li $v0, 4
    la $a0, draw
    syscall
    li $v0, 10
	syscall

initialize:
	sll $t6, $s2, 2
	sw $zero, base1($t6)
	sw $zero, base2($t6)
	sw $zero, base3($t6)
	addi $s2, $s2, 1
	bne $s2, 9, initialize
	jr $ra


input:
	add $t6, $s2, 1
	and $t6, $t6, 1
	beq $t6, 1, p1
	b p2

	p1:
		li $v0, 4
		la $a0, ip1
		syscall

		move $s7, $ra
		jal take_input
		move $ra, $s7

		la $s1, base1
		li $s4,1
		sw $s4, base1($s3)
		sw $s4, base3($s3)
		addi $s2, $s2, 1

		move $s7, $ra
		jal current_status
		move $ra, $s7

		move $s7, $ra
		jal check
		move $ra, $s7

		move $t4, $zero
		addi $t4, $t4, 9
		bne $s2, $t4, input
		jr $ra

	p2:
		li $v0, 4
		la $a0, ip2
		syscall

		move $s7, $ra
		jal take_input
		move $ra, $s7

		la $s1, base2
		li $s4,1
		sw $s4, base2($s3)
		li $s4,2
		sw $s4, base3($s3)
		addi $s2, $s2, 1

		move $s7, $ra
		jal current_status
		move $ra, $s7

		move $s7, $ra
		jal check
		move $ra, $s7

		move $t4, $zero
		addi $t4, $t4, 9
		bne $s2, $t4, input
		jr $ra

take_input:
	li $v0, 5
	syscall
	move $s3, $v0
	sub $s3, $s3, 1
	sll $s3, $s3, 2
	lw $s4, base3($s3)
	bne $s4, $zero, print_invalid
	move $s5, $zero
	add $s5, $s5, 32
	bgt $s3, $s5, print_invalid
	blt $s3, $zero, print_invalid
	jr $ra

	print_invalid:
		li $v0, 4
		la $a0, invalid
		syscall
		b take_input


check:

	lw $t0, 0($s1)
	lw $t1, 4($s1)
	lw $t2, 8($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win

	lw $t0, 12($s1)
	lw $t1, 16($s1)
	lw $t2, 20($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win

	lw $t0, 24($s1)
	lw $t1, 28($s1)
	lw $t2, 32($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win

	lw $t0, 0($s1)
	lw $t1, 12($s1)
	lw $t2, 24($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win

	lw $t0, 4($s1)
	lw $t1, 16($s1)
	lw $t2, 28($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win

	lw $t0, 8($s1)
	lw $t1, 20($s1)
	lw $t2, 32($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win

	lw $t0, 0($s1)
	lw $t1, 16($s1)
	lw $t2, 32($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win

	lw $t0, 8($s1)
	lw $t1, 16($s1)
	lw $t2, 24($s1)
	and $t3, $t0, $t1
	and $t3, $t3, $t2
	beq $t3, 1, win
	jr $ra

win:
	beq $t6, 1, print_w1
	b print_w2

	print_w1:
		li $v0, 4
	    la $a0, win1
	    syscall
	    li $v0, 10
		syscall
	print_w2:
		li $v0, 4
	    la $a0, win2
	    syscall
	    li $v0, 10
		syscall


current_status:
	move $s0,$zero   #s0 stores i
	move $t7, $zero	 #t7 stores done for i
	move $s4, $ra
	jal print_horizontal_partition

	jal print_vertical_partition
	jal print_tab
	jal print_i 					#1
	jal print_tab
	jal print_vertical_partition
	jal print_tab
	jal print_i 					#2
	jal print_tab
	jal print_vertical_partition
	jal print_tab
     jal print_i 					#3
     jal print_tab
	jal print_vertical_partition

	jal print_newline
	jal print_horizontal_partition

	jal print_vertical_partition
	jal print_tab
	jal print_i 					#4
	jal print_tab
	jal print_vertical_partition
	jal print_tab
	jal print_i 					#5
	jal print_tab
	jal print_vertical_partition
	jal print_tab
    jal print_i 					#6
    jal print_tab
	jal print_vertical_partition

	jal print_newline
	jal print_horizontal_partition

	jal print_vertical_partition
	jal print_tab
	jal print_i 					#7
	jal print_tab
	jal print_vertical_partition
	jal print_tab
	jal print_i 					#8
	jal print_tab
	jal print_vertical_partition
	jal print_tab
    jal print_i 					#9
    jal print_tab
	jal print_vertical_partition

	jal print_newline
	jal print_horizontal_partition
	move $ra, $s4
	jr $ra

print_horizontal_partition:
	li $v0, 4
    la $a0, horizontal_partition
    syscall
    jr $ra
print_vertical_partition:
	li $v0, 4
	la $a0, vertical_partition
	syscall
	jr $ra
print_tab:
	li $v0, 4
    la $a0, tab
    syscall
    jr $ra
print_newline:
	li $v0, 4
    la $a0, newline
    syscall
    jr $ra

print_i:
	sll $t0, $s0, 2 	#t0 --> offset
    lw $t1, base3($t0)	#t1 --> Player1vsPlayer2
    beq $t1, 0, print_none
    beq $t1, 1, print_o
    beq $t1, 2, print_x
    print_o:
		li $v0, 4
	    la $a0, o
	    syscall
	    addi $s0, $s0, 1 #i++
	    b done
	print_x:
		li $v0, 4
	    la $a0, x
	    syscall
	    addi $s0, $s0, 1 #i++
	    b done
	print_none:
		li $v0, 1
	    addi $s0, $s0, 1 #i++
	    move $a0, $s0
	    syscall
	    b done
    done:
    	jr $ra
