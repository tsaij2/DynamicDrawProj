;  CS 218 - Assignment #11
;  Functions Template
;  Jonathan Tsai
;  Section 1001

; ***********************************************************************
;  Data declarations
;	Note, the error message strings should NOT be changed.
;	All other variables may changed or ignored...

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1			; unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_lseek	equ	8			; system call code for file repositioning
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q

; -----
;  Define program specific constants.

BUFF_SIZE	equ	750000			; buffer size

; -----
;  Variables for getFileDescriptors() function.

usageMsg	db	"Usage: ./cracker -i <inputFileName> "
		db	"-o <outputFileName>", LF, NULL
errIncomplete	db	"Error, incomplete command line arguments.", LF, NULL
errExtra	db	"Error, too many command line arguments.", LF, NULL
errInputSpec	db	"Error, invalid input file specifier.", LF, NULL
errOutputSpec	db	"Error, invalid output specifier.", LF, NULL
errInputFile	db	"Error, unable to open input file.", LF, NULL
errOutputFile	db	"Error, unable to open output file.", LF, NULL

; -----
;  Variables for getCharacter() function.

errRead		db	"Error, reading input file.", LF,
		db	"Program terminated.", LF, NULL


isEOF		db	FALSE
newBufferLength	dd	0
bufferIndex	dd	0

; -----
;  Variables for putCharacter() function.

errWrite	db	"Error, writting to output file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for cracker() function.

rotate		dd	0
diff		dd	0.0
min		dq	27.0
total		dq	0.0
fltZero		dq	0.0

found		dq	0.0, 0.0, 0.0, 0.0, 0.0
		dq	0.0, 0.0, 0.0, 0.0, 0.0
		dq	0.0, 0.0, 0.0, 0.0, 0.0
		dq	0.0, 0.0, 0.0, 0.0, 0.0
		dq	0.0, 0.0, 0.0, 0.0, 0.0
		dq	0.0

freq		dq	0.07833		; a
		dq	0.01601		; b
		dq	0.02398		; c
		dq	0.04554		; d
		dq	0.12706		; e
		dq	0.02039		; f
		dq	0.02352		; g
		dq	0.05742		; h
		dq	0.06827		; i
		dq	0.00250		; j
		dq	0.01107		; k
		dq	0.03974		; l
		dq	0.02605		; m
		dq	0.06622		; n
		dq	0.07617		; o
		dq	0.01904		; p
		dq	0.00070		; q
		dq	0.05445		; r
		dq	0.06205		; s
		dq	0.09500		; t
		dq	0.02997		; u
		dq	0.00849		; v
		dq	0.02563		; w
		dq	0.00195		; x
		dq	0.01964		; y
		dq	0.00080		; z

; -----
;  Variables for decrypt() function.
;	this should not happen and was included only
;	for debugging purposes.

badErr		db	"Error, can not write null.", LF, NULL
charTmp	dq	"", NULL


; ------------------------------------------------------------------------
;  Unitialized data

section	.bss

buffer		resb	BUFF_SIZE


; ############################################################################

section	.text

; ***************************************************************
;  Routine to get file descriptors.
;	Must parse command line arguments, check for errors,
;	attempt to open file, and, if files open
;	successfully, return descriptors (via reference)
;	and return TRUE.
;	Otherwise, display appropriate error message and
;	return FALSE.

;  Command Line format:
;	./cracker -i <inputFileName> -o <outputFileName>

; -----
;  HLL Call:
;	getFileDescriptors(argc, argv, &readFile, &writeFile)

; -----
;  Arguments:
;	argc, value - rdi
;	argv table, address - rsi 
;	input file descriptor, address - rdx
;	output file descriptor, address - rcx
;  Returns:
;	file decriptors, via reference
;	TRUE (if worked) or FALSE (if error)


global getFileDescriptors
getFileDescriptors:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	push r12
	push r13

	mov qword[rbp - 8], rdx		;input file descriptor address
	mov qword[rbp - 16], rcx	;output file descriptor address
	mov r12, qword[rsi + 16]	;input name add
	mov r13, qword[rsi + 32]	;output name add
	
	cmp rdi, 1		;usage error
	je usageErr

	cmp rdi, 5		;not enough arguments err
	jl incompleteErr

	cmp rdi, 5		;too many arguements err
	jg extraErr

	mov rbx, qword[rsi + 8]			;checking input specifier "-i"
	cmp byte[rbx], "-"
	jne inputSpecErr

	cmp byte[rbx + 1], "i"
	jne inputSpecErr

	cmp byte[rbx + 2], NULL
	jne inputSpecErr

	mov rbx, qword[rsi + 24]		;checking output specifier "-o"
	cmp byte[rbx], "-"
	jne outputSpecErr

	cmp byte[rbx + 1], "o"
	jne outputSpecErr

	cmp byte[rbx + 2], NULL
	jne outputSpecErr


openInputFile:
	mov rax, SYS_open			;system call for file open
	mov rdi, r12	
	mov rsi, O_RDONLY			
	syscall					

	cmp rax, 0				;if negative value, then there was an error opening input file
	jl openInputErr
	
	mov rbx, qword[rbp - 8]
	mov qword[rbx], rax			;save input descriptor

openOutputFile:
	mov rax, SYS_creat			;system call for file open
	mov rdi, r13
	mov rsi, S_IRUSR | S_IWUSR		;allow read/write access 			
	syscall					

	cmp rax, 0				;if negative value, then there was an error opening output file
	jl openOutputErr

	mov rbx, qword[rbp - 16]
	mov qword[rbx], rax			;save output descriptor
	mov rax, TRUE
	jmp done

usageErr:
	mov rdi, usageMsg
	call printString
	mov rax, FALSE
	jmp done

incompleteErr:
	mov rdi, errIncomplete
	call printString
	mov rax, FALSE
	jmp done

extraErr:
	mov rdi, errExtra
	call printString
	mov rax, FALSE
	jmp done

inputSpecErr:
	mov rdi, errInputSpec
	call printString
	mov rax, FALSE
	jmp done

outputSpecErr:
	mov rdi, errOutputSpec
	call printString
	mov rax, FALSE
	jmp done

openInputErr:
	mov rdi, errInputFile
	call printString
	mov rax, FALSE
	jmp done

openOutputErr:
	mov rdi, errOutputFile
	call printString
	mov rax, FALSE

done:
	pop r13
	pop r12
	mov rsp, rbp
	pop rbp
	ret





; ***************************************************************
;  Get character routine
;	Returns one character.
;	If buffer is empty, fills buffer.
;	This routine performs all buffer management.

;	The read buffer itself and some misc. variables are
;	used ONLY by this routine and as such are not passed.

; ----
;  HLL Call:
;	status = getCharacter(readFileDesc, &char);

;  Arguments:
;	input file descriptor, value - rdi
;	character, address - rsi
;  Returns:
;	status (SUCCESS or NOSUCCESS)
;	character, via reference

global getCharacter
getCharacter:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push r10

	mov qword[rbp - 8], rsi		;address for where to store char

continued:
	mov eax, dword[bufferIndex]
	cmp eax, dword[newBufferLength]
	je read
	mov rax, 0


	mov rbx, qword[rbp - 8]		;rbx = address to store char
	mov r10d, dword[bufferIndex]
	mov al, byte[buffer + r10d]
	mov byte[rbx], al		;moving read char into char add
	add dword[bufferIndex], 1
	mov rax, TRUE
	jmp doneChar

read:
	cmp dword[isEOF], TRUE
	je isEOFLabel				;if we're completely done with the file
	mov rax, SYS_read
	mov rdi, rdi		;file descriptor
	mov rsi, buffer		;where to store characters read
	mov rdx, BUFF_SIZE	;how many characters to read
	syscall

	cmp rax, 0			;if there was a read error
	jb readErr

	mov dword[newBufferLength], eax		;update new buffer length and buffer index
	mov dword[bufferIndex],  0

	cmp eax, BUFF_SIZE		;if eax(number of characters read) < buff size, we're at the eof
	jl eofLabel

	mov rax, TRUE
	jmp continued

eofLabel:			;won't allow getCharacter to read again
	mov byte[isEOF], TRUE
	mov rax, TRUE
	jmp continued

isEOFLabel:
	mov rax, FALSE		;function ends after final parse of read
	jmp doneChar

readErr:
	mov rdi, errRead
	call printString
	mov rax, FALSE

doneChar:
	pop r10
	mov rsp, rbp
	pop rbp
	ret

; ***************************************************************
;  Write character to output file.
;	This is poor, but no requirement to buffer here.

; -----
;  HLL Call:
;	status = putCharacter(writeFileDesc, char);

;  Arguments are:
;	write file descriptor (value) - rdi
;	character (value) - rsi
;  Returns:
;	SUCCESS or NOSUCESS

; -----
;  This routine returns SUCCESS when character has been written
;	and returns NOSUCCESS only if there is an
;	error on write (which would not normally occur).


global putCharacter
putCharacter:
	mov qword[charTmp], rsi
	

	mov rax, SYS_write
	;mov rdi, rdi				;file descriptor (already rdi)
	mov rsi, charTmp				;address of char
	mov rdx, 1			        ;count of char to read
	syscall

	cmp rax, 0
	jl writeErr

	mov rax, TRUE
	jmp writeDone

writeErr:
	mov rdi, errWrite
	call printString
	mov rax, FALSE

writeDone:
	ret





; ***************************************************************
;  CS 218 - Ceasar Cypher Decryption Routine.

;  Ceasar Cyphers can be automatically broken by taking
;	advantage of the known letter frequencies for the
;	English language.

;  The frequencies found in the encrypted text are
;	compared against the known frequencies table.  This
;	requires comparing two lists, which is done using the
;	sum of the squares of the differences of the corresponding
;	entries in the list.  By minimizing this sum, you find
;	the best match.  This is called the "least squares fit".
;	As such, based on the letter frequencies, the routine
;	will find the appropriate decryption rotation key.

;  Note, this routine accepts as input the address a "count"
;	array.  The array must have 26 elements, with the first
;	element, or count(0)  being the number of A's, and count(1)
;	being the number of B's found in the original encrypted text.

; -----
;  HLL call:
;	key = cracker(ltrCounts);

; -----
;  Arguments passed
;	populated letter count array, address - rdi
;  Returns:
;	rotation key
;least squares = summation from i =1 - 26 of knownfreq - foundfreq0 ^ 2 


global cracker
cracker:
	push r10	;total
	push r11	;curr key
	push r12	;index
	push r13	;rotating key

	mov r10, 0
	mov r11, 0
	mov r12, 0

	mov rbx, rdi		;rbx = address of known freq

totalCharLp:				;find total amount of characters read
	add r10d, dword[rbx + r12 * 4]
	inc r12
	cmp r12, 26
	jne totalCharLp
	cvtsi2sd xmm0, r10			;convert total into a float xmm0
	movsd qword[total], xmm0		;total = how many characters read
	mov r12, 0				;reset index
	

populateFound:							;populate our found array = ltrcountarr[i]/total
	cvtsi2sd xmm0, dword[rbx + r12 * 4]		;xmm0 = lettercountarr[i]			
	divsd xmm0, qword[total]			;xmm0 = freq
	movsd qword[found + r12 * 8], xmm0
	inc r12
	cmp r12, 26
	jne populateFound
	mov r12, 0


lsLoop:						;find leastSquares for each key and stores the minimum least square key into rotate, and the value into min
	mov r13, r11
	add r13, r12
	cmp r13, 26
	jae modRotate

continue:					
	movsd xmm0, qword[freq + r13 * 8]	;xmm0 = known freq, r11 = current key
	subsd xmm0, qword[found + r12 * 8]	;xmm0 = known freq - found frq
	mulsd xmm0, xmm0				;squaring known freq- found freq
	addsd xmm1, xmm0				;xmm1 = leastSquares
	inc r12
	cmp r12, 26
	jne lsLoop

	ucomisd xmm1, qword[min]			;min currently is 27, and ls will never be over 27
	jb newMin

updateVar:
	movsd xmm1, qword[fltZero]
	mov r12, 0
	inc r11
	cmp r11, 26
	jne lsLoop
	jmp crackDone

modRotate:
	sub r13, 26
	jmp continue
	
newMin:
	movsd qword[min], xmm1
	mov dword[rotate], r11d
	jmp updateVar
	
crackDone:
	mov rax, 0
	mov eax, dword[rotate]
	pop r13
	pop r12
	pop r11
	pop r10
	ret

; ***************************************************************
;  Decrypt the characters in the file.

;  Basic loop will:
;	get a character from input file (get_chr)
;	if letter, decrypt character (i.e., subtract key)

;  HLL Call:
;	status = decrypt(key, encryptedchar);

; -----
;  Arguments:
;	key, value - rdi
;	encryptedchar, add - rsi


global decryptChar
decryptChar:
	mov rax, 0       
	mov rax, rsi		;rax = encrypted char

	cmp rax, NULL
	je errDecrypt

	cmp rax, "A"
	jl finished

	cmp rax, "Z"
	jg maybeLetter

	add rax, rdi		;value of key
	cmp rax, "Z"
	jg over
	jmp finished

maybeLetter:
	cmp rax, "a"
	jl finished

	cmp rax, "z"
	jg finished

	add rax, rdi		;value of key
	cmp rax, "z"
	jg over
	jmp finished	

errDecrypt:
	mov rdi, badErr
	call printString
	jmp finished

over:				;uppercase and lowercase overboard
	sub rax, 26

finished:
	ret


; ***************************************************************
;  Reset read file to beginning.
;	note, must also re-set some buffer variables
;	(variable names will vary).

; -----
;  Arguments
;	input file descriptor

;  Return
;	nothing
;	but, file is reset to beginning

global	resetRead
resetRead:
	mov dword[newBufferLength], 0
	mov dword[bufferIndex], 0
	mov dword[isEOF], FALSE


	mov	rax, SYS_lseek
	mov	rdi, rdi
	mov	rsi, 0
	mov	rdx, 0
	syscall

	ret

; ***************************************************************
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

; ***************************************************************

