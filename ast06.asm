;  CS 218, Assignment #6
;  Jonathan Tsai
;  CS 218 - 1001
;  Assignment 06


; **********************************************************************************
;  Macro, "quinary2int", to convert an unsigned quinary/ASCII string
;  into an integer.  The macro reads the ASCII string (byte-size, with
;  leading blanks, NULL terminated) and converts to a doubleword sized integer.
;  Note, assumes valid/correct data.  As such, no error checking is performed.

;  Example:  given the ASCII string: "       23", NULL
;  (7 spaces, '2', followed by '7',  followed by NULL for a total
;  of STR_LENGTH bytes) would be converted to base-10 integer 13.

; -----
;  Arguments
;	%1 -> string address (reg)
;	%2 -> integer number (destination address)


%macro	quinary2int	2


;	STEP 3
	mov eax, 0
	mov rbx, 0      
	mov rcx, 0

%%lp:	
	movzx ecx, byte[%1 + rbx]
	inc rbx
	cmp ecx, 32
	je %%lp

	mov r9d, 5

%%createInt:
	sub ecx, 48
	mul r9d
	add eax, ecx
	movzx ecx, byte[%1 + rbx]
	inc rbx
	cmp cl, NULL
	jne %%createInt
	mov dword[%2], eax	

%endmacro

; **********************************************************************************
;  Macro, "int2quinary", to convert an unsigned base-10 integer value into
;  an ASCII string representing the quinary (base-5) value.
;  The incoming integer is an unsigned, doubleword value.

;  This macro stores the result into an ASCII string (byte-size, right justified,
;  blank filled, NULL terminated).
;  Assumes valid/correct data.  As such, no error checking is performed.

;  Example:  Since, 19 (base 10) is 34 (base-5), then the integer 19
;  would be converted to ASCII resulting in: "       34", NULL
;  (7 spaces, '3', '4' followed a NULL for a total of 10 bytes).

; -----
;  Arguments
;	%1 -> integer number (to be converted)
;	%2 -> string address (where to store resulting string)


%macro	int2quinary	2

;	STEP 4
	mov ecx, STR_LENGTH
	dec ecx
	mov eax, %1
	mov byte[%2 + ecx], NULL
%%intoq:	
	mov edx, 0
	div dword[five]

	add dl, 48
	mov byte[%2 + rcx - 1], dl
	
	dec rcx
	cmp eax, 0
	jne %%intoq
	
%%emptyLoop:
	mov byte[%2 + rcx - 1], " "
	dec rcx
	cmp rcx, 0
	jne %%emptyLoop
	


%endmacro

; --------------------------------------------------------------
;  Simple macro to display a string to the console.
;	Call:	printString  <stringAddr>

;	Arguments:
;		%1 -> <stringAddr>, string address

;  Count characters (excluding NULL).
;  Display string starting at address <stringAddr>

%macro	printString	1
	push	rax					; save altered registers
	push	rdi					; not required, but
	push	rsi					; does not hurt.  :-)
	push	rdx
	push	rcx

	mov	rdx, 0
	mov	rdi, %1
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write				; system call for write (SYS_write)
	mov	rdi, STDOUT				; standard output
	mov	rsi, %1					; address of the string
	syscall						; call the kernel

	pop	rcx					; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro


; *****************************************************************
;  Data Declarations

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
NOSUCCESS	equ	1			; unsuccessful operation

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
;  Variables and constants.

STR_LENGTH	equ	10			; digits in string, including NULL

newLine		db	LF, NULL

; -----
;  Misc. string definitions.

hdr1		db	"--------------------------------------------"
		db	LF, "CS 218 - Assignment #6", LF
		db	"Quinary (base-5) Numbering Conversions.", LF 
		db	LF, LF, NULL

hdr2		db	LF, LF, "----------------------"
		db	LF, "List Values"
		db	LF, NULL


firstNum	db	"Original Number (base-5): ", NULL
firstNumPlus	db	"Number' [3*n+1] (base-5): ", NULL

lstSum		db	LF, "List Sum:"
		db	LF, NULL

; -----
;  Misc. data definitions (if any).

five		dd	5

; -----
;  Assignment #6 Provided Data:

qStr0		db	"    21243", NULL
iNum0		dd	0


qStrArr1	db	"     1234", NULL, "      324", NULL, "    14232", NULL, "    22442", NULL
		db	"      424", NULL
len1		dd	5
sum1		dd	0


qStrArr2	db	"        1", NULL, "        2", NULL, "        3", NULL, "        4", NULL
		db	"       10", NULL, "       11", NULL, "       12", NULL, "       13", NULL
		db	"       14", NULL, "       20", NULL, "       21", NULL, "       22", NULL
		db	"       23", NULL, "       24", NULL, "       30", NULL, "       31", NULL
len2		dd	16
sum2		dd	0


qStrArr3	db	"      321", NULL, "    22431", NULL, "    13340", NULL, "    22040", NULL
		db	"   413011", NULL, "    14421", NULL, "    22432", NULL, "    11010", NULL
		db	"    11201", NULL, "     1000", NULL, "        4", NULL, "       22", NULL
		db	"      431", NULL, "     4003", NULL, "    13341", NULL, "    14322", NULL
		db	"     2323", NULL, "    13340", NULL, "    41244", NULL, "    11111", NULL
		db	"    12422", NULL, "    11332", NULL, "    12410", NULL, "    14234", NULL
		db	"     2112", NULL, "     4312", NULL, "      420", NULL, "     2332", NULL
		db	"    22113", NULL, "     3132", NULL, "      132", NULL, "    21344", NULL
		db	"     1324", NULL, "     3343", NULL, "    24212", NULL, "    14231", NULL
		db	"     3341", NULL, "    13312", NULL, "      312", NULL, "      404", NULL
		db	"    12344", NULL, "    22341", NULL, "        3", NULL, "        2", NULL
		db	"    31412", NULL, "     2222", NULL, "    11244", NULL, "    10134", NULL
		db	"     3214", NULL, "     4421", NULL, "     2344", NULL, "      244", NULL
		db	"    11212", NULL, "    11442", NULL, "     2012", NULL, "    22430", NULL
		db	"     3134", NULL, "     1023", NULL, "    11321", NULL, "    21000", NULL
		db	"     2134", NULL, "     2122", NULL, "    23212", NULL, "      114", NULL
		db	"    20133", NULL, "    12112", NULL, "    11342", NULL, "    11044", NULL
		db	"    11321", NULL, "    22000", NULL, "    23132", NULL, "    13423", NULL
		db	"     3110", NULL, "      120", NULL, "    13332", NULL, "    10022", NULL
		db	"     3320", NULL, "    12313", NULL, "    11120", NULL, "     4312", NULL
		db	"    11421", NULL, "    23241", NULL, "    22431", NULL, "      330", NULL
		db	"     4313", NULL, "    30233", NULL, "    13223", NULL, "    31113", NULL
		db	"     1321", NULL, "    11312", NULL, "    14324", NULL, "    12241", NULL
		db	"    13231", NULL, "     3214", NULL, "     4433", NULL, "    12124", NULL
		db	"       43", NULL, "    12321", NULL, "    42442", NULL, "     1234", NULL
len3		dd	100
sum3		dd	0


; **********************************************************************************
;  Uninitialized data
;	Note, these variables/arrays are declared and allocated, but no
;	initial values are provided.

section	.bss

num0String	resb	STR_LENGTH
tempString	resb	STR_LENGTH
tempNum		resd	1


; **********************************************************************************

section	.text
global	_start
_start:

; **********************************************************************************
;  Main program
;	display headers
;	calls the macro on various data items
;	display results to screen (via provided macro's)

;  Note, since the print macros do NOT perform an error checking,
;  	if the conversion macros do not work correctly,
;	the print string will not work!

; **********************************************************************************
;  Prints some cute headers...

	printString	hdr1
	printString	firstNum
	printString	qStr0
	printString	newLine

; -----
;  STEP #1
;	Convert quinary string (base-5) into an integer (base-10)
;	DO NOT USE MACRO HERE!!


;	STEP #1
	mov eax, 0
	mov rbx, 0      
	mov rcx, 0

lp:	
	movzx ecx, byte[qStr0 + rbx]
	inc rbx
	cmp ecx, " "
	je lp

	mov r9d, 5

createInt:
	sub ecx, 48
	mul r9d
	add eax, ecx
	movzx ecx, byte[qStr0 + rbx]
	inc rbx
	cmp cl, NULL
	jne createInt
	mov dword[iNum0], eax	

; -----
;  STEP #2
;  Perform (3 * iNum0 + 1) operation.

	mov	eax, dword [iNum0]
	mov	ebx, 3
	mul	ebx
	inc	eax
	mov	dword [iNum0], eax

; -----
;  STEP #3
;	Convert the integer (iNum0) into a quinary ASCII string
;	which is stored in the 'num0String'
;	DO NOT USE MACRO HERE!!

;	STEP #2
	mov ecx, STR_LENGTH
	dec ecx
	mov eax, dword[iNum0]
	mov byte[num0String + ecx], NULL

intoq:	
	mov edx, 0
	div dword[five]

	add dl, 48
	mov byte[num0String + rcx - 1], dl

	dec rcx
	cmp eax, 0
	jne intoq
	
emptyLoop:
	mov byte[num0String + rcx - 1], 32
	dec rcx
	cmp rcx, 0
	jne emptyLoop
	
	mov rax, 0
	mov rbx, 0
	mov rcx, 0
	mov rdx, 0
	
	
; -----
;  Display a simple header and then the string.

	printString	firstNumPlus
	printString	num0String


; **********************************************************************************
;  Next, repeatedly call the macro on each value in an array.

	printString	hdr2

; ==================================================
;  Data Set #1 (short list)

	mov	ecx, [len1]			; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, qStrArr1			; address of string

cvtLoop1:
	push	rcx
	push	rdi

	quinary2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum1], eax

	pop	rdi
	add	rdi, STR_LENGTH

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop1

	mov	eax, [sum1]
	int2quinary	eax, tempString		; convert integer (eax) into string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

; ==================================================
;  Data Set #2 (long list)

	mov	ecx, [len2]			; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, qStrArr2			; address of string

cvtLoop2:
	push	rcx
	push	rdi

	quinary2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum2], eax

	pop	rdi
	add	rdi, STR_LENGTH

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop2

	mov	eax, [sum2]
	int2quinary	eax, tempString		; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

; ==================================================
;  Data Set #3 (long list)

	mov	ecx, [len3]			; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, qStrArr3			; address of stringa

cvtLoop3:
	push	rcx
	push	rdi

	quinary2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum3], eax

	pop	rdi
	add	rdi, STR_LENGTH

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop3

	mov	eax, [sum3]
	int2quinary	eax, tempString		; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

; **********************************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; The system call for exit (sys_exit)
	mov	rdi, EXIT_SUCCESS
	syscall
