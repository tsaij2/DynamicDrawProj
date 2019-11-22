#  Jonathan Tsai
#  Section 1001
#  CS 218, MIPS Assignment #4

#  MIPS assembly language program to perform
#  verification of a possible Suduko solution.

#  Sudoku is a popular brain-teaser puzzle that is solved by
#  placing digits 1 through 9 on a 9-by-9 grid of 81 individual
#  cells grouped into nine 3-by-3 regions.  The object of the
#  puzzle is to fill in all of the empty cells with digits from
#  1 to 9 so that the same digit doesn't appear twice in any
#  row, or any column, or any region.

##########################################################################
#  data segment

.data

hdr:	.ascii	"\nMIPS Assignment #4 \n"
	.asciiz	"Program to verify a possible Sudoku solution. \n\n"

TRUE = 1
FALSE = 0
GRID_SIZE = 9
SUB_GRID_SIZE = 3

lines:	.asciiz	"\n\n"

# -----
#  Sudoku Grids

SGrid1:	.word	5, 3, 4, 6, 7, 8, 9, 1, 2	# valid
	.word	6, 7, 2, 1, 9, 5, 3, 4, 8
	.word	1, 9, 8, 3, 4, 2, 5, 6, 7
	.word	8, 5, 9, 7, 6, 1, 4, 2, 3
	.word	4, 2, 6, 8, 5, 3, 7, 9, 1
	.word	7, 1, 3, 9, 2, 4, 8, 5, 6
	.word	9, 6, 1, 5, 3, 7, 2, 8, 4
	.word	2, 8, 7, 4, 1, 9, 6, 3, 5
	.word	3, 4, 5, 2, 8, 6, 1, 7, 9

SGrid2:	.word	5, 3, 4, 6, 7, 8, 9, 1, 2	# valid
	.word	6, 7, 2, 1, 9, 5, 3, 4, 8
	.word	1, 9, 8, 3, 4, 2, 5, 6, 7
	.word	8, 5, 9, 7, 6, 1, 4, 2, 3
	.word	4, 2, 6, 8, 5, 3, 7, 9, 1
	.word	7, 1, 3, 9, 2, 4, 8, 5, 6
	.word	9, 6, 1, 5, 3, 7, 2, 8, 4
	.word	2, 8, 7, 4, 1, 9, 6, 3, 5
	.word	3, 4, 5, 2, 8, 6, 1, 7, 9

SGrid3:	.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# valid
	.word	4, 5, 6, 7, 8, 9, 1, 2, 3
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	2, 3, 4, 5, 6, 7, 8, 9, 1
	.word	5, 6, 7, 8, 9, 1, 2, 3, 4
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7
	.word	3, 4, 5, 6, 7, 8, 9, 1, 2
	.word	6, 7, 8, 9, 1, 2, 3, 4, 5
	.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid4:	.word	5, 3, 4, 6, 7, 8, 9, 1, 2	# invalid, bad row
	.word	6, 7, 2, 1, 9, 5, 3, 4, 8
	.word	1, 9, 8, 3, 4, 2, 5, 6, 7
	.word	8, 5, 9, 7, 6, 1, 4, 2, 3
	.word	4, 2, 6, 8, 5, 3, 7, 9, 1
	.word	7, 1, 3, 9, 2, 4, 8, 5, 6
	.word	9, 6, 1, 5, 3, 7, 2, 8, 4
	.word	2, 8, 7, 4, 2, 9, 6, 3, 5
	.word	3, 4, 5, 2, 8, 6, 1, 7, 9

SGrid5:	.word	2, 3, 4, 5, 6, 7, 8, 9, 1	# invalid, bad col
	.word	5, 6, 7, 8, 9, 1, 2, 3, 4
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7
	.word	1, 2, 3, 4, 5, 6, 7, 8, 9
	.word	4, 5, 6, 7, 8, 9, 1, 2, 3
	.word	3, 4, 5, 6, 7, 8, 9, 1, 2
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	6, 7, 8, 9, 1, 2, 3, 4, 5
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7

SGrid6:	.word	2, 3, 4, 5, 6, 7, 8, 9, 1	# invalid, bad col
	.word	5, 6, 7, 8, 9, 1, 2, 3, 4
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7
	.word	1, 2, 3, 4, 5, 6, 7, 8, 9
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	4, 5, 6, 7, 8, 9, 1, 2, 3
	.word	3, 4, 5, 6, 7, 8, 9, 1, 2
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid7:	.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# invalid, bad subgrid
	.word	2, 3, 4, 5, 6, 7, 8, 9, 1
	.word	3, 4, 5, 6, 7, 8, 9, 1, 2
	.word	4, 5, 6, 7, 8, 9, 1, 2, 3
	.word	5, 6, 7, 8, 9, 1, 2, 3, 4
	.word	6, 7, 8, 9, 1, 2, 3, 4, 5
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7
	.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid8:	.word	2, 3, 4, 5, 6, 7, 8, 9, 1	# invalid, bad subgrid
	.word	5, 6, 7, 8, 9, 1, 2, 3, 4
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7
	.word	1, 2, 3, 4, 5, 6, 7, 8, 9
	.word	4, 5, 6, 7, 8, 9, 1, 2, 3
	.word	3, 4, 5, 6, 7, 8, 9, 1, 2
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	6, 7, 8, 9, 1, 2, 3, 4, 5
	.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid9:	.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# valid
	.word	4, 5, 6, 7, 8, 9, 1, 2, 3
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	2, 3, 4, 5, 6, 7, 8, 9, 1
	.word	5, 6, 7, 8, 9, 1, 2, 3, 4
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7
	.word	3, 4, 5, 6, 7, 8, 9, 1, 2
	.word	6, 7, 8, 9, 1, 2, 3, 4, 5
	.word	9, 1, 2, 3, 4, 5, 6, 7, 8

SGrid10:
	.word	1, 2, 3, 4, 5, 6, 7, 8, 9	# invalid, bad subgrid
	.word	4, 5, 6, 7, 8, 9, 1, 2, 3
	.word	7, 8, 9, 1, 2, 3, 4, 5, 6
	.word	2, 3, 4, 5, 6, 7, 8, 9, 1
	.word	5, 6, 7, 8, 9, 1, 2, 3, 4
	.word	3, 4, 5, 6, 7, 8, 9, 1, 2
	.word	8, 9, 1, 2, 3, 4, 5, 6, 7
	.word	6, 7, 8, 9, 1, 2, 3, 4, 5
	.word	9, 1, 2, 3, 4, 5, 6, 7, 8

isValid:	.byte	TRUE

addrs:	.word	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

stars:	.ascii	"\n********************************** \n\n"
	.asciiz	"Grid Number:  "


# -----
#  Variables for sudokuVerify function.

found:	.byte	FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE


# -----
#  Variables for displaySudoku function.

new_ln:	.asciiz	"\n"
top_ln:	.asciiz	"  +-------+-------+-------+ \n"
bar:	.asciiz	"| "
space:	.asciiz	" "
space2:	.asciiz	"  "

vmsg:	.asciiz	"\nSudoku Solution IS valid.\n\n"
invmsg:	.asciiz	"\nSudoku Solution IS NOT valid.\n\n"


##########################################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display main program header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Set grid addresses array.
#	Address array is used to allow a looped calls
#	the Sudoku verification and display routines.

	la	$t0, addrs

	la	$t1, SGrid1
	sw	$t1, ($t0)
	la	$t1, SGrid2
	sw	$t1, 4($t0)
	la	$t1, SGrid3
	sw	$t1, 8($t0)
	la	$t1, SGrid4
	sw	$t1, 12($t0)
	la	$t1, SGrid5
	sw	$t1, 16($t0)
	la	$t1, SGrid6
	sw	$t1, 20($t0)
	la	$t1, SGrid7
	sw	$t1, 24($t0)
	la	$t1, SGrid8
	sw	$t1, 28($t0)
	la	$t1, SGrid9
	sw	$t1, 32($t0)
	la	$t1, SGrid10
	sw	$t1, 36($t0)
	sw	$zero, 40($t0)

# -----
#  Main loop to check and display all grids.
#	grid addresses are stored in an array.
#	last entry in addresses array is zero, for loop termination

	la	$s0, addrs
	li	$s1, 1			# grid number counter

mainSudokuLoop:
	lw	$t0, ($s0)
	beqz	$t0, sudokuDone

# -----
#  Verify a possible Sudoku solution.

	lw	$a0, ($s0)
	la	$a1, isValid
	jal	sudokuVerify

# -----
#  Display header and Sudoku grid count

	li	$v0, 4
	la	$a0, stars
	syscall

	li	$v0, 1
	move	$a0, $s1
	syscall

	li	$v0, 4
	la	$a0, lines
	syscall

# -----
#  Display sudoku grid with result.

	lw	$a0, ($s0)
	li	$a1, 0
	lb	$a1, isValid
	jal	displaySudoku

# -----
#  Update counters and loop to check for next grid.

	add	$s1, $s1, 1
	addu	$s0, $s0, 4
	b	mainSudokuLoop

# -----
#  Done, terminate program.

sudokuDone:
	li	$v0, 10
	syscall

.end main


# ---------------------------------------------------------
#  Procedure to verify a Sudoku solution.

#  A valid Sudoku solution must satisfy the following constraints:
#     * Each value (1 through 9) must appear exactly once in each row.
#     * Each value (1 through 9) must appear exactly once in each column.
#     * Each value (1 through 9) must appear exactly once in each
#       3 x 3 sub-grid, where the  9 x 9 board is divided into 9 such sub-grids.

# -----
#  Formula for multiple dimension array indexing:
#	addr of ARRY(x,y) = [ (x * y_dimension) + y ] * data_size

# -----
#  Arguments
#	$a0 - address Sudoku grid
#	$a1 - address of boolean variable for result (true/false)

.globl	sudokuVerify
.ent	sudokuVerify
sudokuVerify:

move $t1, $a0	#first arr
addu $t2, $t1, 4 	#$t2 = next to check
li $t3, 0		#index 0-8
li $t4, 1		#index + 1
li $t5, 0		#curr column/row index

rowCompareLp:
lw $t6, ($t1)
lw $t7, ($t2)
beq $t6, $t7 badSudoku
addu $t2, $t2, 4
addu $t4, $t4, 1
bne $t4, 9, rowCompareLp
addu $t1, $t1, 4
addu $t3, $t3, 1
beq $t3, 8, nextRow
addu $t2, $t1, 4
addu $t4, $t3, 1
j rowCompareLp

nextRow:
addu $t5, $t5, 1	#row ++
beq $t5, 9, reset

mul $t9, $t5, 36	#offset of whole row = 9 * 4 = 36
addu $t1, $a0, $t9	#t1 = next row

li $t3, 0			#reset index
addu $t2, $t1, 4
addu $t4, $t3, 1
j rowCompareLp

reset:
move $t1, $a0	#first arr
addu $t2, $t1, 36 	#$t2 = next to check
li $t3, 0		#index 0-8
li $t4, 1		#index + 1
li $t5, 0		#curr column/row index

columnCompareLp:
lw $t6, ($t1)
lw $t7, ($t2)
beq $t6, $t7 badSudoku
addu $t2, $t2, 36
addu $t4, $t4, 1
bne $t4, 9, columnCompareLp
addu $t1, $t1, 36
addu $t3, $t3, 1
beq $t3, 8, nextColumn
addu $t2, $t1, 36
addu $t4, $t3, 1
j columnCompareLp

nextColumn:
addu $t5, $t5, 1	#column ++
beq $t5, 9, boxReset

mul $t9, $t5, 4		#offset of whole column = 1 * 4 = 4
addu $t1, $a0, $t9	#t1 = next row

li $t3, 0			#reset index
addu $t2, $t1, 36
addu $t4, $t3, 1
j columnCompareLp










boxReset:
move $t1, $a0	#finding arr
li $t3, 0		#index 0-8
li $t4, 0		#box index
li $t5, 0		#subgrid row
li $t6, 0		#rem of index
li $t7, 0		#counted nums
li $t8, 1		#num to find

boxArr:
lw $t2, ($t1)	#compared num
beq $t2, $t8, isNum

nextBoxi:
addu $t3, $t3, 1
remu $t6, $t3, 3
beqz $t6, nextBoxRow
addu $t1, $t1, 4
j boxArr

isNum:
addu $t7, $t7, 1
bgtu $t7, 1, badSudoku
j nextBoxi

nextBoxRow:
beq $t3, 9, nextBoxNum
subu $t1, $t1, 8
addu $t1, $t1, 36
j boxArr

nextBoxNum:
addu $t8, $t8, 1
beq $t8, 10, nextBox
subu $t1, $t1, 80
li $t3, 0		#index 0-8
li $t7, 0		#counted nums
j boxArr

nextBox:
addu $t4, $t4, 1
beq $t4, 9, goodSudoku
li $t3, 0		#index 0-8
li $t7, 0		#counted nums
li $t8, 1		#num to find
remu $t6, $t4, 3
beqz $t6, nextGridRow
move $t1, $a0	#finding arr
mul $t9, $t5, 108
addu $t1, $t1, $t9
remu $t9, $t4, 3
mul $t9, $t9, 12
addu $t1, $t1, $t9
j boxArr

nextGridRow:
addu $t5, $t5, 1
addu $t1, $t1, 4
j boxArr

badSudoku:
li $t1, 0
sw $t1, ($a1) #FALSE
j verified

goodSudoku:
li $t1, 1
sw $t1, ($a1) #TRUE


verified:
jr $ra


.end	sudokuVerify


# ---------------------------------------------------------
#  Function to zero 'found' array (9)

# -----
#  Arguments
#	$a0 - address of 'found' array
# -----
#  Returns
#	found array, all entries set to false.

.globl	zeroFoundArray
.ent	zeroFoundArray
zeroFoundArray:

move $t1, $a0
li $t2, 0		#index
li $t3, 0	#t3 = FALSE

falseArr:
sb $t3, ($t1)
addu $t1, $t1, 4		#inc arr
addu $t2, $t2, 1		#inc index
bne $t2, 9, falseArr	#9 = found arr size

jr $ra

.end	zeroFoundArray


# ---------------------------------------------------------
#  Function to check 'found' array.
#	if a FALSE is found, returns FALSE
#	if no FALSE is found, returns TRUE

# -----
#  Arguments
#	$a0 - address of 'found' array
# -----
#  Returns
#	$v0 - FALSE or TRUE

.globl	checkFoundArray
.ent	checkFoundArray
checkFoundArray:

move $t1, $a0
li $t2, 0		#index
li $t3, 0	#t3 = FALSE

checkArr:
lb $t4, ($t1)	#t4 = found[i]
beq $t4, $t3, isFalse		#if found[i] = FALSE, return FALSE
addu $t1, $t1, 4		#inc arr
addu $t2, $t2, 1		#inc index
bne $t2, 9, checkArr	#9 = found arr size

li $v0, 1		#if we reach end of found[] and nothing is FALSE, return TRUE
j done

isFalse:
li $v0, 0

done:
jr $ra

.end	checkFoundArray


# ---------------------------------------------------------
#  Function to set 'found' array.
#	sets found($a1)

# -----
#  Arguments
#	$a0 - address of 'found' array
#	$a1 - index to set
# -----
#  Returns
#	found array, with $a1 entries set to true

.globl	setFoundArray
.ent	setFoundArray
setFoundArray:

move $t1, $a0
mul $t2, $a1, 4
addu $t1, $t1, $t2
li $t2, 1
sb $t2, ($t1)

jr $ra


.end	setFoundArray


# ---------------------------------------------------------
#  Procedure to display formatted Sudoku grid to output.
#	formatting as per assignment directions

#  Arguments:
#	$a0 - starting address of matrix to ptint
#	$a1 - flag valid (true) or not valid (false)

.globl	displaySudoku
.ent	displaySudoku
displaySudoku:

subu $sp, $sp, 20 # preserve registers
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $fp, 12($sp)
sw $ra, 16($sp)
addu $fp, $sp, 20 # set frame pointer


move $s0, $a0		#s0 = matrix address
li $s1, 0			#index
move $s2, $a1		#false or true value

		
	li $v0, 4 				# print newLine
	la $a0, new_ln
	syscall
	
	
	li $v0, 4 				# print topLine
	la $a0, top_ln
	syscall
	
	li $v0, 4 				# print 2 spaces
	la $a0, space2
	syscall
	
	j printBar

printNewline:
	li $v0, 4 				# print newLine
	la $a0, new_ln
	syscall
	
	li $v0, 4 				# print 2 spaces
	la $a0, space2
	syscall

printBar:
	li $v0, 4 				# print bar
	la $a0, bar
	syscall
	
printSquare:
	li $v0, 1 				# call code for print int
	lw $a0, ($s0) 			# get array[i]
	syscall 				# system call
				
	li $v0, 4 				# print spaces
	la $a0, space
	syscall
	
	addu $s0, $s0, 4 		# increment arr
	add $s1, $s1, 1 		# increment index
	
	rem $t0, $s1, 3
	bnez $t0, printSquare
	
	li $v0, 4 				# print bar
	la $a0, bar
	syscall
	
	rem $t0, $s1, 9
	bnez $t0, printSquare
	rem $t0, $s1, 81
	bnez $t0, printNewline
	
	li $v0, 4 				# print newLine
	la $a0, new_ln
	syscall
	
	li $v0, 4 				# print bottomLine
	la $a0, top_ln
	syscall
	
	li $v0, 4 				# print newLine
	la $a0, new_ln
	syscall
	
	li $t1, 1
	beq $s2, $t1, isValidSudoku
	
	li $v0, 4 				# print not valid msg
	la $a0, invmsg
	syscall
	
	j printDone
	
	
isValidSudoku:
	li $v0, 4 				# print valid msg
	la $a0, vmsg
	syscall
	
printDone:
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $fp, 12($sp)
lw $ra, 16($sp)
addu $sp, $sp, 20
jr $ra

.end displaySudoku
