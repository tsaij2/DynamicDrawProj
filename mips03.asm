#  Jonathan Tsai
#  CS 218 Section 1001
#  CSC218, MIPS Assignment #3
#  MIPS assembly language main program and functions:

#  * MIPS assembly language function, randomNumbers(), to create
#    a series of random numbers, which are stored in an array.
#    The pseudo random number generator uses the linear
#    congruential generator method as follows:
#        R(n+1) = ( A * R(n) + B) mod 2^24

#  * MIPS void function, printNumbers(), to print a list of right
#    justified numbers including a passed header string.

#  * MIPS assembly language function, selectionSort(), to
#    sort a list of numbers into ascending (small to large) order.
#    Uses the shell sort algorithm.

#  * MIPS value returning function, estimatedMedian(), to compute
#    the estimated median of the unsorted array. If the list length
#    is even, the estimated median is computed by summing the first,
#    last, and two middle values and then dividing by 4. If the list
#    length is odd, the estimated median is computed by summing the
#    first, last, and middle values and then dividing by 3.

#  * MIPS void function, stats(), that will find the minimum,
#    median, maximum, sum, and average of the numbers array. The
#    function is called after the list is sorted. The average should
#    be calculated and returned as a floating point value.

#  * MIPS void function, showStats(), to print the list and
#    the statistical information (minimum, maximum, median, estimated
#    median, sum, average) in the format shown in the example.
#    The numbers should be printed 10 per line (see example).
#    In addition, the function should compute and display the difference
#    between actual median and the estimated median (as a floating
#    point value). The formula for percentage change is as follows:



#####################################################################
#  data segment

.data

# -----
#  Data declarations for main.

lst1:		.space		60		# 15 * 4
len1:		.word		15
seed1:		.word		19
min1:		.word		0
med1:		.word		0
max1:		.word		0
estMed1:	.word		0
fSum1:		.float		0.0
fAve1:		.float		0.0


lst2:		.space		340		# 85 * 4
len2:		.word		85
seed2:		.word		39
min2:		.word		0
med2:		.word		0
max2:		.word		0
estMed2:	.word		0
fSum2:		.float		0.0
fAve2:		.float		0.0

lst3:		.space		2800		# 700 * 4
len3:		.word		700
seed3:		.word		239
min3:		.word		0
med3:		.word		0
max3:		.word		0
estMed3:	.word		0
fSum3:		.float		0.0
fAve3:		.float		0.0

lst4:		.space		14160		# 3540 * 4
len4:		.word		3540
seed4:		.word		137
min4:		.word		0
med4:		.word		0
max4:		.word		0
estMed4:	.word		0
fSum4:		.float		0.0
fAve4:		.float		0.0

lst5:		.space		16628		# 4157 * 4
len5:		.word		4157
seed5:		.word		731
min5:		.word		0
med5:		.word		0
max5:		.word		0
estMed5:	.word		0
fSum5:		.float		0.0
fAve5:		.float		0.0


hdr:		.asciiz	"MIPS Assignment #3\n"
hdrMain:		.ascii	"\n---------------------------"
		.asciiz	"\nData Set #"
hdrLength:	.asciiz	"\nLength: "
hdrUnsorted:	.asciiz	"\n\n Random Numbers: \n"
hdrSorted:	.asciiz	"\n Sorted Numbers: \n"

str1:		.asciiz	"         Sum = "
str2:		.asciiz	"     Average = "
str3:		.asciiz	"     Minimum = "
str4:		.asciiz	"      Median = "
str5:		.asciiz	"     Maximum = "
str6:		.asciiz	"  Est Median = "
str7:		.asciiz " Median Diff = "

# -----
#  Variables/constants for randomNumbers function.

A = 127691
B = 7
RAND_LIMIT = 100000

# -----
#  Variables/constants for selection sort function.

TRUE = 1
FALSE = 0

# -----
#  Variables/constants for printNumbers function.

fOneHundred:	.float	100.0

sp1:		.asciiz	" "
sp2:		.asciiz	"  "
sp3:		.asciiz	"   "
sp4:		.asciiz	"    "
sp5:		.asciiz	"     "
sp6:		.asciiz	"      "
sp7:		.asciiz	"       "

# -----
#  Variables for showStats function.

newLine:	.asciiz	"\n"


#####################################################################
#  text/code segment

.text

.globl	main
.ent	main
main:

# -----
#  Display Program Header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

	li	$s0, 1				# counter, data set number

# -----
#  Call routines:
#	* Gnerate random numbers
#	* Display unsorted numbers
#	* find estimated median
#	* Sort numbers
#	* Find stats (min, median, max, float sum, and float average)
#	* Display stats, show sorted numbers, find difference 
#            between estimate median and real median

# ----------------------------
#  Data Set #1
#  Headers

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len1
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst1
	lw	$a1, len1
	lw	$a2, seed1
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst1
	lw	$a2, len1
	jal	printNumbers


# -----
#  Get estimate median
#	estMed = estimatedMedian(lst, len)

	la	$a0, lst1
	lw	$a1, len1
	jal	estimatedMedian

	sw	$v0, estMed1

# -----
#  Sort numbers.
#	selectionSort(lst, len)

	la	$a0, lst1
	lw	$a1, len1
	jal	selectionSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst1			# arg #1
	lw	$a1, len1			# arg #2
	la	$a2, min1			# arg #3
	la	$a3, med1			# arg #4
	la	$t0, max1			# arg #5
	la	$t1, fSum1			# arg #6
	la	$t2, fAve1			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, estMed, dhrStr)

	la	$a0, lst1
	lw	$a1, len1
	l.s	$f2, fSum1
	l.s	$f4, fAve1
	lw	$t0, min1
	lw	$t1, med1
	lw	$t2, max1
	lw	$t3, estMed1
	la	$t4, hdrSorted
	sub	$sp, $sp, 28
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)
	sw	$t4, 24($sp)

	jal	showStats
	add	$sp, $sp, 28

# ----------------------------
#  Data Set #2

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len2
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst2
	lw	$a1, len2
	lw	$a2, seed2
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst2
	lw	$a2, len2
	jal	printNumbers


# -----
#  Get estimate median
#	estMed = estimatedMedian(lst, len)

	la	$a0, lst2
	lw	$a1, len2
	jal	estimatedMedian

	sw	$v0, estMed2

# -----
#  Sort numbers.
#	selectionSort(lst, len)

	la	$a0, lst2
	lw	$a1, len2
	jal	selectionSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst2			# arg #1
	lw	$a1, len2			# arg #2
	la	$a2, min2			# arg #3
	la	$a3, med2			# arg #4
	la	$t0, max2			# arg #5
	la	$t1, fSum2			# arg #6
	la	$t2, fAve2			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, estMed, dhrStr)

	la	$a0, lst2
	lw	$a1, len2
	l.s	$f2, fSum2
	l.s	$f4, fAve2
	lw	$t0, min2
	lw	$t1, med2
	lw	$t2, max2
	lw	$t3, estMed2
	la	$t4, hdrSorted
	sub	$sp, $sp, 28
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)
	sw	$t4, 24($sp)

	jal	showStats
	add	$sp, $sp, 28

# ----------------------------
#  Data Set #3

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len3
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst3
	lw	$a1, len3
	lw	$a2, seed3
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst3
	lw	$a2, len3
	jal	printNumbers


# -----
#  Get estimate median
#	estMed = estimatedMedian(lst, len)

	la	$a0, lst3
	lw	$a1, len3
	jal	estimatedMedian

	sw	$v0, estMed3

# -----
#  Sort numbers.
#	selectionSort(lst, len)

	la	$a0, lst3
	lw	$a1, len3
	jal	selectionSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst3			# arg #1
	lw	$a1, len3			# arg #2
	la	$a2, min3			# arg #3
	la	$a3, med3			# arg #4
	la	$t0, max3			# arg #5
	la	$t1, fSum3			# arg #6
	la	$t2, fAve3			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, estMed, dhrStr)

	la	$a0, lst3
	lw	$a1, len3
	l.s	$f2, fSum3
	l.s	$f4, fAve3
	lw	$t0, min3
	lw	$t1, med3
	lw	$t2, max3
	lw	$t3, estMed3
	la	$t4, hdrSorted
	sub	$sp, $sp, 28
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)
	sw	$t4, 24($sp)

	jal	showStats
	add	$sp, $sp, 28

# ----------------------------
#  Data Set #4

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len4
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst4
	lw	$a1, len4
	lw	$a2, seed4
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst4
	lw	$a2, len4
	jal	printNumbers

# -----
#  Get estimate median
#	estMed = estimatedMedian(lst, len)

	la	$a0, lst4
	lw	$a1, len4
	jal	estimatedMedian

	sw	$v0, estMed4

# -----
#  Sort numbers.
#	selectionSort(lst, len)

	la	$a0, lst4
	lw	$a1, len4
	jal	selectionSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst4			# arg #1
	lw	$a1, len4			# arg #2
	la	$a2, min4			# arg #3
	la	$a3, med4			# arg #4
	la	$t0, max4			# arg #5
	la	$t1, fSum4			# arg #6
	la	$t2, fAve4			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, estMed, dhrStr)

	la	$a0, lst4
	lw	$a1, len4
	l.s	$f2, fSum4
	l.s	$f4, fAve4
	lw	$t0, min4
	lw	$t1, med4
	lw	$t2, max4
	lw	$t3, estMed4
	la	$t4, hdrSorted
	sub	$sp, $sp, 28
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)
	sw	$t4, 24($sp)

	jal	showStats
	add	$sp, $sp, 28

# ----------------------------
#  Data Set #5

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len5
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst5
	lw	$a1, len5
	lw	$a2, seed5
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst5
	lw	$a2, len5
	jal	printNumbers

# -----
#  Get estimate median
#	estMed = estimatedMedian(lst, len)

	la	$a0, lst5
	lw	$a1, len5
	jal	estimatedMedian

	sw	$v0, estMed5

# -----
#  Sort numbers.
#	selectionSort(lst, len)

	la	$a0, lst5
	lw	$a1, len5
	jal	selectionSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst5			# arg #1
	lw	$a1, len5			# arg #2
	la	$a2, min5			# arg #3
	la	$a3, med5			# arg #4
	la	$t0, max5			# arg #5
	la	$t1, fSum5			# arg #6
	la	$t2, fAve5			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, estMed, dhrStr)

	la	$a0, lst5
	lw	$a1, len5
	l.s	$f2, fSum5
	l.s	$f4, fAve5
	lw	$t0, min5
	lw	$t1, med5
	lw	$t2, max5
	lw	$t3, estMed5
	la	$t4, hdrSorted
	sub	$sp, $sp, 28
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)
	sw	$t4, 24($sp)

	jal	showStats
	add	$sp, $sp, 28

# -----
#  Done, terminate program.

	li	$v0, 10
	syscall					# au revoir...

.end main

#####################################################################
#  Generate pseudo random numbers using the linear
#  congruential generator method.

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - count of random numbers to generate
#	$a2 - seed

#    Returns:
#	N/A

.globl	randomNumbers
.ent randomNumbers
randomNumbers:

move $t1, $a0	#address of index
li $t2, 0		#index

#A = 127691
#B = 7
li $t4, 127691		#Value of A
li $t5, 7		#Value of B
move $t6, $a2	#seed


createArr:
move $t3, $t6		#previous R/seed
mul $t3, $t3, $t4	#A * R
addu $t3, $t3, $t5	#A * R + B
remu $t3, $t3, 16777216		#mod 2^24
remu $t9, $t3, 100000		#mod 100000
sw $t9, ($t1)
move $t6, $t3		#store previous R
addu $t2, $t2, 1	#inc index
addu $t1, $t1, 4
bne $t2, $a1, createArr

jr $ra

.end	randomNumbers

#####################################################################
#  Sort a list of numbers using standard selection sort.

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - list length

#    Returns:
#	sorted list (via passed address)

.globl selectionSort
.ent selectionSort
selectionSort:
li $t2, 0		#t2 = i
li $t3, 0		#t3 = j
li $t4, 0		#t4 = current min_index
move $t8, $a1
subu $t8, $t8, 1	#t8 = length - 1

iLp:
beq $t2, $t8, selectionDone		#if i = length - 1, finish
move $t4, $t2					#min_index = i
addu $t3, $t2, 1				#j = 1 + 1

jLp:
move $t1, $a0
mul $t9, $t4, 4
addu $t1, $t1, $t9
lw $t5, ($t1)			#t5 = arr[min_index]  value

move $t1, $a0
mul $t9, $t3, 4
addu $t1, $t1, $t9
lw $t6, ($t1)			#t6= arr[j] value

bltu $t6, $t5, newIndex		#if arr[j] < arr[min_index]

updatej:
addu $t3, $t3, 1		#j++
beq $t3, $a1, swap	#if j = length, exit j lp
j jLp

newIndex:
move $t4, $t3		#min_index = j
move $t1, $a0
mul $t9, $t4, 4
addu $t1, $t1, $t9
lw $t7, ($t1)			#t7 = arr[min_index]  value
j updatej

swap:
move $t1, $a0
mul $t9, $t2, 4
addu $t1, $t1, $t9
lw $t6, ($t1)		#t6 = arr[i] value
sw $t7, ($t1)		#arr[i] = arr[min_index]

move $t1, $a0
mul $t9, $t4, 4
addu $t1, $t1, $t9
sw $t6, ($t1)		#arr[min_index] = arr[i]

addu $t2, $t2, 1		#i++
j iLp

selectionDone:
jr $ra

.end selectionSort


#####################################################################
#  Find estimated median (first, last, and middle two).

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - list length

#    Returns:
#	$v0, estimated median

.globl estimatedMedian
.ent estimatedMedian
estimatedMedian:

move $t1, $a0

mul $t4, $a1, 4		
subu $t4, $t4, 4	#t4 = last index offset
divu $t5, $a1, 2
mul $t5, $t5, 4		#t5 = middle index offset

li $t2, 0			#sum
remu $t3, $a1, 2		#t3 = rem

lw $t9, ($t1)
addu $t2, $t2, $t9		#$t2 = first num

addu $t1, $t1, $t4		#t1 at last index
lw $t9, ($t1)
addu $t2, $t2, $t9		#$t2 = first + last

move $t1, $a0
addu $t1, $t1, $t5		#t1 at mid index
lw $t9, ($t1)
addu $t2, $t2, $t9		#$t2 = first + last + mid

beqz $t3, evenMed		#branches if we have even length

divu $t2, $t2, 3
j done

evenMed:
subu $t1, $t1, 4
lw $t9, ($t1)
addu $t2, $t2, $t9
divu $t2, $t2, 4

done:
	move $v0, $t2
	jr $ra

.end estimatedMedian


#####################################################################
#  MIPS assembly language function, stats(), that will
#    find the sum, average, minimum, maximum, and median of the list.
#    The average is returned as floating point value.

#  HLL Call:
#	call stats(lst, len, min, med, max, fSum, fAve)

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - list length
#	$a2 - addr of min
#	$a3 - addr of med
#	($fp) - addr of max
#	4($fp) - addr of fSum
#	8($fp) - addr of fAve

#    Returns (via reference):
#	min
#	med
#	max
#	fSum
#	fAve

.globl stats
.ent stats
stats:

subu $sp, $sp, 8 # preserve registers
sw $fp, ($sp)
addu $fp, $sp, 8 # set frame pointer

move $t1, $a0
li $t2, 0		#hold sum
li $t6, 0		#index
lw $t7, ($t1)	#t7 = min
li $t9, 0		#sum

sumLp:
lw $t2, ($t1)
addu $t9, $t9, $t2

addu $t1, $t1, 4
addu $t6, $t6, 1
bne $t6, $a1, sumLp

subu $t1, $t1, 4
lw $t8, ($t1) 	#t8 = max
j fAverage

fAverage:
mtc1 $t9, $f4		#f4 = sum
cvt.s.w $f9, $f4	#f9 = float sum

mtc1 $a1, $f4		#f4 = len
cvt.s.w $f8, $f4	#f8 = float len

div.s $f7, $f9, $f8		#f7 = ave = SUM/LENGTH

med:
move $t1, $a0
remu $t2, $a1, 2		#t2 = rem
divu $t3, $a1, 2	#t3 = middle index
mul $t3, $t3, 4		#t3 = middle index offset
addu $t1, $t1, $t3
bnez $t2, oddMed
lw $t4, ($t1)
subu $t1, $t1, 4
lw $t5, ($t1)
addu $t4, $t4, $t5
divu $t4, $t4, 2		#t4 = med
j store

oddMed:
lw $t4, ($t1)		#t4 = med

store:
lw $t0, ($fp)			#max address
lw $t1, 4($fp)			#sum address
lw $t2, 8($fp)			#ave address
sw $t4, ($a3)			#med
sw $t7, ($a2)			#min
sw $t8, ($t0)			#max
s.s $f9, ($t1)			#fSum
s.s $f7, ($t2)			#fAve

lw $fp, ($sp)
addu $sp, $sp, 8
jr $ra

.end stats

#####################################################################
#  MIPS assembly language function, printNumbers(), to display
#    the right justified numbers in the passed array.
#    The numbers should be printed 10 per line (see example).

# -----
#    Arguments:
#	$a0 - address of header string
#	$a1 - starting address of the list
#	$a2 - list length

#    Returns:
#	N/A

.globl	printNumbers
.ent printNumbers
printNumbers:
subu $sp, $sp, 24 # preserve registers
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $fp, 16($sp)
sw $ra, 20($sp)
addu $fp, $sp, 24 # set frame pointer

	#move	$a0, $a0
	li	$v0, 4
	syscall				# print header

	move $s0, $a1
	li $s1, 0
	move $s2, $a2
		
	li $v0, 4 				# print 2 spaces
	la $a0, sp2
	syscall
	
printLoop:

lw $t1, ($s0)			#Determine how many spaces to print for justification
bltu $t1, 10, printFour
bltu $t1, 100, printThree
bltu $t1, 1000, printTwo
bltu $t1, 10000, printOne
j justified
	
printOne:
	li $v0, 4 				# print 1 spaces
	la $a0, sp1
	syscall
	j justified
	
printTwo:
	li $v0, 4 				# print 2 spaces
	la $a0, sp2
	syscall
	j justified
	
printThree:
	li $v0, 4 				# print 3 spaces
	la $a0, sp3
	syscall
	j justified
	
printFour:
	li $v0, 4 				# print 4 spaces
	la $a0, sp4
	syscall

justified:	

	li $v0, 1 				# call code for print int
	lw $a0, ($s0) 			# get array[i]
	syscall 				# system call
				
	li $v0, 4 				# print 2 spaces
	la $a0, sp2
	syscall
	
	addu $s0, $s0, 4 		# increment arr
	add $s1, $s1, 1 		# increment index
	
	rem $t0, $s1, 10
	bnez $t0, skipNewLine
	
	li $v0, 4 				# print new line
	la $a0, newLine
	syscall
	
	li $v0, 4 				# print 2 spaces
	la $a0, sp2
	syscall
	
skipNewLine:
bne $s1, $s2, printLoop 	# if index < length

	li $v0, 4 				# print new line
	la $a0, newLine
	syscall

lw $s0, 0($sp)
lw $s1, 4($sp)	
lw $s2, 8($sp)	
lw $s3, 12($sp)		
lw $fp, 16($sp)
lw $ra, 20($sp)
addu $sp, $sp, 24
jr $ra

.end	printNumbers

#####################################################################
#  MIPS assembly language function, showStats(), to display
#    the tAreas and the statistical information:
#	sum (float), average (float), minimum, median, maximum,
#	estimated median in the presribed format.
#    The numbers should be printed four (4) per line (see example).

#  Note, due to the system calls, the saved registers must
#        be used.  As such, push/pop saved registers altered.

#  HLL Call:
#	call showStats(lst, len, fSum, fAve, min, med, max, estMed, hdrStr)

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - list length
#	($fp) - sum (float)
#	4($fp) - average (float)
#	8($fp) - min
#	12($fp) - med
#	16($fp) - max
#	20($fp) - est median
#	24($fp) - header string addr

#    Returns:
#	N/A

.globl	showStats
.ent showStats
showStats:

subu $sp, $sp, 36 # preserve registers
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
s.s $f20, 20($sp)
s.s $f21, 24($sp)
sw $fp, 28($sp)
sw $ra, 32($sp)
addu $fp, $sp, 36 # set frame pointer

l.s $f20, ($fp)	 	#sum (float)
l.s $f21, 4($fp)	 #average (float)

lw $s0, 8($fp)		#s0 = min
lw $s1, 12($fp)		#s1 = med
lw $s2, 16($fp)		#s2 = max
lw $s3, 20($fp)		#s3 = est med

move $a2, $a1		#a2 = len
move $a1, $a0		#a1 = lst
lw $a0, 24($fp)		#a0 = hdrStr
jal printNumbers

li $v0, 4 				# print new line
la $a0, newLine
syscall

la $a0, str1			# print Sum
li $v0, 4
syscall				

li $v0, 2				# call code for print float
mov.s $f12, $f20 			# get sum
syscall 				# system call
		
li $v0, 4 				# print new line
la $a0, newLine
syscall

la $a0, str2			#print Average
li $v0, 4
syscall	
			
li $v0, 2				# call code for print float
mov.s $f12, $f21 			# get average
syscall 				# system call
		
li $v0, 4 				# print new line
la $a0, newLine
syscall

la $a0, str3			#print Minimum
li $v0, 4
syscall	
			
li $v0, 1				# call code for print int
move $a0, $s0 			# get minimum
syscall 				# system call
		
li $v0, 4 				# print new line
la $a0, newLine
syscall

la $a0, str4			#print Median
li $v0, 4
syscall	
			
li $v0, 1				# call code for print int
move $a0, $s1 			# get median
syscall 				# system call
		
li $v0, 4 				# print new line
la $a0, newLine
syscall

la $a0, str5			#print Maximum
li $v0, 4
syscall	
			
li $v0, 1				# call code for print int
move $a0, $s2 			# get maximum
syscall 				# system call
		
li $v0, 4 				# print new line
la $a0, newLine
syscall

la $a0, str6			#print Est Median
li $v0, 4
syscall	
			
li $v0, 1				# call code for print int
move $a0, $s3 			# get Est Median
syscall 				# system call
		
li $v0, 4 				# print new line
la $a0, newLine
syscall


move $t0, $s3
subu $t0, $t0, $s1		#t0 = est median - median
mtc1 $t0, $f4
cvt.s.w $f6, $f4		#f6 = float est median - median

mtc1 $s1, $f4
cvt.s.w $f5, $f4		#f5 = float median

li $t0, 100
mtc1 $t0, $f4
cvt.s.w $f7, $f4		#f7 = float 100

div.s $f4, $f6, $f5		#f4 = (flost est - median) / median
mul.s $f4, $f4, $f7
mov.s $f20, $f4			#f20 = est med

la $a0, str7			#print Median diff
li $v0, 4
syscall	
			
li $v0, 2				# call code for print float
mov.s $f12, $f20 			# get median diff
syscall 				# system call
		
li $v0, 4 				# print new line
la $a0, newLine
syscall

li $v0, 4 				# print new line
la $a0, newLine
syscall

lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
l.s $f20, 20($sp)
l.s $f21, 24($sp)
lw $fp, 28($sp)
lw $ra, 32($sp)
addu $sp, $sp, 36
jr $ra

.end showStats

#####################################################################
