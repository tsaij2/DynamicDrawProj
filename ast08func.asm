;  CS 218 - Assignment 8
;  Functions Template.
;  Jonathan Tsai
;  Section 1001

; --------------------------------------------------------------------
;  Write some assembly language functions.

;  The function, countSort(), sorts the numbers into descending
;  order (small to large).  Uses the count sort algorithm from
;  assignment #7 (modified to sort in descending order).

;  The function, listStats(), finds the sum, average, minimum,
;  median, and maximum for a list of numbers.
;  Note, the median is determined after the list is sorted.
;	This function must call the lstAvergae()
;	function to get the average.

;  The function, coVariance(), computes the sample covariance for
;  the two data sets.  Summation and division performed as quads.

; ********************************************************************************

section	.data

; -----
;  Define constants.

TRUE		equ	1
FALSE		equ	0

; -----
;  Variables/constants for countSort() function (if any).

LIMIT		equ	4000000


; -----
;  Variables/constants for listStats() function (if any).


; -----
;  Variables/constants for coVariance() function (if any).



section	.bss

; -----
;  Unitialized variables.

count		resd	LIMIT

qSum		resq	1
qTmp		resq	1


; ********************************************************************************

section	.text

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
;	2) length, value - esi

;  Returns:
;	sorted list (list passed by reference)

global countSort
countSort:
	push r12
	push r13
	push r14
	push rbx
	mov r12, 0

zeroLp:	
	mov eax, 0
	mov dword[count + r12 * 4], eax
	inc r12
	cmp r12, LIMIT
	jne zeroLp
	mov r12, 0

countLp:
	cmp r12d, esi
	je sort
	mov ebx, dword[rdi + r12 * 4]	;count[list[i]]
	inc dword[count + ebx * 4]
	inc r12
	jmp countLp

sort:
	mov r12, 0
	mov r14d, esi	;p = list[length]
	dec r14d

sortLp:
	mov r13,1	;j
	cmp r12, LIMIT
	je done
	cmp dword[count + r12 * 4], 0
	je next

ifLp:
	cmp r13d, dword[count + r12 *4]
	ja next
	mov dword[rdi + r14 * 4], r12d	;list[p] = 1
	dec r14
	inc r13
	jmp ifLp
next:
	inc r12
	jmp sortLp

done:
	pop rbx
	pop r14
	pop r13
	pop r12
	ret


; --------------------------------------------------------
;  Find statistical information for a list of integers:
;	sum, average, minimum, median, and maximum

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  Note, assumes the list is already sorted.

; -----
;  Call:
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

;	mov eax, dword[rdi]		;min
;	mov dword[r8], eax
	
;	mov eax, dword[rdi + rsi * 4 - 4]	;max
;	mov r11, qword[rbp + 16]
;	mov dword[r11], eax

	mov eax, dword[rdi]			;max
	mov r11, qword[rbp + 16]
	mov dword[r11], eax
	
	mov eax, dword[rdi + rsi * 4 - 4]	;min
	mov dword[r8], eax




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

; -----
;  Call:
;	ans = lstAverage(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

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
;  Function to calculate the covariance for
;  two lists (of equal size).

;  This function must call the lstAverage() function
;  to get the average.

; -----
;  Call:
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

; ********************************************************************************
