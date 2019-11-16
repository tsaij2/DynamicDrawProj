#  CS 218, MIPS Assignment #2
#  Jonathan Tsai
#  Section 1001

#  MIPS assembly language program to calculate the
#  area for each rectangular kite in a set of
#  rectangular kites.

#  Then find est median, max, sum, and average
#  for the kite areas.


###########################################################
#  data segment

.data

pSides:
	.word	  327,   344,   310,   372,   324 
	.word	  325,   316,   362,   328,   392 
	.word	  317,   314,   315,   372,   324 
	.word	  325,   316,   362,   338,   392 
	.word	  321,   383,   333,   330,   337 
	.word	  342,   335,   358,   323,   335 
	.word	  327,   326,   326,   327,   227 
	.word	  357,   387,   399,   311,   323 
	.word	  324,   325,   326,   375,   394 
	.word	  349,   326,   362,   331,   327 
	.word	  377,   399,   397,   375,   314 
	.word	  364,   341,   342,   373,   366 
	.word	  304,   346,   323,   356,   363 
	.word	  321,   318,   377,   343,   378 
	.word	  312,   311,   310,   335,   310 
	.word	  377,   399,   377,   375,   314 
	.word	  394,   324,   312,   343,   376 
	.word	  334,   326,   332,   356,   363 
	.word	  324,   319,   322,   383,   310 
	.word	  391,   392,   329,   329,   322 

qSides:
	.word	  226,   252,   257,   267,   234 
	.word	  217,   254,   217,   225,   253 
	.word	  223,   273,   235,   261,   259 
	.word	  225,   224,   263,   247,   223 
	.word	  234,   234,   256,   264,   242 
	.word	  233,   214,   273,   231,   255 
	.word	  264,   273,   274,   223,   256 
	.word	  244,   252,   231,   242,   256 
	.word	  255,   224,   236,   275,   246 
	.word	  253,   223,   253,   267,   235 
	.word	  254,   229,   264,   267,   234 
	.word	  256,   253,   264,   253,   265 
	.word	  236,   252,   232,   231,   246 
	.word	  250,   254,   278,   288,   292 
	.word	  282,   295,   247,   252,   257 
	.word	  257,   267,   279,   288,   294 
	.word	  234,   252,   274,   286,   297 
	.word	  244,   276,   242,   236,   253 
	.word	  232,   251,   236,   287,   290 
	.word	  220,   241,   223,   232,   245 

length:	.word	100 

kiteAreas:
	.space	400 

kaMin:	.word	0 
kaMid:	.word	0 
kaMax:	.word	0 
kaSum:	.word	0 
kaAve:	.word	0 

LN_CNTR	= 6

# -----

hdr:	.ascii	"MIPS Assignment #2 \n"
	.ascii	"  Rectangular Kite Areas Program:\n"
	.ascii	"  Also finds minimum, est median, value, maximum,\n"
	.asciiz	"  sum, and average for the areas.\n\n"

a1_st:	.asciiz	"\nAreas Minimum      = "
a2_st:	.asciiz	"\nAreas Est. Median  = "
a3_st:	.asciiz	"\nAreas Maximum      = "
a4_st:	.asciiz	"\nAreas Sum          = "
a5_st:	.asciiz	"\nAreas Average      = "

newLn:	.asciiz	"\n"
blnks:	.asciiz	"  "


###########################################################
#  text/code segment

# --------------------
#  Compute Areas and statistics.

.text
.globl main
.ent main
main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall				# print header

# -----

#psides * qsides / 2
la $t0, pSides
la $t1, qSides
la $t2, kiteAreas
li $t5, 0			#index
li $t6, 0			#min
li $t7, 0			#max
li $t8, 0			#sum
lw $t9, length		#length

#set intial min/max
	lw $t3, ($t0)
	lw $t4, ($t1)
	mul $t3, $t3, $t4
	divu $t3, $t3, 2
	sw $t3, ($t2)
	move $t6, $t3
	move $t7, $t3
	addu $t8, $t8, $t3
	j continue

mainLp:
	lw $t3, ($t0)
	lw $t4, ($t1)
	mul $t3, $t3, $t4
	divu $t3, $t3, 2
	sw $t3, ($t2)
	addu $t8, $t8, $t3
	bltu, $t3, $t6, newMin
	bgtu, $t3, $t7, newMax

continue:
	addu $t0, $t0, 4
	addu $t1, $t1, 4
	addu $t2, $t2, 4
	addu $t5, 1
	bne $t5, $t9, mainLp
	j averageLb
	
newMin:
	move $t6, $t3
	j continue
	
newMax:
	move $t7, $t3
	j continue

averageLb:
	sw $t6, kaMin
	sw $t7, kaMax
	sw $t8, kaSum
	
	divu $t8, $t8, $t9
	sw $t8, kaAve

midLp:
	la $t2 kiteAreas
	lw $t3, ($t2)
	mul $t9, $t9, 4
	subu $t9, $t9, 4
	addu $t2, $t2, $t9
	lw $t4, ($t2)
	addu $t3, $t3, $t4
	
	la $t2, kiteAreas
	lw $t9, length
	divu $t9, $t9, 2
	mul $t9, $t9, 4
	addu $t2, $t2, $t9
	lw $t4, ($t2)
	addu $t3, $t3, $t4
	
	subu $t2, $t2, 4
	lw $t4, ($t2)
	addu  $t3, $t3, $t4
	
	divu $t3, $t3, 4
	
	sw $t3, kaMid

	
	##########################################################
#  Display numbers.

	la $s0, kiteAreas
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
	
	rem $t0, $s1, 6
	bnez $t0, skipNewLine
	
	li $v0, 4 				# print new line
	la $a0, newLn
	syscall
	
	li $v0, 4 				# print 2 spaces
	la $a0, blnks
	syscall
	
skipNewLine:
bne $s1, $s2, printLoop 	# if index < length
	
	


##########################################################
#  Display results.

	la	$a0, newLn		# print a newline
	li	$v0, 4
	syscall

#  Print min message followed by result.

	la	$a0, a1_st
	li	$v0, 4
	syscall				# print "min = "

	lw	$a0, kaMin
	li	$v0, 1
	syscall				# print min

# -----
#  Print middle message followed by result.

	la	$a0, a2_st
	li	$v0, 4
	syscall				# print "est med = "

	lw	$a0, kaMid
	li	$v0, 1
	syscall				# print mid

# -----
#  Print max message followed by result.

	la	$a0, a3_st
	li	$v0, 4
	syscall				# print "max = "

	lw	$a0, kaMax
	li	$v0, 1
	syscall				# print max

# -----
#  Print sum message followed by result.

	la	$a0, a4_st
	li	$v0, 4
	syscall				# print "sum = "

	lw	$a0, kaSum
	li	$v0, 1
	syscall				# print sum

# -----
#  Print average message followed by result.

	la	$a0, a5_st
	li	$v0, 4
	syscall				# print "ave = "

	lw	$a0, kaAve
	li	$v0, 1
	syscall				# print average

# -----
#  Done, terminate program.

endit:
	la	$a0, newLn		# print a newline
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall				# all done!

.end main