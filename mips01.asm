#  CS 218, MIPS Assignment #1
#  Jonathan Tsai
#  Section 1001

#  Program to calculate the perimeter for each rectangular
#  kite in a set of rectangular kites.  Then finds the min,
#  median, max, sum, and average of perimeters.


###########################################################
#  data segment

.data

aSides:	.word	  10,   15,   25,   33,   44,   58,   69,   72,   86,   99
	.word	 102,  121,  136,  147,  149,  155,  161,  173,  182,  195
	.word	 207,  211,  227,  231,  247,  257,  267,  271,  281,  299
	.word	 302,  309,  315,  319,  323,  325,  331,  342,  344,  349
	.word	 351,  353,  366,  369,  371,  377,  380,  388,  391,  399
	.word	 402,  411,  416,  427,  430,  434,  441,  450,  453,  463
	.word	 469,  474,  477,  479,  482,  484,  486,  488,  492,  493
	.word	 505,  510,  515,  521,  529,  533,  538,  542,  544,  549
	.word	 552,  559,  563,  567,  570,  573,  580,  588,  592,  599
	.word	 604,  612,  624,  636,  647,  654,  666,  670,  686,  695

cSides:	.word	 101,  109,  112,  129,  134,  141,  155,  168,  176,  187
	.word	 206,  212,  222,  231,  246,  250,  254,  278,  288,  292
	.word	 303,  315,  321,  339,  348,  359,  362,  374,  380,  391
	.word	 400,  404,  406,  407,  424,  425,  426,  429,  438,  442
	.word	 450,  457,  462,  469,  470,  478,  481,  487,  490,  498
	.word	 501,  509,  511,  517,  524,  526,  535,  537,  540,  549
	.word	 551,  557,  562,  569,  570,  575,  580,  586,  591,  598
	.word	 604,  609,  614,  618,  622,  627,  631,  637,  643,  647
	.word	 644,  659,  661,  668,  672,  677,  681,  687,  693,  699
	.word	 702,  715,  727,  738,  743,  755,  764,  779,  788,  799

length:	.word	  100

kitePerims:
	.space	400				# 4 bytes * 100 items

kpMin:	.word	0
kpMed:	.word	0
kpMax:	.word	0
kpSum:	.word	0
kpAve:	.word	0

hdr:	.ascii	"MIPS Assignment #1 \n\n"
	.ascii	"MIPS Program to calculate the perimeter of each kite \n"
	.ascii	" in a series of kites.  Also finds min, mid, max, sum,\n"
	.asciiz	" and average for the kite perimeters. \n\n"

newLine:
	.asciiz	"\n"

blnks:	.asciiz	"  "

a1_st:	.asciiz	"\nKite Perimeters Minimum = "
a2_st:	.asciiz	"\nKite Perimeters Median  = "
a3_st:	.asciiz	"\nKite Perimeters Maximum = "
a4_st:	.asciiz	"\nKite Perimeters Sum     = "
a5_st:	.asciiz	"\nKite Perimeters Average = "

###########################################################
#  text/code segment

.text
.globl	main
.ent	main
main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall				# print header

# -----
#  Calculate rectangular kite perimeters.


	la $t0, aSides
	la $t1, cSides
	la $t4, kitePerims
	li $t5, 0
	lw $t6, length
	li $t7, 0
	
Lp:
	lw $t2, ($t0)
	lw $t9, ($t1)
	mul $t2, $t2, $t9
	add $t0, $t0, 4
	add $t1, $t1, 4
	mul $t3, $t2, 2
	sw $t3, ($t4)
	add $t7, $t7, $t3		#Sum
	add $t4, $t4, 4		#Inc kitePerims
	add $t5, $t5, 1		#Index Tracker
	bne $t5, $t6, Lp	#Branch if index has reached length
	
	sub $t4, $t4, 4		#Max
	lw $t2, ($t4)
	sw $t2, kpMax
	
	la $t4, kitePerims	#Min
	lw $t2, ($t4)
	sw $t2, kpMin
	
	sw $t7, kpSum		#Sum
	div $t7, $t7, $t6	#Avg
	sw $t7, kpAve
	
	rem $t8, $t6, 2		#Remainder
	div $t6, $t6, 2		#t6 = length/2
	mul $t6, $t6, 4		#Index for middle of kitePerims arr
	add $t4, $t4, $t6
	beq $t8, 0, evenMed		#If remainder is 0, we have an even length
	lw $t2, ($t4)
	sw $t2, kpMed			#Odd remainder, so middle of array is med
	j done
	
evenMed:
	lw $t9, ($t4)	
	sub $t4, $t4, 4
	lw $t2, ($t4)	
	add $t9, $t9, $t2
	div $t9, $t9, 2
	sw $t9, kpMed

done:


##########################################################
#  Display numbers.

	la $s0, kitePerims
	li $s1, 0
	lw $s2, length
		
	li $v0, 4 				# print 2 spaces
	la $a0, blnks
	syscall
	
printLoop:
	li $v0, 1 				# call code for print int
	lw $a0, ($s0) 			# get array[i]
	syscall 				# system call
				
	li $v0, 4 				# print 2 spaces
	la $a0, blnks
	syscall
	
	addu $s0, $s0, 4 		# increment arr
	add $s1, $s1, 1 		# increment index
	
	rem $t0, $s1, 7
	bnez $t0, skipNewLine
	
	li $v0, 4 				# print new line
	la $a0, newLine
	syscall
	
	li $v0, 4 				# print 2 spaces
	la $a0, blnks
	syscall
	
skipNewLine:
bne $s1, $s2, printLoop 	# if index < length



##########################################################
#  Display results.

	la	$a0, newLine		# print a newline
	li	$v0, 4
	syscall
	la	$a0, newLine		# print a newline
	li	$v0, 4
	syscall

#  Print min message followed by result.

	la	$a0, a1_st
	li	$v0, 4
	syscall				# print "min = "

	lw	$a0, kpMin
	li	$v0, 1
	syscall				# print min

# -----
#  Print middle message followed by result.

	la	$a0, a2_st
	li	$v0, 4
	syscall				# print "med = "

	lw	$a0, kpMed
	li	$v0, 1
	syscall				# print mid

# -----
#  Print max message followed by result.

	la	$a0, a3_st
	li	$v0, 4
	syscall				# print "max = "

	lw	$a0, kpMax
	li	$v0, 1
	syscall				# print max

# -----
#  Print sum message followed by result.

	la	$a0, a4_st
	li	$v0, 4
	syscall				# print "sum = "

	lw	$a0, kpSum
	li	$v0, 1
	syscall				# print sum

# -----
#  Print average message followed by result.

	la	$a0, a5_st
	li	$v0, 4
	syscall				# print "ave = "

	lw	$a0, kpAve
	li	$v0, 1
	syscall				# print average

# -----
#  Done, terminate program.

endit:
	la	$a0, newLine		# print a newline
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall				# all done!

.end main
