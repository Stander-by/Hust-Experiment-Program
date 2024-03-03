; ==========================================
; ����һ
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

ProcPagingDemo	equ	00301000h ; �ڸõ�ַ��д�������ú�������������Ե�ַ�϶�Ӧ�ĺ���

org	0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT
;                                         �λ�ַ,       �ν���     , ����
LABEL_GDT:		Descriptor	       0,                 0, 0				; ��������
LABEL_DESC_NORMAL:	Descriptor	       0,            0ffffh, DA_DRW			; Normal ������
LABEL_DESC_FLAT_C:	Descriptor             0,           0fffffh, DA_CR | DA_32 | DA_LIMIT_4K | DA_DPL3; 0 ~ 4G�����룿����Ҫ���Ǹ�Ϊring3
LABEL_DESC_FLAT_RW:	Descriptor             0,           0fffffh, DA_DRW | DA_LIMIT_4K | DA_DPL3	; 0 ~ 4G����д�ڴ棿
LABEL_DESC_CODE32:	Descriptor	       0,  SegCode32Len - 1, DA_CR | DA_32		; ��һ�´����, 32
LABEL_DESC_CODE16:	Descriptor	       0,            0ffffh, DA_C			; ��һ�´����, 16


;#######################################################################################################################
; ����ring3�����
LABEL_DESC_CODE_RING3_1:	Descriptor	       0, SegCodeRing3_1Len - 1, DA_C + DA_32 + DA_DPL3
LABEL_DESC_CODE_RING3_2:	Descriptor	       0, SegCodeRing3_2Len - 1, DA_C + DA_32 + DA_DPL3

LABEL_DESC_DATA:	Descriptor	       0,	DataLen - 1, DA_DRW			; Data
LABEL_DESC_STACK:	Descriptor	       0,        TopOfStack, DA_DRWA | DA_32		; Stack, 32 λ
LABEL_DESC_STACK3_1:	Descriptor	       0,         TopOfStack3_1, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 λ��ring3��ջ��
LABEL_DESC_STACK3_2:	Descriptor	       0,         TopOfStack3_2, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 λ��ring3��ջ��
LABEL_DESC_VIDEO:	Descriptor	 0B8000h,            0ffffh, DA_DRW | DA_DPL3		; �Դ��׵�ַ

; ����������
LABEL_DESC_CODE_DEST_1:	Descriptor	       0,  SegCodeDestLen_1 - 1, DA_C + DA_32
LABEL_CALL_GATE_TEST_1:	Gate		  SelectorCodeDest_1,          0,      0, DA_386CGate + DA_DPL3
LABEL_DESC_CODE_DEST_2:	Descriptor	       0,  SegCodeDestLen_2 - 1, DA_C + DA_32
LABEL_CALL_GATE_TEST_2:	Gate		  SelectorCodeDest_2,          0,      0, DA_386CGate + DA_DPL3

; TSS
LABEL_DESC_TSS:		Descriptor	       0,          TSSLen - 1, DA_386TSS		; TSS

; GDT ����
;#######################################################################################################################


GdtLen		equ	$ - LABEL_GDT	; GDT����
GdtPtr		dw	GdtLen - 1	; GDT����
		dd	0		; GDT����ַ

; GDT ѡ����
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT + SA_RPL3 
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT + SA_RPL3 
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT


;#######################################################################################################################
; ����ring3����ε�ѡ����
SelectorCodeRing3_1	equ	LABEL_DESC_CODE_RING3_1	- LABEL_GDT + SA_RPL3
SelectorCodeRing3_2	equ	LABEL_DESC_CODE_RING3_2	- LABEL_GDT + SA_RPL3

SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT

SelectorStack3_1		equ	LABEL_DESC_STACK3_1	- LABEL_GDT + SA_RPL3       ;���ѡ������ת������Ķ�ջ��(ring3��)
SelectorStack3_2		equ	LABEL_DESC_STACK3_2	- LABEL_GDT + SA_RPL3       ;���ѡ������ת������Ķ�ջ��(ring3��)

; ���������ѡ����
SelectorCodeDest_1	equ	LABEL_DESC_CODE_DEST_1	- LABEL_GDT
SelectorCallGateTest_1	equ	LABEL_CALL_GATE_TEST_1	- LABEL_GDT + SA_RPL3
SelectorCodeDest_2	equ	LABEL_DESC_CODE_DEST_2	- LABEL_GDT
SelectorCallGateTest_2	equ	LABEL_CALL_GATE_TEST_2	- LABEL_GDT + SA_RPL3
;#######################################################################################################################


; TSS
SelectorTSS		equ	LABEL_DESC_TSS		- LABEL_GDT

SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT + SA_RPL3
; END of [SECTION .gdt]

[SECTION .data1]	 ; ���ݶ�
ALIGN	32
[BITS	32]
LABEL_DATA:
; ʵģʽ��ʹ����Щ����
; �ַ���
_szPMMessage:			db	"this is rang0 protection mode :) ", 0Ah, 0Ah, 0	; ���뱣��ģʽ����ʾ���ַ���
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

_MemChkBuf:	times	256	db	0

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
PageTableNumber		equ	_PageTableNumber- $$

DataLen			equ	$ - LABEL_DATA
; END of [SECTION .data1]


; ȫ�ֶ�ջ��
[SECTION .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 512 db 0

TopOfStack	equ	$ - LABEL_STACK - 1

; END of [SECTION .gs]


;#######################################################################################################################
[SECTION .s3_1]
ALIGN	32          ;align��һ�������ݶ���ĺꡣͨ��align�Ķ�����1��4��8�ȡ������align 32��û������ģ���Ϊ��������ֻ��32b�ĵ�ַ���߿�ȡ�
[BITS	32]         ;32λģʽ�Ļ�������
LABEL_STACK3_1:       ;����LABEL_STACK3
	times 512 db 0
TopOfStack3_1	equ	$ - LABEL_STACK3_1 - 1  ;���ring3����ջ�εĴ�С
; END of [SECTION .s3]            //���ring3����ջ��

[SECTION .s3_2]
ALIGN	32          ;align��һ�������ݶ���ĺꡣͨ��align�Ķ�����1��4��8�ȡ������align 32��û������ģ���Ϊ��������ֻ��32b�ĵ�ַ���߿�ȡ�
[BITS	32]         ;32λģʽ�Ļ�������
LABEL_STACK3_2:       ;����LABEL_STACK3
	times 512 db 0
TopOfStack3_2	equ	$ - LABEL_STACK3_2 - 1  ;���ring3����ջ�εĴ�С
; END of [SECTION .s3]            //���ring3����ջ��
;#######################################################################################################################


[SECTION .tss]          ;��ø��εĴ�С
ALIGN	32              ;align��һ�������ݶ���ĺꡣͨ��align�Ķ�����1��4��8�ȡ������align 32��û������ģ���Ϊ��������ֻ��32b�ĵ�ַ���߿�ȡ�
[BITS	32]             ;32λģʽ�Ļ�������
LABEL_TSS:              ;����LABEL_TSS
		DD	0			; Back
		DD	TopOfStack		; 0 ����ջ   //�ڲ�ring0����ջ����TSS��
		DD	SelectorStack		; 
		DD	0			; 1 ����ջ
		DD	0			; 
		DD	0			; 2 ����ջ
		DD	0			;               //TSS�����ֻ�ܷ���Ring2����ջ��ring3����ջ����Ҫ����
		DD	0			; CR3
		DD	0			; EIP
		DD	0			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	0			; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	0			; CS
		DD	0			; SS
		DD	SelectorData			; DS
		DD	0			; FS
		DD	0			; GS
		DD	0			; LDT
		DW	0			; ���������־
		DW	$ - LABEL_TSS + 2	; I/Oλͼ��ַ
		DB	0ffh			; I/Oλͼ������־
TSSLen		equ	$ - LABEL_TSS   ;��öεĴ�С

[SECTION .s16] ; ����Ӧ���Ǵ����￪ʼִ�е�
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


;#######################################################################################################################
	; ����ring3��ջ�ĳ�ʼ������
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
	add	eax, LABEL_STACK3_2
	mov	word [LABEL_DESC_STACK3_2 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK3_2 + 4], al
	mov	byte [LABEL_DESC_STACK3_2 + 7], ah

	; ��ʼ������Ring3������
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_CODE_RING3_1
	mov	word [LABEL_DESC_CODE_RING3_1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE_RING3_1 + 4], al
	mov	byte [LABEL_DESC_CODE_RING3_1 + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_CODE_RING3_2
	mov	word [LABEL_DESC_CODE_RING3_2 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE_RING3_2 + 4], al
	mov	byte [LABEL_DESC_CODE_RING3_2 + 7], ah

	; �����ų�ʼ��
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE_DEST_1              ;�����ŵĴ����
	mov	word [LABEL_DESC_CODE_DEST_1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE_DEST_1 + 4], al
	mov	byte [LABEL_DESC_CODE_DEST_1 + 7], ah

	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE_DEST_2               ;�����ŵĴ����
	mov	word [LABEL_DESC_CODE_DEST_2 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE_DEST_2 + 4], al
	mov	byte [LABEL_DESC_CODE_DEST_2 + 7], ah

	; TSS
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_TSS
	mov	word [LABEL_DESC_TSS + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_TSS + 4], al
	mov	byte [LABEL_DESC_TSS + 7], ah
;#######################################################################################################################


	; Ϊ���� GDTR ��׼�����˶δ���Ľ�����pmtest1��
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt ����ַ
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt ����ַ

	; ���� GDTR
	lgdt	[GdtPtr]

	; ���ж�
	cli

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

	in	al, 92h		; ��
	and	al, 11111101b	; �� �ر� A20 ��ַ��
	out	92h, al		; ��

	sti			; ���ж�

	mov	ax, 4c00h	; ��
	int	21h		; ���ص� DOS
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


	; ������ʾһ���ַ���
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4

	call	DispMemSize		; ��ʾ�ڴ���Ϣ

	call	PagingDemo		; ��ʾ�ı�ҳĿ¼��Ч���������SetupPaging����

	jmp	SelectorCode16:0 ; ����������LABEL_DESC_CODE16��

; ������ҳ���� --------------------------------------------------------------
SetupPaging:
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

	mov	eax, PageDirBase0
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short .3
.3:
	nop

	ret
; ��ҳ����������� ----------------------------------------------------------


; ���Է�ҳ���� 
PagingDemo: ; ������������13-17�е��ڴ��ַ
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


;#######################################################################################################################
	mov	ax, SelectorTSS         ;ltr ��ring0��ָ�ֻ��������ring0��������С���ring0����Ҫ�ֶ�����tssʵ�ֶ�ջ�л�����call����ϵͳ�Զ�����tss�л���
	ltr	ax

	push	SelectorStack3_1      ;ִ��retfָ��ʱϵͳ�����ѡ����(ring3��)
	push	TopOfStack3_1         ;ִ��retfָ��ʱϵͳ���Զ��ڵ��Ĳ��л���ring3���������ջ
	push	SelectorCodeRing3_1   ;retf ʱ����Ҫ����ѡ���ӵ�rpl�����Ƿ���Ҫ�任��Ȩ��
	push	0                   ;��Ȩת��ʹ��retfʹ��֮ǰ��ѹ��ss��sp��cs��ip ���ڲ�Ring0��ջ  push 0 ��ʾipΪ0.    0Ϊƫ����
	retf
	; �޸Ľ���

LABEL_DESC1:
	call	PSwitch			; �л�ҳĿ¼���ı��ַӳ���ϵ

	push	SelectorStack3_2      ;ִ��retfָ��ʱϵͳ�����ѡ����(ring3��)
	push	TopOfStack3_2         ;ִ��retfָ��ʱϵͳ���Զ��ڵ��Ĳ��л���ring3���������ջ
	push	SelectorCodeRing3_2   ;retf ʱ����Ҫ����ѡ���ӵ�rpl�����Ƿ���Ҫ�任��Ȩ��
	push	0                   ;��Ȩת��ʹ��retfʹ��֮ǰ��ѹ��ss��sp��cs��ip ���ڲ�Ring0��ջ  push 0 ��ʾipΪ0.    0Ϊƫ����
	retf
LABEL_DESC2:
	ret
;#######################################################################################################################



; PagingDemoProc ------------------------------------------------------------
PagingDemoProc:
OffsetPagingDemoProc	equ	PagingDemoProc - $$
	mov	eax, LinearAddrDemo ; LinearAddrDemo��ProcFoo���
	call	eax
	retf
; ---------------------------------------------------------------------------
LenPagingDemoAll	equ	$ - PagingDemoProc
; ---------------------------------------------------------------------------


;#######################################################################################################################
; foo 
foo:
OffsetFoo	equ	foo - $$
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'P'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; ��Ļ�� 17 ��, �� 0 �С�
	mov	al, 'A'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; ��Ļ�� 17 ��, �� 1 �С�
	ret
LenFoo	equ	$ - foo

; bar 
bar:
OffsetBar	equ	bar - $$
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'P'
	mov	[gs:((80 * 18 + 0) * 2)], ax	; ��Ļ�� 18 ��, �� 0 �С�
	mov	al, 'B'
	mov	[gs:((80 * 18 + 1) * 2)], ax	; ��Ļ�� 18 ��, �� 1 �С�
	ret
LenBar	equ	$ - bar
;#######################################################################################################################


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


;#######################################################################################################################
; ����Ŀ������
[SECTION .sdest1]; ������Ŀ��Σ�[SECTION .sdest]���Ƿ�һ��32λ�Σ�����DPL=0�����ҵ�ǰCPL=0�����˺��õ��ġ�DPL���͡�ѡ�����е�RPL����Ϊ0�����������Ȩ������ת������Ҫ���Ȩ�޼����
[BITS	32]
LABEL_SEG_CODE_DEST_1:    ;ring0�������
	mov	ax, SelectorVideo
	mov	gs, ax			; ��Ƶ��ѡ����(Ŀ��)

	mov	edi, (80 * 8 + 0) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, '0'
	mov	[gs:edi], ax    

	call	PSwitch			; �л�ҳĿ¼���ı��ַӳ���ϵ  

	push	SelectorStack3_2      ;ִ��retfָ��ʱϵͳ�����ѡ����(ring3��)
	push	TopOfStack3_2         ;ִ��retfָ��ʱϵͳ���Զ��ڵ��Ĳ��л���ring3���������ջ
	push	SelectorCodeRing3_2   ;retf ʱ����Ҫ����ѡ���ӵ�rpl�����Ƿ���Ҫ�任��Ȩ��
	push	0                   ;��Ȩת��ʹ��retfʹ��֮ǰ��ѹ��ss��sp��cs��ip ���ڲ�Ring0��ջ  push 0 ��ʾipΪ0.    0Ϊƫ����
	retf

PSwitch:
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov ax, SelectorData
	mov ds, ax
	mov	edi, PageDirBase1	; �˶��׵�ַΪ PageDirBase1
	xor	eax, eax
	mov	eax, PageTblBase1 | PG_P  | PG_USU | PG_RWW
	mov	ecx, [ds:PageTableNumber]
	
.1:
	stosd
	add	eax, 4096		; Ϊ�˼�, ����ҳ�����ڴ�����������.
	loop	.1

	; �ٳ�ʼ������ҳ��
	mov	eax, [ds:PageTableNumber]	; ҳ�����
	mov	ebx, 1024		; ÿ��ҳ�� 1024 �� PTE
	mul	ebx
	mov	ecx, eax		; PTE���� = ҳ����� * 1024
	mov	edi, PageTblBase1	; �˶��׵�ַΪ PageTblBase1
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; ÿһҳָ�� 4K �Ŀռ�
	loop	.2

	; �ڴ˼����ڴ��Ǵ��� 8M ��
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
	jmp	short .3
.3:
	nop

	
	ret

SegCodeDestLen_1	equ	$ - LABEL_SEG_CODE_DEST_1   ;���������Ŀ��εĴ�С
;#######################################################################################################################


;#######################################################################################################################
[SECTION .sdest2]; ������Ŀ��Σ�[SECTION .sdest]���Ƿ�һ��32λ�Σ�����DPL=0�����ҵ�ǰCPL=0�����˺��õ��ġ�DPL���͡�ѡ�����е�RPL����Ϊ0�����������Ȩ������ת������Ҫ���Ȩ�޼����
[BITS	32]

LABEL_SEG_CODE_DEST_2:    ;ring0�������
	mov	ax, SelectorVideo
	mov	gs, ax			; ��Ƶ��ѡ����(Ŀ��)

	mov	edi, (80 * 10 + 0) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, '0'
	mov	[gs:edi], ax    
	
	jmp	SelectorCode16:0

SegCodeDestLen_2	equ	$ - LABEL_SEG_CODE_DEST_2   ;���������Ŀ��εĴ�С
;#######################################################################################################################


;#######################################################################################################################
; ��һ��ring3�����
[SECTION .ring3_1]
LABEL_CODE_RING3_1:
	mov	ax, SelectorVideo
	mov	gs, ax			; ��Ƶ��ѡ����(Ŀ��)

	mov	edi, (80 * 7 + 0) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, '3'
	mov	[gs:edi], ax    
	mov	edi, (80 * 7 + 2) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'P'
	mov	[gs:edi], ax 
	mov	edi, (80 * 7 + 3) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'A'
	mov	[gs:edi], ax    

	call	SelectorFlatC:ProcPagingDemo
	call	SelectorCallGateTest_1:0
	jmp $
SegCodeRing3_1Len	equ $ - LABEL_CODE_RING3_1

[SECTION .ring3_2]
LABEL_CODE_RING3_2:
	mov	edi, (80 * 9 + 0) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, '3'
	mov	[gs:edi], ax    
	mov	edi, (80 * 9 + 2) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'P'
	mov	[gs:edi], ax 
	mov	edi, (80 * 9 + 3) * 2	
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'B'
	mov	[gs:edi], ax     

	call	SelectorFlatC:ProcPagingDemo
	call	SelectorCallGateTest_2:0
	jmp $
SegCodeRing3_2Len	equ $ - LABEL_CODE_RING3_2
;#######################################################################################################################


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
