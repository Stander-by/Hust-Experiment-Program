; ==========================================
; ������
; ������������������A��B��Ϊ��ѭ���������л�
; ����2004��-���-U202011107
; ==========================================

%include	"pm.inc"	; ����, ��, �Լ�һЩ˵��

PageDirBase0		equ	200000h	; ҳĿ¼��ʼ��ַ:	2M
PageTblBase0		equ	201000h	; ҳ��ʼ��ַ:		2M +  4K
PageDirBase1		equ	210000h	; ҳĿ¼��ʼ��ַ:	2M + 64K
PageTblBase1		equ	211000h	; ҳ��ʼ��ַ:		2M + 64K + 4K

LinearAddrDemo	equ	00401000h ; �����ĸ��������ص��ע
ProcFoo		equ	00401000h ; ָ�������ַ����ȷ����ǰ�Ķ�Ϊflat�Σ��Լ���д�ĺ�����Ҫ��������������ַ��
ProcBar		equ	00501000h

ProcPagingDemo	equ	00301000h

org	0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT
;                                         �λ�ַ,       �ν���     , ����
LABEL_GDT:		Descriptor	       0,                 0, 0				; ��������
LABEL_DESC_NORMAL:	Descriptor	       0,            0ffffh, DA_DRW			; Normal ������
LABEL_DESC_FLAT_C:	Descriptor             0,           0fffffh, DA_CR | DA_32 | DA_LIMIT_4K | DA_DPL3; 0 ~ 4G�����룿
LABEL_DESC_FLAT_RW:	Descriptor             0,           0fffffh, DA_DRW | DA_LIMIT_4K | DA_DPL3	; 0 ~ 4G����д�ڴ棿
LABEL_DESC_CODE32:	Descriptor	       0,  SegCode32Len - 1, DA_CR | DA_32		; ��һ�´����, 32
LABEL_DESC_CODE16:	Descriptor	       0,            0ffffh, DA_C			; ��һ�´����, 16
LABEL_DESC_DATA:	Descriptor	       0,	DataLen - 1, DA_DRW			; Data
LABEL_DESC_STACK:	Descriptor	       0,        TopOfStack, DA_DRWA | DA_32		; Stack, 32 λ
LABEL_DESC_VIDEO:	Descriptor	 0B8000h,            0ffffh, DA_DRW	| DA_DPL3		; �Դ��׵�ַ


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; �����������ε�LDT���ȼӶ��ټ�����������ѡ����
LABEL_DESC_LDT0:		Descriptor	       0,        LDT0Len - 1, DA_LDT		; LDT��������
LABEL_DESC_LDT1:		Descriptor	       0,        LDT1Len - 1, DA_LDT		; LDT��������

; ���������TSS
LABEL_DESC_TSS0:	Descriptor	       0,          TSS0Len - 1, DA_386TSS		; TSS
LABEL_DESC_TSS1:	Descriptor	       0,          TSS1Len - 1, DA_386TSS		; TSS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	

; GDT ����

GdtLen		equ	$ - LABEL_GDT	; GDT����
GdtPtr		dw	GdtLen - 1	; GDT����
		dd	0		; GDT����ַ

; GDT ѡ����
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT
SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT + SA_RPL3


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; �������LDT��ѡ����
SelectorLDT0		equ LABEL_DESC_LDT0 	- LABEL_GDT
SelectorLDT1		equ LABEL_DESC_LDT1		- LABEL_GDT
; ���������ջ��TSS��ѡ����
SelectorTSS0		equ LABEL_DESC_TSS0		- LABEL_GDT
SelectorTSS1		equ LABEL_DESC_TSS1		- LABEL_GDT
; END of [SECTION .gdt]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


[SECTION .data1]	 ; ���ݶ�
ALIGN	32
[BITS	32]
LABEL_DATA:
; ʵģʽ��ʹ����Щ����
; �ַ���
_szPMMessage:			db	"this is rang0 protection mode :)", 0Ah, 0Ah, 0	; ���뱣��ģʽ����ʾ���ַ���
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; ���뱣��ģʽ����ʾ���ַ���
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0
; ����
_wSPValueInRealMode		dw	0
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	; ��Ļ�� 6 ��, �� 0 �С�
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0
_PageTableNumber		dd	0
_SavedIDTR:			dd	0	; ���ڱ��� IDTR
				dd	0
_SavedIMREG:			db	0	; �ж����μĴ���ֵ
_MemChkBuf:	times	256	db	0


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_szCurTask				dd  0   ;�ṩѡ��
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; ����ģʽ��ʹ����Щ����
szPMMessage		equ	_szPMMessage	- $$
szMemChkTitle		equ	_szMemChkTitle	- $$
szRAMSize		equ	_szRAMSize	- $$
szReturn		equ	_szReturn	- $$
dwDispPos		equ	_dwDispPos	- $$
dwMemSize		equ	_dwMemSize	- $$
dwMCRNumber		equ	_dwMCRNumber	- $$
ARDStruct		equ	_ARDStruct	- $$
	dwBaseAddrLow	equ	_dwBaseAddrLow	- $$
	dwBaseAddrHigh	equ	_dwBaseAddrHigh	- $$
	dwLengthLow	equ	_dwLengthLow	- $$
	dwLengthHigh	equ	_dwLengthHigh	- $$
	dwType		equ	_dwType		- $$
MemChkBuf		equ	_MemChkBuf	- $$
SavedIDTR		equ	_SavedIDTR	- $$
SavedIMREG		equ	_SavedIMREG	- $$
PageTableNumber		equ	_PageTableNumber- $$


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CurTask 		equ _szCurTask - $$
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


DataLen			equ	$ - LABEL_DATA
; END of [SECTION .data1]


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; IDT
[SECTION .idt]
ALIGN	32
[BITS	32]
LABEL_IDT:
; ��                                Ŀ��ѡ����,            ƫ��, DCount, ����
%rep 32
			Gate	SelectorCode32, SpuriousHandler,      0, DA_386IGate
%endrep
.020h:			Gate	SelectorCode32,    ClockHandler,      0, DA_386IGate
%rep 95
			Gate	SelectorCode32, SpuriousHandler,      0, DA_386IGate
%endrep
.080h:			Gate	SelectorCode32,  UserIntHandler,      0, DA_386IGate

IdtLen		equ	$ - LABEL_IDT
IdtPtr		dw	IdtLen - 1	; �ν���
		dd	0		; ����ַ
; END of [SECTION .idt]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ����������ں�ջ
[SECTION .st0] 
ALIGN	32
[BITS	32]
LABEL_STACK0:
	times 512 db 0

TopOfStack0	equ	$ - LABEL_STACK0 - 1

[SECTION .st1]
ALIGN	32
[BITS	32]
LABEL_STACK1:
	times 512 db 0

TopOfStack1	equ	$ - LABEL_STACK1 - 1

; ����������û�ջ
[SECTION .st3_0] 
ALIGN	32
[BITS	32]
LABEL_STACK3_0:
	times 512 db 0

TopOfStack3_0	equ	$ - LABEL_STACK3_0 - 1

[SECTION .st3_1]
ALIGN	32
[BITS	32]
LABEL_STACK3_1:
	times 512 db 0

TopOfStack3_1	equ	$ - LABEL_STACK3_1 - 1

; ���������TSS
[SECTION .tss0]          ;��ø��εĴ�С
ALIGN	32              ;align��һ�������ݶ���ĺꡣͨ��align�Ķ�����1��4��8�ȡ������align 32��û������ģ���Ϊ��������ֻ��32b�ĵ�ַ���߿�ȡ�
[BITS	32]             ;32λģʽ�Ļ�������
LABEL_TSS0:              ;����LABEL_TSS
		DD	0			; Back
		DD	TopOfStack0		; 0 ����ջ   ģ��֮ǰ����������
		DD	SelectorStack0		; 
		DD	0			; 1 ����ջ
		DD	0			; 
		DD	0			; 2 ����ջ
		DD	0			;               TSS�����ֻ�ܷ���Ring2����ջ��ring3����ջ����Ҫ����
		DD	PageDirBase0			; CR3
		DD	0			; EIP
		DD	0x200			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	TopOfStack3_0			; ESP ֮ǰ������󣬰��û�ջ���ں�ջ����һ���ˣ�Ҳû������ring0��ring3
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	SelectorLDT0CodeA		; CS
		DD	SelectorStack3_0			; SS
		DD	SelectorTask0Data			; DS
		DD	0			; FS
		DD	SelectorVideo			; GS
		DD	SelectorLDT0			; LDT
		DW	0			; ���������־
		DW	$ - LABEL_TSS0 + 2	; I/Oλͼ��ַ
		DB	0ffh			; I/Oλͼ������־
TSS0Len		equ	$ - LABEL_TSS0   ;��öεĴ�С

[SECTION .tss1]          ;��ø��εĴ�С
ALIGN	32              ;align��һ�������ݶ���ĺꡣͨ��align�Ķ�����1��4��8�ȡ������align 32��û������ģ���Ϊ��������ֻ��32b�ĵ�ַ���߿�ȡ�
[BITS	32]             ;32λģʽ�Ļ�������
LABEL_TSS1:              ;����LABEL_TSS
		DD	0			; Back
		DD	TopOfStack1		; 0 ����ջ   //�ڲ�ring0����ջ����TSS��
		DD	SelectorStack1		; 
		DD	0			; 1 ����ջ
		DD	0			; 
		DD	0			; 2 ����ջ
		DD	0			;               //TSS�����ֻ�ܷ���Ring2����ջ��ring3����ջ����Ҫ����
		DD	PageDirBase1			; CR3
		DD	0			; EIP
		DD	0x200			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	TopOfStack3_1			; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	SelectorLDT1CodeA			; CS
		DD	SelectorStack3_1			; SS
		DD	SelectorTask1Data			; DS
		DD	0			; FS
		DD	SelectorVideo			; GS
		DD	SelectorLDT1			; LDT
		DW	0			; ���������־
		DW	$ - LABEL_TSS1 + 2	; I/Oλͼ��ַ
		DB	0ffh			; I/Oλͼ������־
TSS1Len		equ	$ - LABEL_TSS1   ;��öεĴ�С
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ���������������ݶ�
[SECTION .task0data]
ALIGN	32
[BITS	32]
LABEL_T0_DATA:
_szTask0Message:	db	"r23", 0Ah, 0Ah, 0
Task0Message	equ _szTask0Message - $$
Task0DataLen	equ	$ - LABEL_T0_DATA

[SECTION .task1data]
ALIGN	32
[BITS	32]
LABEL_T1_DATA:
_szTask1Message:	db	"r23", 0Ah, 0Ah, 0
Task1Message	equ _szTask1Message - $$
Task1DataLen	equ	$ - LABEL_T1_DATA
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; ȫ�ֶ�ջ��
[SECTION .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 512 db 0

TopOfStack	equ	$ - LABEL_STACK - 1

; END of [SECTION .gs]


[SECTION .s16] 
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

	mov	[LABEL_GO_BACK_TO_REAL+3], ax
	mov	[_wSPValueInRealMode], sp

	; �õ��ڴ�������δ���Ľ�����pmtest7��
	mov	ebx, 0
	mov	di, _MemChkBuf
.loop:
	mov	eax, 0E820h
	mov	ecx, 20
	mov	edx, 0534D4150h
	int	15h
	jc	LABEL_MEM_CHK_FAIL
	add	di, 20
	inc	dword [_dwMCRNumber]
	cmp	ebx, 0
	jne	.loop
	jmp	LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov	dword [_dwMCRNumber], 0
LABEL_MEM_CHK_OK:

	; ��ʼ�� 16 λ�����������
	mov	ax, cs
	movzx	eax, ax
	shl	eax, 4
	add	eax, LABEL_SEG_CODE16
	mov	word [LABEL_DESC_CODE16 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE16 + 4], al
	mov	byte [LABEL_DESC_CODE16 + 7], ah

	; ��ʼ�� 32 λ�����������
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; ��ʼ�����ݶ�������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; ��ʼ����ջ��������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ��ʼ��LDT0��GDT�е�������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT0
	mov	word [LABEL_DESC_LDT0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT0 + 4], al
	mov	byte [LABEL_DESC_LDT0 + 7], ah

	; ��ʼ��LDT1��GDT�е�������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT1
	mov	word [LABEL_DESC_LDT1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT1 + 4], al
	mov	byte [LABEL_DESC_LDT1 + 7], ah

	; ��ʼ��LDT0�е�������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT0_CODE_A
	mov	word [LABEL_LDT0_DESC_CODEA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT0_DESC_CODEA + 4], al
	mov	byte [LABEL_LDT0_DESC_CODEA + 7], ah

	; ��ʼ��LDT1�е�������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT1_CODE_A
	mov	word [LABEL_LDT1_DESC_CODEA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT1_DESC_CODEA + 4], al
	mov	byte [LABEL_LDT1_DESC_CODEA + 7], ah

	; �����ʼ��Stack��TSS��������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK0
	mov	word [LABEL_DESC_STACK0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK0 + 4], al
	mov	byte [LABEL_DESC_STACK0 + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK1
	mov	word [LABEL_DESC_STACK1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK1 + 4], al
	mov	byte [LABEL_DESC_STACK1 + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK3_0
	mov	word [LABEL_DESC_STACK3_0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK3_0 + 4], al
	mov	byte [LABEL_DESC_STACK3_0 + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK3_1
	mov	word [LABEL_DESC_STACK3_1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK3_1 + 4], al
	mov	byte [LABEL_DESC_STACK3_1 + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TSS0
	mov	word [LABEL_DESC_TSS0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS0 + 4], al
	mov	byte [LABEL_DESC_TSS0 + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TSS1
	mov	word [LABEL_DESC_TSS1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS1 + 4], al
	mov	byte [LABEL_DESC_TSS1 + 7], ah

	; �����ʼ�������������ݶε�������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_T0_DATA
	mov	word [LABEL_LDT0_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT0_DESC_DATA + 4], al
	mov	byte [LABEL_LDT0_DESC_DATA + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_T1_DATA
	mov	word [LABEL_LDT1_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT1_DESC_DATA + 4], al
	mov	byte [LABEL_LDT1_DESC_DATA + 7], ah
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; Ϊ���� GDTR ��׼�����˶δ���Ľ�����pmtest1��
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt ����ַ
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt ����ַ


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ׼������ IDTR 
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_IDT		; eax <- idt ����ַ
	mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt ����ַ

	; ���� IDTR
	sidt	[_SavedIDTR]

	; �����ж����μĴ���
	in	al, 21h
	mov	[_SavedIMREG], al
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; ���� GDTR
	lgdt	[GdtPtr]

	; ���ж�
	cli


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ���� IDTR
	lidt	[IdtPtr]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; �򿪵�ַ��A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; ׼���л�������ģʽ�����������pmtest1��
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; �������뱣��ģʽ
	jmp	dword SelectorCode32:0	; ִ����һ���� SelectorCode32 װ�� cs, ����ת�� Code32Selector:0  ��

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:		; �ӱ���ģʽ���ص�ʵģʽ�͵�������
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	sp, [_wSPValueInRealMode] ; ������ʵģʽ����ʹ��ʵģʽ�ı�־

	; �޸Ŀ�ʼ
	lidt	[_SavedIDTR]	; �ָ� IDTR ��ԭֵ

	mov	al, [_SavedIMREG]	; ���ָ��ж����μĴ���(IMREG)��ԭֵ
	out	21h, al			    ; ��
	; �޸Ľ���

	in	al, 92h		    ; ��
	and	al, 11111101b	; �� �ر� A20 ��ַ��
	out	92h, al		    ; ��

	sti			; ���ж�

	mov	ax, 4c00h	; ��
	int	21h		    ; ���ص� DOS
; END of [SECTION .s16]


[SECTION .s32]; 32 λ�����. ��ʵģʽ����.
[BITS	32]

LABEL_SEG_CODE32:
	mov	ax, SelectorData
	mov	ds, ax			; ���ݶ�ѡ����
	mov	es, ax
	mov	ax, SelectorVideo
	mov	gs, ax			; ��Ƶ��ѡ����

	mov	ax, SelectorStack
	mov	ss, ax			; ��ջ��ѡ����

	mov	esp, TopOfStack


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	call	Init8259A ; 286-289Ϊ�����жϲ�����080H���ж�
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; ������ʾһ���ַ���
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4

	call	DispMemSize		; ��ʾ�ڴ���Ϣ

	call PagingDemo ; ��������SetupPaging


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	sti ; �����ж�����

	mov		ax, SelectorTSS0	; �� ���� TSS
	ltr		ax					; ��

	mov		ax, SelectorLDT0	; �� ���� LDT
	lldt	ax					; ��

	mov	eax, PageDirBase0
	mov	cr3, eax   ; ���浱ǰҳĿ¼
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax  ; 
	jmp	short .5
.5:
	nop

	; ʹ��iretdָ���л�������0
	push SelectorStack3_0 ; SS  Ŀ�꣺rang3ջ
	push TopOfStack3_0	; ESP ��Ϊѹ��ring3���û�ջ
	pushfd				; ѹ��EFLAGS����־�Ĵ�����
	pop eax
	or eax, 0x200		; IFλ��1�������ж�
	push eax
	push SelectorLDT0CodeA ; CS
	push 0				; EIP

	iretd ; ���ص�SelectorLDT0CodeA

	call	SetRealmode8259A ; �ָ�8259A�Է���ʵģʽ
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; ����ֹͣ
	jmp	SelectorCode16:0 ; ����������LABEL_DESC_CODE16��

; Init8259A ---------------------------------------------------------------------------------------------
Init8259A:
	mov	al, 011h
	out	020h, al	; ��8259, ICW1.
	call	io_delay

	out	0A0h, al	; ��8259, ICW1.
	call	io_delay

	mov	al, 020h	; IRQ0 ��Ӧ�ж����� 0x20
	out	021h, al	; ��8259, ICW2.
	call	io_delay

	mov	al, 028h	; IRQ8 ��Ӧ�ж����� 0x28
	out	0A1h, al	; ��8259, ICW2.
	call	io_delay

	mov	al, 004h	; IR2 ��Ӧ��8259
	out	021h, al	; ��8259, ICW3.
	call	io_delay

	mov	al, 002h	; ��Ӧ��8259�� IR2
	out	0A1h, al	; ��8259, ICW3.
	call	io_delay

	mov	al, 001h
	out	021h, al	; ��8259, ICW4.
	call	io_delay

	out	0A1h, al	; ��8259, ICW4.
	call	io_delay

	mov	al, 11111110b	; ����������ʱ���жϣ���ʱ���жϵĶ�Ӧ��λ��Ϊ0
	;mov	al, 11111111b	; ������8259�����ж�
	out	021h, al	; ��8259, OCW1.
	call	io_delay ; �ú����������Ǽ���nopָ�����������ʱ������

	mov	al, 11111111b	; ���δ�8259�����ж�
	out	0A1h, al	; ��8259, OCW1.
	call	io_delay

	ret
; Init8259A ---------------------------------------------------------------------------------------------


; SetRealmode8259A ---------------------------------------------------------------------------------------------
SetRealmode8259A:
	mov	ax, SelectorData
	mov	fs, ax

	mov	al, 017h
	out	020h, al	; ��8259, ICW1.
	call	io_delay

	mov	al, 008h	; IRQ0 ��Ӧ�ж����� 0x8
	out	021h, al	; ��8259, ICW2.
	call	io_delay

	mov	al, 001h
	out	021h, al	; ��8259, ICW4.
	call	io_delay

	mov	al, [fs:SavedIMREG]	; ���ָ��ж����μĴ���(IMREG)��ԭֵ
	out	021h, al		; ��
	call	io_delay

	ret
; SetRealmode8259A ---------------------------------------------------------------------------------------------

io_delay:
	nop
	nop
	nop
	nop
	ret

; int handler ---------------------------------------------------------------
_ClockHandler: ; ʱ���жϴ��������Ҫ�޸ĳ��л�����ĺ���
ClockHandler	equ	_ClockHandler - $$

	push ds
	push eax

	inc	byte [gs:((80 * 0 + 70) * 2)]	; ��Ļ�� 0 ��, �� 70 �С�
	mov		eax, SelectorData			; �� ���� DS �Զ�ȡ dwCurrentTask
	mov		ds, ax

	mov	al, 20h
	out	20h, al				; ���� EOI 


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp dword [CurTask], 0
	je ll1
	mov dword [CurTask], 0
	
	call PSwitchToZero

	mov	ah, 0Ch				; 0000: �ڵ�    1100: ����
	mov	al, '1'
	mov	[gs:((80 * 0 + 61) * 2)], ax

	jmp SelectorTSS0:0
	;call SelectorFlatC:ProcPagingDemo ; �˴�����ֱ�ӵ��ö�Ӧ����������������ѭ�����޷�����EOI
	jmp ll2
	
ll1:
	mov dword [CurTask], 1
	call PSwitchToOne

	mov	ah, 0Ch				; 0000: �ڵ�    1100: ����
	mov	al, '0'
	mov	[gs:((80 * 0 + 60) * 2)], ax

	jmp SelectorTSS1:0

ll2:
	pop eax
	pop ds
	iretd

_UserIntHandler:
UserIntHandler	equ	_UserIntHandler - $$
	mov	ah, 0Ch				; 0000: �ڵ�    1100: ����
	mov	al, 'I'
	mov	[gs:((80 * 0 + 70) * 2)], ax	; ��Ļ�� 0 ��, �� 70 �С�
	iretd

_SpuriousHandler:
SpuriousHandler	equ	_SpuriousHandler - $$
	mov	ah, 0Ch				; 0000: �ڵ�    1100: ����
	mov	al, '!'
	mov	[gs:((80 * 0 + 75) * 2)], ax	; ��Ļ�� 0 ��, �� 75 �С�
	jmp	$
	iretd
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; ������ҳ���� --------------------------------------------------------------
SetupPaging: ; �˴��Ѿ�������ҳ���ʼ�����������л�ҳ��ʱ���³�ʼ��
	; �����ڴ��С����Ӧ��ʼ������PDE�Լ�����ҳ��
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, һ��ҳ���Ӧ���ڴ��С
	div	ebx
	mov	ecx, eax	; ��ʱ ecx Ϊҳ��ĸ�����Ҳ�� PDE Ӧ�õĸ���
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; ���������Ϊ 0 ��������һ��ҳ��
.no_remainder:
	mov	[PageTableNumber], ecx	; �ݴ�ҳ�����

	; Ϊ�򻯴���, �������Ե�ַ��Ӧ��ȵ������ַ. ���Ҳ������ڴ�ն�.

	; ���ȳ�ʼ��ҳĿ¼
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase0	; �˶��׵�ַΪ PageDirBase0
	xor	eax, eax
	mov	eax, PageTblBase0 | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; Ϊ�˼�, ����ҳ�����ڴ�����������.
	loop	.1

	; �ٳ�ʼ������ҳ��
	mov	eax, [PageTableNumber]	; ҳ���������7����������7û����һ��ʼ�涨ҳ��ĸ���������ͨ��ʵ���ڴ�Ĵ�Сʹҳ��ĸ������
	mov	ebx, 1024		; ÿ��ҳ�� 1024 �� PTE
	mul	ebx
	mov	ecx, eax		; PTE���� = ҳ����� * 1024
	mov	edi, PageTblBase0	; �˶��׵�ַΪ PageTblBase0
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; ÿһҳָ�� 4K �Ŀռ�
	loop	.2


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ��ʼ��ҳĿ¼
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase1	; �˶��׵�ַΪ PageDirBase1
	xor	eax, eax
	mov	eax, PageTblBase1 | PG_P  | PG_USU | PG_RWW
	mov	ecx, [PageTableNumber]
.3:
	stosd
	add	eax, 4096		; Ϊ�˼�, ����ҳ�����ڴ�����������.
	loop	.3

	; �ٳ�ʼ������ҳ��
	mov	eax, [PageTableNumber]	; ҳ�����
	mov	ebx, 1024		; ÿ��ҳ�� 1024 �� PTE
	mul	ebx
	mov	ecx, eax		; PTE���� = ҳ����� * 1024
	mov	edi, PageTblBase1	; �˶��׵�ַΪ PageTblBase1
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.4:
	stosd
	add	eax, 4096		; ÿһҳָ�� 4K �Ŀռ�
	loop	.4
	ret
; ��ҳ�����������
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ������������13-17�е��ڴ��ַ 
PagingDemo: 
	mov	ax, cs
	mov	ds, ax ; Դ������ds����
	mov	ax, SelectorFlatRW
	mov	es, ax ; Ŀ��������es����

	push	LenFoo
	push	OffsetFoo
	push	ProcFoo
	call	MemCpy ; memcpy(ProcFoo, OffsetFoo, LenFoo); �˴�memcpy����Դ������ds���У�Ŀ��������es����
	add	esp, 12

	push	LenBar
	push	OffsetBar
	push	ProcBar
	call	MemCpy ; memcpy(ProcBar, OffsetBar, LenBar);
	add	esp, 12

	push	LenPagingDemoAll
	push	OffsetPagingDemoProc
	push	ProcPagingDemo
	call	MemCpy ; memcpy(ProcPagingDemo, OffsetPagingDemoProc, LenPagingDemoAll);
	add	esp, 12

	mov	ax, SelectorData
	mov	ds, ax			; ���ݶ�ѡ����
	mov	es, ax

	call	SetupPaging		; ������ҳ

	ret
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PSwitchToZero:
	mov	ax, SelectorFlatRW
	mov	es, ax ; Ŀ��������es����
	mov	eax, LinearAddrDemo ; ��LinearAddrDemoӳ����Bar�����ı����Ե�ַ��Ӧ�������ַ��
	shr	eax, 22
	mov	ebx, 4096
	mul	ebx
	mov	ecx, eax
	mov	eax, LinearAddrDemo
	shr	eax, 12
	and	eax, 03FFh	; 1111111111b (10 bits)
	mov	ebx, 4
	mul	ebx
	add	eax, ecx ; eax��ֵΪ��Ӧҳ�������������ҳ������ĳ�ʼ��ַ
	add	eax, PageTblBase0 ; eax��ֵΪ��Ӧҳ������������еľ��Ե�ַ
	mov	dword [es:eax], ProcFoo | PG_P | PG_USU | PG_RWW ; �����ַ�仯�Ĺ���û��ô���������������ˣ�

	mov	eax, PageDirBase0
	mov	cr3, eax
	jmp	short .3
.3:
	nop

	ret
PSwitchToOne:
	mov	ax, SelectorFlatRW
	mov	es, ax ; Ŀ��������es����
	mov	eax, LinearAddrDemo ; ��LinearAddrDemoӳ����Bar�����ı����Ե�ַ��Ӧ�������ַ��
	shr	eax, 22
	mov	ebx, 4096
	mul	ebx
	mov	ecx, eax
	mov	eax, LinearAddrDemo
	shr	eax, 12
	and	eax, 03FFh	; 1111111111b (10 bits)
	mov	ebx, 4
	mul	ebx
	add	eax, ecx ; eax��ֵΪ��Ӧҳ�������������ҳ������ĳ�ʼ��ַ
	add	eax, PageTblBase1 ; eax��ֵΪ��Ӧҳ������������еľ��Ե�ַ
	mov	dword [es:eax], ProcBar | PG_P | PG_USU | PG_RWW ; �����ַ�仯�Ĺ���û��ô���������������ˣ�

	mov	eax, PageDirBase1
	mov	cr3, eax
	jmp	short .33
.33:
	nop

	ret
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PagingDemoProc:
OffsetPagingDemoProc	equ	PagingDemoProc - $$
PgDmTag:
	mov	eax, LinearAddrDemo ; LinearAddrDemo��Bar��Foo���
	call	eax
	retf
LenPagingDemoAll	equ	$ - PagingDemoProc
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
foo:
OffsetFoo	equ	foo - $$
FooTag:
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'H'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; ��Ļ�� 17 ��, �� 0 �С�
	mov	al, 'U'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; ��Ļ�� 17 ��, �� 1 �С�
	mov	al, 'S'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; ��Ļ�� 17 ��, �� 2 �С�
	mov	al, 'T'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; ��Ļ�� 17 ��, �� 3 �С�
	jmp FooTag
LenFoo	equ	$ - foo
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bar:
OffsetBar	equ	bar - $$
BarTag:
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'M'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; ��Ļ�� 17 ��, �� 0 �С�
	mov	al, 'R'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; ��Ļ�� 17 ��, �� 1 �С�
	mov	al, 'S'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; ��Ļ�� 17 ��, �� 2 �С�
	mov	al, 'V'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; ��Ļ�� 17 ��, �� 3 �С�	
	jmp BarTag
LenBar	equ	$ - bar
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; ��ʾ�ڴ���Ϣ --------------------------------------------------------------
DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi, MemChkBuf
	mov	ecx, [dwMCRNumber]	;for(int i=0;i<[MCRNumber];i++) // ÿ�εõ�һ��ARDS(Address Range Descriptor Structure)�ṹ
.loop:					;{
	mov	edx, 5			;	for(int j=0;j<5;j++)	// ÿ�εõ�һ��ARDS�еĳ�Ա����5����Ա
	mov	edi, ARDStruct		;	{			// ������ʾ��BaseAddrLow��BaseAddrHigh��LengthLow��LengthHigh��Type
.1:					;
	push	dword [esi]		;
	call	DispInt			;		DispInt(MemChkBuf[j*4]); // ��ʾһ����Ա
	pop	eax			;
	stosd				;		ARDStruct[j*4] = MemChkBuf[j*4];
	add	esi, 4			;
	dec	edx			;
	cmp	edx, 0			;
	jnz	.1			;	}
	call	DispReturn		;	printf("\n");
	cmp	dword [dwType], 1	;	if(Type == AddressRangeMemory) // AddressRangeMemory : 1, AddressRangeReserved : 2
	jne	.2			;	{
	mov	eax, [dwBaseAddrLow]	;
	add	eax, [dwLengthLow]	;
	cmp	eax, [dwMemSize]	;		if(BaseAddrLow + LengthLow > MemSize)
	jb	.2			;
	mov	[dwMemSize], eax	;			MemSize = BaseAddrLow + LengthLow;
.2:					;	}
	loop	.loop			;}
					;
	call	DispReturn		;printf("\n");
	push	szRAMSize		;
	call	DispStr			;printf("RAM size:");
	add	esp, 4			;
					;
	push	dword [dwMemSize]	;
	call	DispInt			;DispInt(MemSize);
	add	esp, 4			;

	pop	ecx
	pop	edi
	pop	esi
	ret
; ---------------------------------------------------------------------------

%include	"lib.inc"	; �⺯��

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; �˴�ΪLDT0
[SECTION .ldt0]
ALIGN	32
LABEL_LDT0:
;                                         �λ�ַ       �ν���     ,   ����
LABEL_LDT0_DESC_CODEA:	Descriptor	       0,     LDT0CodeALen - 1,   DA_C + DA_32 + DA_DPL3	; Code, 32 λ �λ�ַ��ʵģʽ�Ĵ����п������
LABEL_LDT0_DESC_DATA:	Descriptor		   0,	Task0DataLen - 1, DA_DRWA + DA_DPL3
LABEL_DESC_STACK0:	Descriptor	       0,        TopOfStack0, DA_DRWA | DA_32		; Stack, 32 λ
LABEL_DESC_STACK3_0:	Descriptor	       0,         TopOfStack3_0, DA_DRWA + DA_32 + DA_DPL3


LDT0Len		equ	$ - LABEL_LDT0

; LDT0 ѡ����
SelectorLDT0CodeA	equ	LABEL_LDT0_DESC_CODEA	- LABEL_LDT0 + SA_TIL + SA_RPL3 ; SA_TILֵΪ4����������ڶ�λΪ1��ʾʹ�þֲ���������
SelectorTask0Data		equ LABEL_LDT0_DESC_DATA	- LABEL_LDT0 + SA_TIL + SA_RPL3
SelectorStack0		equ LABEL_DESC_STACK0	- LABEL_LDT0 + SA_TIL
SelectorStack3_0		equ	LABEL_DESC_STACK3_0	- LABEL_LDT0 + SA_RPL3
; END of [SECTION .ldt0]

; �˴�ΪLDT0��Ӧ�Ĵ����
[SECTION .la0]
ALIGN	32
[BITS	32]
LABEL_LDT0_CODE_A:
	call	SelectorFlatC:ProcPagingDemo
	jmp $
LDT0CodeALen	equ	$ - LABEL_LDT0_CODE_A
; END of [SECTION .la0]

; �˴�ΪLDT1
[SECTION .ldt1]
ALIGN	32
LABEL_LDT1:
;                                         �λ�ַ       �ν���     ,   ����
LABEL_LDT1_DESC_CODEA:	Descriptor	       0,     LDT1CodeALen - 1,   DA_C + DA_32 + DA_DPL3	; Code, 32 λ �λ�ַ��ʵģʽ�Ĵ����п������
LABEL_LDT1_DESC_DATA:	Descriptor		   0,	Task1DataLen - 1, DA_DRWA + DA_DPL3
LABEL_DESC_STACK1:	Descriptor	       0,        TopOfStack1, DA_DRWA | DA_32		; Stack, 32 λ
LABEL_DESC_STACK3_1:	Descriptor	       0,         TopOfStack3_1, DA_DRWA + DA_32 + DA_DPL3

LDT1Len		equ	$ - LABEL_LDT1

; LDT0 ѡ����
SelectorLDT1CodeA	equ	LABEL_LDT1_DESC_CODEA	- LABEL_LDT1 + SA_TIL + SA_RPL3 ; SA_TILֵΪ4����������ڶ�λΪ1��ʾʹ�þֲ���������
SelectorTask1Data		equ LABEL_LDT1_DESC_DATA	- LABEL_LDT1 + SA_TIL + SA_RPL3
SelectorStack1		equ LABEL_DESC_STACK1	- LABEL_LDT1 + SA_TIL
SelectorStack3_1		equ	LABEL_DESC_STACK3_1	- LABEL_LDT1 + SA_RPL3
; END of [SECTION .ldt1]

; �˴�ΪLDT1��Ӧ�Ĵ����
[SECTION .la1]
ALIGN	32
[BITS	32]
LABEL_LDT1_CODE_A:
	call	SelectorFlatC:ProcPagingDemo
	jmp $
LDT1CodeALen	equ	$ - LABEL_LDT1_CODE_A
; END of [SECTION .la0]
; �޸Ľ���

; 16 λ�����. �� 32 λ���������, ������ʵģʽ
[SECTION .s16code]
ALIGN	32
[BITS	16]
LABEL_SEG_CODE16:
	; ����ʵģʽ:
	mov	ax, SelectorNormal
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	mov	eax, cr0
	and	al, 11111110b
	mov	cr0, eax

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY	; �ε�ַ���ڳ���ʼ�������ó���ȷ��ֵ

Code16Len	equ	$ - LABEL_SEG_CODE16
; END of [SECTION .s16code]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
