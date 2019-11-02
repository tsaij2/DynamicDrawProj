;  CS 218 - Assignment 9
;  Functions Template.
;  Jonathan Tsai
;  Section 1001

; --------------------------------------------------------------------
;  Write assembly language functions.

;  The value returning function, rdQuinaryNum(), should read
;  a quinary number from the user (STDIN) and perform
;  apprpriate error checking and conversion (string to integer).

;  The void function, countSort(), sorts the numbers into
;  ascending order (small to large).  Uses the insertion sort
;  algorithm modified to sort in ascending order.

;  The value returning function, lstAverage(), to return the
;  average of a list.

;  The void function, listStats(), finds the minimum, median,
;  and maximum, sum, and average for a list of numbers.
;  The median is determined after the list is sorted.
;  Must call the lstAverage() function.

;  The value returning function, coVariance(), computes the
;  co-variance for the two passed data sets.

;  The boolean function, rdQuinaryNum(), reads a quinary
;  number from standard input, performs conversion, and
;  error checks and range checks the value.

; ********************************************************************************

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  Define program specific constants.

MIN_NUM		equ	5
MAX_NUM		equ	156250
BUFFSIZE	equ	51			; 50 chars plus NULL

LIMIT		equ	MAX_NUM+1

; -----
;  NO static local variables allowed...


; ********************************************************************************

section	.text

; --------------------------------------------------------
;  Read an ASCII/quinary number from the user.
;  Perform appropriate error checking and, if OK,
;  convert to integer and return true.

;  If there is an error, print the applicable passed
;  error message string.

;  If the user enters a return (no other input, no
;  leading spaces), the function should return true.
;  This indicates no further input.

; -----
;  HLL Call:
;	status = rdQuinaryNum(&numberRead, promptStr, errMsg1,
;					errMsg2, errMSg3);

;  Arguments Passed:
;	1) numberRead, addr - rdi
;	2) promptStr, addr - rsi
;	3) errMsg1, addr - rdx
;	3) errMsg2, addr - rcx
;	3) errMsg3, addr - r8

;  Returns:
;	number read (via reference)
;	TRUE or FALSE


global rdQuinaryNum
rdQuinaryNum:

	push rbp
	mov rbp, rsp
	sub rsp, BUFFSIZE + 40
	push r12
	push r13
	push r14

	mov r12, 0			;index

	mov qword[rbp - BUFFSIZE - 8], rdi		;readnum add
	mov qword[rbp - BUFFSIZE - 16], rsi		;prompt str add
	mov qword[rbp - BUFFSIZE - 24], rdx		;err 1 prompt
	mov qword[rbp - BUFFSIZE - 32], rcx		;err 2 prompt
	mov qword[rbp - BUFFSIZE - 40], r8		;err 3 prompt

zeroLoopy:
	mov byte[rbp - BUFFSIZE + r12], 0
	inc r12
	cmp r12, BUFFSIZE
	jne zeroLoopy

	mov r12, 0		;index
	mov rdi, qword[rbp - BUFFSIZE - 16]		;for prompt
	call printString

inputLoop:
	mov rax, SYS_read
	mov rdi, STDIN
	lea rsi, byte[rbp - BUFFSIZE + r12]		;where to store string
	mov rdx, 1					;number of chars to read
	syscall
			
	cmp byte[rbp - BUFFSIZE + r12], LF		;returns false if enters is only LF
	je readDone

	inc r12
	cmp r12, BUFFSIZE		
	je dontStore			;Error, input too long. Please re-enter\n"
	jmp inputLoop

dontStore:
	dec r12
	jmp inputLoop

qToi:
        mov rax, 0  
	mov r12, 0
	mov r13, 0
	mov r14, 0

lp:					;getting rid of all spaces/0
	movzx r14d, byte[rbp - BUFFSIZE + r12]
	inc r12
	cmp r14d, " "		;comparing to spaces
	je lp

	mov r13d, 5

createInt:
	cmp r14d, "0"		;err1 if char isnt 0-4 inclusive
	jb err1					;"Error, invalid. Please re-enter\n"
	cmp r14d, "4"
	ja err1
	cmp r14d, " "
	je err1

	sub r14d, 48
	mul r13d
	add eax, r14d
	movzx r14d, byte[rbp - BUFFSIZE + r12]
	inc r12
	
	cmp r14d, LF
	jne createInt

	cmp eax, MIN_NUM		;err2 check, if entered quinary is too small or large
	jb err2				;"Error, out of range. Please re-enter\n"
	cmp rax, MAX_NUM
	ja err2
	
	mov r12, qword[rbp - BUFFSIZE - 8]
	mov dword[r12], eax		;numread address
	mov rax, TRUE
	jmp endOfRdQuinary

readDone:
	inc r12
	cmp r12, BUFFSIZE		;err3 check, if entered num is too long
	je err3				;;Error, input too long. Please re-enter\n"

	cmp byte[rbp - BUFFSIZE], LF			;If user only inputs LF
	je err0		
	jmp qToi

err0:	
	mov rax, FALSE
	jmp endOfRdQuinary
	
err1:
	mov rdi, qword[rbp - BUFFSIZE - 24]
	jmp errorDone

err2:
	mov rdi, qword[rbp - BUFFSIZE - 32]
	jmp errorDone

err3:
	mov rdi, qword[rbp - BUFFSIZE - 40]

errorDone:
	call printString
	mov r12, 0 			;reset index
	jmp zeroLoopy

endOfRdQuinary:
	pop r14
	pop r13
	pop r12
	mov rsp, rbp
	pop rbp
	ret



; --------------------------------------------------------
;  Count sort function.

; -----
;  Count Sort Algorithm:

;	for  i = 0 to (len-1)
;	    count[list[i]] = count[list[i]] + 1
;	endFor

;	p = 0
;	for  i = 0 to (limit-1) do
;	    if  count[i] <> 0  then
;		for  j = 1 to count[i]
;		    list[p] = i
;		    p = p + 1
;		endFor
;	    endIf
;	endFor


; -----
;  HLL Call:
;	call countSort(list, len)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi

;  Returns:
;	sorted list (list passed by reference)

global countSort
countSort:
	push rbp
	mov rbp, rsp
	sub rsp, LIMIT*4
	push r12
	push r13
	push r14
	push rbx
	push rcx
					
	lea rcx, dword[rbp - LIMIT * 4]		;initializing count arr
	mov r12, 0

zeroLp:	
	mov dword[rcx + r12 * 4], 0
	inc r12
	cmp r12, LIMIT
	jne zeroLp
	lea rcx, dword[rbp - LIMIT * 4]
	mov r12, 0

countLp:
	cmp r12d, esi
	je sort
	mov ebx, dword[rdi + r12 * 4]	;ebx = list[i]
	inc dword[rcx + rbx * 4]
	inc r12
	jmp countLp

sort:
	mov r12, 0
	mov r14d, 0 	;p = 0 = list[0]

sortLp:
	mov r13,1	;j
	cmp r12, LIMIT
	je done
	cmp dword[rcx + r12 * 4], 0
	je next

ifLp:
	cmp r13d, dword[rcx + r12 * 4]
	ja next
	mov dword[rdi + r14 * 4], r12d	;list[p] = 1
	inc r14				;p = p + 1
	inc r13
	jmp ifLp

next:
	inc r12
	jmp sortLp

done:
	pop rcx
	pop rbx
	pop r14
	pop r13
	pop r12
	mov rsp, rbp
	pop rbp
	ret

; --------------------------------------------------------
;  Find statistical information for a list of integers:
;	sum, average, minimum, median, and maximum

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstAverage() function
;  to get the average.

;  Note, assumes the list is already sorted.

; -----
;  HLL Call:
;	call listStats(list, len, sum, ave, min, med, max)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi
;	6) sum, addr - rdx
;	7) ave, addr - rcx
;	3) minimum, addr - r8
;	4) median, addr - r9
;	5) maximum, addr - stack, rbp+16

;  Returns:
;	sum, average, minimum, median, and maximum
;		via pass-by-reference

global listStats
listStats:
	push    rbp
	mov     rbp, rsp
	push r12
	mov r12, 0
	mov rax, 0
sumLp:
	add eax, dword[rdi + r12 * 4]
	inc r12
	cmp r12, rsi
	jne sumLp
	mov dword[rdx], eax
	
	push rdx				;ave
	mov edx, 0				
	div esi
	mov dword[rcx], eax

	mov eax, dword[rdi]		;min
	mov dword[r8], eax
	
	mov eax, dword[rdi + rsi * 4 - 4]	;max
	mov r11, qword[rbp + 16]
	mov dword[r11], eax

;	mov eax, dword[rdi]			;max
;	mov r11, qword[rbp + 16]
;	mov dword[r11], eax
	
;	mov eax, dword[rdi + rsi * 4 - 4]	;min
;	mov dword[r8], eax




	mov eax, esi
	mov ebx, 2
	mov edx, 0
	div ebx
	mov ebx, eax
	cmp edx, 1
	jne evenLength
	mov eax, dword[rdi + rbx * 4]
	mov dword[r9], eax
	jmp done1

evenLength:
	mov eax, dword[rdi + rbx * 4]
	add eax, dword[rdi + rbx * 4 - 4]
	mov ebx, 2
	mov edx, 0
	div ebx
	mov dword[r9], eax
	jmp done1

done1:
	pop rdx
	pop r12
	pop rbp
	ret


; --------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() function.

; -----
;  HLL Call:
;	ans = lstAverage(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	2) length, value - rsi

;  Returns:
;	average (in eax)

global lstAverage
lstAverage:
	push r12
	mov r12, 0
	mov rax, 0

sumAveLp:
	add eax, dword[rdi + r12 * 4]
	inc r12
	cmp r12, rsi
	jne sumAveLp
	
	mov edx, 0
	div esi

	pop r12
	ret

; --------------------------------------------------------
;  Function to calculate the co-variance between two lists.
;  Note, the two data sets must be of equal size.

; -----
;  HLL Call:
;	coVariance(xList, yList, len)

;  Arguments Passed:
;	1) xList, address - rdi
;	2) yList, address - rsi
;	3) length, value - rdx

;  Returns:
;	covariance (in rax)

global coVariance
coVariance:
	push r12		;index
	mov r8, rdx	;r8 = len
	push rdx
	mov r12, 0
	mov rax, 0
	mov r9, rdi		;temp xlist addr
	mov r10, rsi		;temp ylist addr
	

	mov rsi, rdx
	call lstAverage
	mov ebx, eax		;average of x = ebx

	mov rdi, r10
	call lstAverage
	mov ecx, eax		;average of y = ecx

	mov rdi, r9
	mov rsi, r10
	mov r9, 0		
	mov r10, 0		;sum
	
covSumLp:
	mov eax, dword[rdi + r12 * 4]		;x1 - xave	
	sub eax, ebx
	movsxd rax, eax	

	mov r11d, dword[rsi + r12 * 4]		;y1 - yave		
	sub r11d, ecx
	movsxd r11, r11d

	imul r11				;mul and add into r10
	add r10, rax

	inc r12
	cmp r12, r8
	jne covSumLp

	mov rax, r10
	dec r8					;r8 = len - 1
	cqo
	idiv r8

	pop rdx
	pop r12
	ret


; ******************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of char to write
	mov	rdi, STDOUT			; file descriptor for std in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************


