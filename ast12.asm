;  Jonathan Tsai
;  CS 218 Section 1
;  Assignment 12
;  k-hyperperfect numbers
;  Threading program, provided template

; ***************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	-1

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

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

STR_LENGTH	equ	12

; -----
;  Message strings

header		db	LF, "*******************************************", LF
		db	ESC, "[1m", "Number Type Counting Program", ESC, "[0m", LF, LF, NULL
msgStart	db	"--------------------------------------", LF	
		db	"Start Counting", LF, NULL
pMsgMain	db	"Perfect Count: ", NULL
aMsgMain	db	"hp num: ", NULL
msgProgDone	db	LF, "Completed.", LF, NULL

numberLimit	dq	0
threadCount	dd	0

; -----
;  Globals (used by threads)

idxCounter	dq	2
hpCount		dq	0

myLock		dq	0

; -----
;  Thread data structures

pthreadID0	dq	0, 0, 0, 0, 0
pthreadID1	dq	0, 0, 0, 0, 0
pthreadID2	dq	0, 0, 0, 0, 0
pthreadID3	dq	0, 0, 0, 0, 0

; -----
;  Variables for thread function.

msgThread1	db	" ...Thread starting...", LF, NULL

; -----
;  Variables for printMessageValue

newLine		db	LF, NULL

; -----
;  Variables for getParams function

LIMITMIN	equ	100
LIMITMAX	equ	4000000000

errUsage	db	"Usgae: ./hyperPerfect -th <1|2|3|4> ",
		db	"-lm <quinaryNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errTHspec	db	"Error, invalid thread count specifier."
		db	LF, NULL
errTHvalue	db	"Error, invalid thread count value."
		db	LF, NULL
errLSpec	db	"Error, invalid limit specifier."
		db	LF, NULL
errLValue	db	"Error, limit out of range."
		db	LF, NULL

; -----
;  Variables for int2quinary function

; -----
;  Variables for quinary2int function

dFive		dd	10
tmpNum		dq	0

; -----

section	.bss
tmpString	resb	20


; ***************************************************************

section	.text

; -----
; External statements for thread functions.

extern	pthread_create, pthread_join

; ================================================================
;  Number type counting program.

global main
main:
	push	rbp
	mov	rbp, rsp

; -----
;  Check command line arguments

	mov	rdi, rdi			; argc
	mov	rsi, rsi			; argv
	mov	rdx, threadCount
	mov	rcx, numberLimit
	call	getParams

	cmp	rax, TRUE
	jne	progDone

; -----
;  Initial actions:
;	Display initial messages

	mov	rdi, header
	call	printString

	mov	rdi, msgStart
	call	printString

; -----
;  Create new thread(s)
;	pthread_create(&pthreadID0, NULL, &threadFunction0, NULL);
;  if sequntial, start 1 thread
;  if parallel, start 3 threads

	mov eax, dword[threadCount]
	cmp eax, 1
	je oneThread
	cmp eax, 2
	je twoThread
	cmp eax, 3
	je threeThread
	cmp eax, 4
	je fourThread

fourThread:
	mov	rdi, pthreadID0
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create

threeThread:
	mov	rdi, pthreadID1
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create

twoThread:
	mov	rdi, pthreadID2
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create

oneThread:
	mov	rdi, pthreadID3
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create

howManyWait:
	mov eax, dword[threadCount]
	cmp eax, 1
	je waitOne
	cmp eax, 2
	je waitTwo
	cmp eax, 3
	je waitThree
	cmp eax, 4
	je waitFour


;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);

waitFour:
	mov	rdi, qword [pthreadID0]
	mov	rsi, NULL
	call	pthread_join
	
waitThree:

	mov	rdi, qword [pthreadID1]
	mov	rsi, NULL
	call	pthread_join

waitTwo:

	mov	rdi, qword [pthreadID2]
	mov	rsi, NULL
	call	pthread_join

waitOne:

	mov	rdi, qword [pthreadID3]
	mov	rsi, NULL
	call	pthread_join

; -----
;  Display final count

showFinalResults:
	mov	rdi, newLine
	call	printString

	mov	rdi, pMsgMain
	call	printString
	mov	rdi, qword [hpCount]
	mov	rsi, tmpString
	call	int2quinary
	mov	rdi, tmpString
	call	printString
	mov	rdi, newLine
	call	printString

; **********
;  Program done, display final message
;	and terminate.

	mov	rdi, msgProgDone
	call	printString

progDone:
	pop	rbp
	mov	rdi, SYS_exit			; system call for exit
	mov	rsi, SUCCESS			; return code SUCCESS
	syscall

; ******************************************************************
;  Thread function, hpNumberCounter()
;	Determine if the numbers is 2-hyperperfect for
;	numbers between 1 and numberLimit (gloabally available)

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)


global hpNumberCounter
hpNumberCounter:
	call spinLock
	mov r9, qword[idxCounter]
	call spinUnlock
	cmp r9, qword[numberLimit]			;done if no more numbers to check or if 2 is inputted
	ja done

	mov rbx, 2
	mov rax, r9
	mov rdx, 0
	div rbx

	mov rcx, rax			; rcx = currNum / 2
	mov r8, 0			; r8 = factor total
	mov rbx, 1			;first factor

factorLp:	
	mov rax, r9
	mov rdx, 0
	div rbx
	cmp rdx, 0
	je isFactor			;if no remainder than rax/rbx = factors
	inc rbx
	cmp rbx, rcx			;we've gone through all factors once rbx = above limit/2
	ja hyperCalc
	jmp factorLp

isFactor:
	add r8, rbx
	inc rbx
	cmp rbx, rcx			;we've gone through all factors once rbx = above limit/2
	ja hyperCalc
	jmp factorLp

hyperCalc:
	mov rax, r8			;rax = sumFac
	dec rax				;sumFac - 1
	mov rbx, 2
	mul rbx				;rax = 2 * (sumFac - 1)
	add rax, 1			;rax = 1 + 2 * (sumFac - 1)
	cmp rax, r9			;comparing to r9, which is current num to check		
	je isHyper
	jmp next

isHyper:
	call spinLock
	lock	inc qword[hpCount]
	call spinUnlock

next:
	call spinLock
	lock	inc qword[idxCounter]
	call spinUnlock
	jmp hpNumberCounter

done:
	ret
	
	




; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free

global	spinLock
spinLock:
	mov	rax, 1			; Set the EAX register to 1.

lock	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock
spinUnlock:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Convert integer to ASCII/Quinary string.
;	Note, no error checking required on integer.

; -----
;  Arguments:
;	1) integer, value - rdi
;	2) string, address - rsi
; -----
;  Returns:
;	ASCII/Quinary string (NULL terminated)

global	int2quinary
int2quinary:
	mov rcx, 0
	mov rcx, 20
	dec rcx
	mov rax, rdi
	mov byte[rsi + rcx], NULL

intoq:	
	mov rdx, 0
	mov rbx, 5
	div rbx

	add dl, 48
	mov byte[rsi + rcx - 1], dl
	
	dec rcx
	cmp rax, 0
	jne intoq
	
emptyLoop:
	mov byte[rsi + rcx - 1], " "
	dec rcx
	cmp rcx, 0
	jne emptyLoop
	ret

; ******************************************************************
;  Function: Check and convert ASCII/Quinary to integer

;  Example HLL Call:
;	stat = quinary2int(qStr, &num);
; rdi = qStr add
; rsi = num add

global	quinary2int
quinary2int:
	mov rax, 0
	mov rbx, 0      
	mov rcx, 0

spaceLp:	
	movzx ecx, byte[rdi + rbx]
	inc rbx
	cmp ecx, 32
	je spaceLp
	mov r9d, 5

createInt:
	sub ecx, 48
	mul r9d
	add eax, ecx
	movzx ecx, byte[rdi + rbx]
	inc rbx
	cmp cl, NULL
	jne createInt
	mov dword[rsi], eax	
	ret

; ******************************************************************
;  Generic funciton to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
; Count characters to write.

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
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************
;  Function getParams()
;	Get, check, convert, verify range, and return the
;	thread count and user entered limit.

;  Example HLL call:
;	stat = getParams(argc, argv, &isSequntial, &primeLimit)

;  This routine performs all error checking, conversion of ASCII/Quinary
;  to integer, verifies legal range of each value.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;	-th <1|2|3|4> -lm <quinaryNumber>

; -----
;  Arguments:
;	1) ARGC, value - rdi
;	2) ARGV, address - rsi
;	3) thread count (dword), address - rdx
;	4) prime limit (qword), address - rcx


global getParams
getParams:
	push r12
	mov r12, rcx		;hold limit address cause might change after quinary call
	cmp edi, 1
	jne checkArgumentCount

	mov rdi, errUsage
	call printString
	mov rax, FALSE
	jmp checksDone

checkArgumentCount:
	cmp edi, 5
	je checkThreadTag
	mov rdi, errOptions
	call printString
	mov rax, FALSE
	jmp checksDone

checkThreadTag:
	mov rbx, qword[rsi + 8]
	cmp byte[rbx], "-"
	jne checkThreadTagError

	cmp byte[rbx + 1], "t"
	jne checkThreadTagError

	cmp byte[rbx + 2], "h"
	jne checkThreadTagError

	cmp byte[rbx + 3], NULL
	jne checkThreadTagError

	jmp checkThreadNum

checkThreadTagError:
	mov rdi, errTHspec
	call printString
	mov rax, FALSE
	jmp checksDone

checkThreadNum:
	mov rbx, qword[rsi + 16]
	cmp byte[rbx], "1"
	je legitThread

	cmp byte[rbx], "2"
	je legitThread

	cmp byte[rbx], "3"
	je legitThread

	cmp byte[rbx], "4"
	je legitThread

	jmp threadNumError

legitThread:
	cmp byte[rbx + 1], NULL
	jne threadNumError
	mov rax, 0
	movzx eax, byte[rbx]
	sub eax, 48

	mov dword[rdx], eax		;thread count num
	jmp checkLimitTag

threadNumError:
	mov rdi, errTHvalue
	call printString
	mov rax, FALSE
	jmp checksDone

checkLimitTag:
	mov rbx, qword[rsi + 24]
	cmp byte[rbx], "-"
	jne checkLimitTagError

	cmp byte[rbx + 1], "l"
	jne checkLimitTagError

	cmp byte[rbx + 2], "m"
	jne checkLimitTagError

	cmp byte[rbx + 3], NULL
	jne checkLimitTagError

	jmp checkLimitQuinary

checkLimitTagError:
	mov rdi, errLSpec
	call printString
	mov rax, FALSE
	jmp checksDone

checkLimitQuinary:
	mov rdi, qword[rsi + 32]	;quinary num for -sz
	mov rsi, r12			;limit address
	call quinary2int
	
	cmp qword[r12], LIMITMIN
	jl limitQuinErr
	cmp qword[r12], LIMITMAX
	ja limitQuinErr

	mov rax, TRUE
	jmp checksDone

limitQuinErr:
	mov rdi, errLValue
	call printString
	mov rax, FALSE
	jmp checksDone

checksDone:
	pop r12
	ret

; ******************************************************************


