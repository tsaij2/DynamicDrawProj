
;	Jonathan Tsai
;	Assignment 04
;	Section 001



; *****************************************************************
;  Data Declarations
          
section	.data

; -----
;  Standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
SYS_exit	equ	60			; call code for terminate

; -----

lst		dd	3707, 1111, 1540, 1243, 1674
		dd	1629, 2412, 1818, 1242,  330 
		dd	2310, 1210, 2726, 1140, 2565
		dd	2871, 1614, 2418, 2513, 1422 
		dd	1809, 1215, 1525,  712, 1441
		dd	3622,  891, 1729, 1615, 2724 
		dd	1210, 1224, 1580, 1147, 2324
		dd	1425, 1816, 1262, 2718, 1192 
		dd	1430, 1235, 2764, 1615, 1310
		dd	1765, 1954,  967, 1515, 1556 
		dd	 342, 7321, 1556, 2727, 1227
		dd	1927, 1382, 1465, 3955, 1435 
		dd	 220, 2409, 2530, 1345, 2467
		dd	1615, 1959, 1342, 2856, 2553 
		dd	1035, 1833, 1464, 1915, 1810
		dd	1465, 1554,  267, 1615, 1656 
		dd	2189,  825, 1925, 2312, 1725
		dd	2517, 1498,  677, 1475, 2034 
		dd	1223, 1883, 1173, 1350, 2409
		dd	1089, 1133, 1122, 1705, 3025
length		dd	100

two		dw	2
four		dw	4
lengthMiddle	dd	0
modEven		dw	2
modEleven	dw	11

lstMin		dd	0
estMed		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

evenCnt		dd	0
evenSum		dd	0
evenAve		dd	0

elevenCnt	dd	0
elevenSum	dd	0
elevenAve	dd	0

; *****************************************************************
;  Code Section

section	.text
global _start
_start:

; ----------
;estMed calculation
	mov ebx, 0
	
	mov eax, dword[length]
	div word[two]
	mov dword[lengthMiddle], eax
	mov rax, 0

	mov ecx, dword[lengthMiddle]
	mov ebx, dword[lst]
	add eax, ebx
	mov ebx, dword[lst + ecx * 4]
	add eax, ebx
	mov ebx, dword[lst + ecx * 4 - 4]
	add eax, ebx
	mov ebx, dword[lst + ecx * 2 * 4 - 4]
	add eax, ebx
	div word[four]
	mov dword[estMed], eax
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	
	mov rsi, 0
	mov ecx, dword[length]
	mov eax, dword[lst]
	mov dword[lstMin], eax
	mov dword[lstMax], eax

lp:	
	mov eax, 0
	mov edx, 0
	mov eax, dword[lst + rsi * 4]
	add dword[lstSum], eax
	cmp eax, dword[lstMin] 
	jl newMin
	cmp eax, dword[lstMax]
	jg newMax
	jmp evenCheck

newMin:
	mov dword[lstMin], eax
	jmp evenCheck

newMax:
	mov dword[lstMax], eax
	jmp evenCheck
	
evenCheck:
	div word[modEven]
	mov eax, dword[lst + rsi * 4]

	cmp edx, 0
	jne elevenCheck

	add dword[evenSum], eax
	add dword[evenCnt], 1
	jmp elevenCheck

elevenCheck:
	mov edx, 0
	div word[modEleven]

	cmp edx, 0
	jne checksDone
	
	mov eax, dword[lst + rsi * 4]
	add dword[elevenSum], eax
	add dword[elevenCnt], 1
	jmp checksDone


checksDone:
	inc rsi
	dec ecx
	cmp ecx, 0
	jne lp

;Calculating averages
;lstAve
	mov eax, dword[lstSum]
	cdq
	div dword[length]
	mov dword[lstAve], eax
	mov rax, 0

;evenAve
	mov eax, dword[evenSum]
	cdq
	div dword[evenCnt]
	mov dword[evenAve], eax
	mov rax, 0

;elevenAve
	mov eax, dword[elevenSum]
	cdq
	div dword[elevenCnt]
	mov dword[elevenAve], eax
	mov rax, 0

; *****************************************************************
;	Done, terminate program.

last:
	mov	eax, SYS_exit		; call code for exit
	mov	ebx, EXIT_SUCCESS	; exit program with success
	syscall

