#  CS 218, MIPS Assignment #5
#  Jonathan Tsai
#  CS 218 Section 1001
#  Nellis Parking Lot Program

###########################################################################
#  data segment

.data

# -----
#  Constants

TRUE = 1
FALSE = 0

# -----
#  Variables for main

hdr:		.ascii	"\nMIPS Assignment #5\n"
		.asciiz	"Nellis Parking Lot Program\n\n"

againPrompt:	.asciiz	"Try another parking lot size (y/n)? "

endMsg:		.ascii	"\nYou have reached recursive nirvana.\n"
		.asciiz	"Program Terminated.\n"

# -----
#  Local variables for prtNewline function.

newLine:	.asciiz	"\n"

# -----
#  Local variables for displayResult() function.

maxMsg1:	.ascii	"The maximum number of ways to park "
		.asciiz	"for a parking lot size of "
maxMsg2:	.asciiz " is "
maxMsg3:	.asciiz "."

# -----
#  Local variables for readParkingLotSize() function.

MINSIZE = 1
MAXSIZE = 50

strtMsg1:	.asciiz	"Enter parking lots size ("
strtMsg2:	.asciiz	"-"
strtMsg3:	.asciiz	"): "

errValue:	.ascii	"\nError, invalid size. "
		.asciiz	"Please re-enter.\n"

# -----
#  Local variables for askPrompt() function.

ansErr:		.asciiz	"Error, must answer with (y/n).\n"
ans:		.space	3


###########################################################################
#  text/code segment

.text
.globl main
.ent main
main:

# -----
#  Display program header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Basic steps:
#	read praking lot size
#	compute max
#	display result

tryAgain:
	jal	readParkingLotSize
	move	$s0, $v0			# parking lot size

	move	$a0, $v0
	jal	nellisParkingLot

	move	$a0, $s0
	move	$a1, $v0
	jal	displayResult

# -----
#  See if user want to try another?

	jal	prtNewline
	la	$a0, againPrompt
	jal	askPrompt

	beq	$v0, TRUE, tryAgain

# -----
#  Done, show message and terminate program.

gameOver:
	li	$v0, 4
	la	$a0, endMsg
	syscall

	li	$v0, 10
	syscall					# all done...
.end main

# =========================================================================
#  Very simple function to print a new line.
#	Note, use of this routine is optional.

.globl	prtNewline
.ent	prtNewline
prtNewline:
	la	$a0, newLine
	li	$v0, 4
	syscall

	jr	$ra
.end	prtNewline

# =========================================================================
#  Prompt for, read, and check starting position.
#	must be > 0 and <= length

# -----
#    Arguments:
#	none

#    Returns:
#	$v0, parking lot size

.globl	readParkingLotSize
.ent	readParkingLotSize
readParkingLotSize:

	li $v0, 4 				#start message
	la $a0, strtMsg1
	syscall
	
	li $v0, 1 				# call code for print int
	li $a0, MINSIZE		    # get minsize
	syscall 				# system call
	
	li $v0, 4 				#start message2
	la $a0, strtMsg2
	syscall
	
	li $v0, 1 				# call code for print int
	li $a0, MAXSIZE		    # get maxsize
	syscall 				# system call
	
	li $v0, 4 				#start message2
	la $a0, strtMsg3
	syscall

readInt:				
	li $v0, 5 				#read int
	syscall
	
	li $t0, MINSIZE
	li $t1, MAXSIZE
	bltu $v0, $t0, invalid
	bgtu $v0, $t1, invalid

	j done
	
invalid:
	li $v0, 4 				#start message2
	la $a0, errValue
	syscall
	j readInt
	
done:
jr $ra

.end	readParkingLotSize

# =========================================================================
#  Function to recursivly determine the maximum number of
#	ways to park in the Nellis parking lot.

# -----
#  Arguments:
#	$a0 - parking lot size

#  Returns:
#	$v0 - maximum ways

.globl	nellisParkingLot
.ent	nellisParkingLot
nellisParkingLot:
subu $sp, $sp, 12
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
li $s0, 0
move $s1, $a0

bleu $a0, 1, parkingOne
beq $a0, 2, parkingTwo

subu $a0, $s1, 1
jal nellisParkingLot
addu $s0, $s0, $v0 # s0 = npl(n-1)

subu $a0, $s1, 2
jal nellisParkingLot
addu $s0, $s0, $v0 # s0 = npl(n-1) + npl(n-2)

subu $a0, $s1, 3
jal nellisParkingLot
addu $s0, $s0, $v0 # s0 = npl(n-1) + npl(n-2) + npl(n-3)

move $v0, $s0
j parkingDone

parkingOne:
li $v0 1 #1 space for 0/1
j parkingDone

parkingTwo:
li $v0, 2 #2 space for 2


parkingDone:
lw $ra, ($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
addu $sp, $sp, 12
jr $ra

.end nellisParkingLot

# =========================================================================
#  Function to display formatted final result.

# -----
#    Arguments:
#	$a0 - parking lot size
#	$a1 - maximum number of ways to park

#    Returns:
#	n/a


.globl	displayResult
.ent	displayResult
displayResult:

subu $sp, $sp, 12
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
li $s0, 0
move $s0, $a0
move $s1, $a1

	li $v0, 4 				#max message 1
	la $a0, maxMsg1
	syscall
	
	li $v0, 1 				# call code for print int
	move $a0, $s0 			# parking lot size
	syscall 				# system call
	
	li $v0, 4 				#max message 2
	la $a0, maxMsg2
	syscall
	
	li $v0, 1 				# call code for print int
	move $a0, $s1 			# max number of ways to park
	syscall 	
	
	li $v0, 4 				#max message 3
	la $a0, maxMsg3
	syscall
	
	jal prtNewline
	jal prtNewline
	
	
lw $ra, ($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
addu $sp, $sp, 12
jr $ra
.end	displayResult

# =========================================================================
#  Function to ask user if they want to do another start position.

#  Basic flow:
#	prompt user
#	read user answer (as character)
#		if y/Y -> return TRUE
#		if n/N -> return FALSE
#	otherwise, display error and re-prompt
#  Note, uses read string syscall.

# -----
#  Arguments:
#	$a0 - prompt string
#  Returns:
#	$v0 - TRUE/FALSE

.globl	askPrompt
.ent	askPrompt
askPrompt:
subu $sp, $sp, 4
sw $ra, ($sp)

	li $v0, 4 				#prompt message
	syscall					# y or n?
	
charRead:
	li $v0, 8				#string read
	la $a0, ans
	li $a1, 2
	syscall

	la $t0, ans
	lb $t1, ($t0)
	beq $t1, 89, isTrue
	beq $t1, 121, isTrue
	
	beq $t1, 78, isFalse
	beq $t1, 110, isFalse
	
	jal prtNewline
	li $v0, 4 				#err
	la $a0, ansErr
	syscall
	
	
	j charRead
	
isTrue:
	jal prtNewline
	jal prtNewline
	li $v0, TRUE
	j askDone

isFalse:
	jal prtNewline
	jal prtNewline
	li $v0, FALSE
	
askDone:
lw $ra, ($sp)
addu $sp, $sp, 4
jr $ra
	
.end	askPrompt

#####################################################################
