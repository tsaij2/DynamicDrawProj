
;	Jonathan Tsai
;	Assignment 05
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

;  Provided Data

aSides		db	   10,    14,    13,    37,    54
		db	   31,    13,    20,    61,    36
		db	   14,    53,    44,    19,    42
		db	   27,    41,    53,    62,    10
		db	   19,    28,    14,    10,    15
		db	   15,    11,    22,    33,    70
		db	   15,    23,    15,    63,    26
		db	   24,    33,    10,    61,    15
		db	   14,    34,    13,    71,    81
		db	   38,    73,    29,    17,    93

sSides		dd	 1145,  1135,  1123,  1123,  1123
		dd	 1254,  1454,  1152,  1164,  1542
		dd	 1353,  1457,  1182,  1142,  1354
		dd	 1364,  1134,  1154,  1344,  1142
		dd	 1173,  1543,  1151,  1352,  1434
		dd	 1355,  1037,  1123,  1024,  1453
		dd	 1134,  2134,  1156,  1134,  1142
		dd	 1267,  1104,  1134,  1246,  1123
		dd	 1134,  1161,  1176,  1157,  1142
		dd	 1153,  1193,  1184,  1142,  2034

hSides		dw	  133,   114,   173,   131,   115
		dw	  164,   173,   174,   123,   156
		dw	  144,   152,   131,   142,   156
		dw	  115,   124,   136,   175,   146
		dw	  113,   123,   153,   167,   135
		dw	  114,   129,   164,   167,   134
		dw	  116,   113,   164,   153,   165
		dw	  126,   112,   157,   167,   134
		dw	  117,   114,   117,   125,   153
		dw	  123,   173,   115,   106,   113

length		dd	50

lAreaMin	dd	0
lAreaMid	dd	0
lAreaMax	dd	0
lAreaSum	dd	0
lAreaAve	dd	0

volMin		dd	0
volMid		dd	0
volMax		dd	0
volSum		dd	0
volAve		dd	0

; -----
;  Additional variables (if any)
three		dd	3
two		dd	2
temp		dd	0
middleLength	dw	0



; --------------------------------------------------------------
; Uninitialized data

section	.bss

latAreas	resd	50
volumes		resd	50

; *****************************************************************
;  Code Section

section	.text
global _start
_start:

; ----------
;Calculate latAreas/volume/sum
	mov rsi, 0
	mov ecx, dword[length]

;latArea[n] = 2 × aSides[n] × sSides[n]
lp:	mov rax, 0
	mov rdx, 0
	mov al, byte[aSides + rsi]
	mul dword[sSides + rsi * 4]
	mul dword[two]	
	mov dword[latAreas + rsi * 4], eax
	add dword[lAreaSum], eax

;volume[n] = (aSides[n]^2 × hSides[n]) / 3
 	mov rax, 0
	mov rdx, 0
	mov al, byte[aSides + rsi]
	mul byte[aSides + rsi]
	movzx eax, ax
	
	mov bx, word[hSides + rsi * 2]
	movzx ebx, bx
	mul ebx
	div dword[three]
	mov dword[volumes + rsi * 4], eax
	add dword[volSum], eax

	inc rsi
	dec ecx
	cmp ecx, 0
	jne lp

;Calculaing min/max
	mov rax, 0
	mov rsi, 0
	mov ecx, dword[length]
	mov eax, dword[latAreas]
	mov dword[lAreaMin], eax
	mov dword[lAreaMax], eax
	mov eax, dword[volumes]
	mov dword[volMin], eax
	mov dword[volMax], eax

lp1:	
	mov eax, dword[latAreas + rsi * 4]
	cmp eax, dword[lAreaMin]
	jb newAreaMin
	cmp eax, dword[lAreaMax]
	ja newAreaMax
	jmp volumeLoop

newAreaMin:
	mov dword[lAreaMin], eax
	jmp volumeLoop

newAreaMax:
	mov dword[lAreaMax], eax
	jmp volumeLoop

volumeLoop:
	mov eax, dword[volumes + rsi * 4]
	cmp eax, dword[volMin]
	jb newVolMin
	cmp eax, dword[volMax]
	ja newVolMax
	jmp loopDone

newVolMin:
	mov dword[volMin], eax
	jmp loopDone

newVolMax:
	mov dword[volMax], eax
	jmp loopDone

loopDone:
	inc rsi
	dec ecx
	cmp ecx, 0
	jne lp1


;Calculating middle depending on size of list

	mov rax, 0
	mov eax, dword[length]
	div dword[two]
	mov word[middleLength], ax
	cmp dx, 0
	jne oddLength
	jmp evenLength

oddLength:
	mov bx, word[middleLength]
	movzx rax, bx
	mov rsi, rax
	mov eax, dword[latAreas +rsi * 4]
	mov dword[lAreaMid], eax

	mov eax, dword[volumes +rsi * 4]
	mov dword[volMid], eax
	jmp averages

evenLength:
	mov bx, word[middleLength]
	movzx rax, bx
	mov rsi, rbx
	mov eax, dword[latAreas + rsi * 4]
	add eax, dword[latAreas + rsi * 4 - 4]
	div dword[two]
	mov word[lAreaMid], ax
	
	mov rax, 0
	mov eax, dword[volumes + rsi * 4]
	add eax, dword[volumes + rsi * 4 - 4]
	div dword[two]
	mov word[volMid], ax
	jmp averages
	
	
;Calculating averages for lAreaAve and volAve
averages:	
	mov rax, 0
	mov rdx, 0
	mov eax, dword[lAreaSum]
	div dword[length]
	mov dword[lAreaAve], eax

	mov rax, 0
	mov rdx, 0
	mov eax, dword[volSum]
	div dword[length]
	mov dword[volAve], eax




; *****************************************************************
;	Done, terminate program.

last:
	mov	eax, SYS_exit		; call code for exit
	mov	ebx, EXIT_SUCCESS	; exit program with success
	syscall

