;  Must include:
;	Name Jonathan Tsai
;	Assignment Number 2
;	Section 001

; -----
;  Short description of program goes here...


; *****************************************************************
;  Static Data Declarations (initialized)

section	.data

bVar1		db	45
bVar2		db	16
bAns1		db	0
bAns2		db	0
wVar1		dw	5436
wVar2		dw	3816
wAns1		dw	0
wAns2		dw	0
dVar1		dd	249521376
dVar2		dd	102727691
dVar3		dd	-532456
dAns1		dd	0
dAns2		dd	0
flt1		dd	8.25
flt2		dd	-15.625
pi		dd	3.14159
qVar1		dq	214578927150
eVal		dd	2.71828
myClass		db	"CS 218", NULL
edName		db	"Ed Jorgensen", NULL
myName		db	"Jonathan Tsai", NULL

; -----
;  Define standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation
SYS_exit	equ	60			; call code for terminate

; -----
;  Initialized Static Data Declarations.

;	Place data declarations here...




; ----------------------------------------------
;  Uninitialized Static Data Declarations.

section	.bss

;	Place data declarations for uninitialized data here...
;	(i.e., large arrays that are not initialized)


; *****************************************************************

section	.text
global _start
_start:


; -----
;	YOUR CODE GOES HERE...

;bAns1 = bVar1 + bVar2
mov al, byte[bVar1]
add al, byte[bVar2]
mov byte[bAns1], al

;bAns2 = bVar1 - bVar2
mov al, byte[bVar1]
sub al, byte[bVar2]
mov byte[bAns2], al

;wAns1 = wVar1 + wVar2
mov ax, word[wVar1]
add ax, word[wVar2]
mov word[wAns1], ax

;wAns2 = wVar1 - wVar2
mov ax, word[wVar1]
sub ax, word[wVar2]
mov word[wAns2], ax

;dAns1 = dVar1 + dVar2
mov eax, dword[dVar1]
add eax, dword[dVar2]
mov dword[dAns1], eax

;dAns2 = dVar1 - dVar2
mov eax, dword[dVar1]
sub eax, dword[dVar2]
mov dword[dAns2], eax



; *****************************************************************
;	Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rbx, EXIT_SUCCESS	; return code of 0 (no error)
	syscall


