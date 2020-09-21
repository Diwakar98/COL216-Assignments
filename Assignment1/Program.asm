#####################################################
#		Assignment1
# Entry no 1: Diwakar Prajapati (2018CS10330)
# Entry no 2: Satwik Banchorr (2018CS10)
# This program in MIPS calculate the Root Mean Square of two 3 x 3 Matrics having integer  values.
# It gives the answer as Integer (integer value of floating number)
# In this I am running three loops:
# 1 - Taking input for Matrix 1 in Row-Major format
# 2 - Taking input for Matrix 2 in Row-Major format
# 3 - Calculating the root mean square of the matrices.
#####################################################





.globl main	# The label declares that main is the global function from where the program starts
.data		# Data is the memory to store data values
	base1: .space 36	# This is the base address for Matrix 1
	base2: .space 36	# This is the base address for Matrix 2
	matrix1: .asciiz "\nData for Matrix 1:\n"	# .asciiz stores text, all these are simple text to be
	matrix2: .asciiz "\nData for Matrix 2:\n"	# displayed in the console for proper intstruction to the user.
	enter: .asciiz "\Enter value at ("
	comma: .asciiz ","
	closebrac: .asciiz "): "
	newline: .asciiz "\n"
	rms: .asciiz "\nRoot Mean Square is: "
.text
main:
	add     $t0, ,$zero, 3        # $t0 = number of rows
        add     $t1, ,$zero, 3        # $t1 = number of columns

        move    $s0, $zero     	# $s0 = row counter
        move    $s1, $zero     	# $s1 = column counter

        move $t4, $zero 	     # $t4 = sum of (xij - yij) * (xij - yij)
        move $t5, $zero		# $t4 = Root Mean Square of Matrix1 and Matrix2

        li $v0, 4 		     # $v0 gives instruction, 4 instructs to print text
        la $a0, matrix1		# la loads data to be printed in $a0
        syscall			# Tells system to print whatever is print in register $a0

        jal loop_input_1	# jal = jump and link to label loop_input_1

        li $v0, 4
        la $a0, matrix2
        syscall
        move    $s0, $zero     # $s0 = row counter
        move    $s1, $zero     # $s1 = column counter
        jal loop_input_2

        move    $s0, $zero     # $s0 = row counter
        move    $s1, $zero     # $s1 = column counter
        jal loop_rms

        li $t6, 9
        #div $t6, $t5, $t6

        mtc1 $t5,$f5		# $f5 <- $t5
        mtc1 $t6,$f6		# $f6 <- $f6
        cvt.s.w $f5,$f5		# converting integer value to floating value
        cvt.s.w $f6,$f6		# converting integer value to floating value
        div.s $f7,$f5,$f6 	# floating point division in single precision


        li $v0, 4
        la $a0, rms
        syscall

        li $v0, 2
        mov.s $f12, $f7
        syscall


        li $v0, 10
	syscall

loop_input_1:			# label for matrix 1 input
	mult    $s0, $t1
        mflo    $s2
        add     $s2, $s2, $s1	# s2 stores address, 1 greater no of addresses already visited in row major format.
        sll	$s2, $s2, 2	# $s2 = $s2 * 4, since it stores hexadecimal value which uses 4 bits.

        li $v0, 4
        la $a0, enter
        syscall

        li $v0, 1		# 1 for printing integer
        move $a0, $s0		# moving integer data to register $a0
        syscall

        li $v0, 4
        la $a0, comma
        syscall

        li $v0, 1
        move $a0, $s1
        syscall

        li $v0, 4
        la $a0, closebrac
        syscall

        li $v0, 5		# 5 for telling system to take integer input
        syscall
        move $t2, $v0

	sw $t2, base1($s2)	# stores the entries at different addresses

	addi $s1, $s1, 1		# increments row counter by 1
	bne $s1, $t1, loop_input_1	# checks if row counter has reached the end
	move $s1, $zero
	addi $s0, $s0, 1		# increments column counter by 1
	bne $s0, $t0, loop_input_1	# check if column counter has reached the end

	jr $ra				# return back from where this function was called

loop_input_2:
	mult    $s0, $t1
        mflo    $s2
        add     $s2, $s2, $s1
        sll	$s2, $s2, 2

        li $v0, 4
        la $a0, enter
        syscall

        li $v0, 1
        move $a0, $s0
        syscall

        li $v0, 4
        la $a0, comma
        syscall

        li $v0, 1
        move $a0, $s1
        syscall

        li $v0, 4
        la $a0, closebrac
        syscall

        li $v0, 5
        syscall
        move $t2, $v0

	sw $t2, base2($s2)

	addi $s1, $s1, 1
	bne $s1, $t1, loop_input_2
	move $s1, $zero
	addi $s0, $s0, 1
	bne $s0, $t0, loop_input_2

	jr $ra

loop_rms:
	mult    $s0, $t1
        mflo    $s2
        add     $s2, $s2, $s1
        sll	$s2, $s2, 2

	lw $t2, base2($s2)		# $t2 = xij
	lw $t3, base1($s2)		# $t3 = yij
	sub $t4, $t2, $t3		# $t4 = xij - yij
	mult $t4, $t4			# lo = (xij - yij) * (xij - yij)
	mflo $t4			# $t4 = $lo
	add $t5,$t5,$t4			# $t5 = sigma [ (xij - yij) * (xij - yij) ]

	addi $s1, $s1, 1
	bne $s1, $t1, loop_rms
	move $s1, $zero
	addi $s0, $s0, 1
	bne $s0, $t0, loop_rms

	jr $ra				#return from where it was called
