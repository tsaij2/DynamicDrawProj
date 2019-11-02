;  Assignment #10
;  Jonathan Tsai
;  CS 218
;  Section 1001

;  Support Functions.
;  Provided Template

; -----
;  Function getArguments()
;	Gets, checks, converts, and returns command line arguments.

;  Function drawDancingLine()
;	Plots provided dancing function

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program specific constants.

SZ_MIN		equ	200
SZ_MAX		equ	1200

BC_MIN		equ	0
BC_MAX		equ	16777215

LC_MIN		equ	0
LC_MAX		equ	16777215

DS_MIN		equ	0
DS_MAX		equ	15


; -----
;  Variables for getArguments function.

STR_LENGTH	equ	12

ddFive	dd	5

errUsage	db	"Usage: dancingLine -sz <quinaryNumber> -bc <quinaryNumber> "
		db	"-lc <quinaryNumber> -ds <quinaryNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL

errSZsp		db	"Error, image size specifier incorrect."
		db	LF, NULL
errSZvalue	db	"Error, image size value must be between 1300(5) and 14300(5)."
		db	LF, NULL

errBCsp		db	"Error, base color specifier incorrect."
		db	LF, NULL
errBCvalue	db	"Error, base color value must be between "
		db	"0 and 13243332330(5)."
		db	LF, NULL

errLCsp		db	"Error, line color specifier incorrect."
		db	LF, NULL
errLCvalue	db	"Error, line color value must be between "
		db	"0 and 13243332330(5)."
		db	LF, NULL

errBCLCsame	db	"Error, base color and line color can "
		db	"not be the same."
		db	LF, NULL

errDSsp		db	"Error, draw speed specifier incorrect."
		db	LF, NULL
errDSvalue	db	"Error, draw speed color value must be between "
		db	"0 and 30(5)."
		db	LF, NULL

; -----
;  Variables for draw dancing line function.

pi		dq	3.14159265358979	; constant
fltZero		dq	0.0
fltOne		dq	1.0
fltTwo		dq	2.0

tBase		dq	0.0016			; values tStep formula
tOffset		dq	0.00025
tScale		dq	200.0

drawScale	dq	5000.0			; scale factor for draw speed

tStep		dq	0.0			; t step
sStep		dq	0.0			; s step


bcRed		dd	0			; base color
bcGreen		dd	0
bcBlue		dd	0

lcRed		dd	0			; line color
lcGreen		dd	0
lcBlue		dd	0

t		dq	0.0			; loop index variable
x		dq	0.0			; current x
y		dq	0.0			; current y
s		dq	0.0			; s variable (for line dance)
bInside		dq	0.0
lInside		dq	0.0

; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize
extern	glutInitWindowPosition, glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d
extern	glPointSize, glutPostRedisplay

extern	cos, sin


; ******************************************************************
;  Generic function to display a string to the screen.
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
	push	rbx
	push	rsi
	push	rdi
	push	rdx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	ret

; ******************************************************************
;  Boolean value returning function getArguments()
;	Gets size, draw speed, square color, and line color
;	from the command line.
;	- converts ASCII/Quinary parameters to integer
;	- performs all applicable error checking

;	Command line format (fixed order):
;	  "-sz <quinaryNumber> -bc <quinaryNumber> -lc <quinaryNumber>
;					-ds <quinaryNumber>"

; -----
;  HLL CAll:
;	bool = getArguments(argc, argv, &size, &baseColor,
;					&lineColor, &drawSpeed);

; -----
;  Arguments:
;	1) ARGC, double-word, value - rdi
;	2) ARGV, double-word, address - rsi
;	3) size, double-word, address - rdx
;	4) base color, double-word, address - rcx
;	5) line color, double-word, address - r8
;	6) draw speed, double-word, address - r9

global getArguments
getArguments:
	push rbp
	mov rbp, rsp
	sub rsp, 32

	push r10	;sz quin
	push r11	;bc quin
	push r12	;lc quin
	push r13	;ds quin

	mov qword[rbp - 8], rdx		;size, double-word, address
	mov qword[rbp - 16], rcx	;base color, double-word, address
	mov qword[rbp - 24], r8		;line color, double-word, address
	mov qword[rbp - 32], r9 	;draw speed, double-word, address

	cmp edi, 1
	jne checkArgumentCount

	mov rdi, errUsage
	call printString
	mov rax, FALSE
	jmp checksDone

checkArgumentCount:
	cmp edi, 9
	je checkSizeTag
	mov rdi, errBadCL
	call printString
	mov rax, FALSE
	jmp checksDone


;size
checkSizeTag:
	mov rbx, qword[rsi + 8]
	cmp byte[rbx], "-"
	jne checkSizeTagError

	cmp byte[rbx + 1], "s"
	jne checkSizeTagError

	cmp byte[rbx + 2], "z"
	jne checkSizeTagError

	cmp byte[rbx + 3], NULL
	jne checkSizeTagError

	jmp checkSizeQuinary

checkSizeTagError:
	mov rdi, errSZsp
	call printString
	mov rax, FALSE
	jmp checksDone

checkSizeQuinary:
	mov rdi, qword[rsi + 16]	;quinary num for -sz
	call rdQuinaryNum

	cmp rax, FALSE
	je szQuinErr
	sub rax, 1			;accounts for quins of 0
	cmp rax, SZ_MIN
	jl szQuinErr
	cmp rax, SZ_MAX
	ja szQuinErr

	mov r10d, eax			;storing size

	jmp checkBCTag

szQuinErr:
	mov rdi, errBCvalue
	call printString
	mov rax, FALSE
	jmp checksDone



;base color
checkBCTag:
	mov rbx, qword[rsi + 24]
	cmp byte[rbx], "-"
	jne checkBCError

	cmp byte[rbx + 1], "b"
	jne checkBCError

	cmp byte[rbx + 2], "c"
	jne checkBCError

	cmp byte[rbx + 3], NULL
	jne checkBCError

	jmp checkBCQuinary

checkBCError:
	mov rdi, errBCsp
	call printString
	mov rax, FALSE
	jmp checksDone

checkBCQuinary:
	mov rdi, qword[rsi + 32]	;quinary num for -bc
	call rdQuinaryNum

	cmp rax, FALSE
	je BCQuinErr
	sub rax, 1			;accounts for quins of 0
	cmp rax, BC_MIN
	jl BCQuinErr
	cmp rax, BC_MAX
	ja BCQuinErr

	mov r11d, eax			;storing base color

	jmp checkLCTag

BCQuinErr:
	mov rdi, errBCvalue
	call printString
	mov rax, FALSE
	jmp checksDone


;line color
checkLCTag:
	mov rbx, qword[rsi + 40]
	cmp byte[rbx], "-"
	jne checkLCError

	cmp byte[rbx + 1], "l"
	jne checkLCError

	cmp byte[rbx + 2], "c"
	jne checkLCError

	cmp byte[rbx + 3], NULL
	jne checkLCError

	jmp checkLCQuinary

checkLCError:
	mov rdi, errLCsp
	call printString
	mov rax, FALSE
	jmp checksDone

checkLCQuinary:
	mov rdi, qword[rsi + 48]	;quinary num for -lc
	call rdQuinaryNum

	cmp rax, FALSE
	je LCQuinErr
	sub rax, 1			;accounts for quins of 0
	cmp rax, LC_MIN
	jl LCQuinErr
	cmp rax, LC_MAX
	ja LCQuinErr

	mov r12d, eax			;storing line color

	jmp cmpBCLC

LCQuinErr:
	mov rdi, errLCvalue
	call printString
	mov rax, FALSE
	jmp checksDone


;comparing bc and lc
cmpBCLC:		;making sure bc != lc
	cmp r11d, r12d
	jne checkDSTag
	mov rdi, errBCLCsame
	call printString
	mov rax, FALSE
	jmp checksDone

;draw speed
checkDSTag:
	mov rbx, qword[rsi + 56]
	cmp byte[rbx], "-"
	jne checkDSError

	cmp byte[rbx + 1], "d"
	jne checkDSError

	cmp byte[rbx + 2], "s"
	jne checkDSError

	cmp byte[rbx + 3], NULL
	jne checkDSError

	jmp checkDSQuinary

checkDSError:
	mov rdi, errDSsp
	call printString
	mov rax, FALSE
	jmp checksDone

checkDSQuinary:
	mov rdi, qword[rsi + 64]	;quinary num for -ds
	call rdQuinaryNum

	cmp rax, FALSE
	je DSQuinErr
	sub rax, 1			;accounts for quins of 0
	cmp rax, DS_MIN
	jl DSQuinErr
	cmp rax, DS_MAX
	ja DSQuinErr

	mov r13d, eax			;storing draw speed

	jmp storeLabel

DSQuinErr:
	mov rdi, errDSvalue
	call printString
	mov rax, FALSE
	jmp checksDone

storeLabel:
	mov rbx, qword[rbp - 8]			;storing into size address
	mov dword[rbx], r10d
	mov rbx, qword[rbp - 16]		;storing into base color address
	mov dword[rbx], r11d
	mov rbx, qword[rbp - 24]		;storing into line color address
	mov dword[rbx], r12d
	mov rbx, qword[rbp - 32]		;storing into draw speed address
	mov dword[rbx], r13d

	mov rax, TRUE

checksDone:
	pop r13
	pop r12
	pop r11
	pop r10
	mov rsp, rbp
	pop rbp
	ret


; ******************************************************************

;  HLL Call:
;	status = rdQuinaryNum(&numberRead, promptStr, errMsg1,
;					errMsg2, errMSg3);

;  Arguments Passed:
;	1) numberToRead, addr - rdi

;  Returns:
;	number read (via rax)
;	or FALSE


global rdQuinaryNum
rdQuinaryNum:

	push rbp
	mov rbp, rsp
	sub rsp, 1
	push r12
	push r13
	push r14

	mov r12, 0			;index

inputLoop:
	mov al, byte[rdi + r12]
	mov byte[rbp - 1], al		;where to store string

			
	cmp byte[rbp - 1], NULL		;continues until quinary is done reading
	je qToi

	inc r12
	jmp inputLoop

qToi:
	cmp r12, STR_LENGTH		;if the quinary is too long
	jae err0
				
        mov rax, 0  
	mov r12, 0
	mov r13, 0
	mov r14, 0

lp:					;getting rid of all spaces/0
	movzx r14d, byte[rdi + r12]
	inc r12
	cmp r14d, " "		;comparing to spaces
	je lp

	mov r13d, 5

createInt:
	cmp r14d, "0"		;err if char isnt 0-4 inclusive
	jb err0				
	cmp r14d, "4"
	ja err0
	cmp r14d, " "
	je err0

	sub r14d, 48
	mul r13d
	add eax, r14d
	movzx r14d, byte[rdi + r12]
	inc r12
	
	cmp r14d, NULL
	jne createInt
	add eax, 1
	jmp endOfRdQuinary

err0:	
	mov rax, FALSE

endOfRdQuinary:
	pop r14
	pop r13
	pop r12
	mov rsp, rbp
	pop rbp
	ret


; ******************************************************************
;  Draw dancing line function.
;  Plots the following equations:

;	for (t=0.0; t<1.0; t+=tStep) {

;		x = cos(2.0*pi*t)^3;
;		y = sin(2.0*pi*t)^3;
;		glColor3ub(255,0,255);
;		glVertex2d(x, y);

;		x = cos(2.0*pi*s)*t;
;		y = sin(2.0*pi*s)*(1.0-t);
;		glColor3ub(0,255,0);
;		glVertex2d(x, y);

;	}

; -----
;  Global variables accessed.

common	imageSize	1:4			; image size
common	baseColor	1:4			; base color (for square)
common	lineColor	1:4			; line color (for dancing line)
common	drawSpeed	1:4			; draw speed

global drawDancingLine
drawDancingLine:
	push	rbp
	push	rbx
	push	r12
	movsd xmm15, qword[fltZero]

; -----
;  set base color(r,g,b) values
	
	mov rax, 0
	mov rbx, 0
	mov eax, dword[baseColor]
	movzx bx, al
	movzx ebx, bx
	mov dword[bcBlue], ebx
	
	mov rbx, 0
	movzx bx, ah
	movzx ebx, bx
	mov dword[bcGreen], ebx

	mov rbx, 0
	shr rax, 8
	movzx bx, ah
	movzx ebx, bx
	mov dword[bcRed], ebx

; -----
;  set line color(r,g,b) values

	mov rax, 0
	mov ebx, 0
	mov eax, dword[lineColor]
	movzx bx, al
	movzx ebx, bx
	mov dword[lcBlue], ebx
	
	mov rbx, 0
	movzx bx, ah
	movzx ebx, bx
	mov dword[lcGreen], ebx

	mov rbx, 0
	shr rax, 8
	movzx bx, ah
	movzx ebx, bx
	mov dword[lcRed], ebx

; -----
;  Set tStep speed based on user entered image size
;	tStep = tBase - (tOffset * (real(imageSize)/tScale))
	
	mov eax, dword[imageSize]
	cvtsi2sd xmm0, rax		;convert integer to float
	divsd xmm0, qword[tScale]


	mulsd xmm0, qword[tOffset]

	movsd xmm1, qword[tBase]
	subsd xmm1, xmm0

	movsd qword[tStep], xmm1


; -----
;  Set sStep speed based on user entered drawSpeed
;	sStep = drawSpeed / drawScale

	mov eax, dword[drawSpeed]
	cvtsi2sd xmm0, rax
	divsd xmm0, qword[drawScale]
	movsd qword[sStep], xmm0


; -----
;  Prepare for drawing
;  Initialize for drawing points

	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Main plot loop.
;	find iterations -> (1.0 / tStep)

mainLp:
	movsd xmm3, qword[t]		  	;xmm15 = 0->t by t step
	mulsd xmm3, qword[fltTwo]
	mulsd xmm3, qword[pi]			;xmm3 = 2 * pi * t

	movsd xmm0, xmm3
	movsd qword[bInside], xmm3		;bInside holds the value 2 * pi * t		
	call cos
	movsd xmm1, xmm0			
	mulsd xmm1, xmm0
	mulsd xmm1, xmm0			;xmm1 = x base color

	movsd qword[x], xmm1			;set x for base

	movsd xmm0, qword[bInside]
	call sin
	movsd xmm2, xmm0			
	mulsd xmm2, xmm0
	mulsd xmm2, xmm0			;xmm2 = y base color

	movsd qword[y], xmm2			;set y for base

	mov edi, dword[bcRed]			;set base colors
	mov esi, dword[bcGreen]
	mov edx, dword[bcBlue]
	call glColor3ub

	movsd xmm0, qword[x]			;plot x, y
	movsd xmm1, qword[y]
	call glVertex2d

	movsd xmm3, qword[s]			;x line image
	mulsd xmm3, qword[fltTwo]
	mulsd xmm3, qword[pi]			;xmm3 = 2 * pi * s

	movsd xmm0, xmm3
	movsd qword[lInside], xmm3		;lInside holds the value 2 * pi * t	
	call cos
	movsd xmm1, xmm0	
	mulsd xmm1, qword[t]			;xmm1 = x line color
	movsd qword[x], xmm1			;set x for line

	movsd xmm0, qword[lInside]
	call sin
	movsd xmm2, xmm0			
	movsd xmm0, qword[fltOne]
	subsd xmm0, qword[t]			;xmm0 = 1.0 - t
	mulsd xmm2, xmm0			;xmm2 = y line color

	movsd qword[y], xmm2			;set y for line

	mov edi, dword[lcRed]			;set line colots
	mov esi, dword[lcGreen]
	mov edx, dword[lcBlue]
	call glColor3ub

	movsd xmm0, qword[x]			;plot x, y
	movsd xmm1, qword[y]
	call glVertex2d

	movsd xmm0, qword[tStep]
	movsd xmm1, qword[t]
	addsd xmm1, xmm0		;t + tstep
	movsd qword[t], xmm1
	ucomisd xmm1, qword[fltOne]
	jb mainLp
	movsd xmm0, qword[fltZero]
	movsd qword[t], xmm0
	

; -----
;  Main loop done, call required openGL functions

	call	glEnd
	call	glFlush

	call	glutPostRedisplay

; -----
;  Update s before leaving function
	
	movsd xmm0, qword[s]
	movsd xmm14, qword[sStep]
	addsd xmm0, xmm14
	movsd qword[s], xmm0

; -----
;  Check if s is > 1.0 and if so, reset s to 0.0

	ucomisd	xmm0, qword [fltOne]
	jb	sIsSet
	movsd	xmm0, qword [fltZero]
	movsd	qword [s], xmm0
sIsSet:

; -----
;  Done, return

	pop	r12
	pop	rbx
	pop	rbp
	ret

; ******************************************************************

