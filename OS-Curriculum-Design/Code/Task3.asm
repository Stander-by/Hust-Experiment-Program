; ==========================================
; 任务三
; 任务描述：两个任务A和B均为死循环且轮流切换
; 网安2004班-熊睿-U202011107
; ==========================================

%include	"pm.inc"	; 常量, 宏, 以及一些说明

PageDirBase0		equ	200000h	; 页目录开始地址:	2M
PageTblBase0		equ	201000h	; 页表开始地址:		2M +  4K
PageDirBase1		equ	210000h	; 页目录开始地址:	2M + 64K
PageTblBase1		equ	211000h	; 页表开始地址:		2M + 64K + 4K

LinearAddrDemo	equ	00401000h ; 以下四个变量需重点关注
ProcFoo		equ	00401000h ; 指定物理地址，需确保当前的段为flat段，自己编写的函数需要放置在这两个地址中
ProcBar		equ	00501000h

ProcPagingDemo	equ	00301000h

org	0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT
;                                         段基址,       段界限     , 属性
LABEL_GDT:		Descriptor	       0,                 0, 0				; 空描述符
LABEL_DESC_NORMAL:	Descriptor	       0,            0ffffh, DA_DRW			; Normal 描述符
LABEL_DESC_FLAT_C:	Descriptor             0,           0fffffh, DA_CR | DA_32 | DA_LIMIT_4K | DA_DPL3; 0 ~ 4G，代码？
LABEL_DESC_FLAT_RW:	Descriptor             0,           0fffffh, DA_DRW | DA_LIMIT_4K | DA_DPL3	; 0 ~ 4G，读写内存？
LABEL_DESC_CODE32:	Descriptor	       0,  SegCode32Len - 1, DA_CR | DA_32		; 非一致代码段, 32
LABEL_DESC_CODE16:	Descriptor	       0,            0ffffh, DA_C			; 非一致代码段, 16
LABEL_DESC_DATA:	Descriptor	       0,	DataLen - 1, DA_DRW			; Data
LABEL_DESC_STACK:	Descriptor	       0,        TopOfStack, DA_DRWA | DA_32		; Stack, 32 位
LABEL_DESC_VIDEO:	Descriptor	 0B8000h,            0ffffh, DA_DRW	| DA_DPL3		; 显存首地址


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 添加两个代码段的LDT，先加段再加描述符最后加选择子
LABEL_DESC_LDT0:		Descriptor	       0,        LDT0Len - 1, DA_LDT		; LDT段描述符
LABEL_DESC_LDT1:		Descriptor	       0,        LDT1Len - 1, DA_LDT		; LDT段描述符

; 两个任务的TSS
LABEL_DESC_TSS0:	Descriptor	       0,          TSS0Len - 1, DA_386TSS		; TSS
LABEL_DESC_TSS1:	Descriptor	       0,          TSS1Len - 1, DA_386TSS		; TSS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	

; GDT 结束

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		dd	0		; GDT基地址

; GDT 选择子
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT
SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT + SA_RPL3


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 添加两个LDT的选择子
SelectorLDT0		equ LABEL_DESC_LDT0 	- LABEL_GDT
SelectorLDT1		equ LABEL_DESC_LDT1		- LABEL_GDT
; 两个任务堆栈与TSS的选择子
SelectorTSS0		equ LABEL_DESC_TSS0		- LABEL_GDT
SelectorTSS1		equ LABEL_DESC_TSS1		- LABEL_GDT
; END of [SECTION .gdt]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


[SECTION .data1]	 ; 数据段
ALIGN	32
[BITS	32]
LABEL_DATA:
; 实模式下使用这些符号
; 字符串
_szPMMessage:			db	"this is rang0 protection mode :)", 0Ah, 0Ah, 0	; 进入保护模式后显示此字符串
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0
; 变量
_wSPValueInRealMode		dw	0
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列。
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0
_PageTableNumber		dd	0
_SavedIDTR:			dd	0	; 用于保存 IDTR
				dd	0
_SavedIMREG:			db	0	; 中断屏蔽寄存器值
_MemChkBuf:	times	256	db	0


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_szCurTask				dd  0   ;提供选择
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; 保护模式下使用这些符号
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
; 门                                目标选择子,            偏移, DCount, 属性
%rep 32
			Gate	SelectorCode32, SpuriousHandler,      0, DA_386IGate
%endrep
.020h:			Gate	SelectorCode32,    ClockHandler,      0, DA_386IGate
%rep 95
			Gate	SelectorCode32, SpuriousHandler,      0, DA_386IGate
%endrep
.080h:			Gate	SelectorCode32,  UserIntHandler,      0, DA_386IGate

IdtLen		equ	$ - LABEL_IDT
IdtPtr		dw	IdtLen - 1	; 段界限
		dd	0		; 基地址
; END of [SECTION .idt]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 两个任务的内核栈
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

; 两个任务的用户栈
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

; 两个任务的TSS
[SECTION .tss0]          ;求得各段的大小
ALIGN	32              ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]             ;32位模式的机器运行
LABEL_TSS0:              ;定义LABEL_TSS
		DD	0			; Back
		DD	TopOfStack0		; 0 级堆栈   模仿之前的样例代码
		DD	SelectorStack0		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			;               TSS中最高只能放入Ring2级堆栈，ring3级堆栈不需要放入
		DD	PageDirBase0			; CR3
		DD	0			; EIP
		DD	0x200			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	TopOfStack3_0			; ESP 之前理解有误，把用户栈和内核栈混在一起了，也没有区分ring0和ring3
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
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS0 + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSS0Len		equ	$ - LABEL_TSS0   ;求得段的大小

[SECTION .tss1]          ;求得各段的大小
ALIGN	32              ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]             ;32位模式的机器运行
LABEL_TSS1:              ;定义LABEL_TSS
		DD	0			; Back
		DD	TopOfStack1		; 0 级堆栈   //内层ring0级堆栈放入TSS中
		DD	SelectorStack1		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			;               //TSS中最高只能放入Ring2级堆栈，ring3级堆栈不需要放入
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
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS1 + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSS1Len		equ	$ - LABEL_TSS1   ;求得段的大小
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 添加两个任务的数据段
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


; 全局堆栈段
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

	; 得到内存数，这段代码的解释在pmtest7中
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

	; 初始化 16 位代码段描述符
	mov	ax, cs
	movzx	eax, ax
	shl	eax, 4
	add	eax, LABEL_SEG_CODE16
	mov	word [LABEL_DESC_CODE16 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE16 + 4], al
	mov	byte [LABEL_DESC_CODE16 + 7], ah

	; 初始化 32 位代码段描述符
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; 初始化数据段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; 初始化堆栈段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; 初始化LDT0在GDT中的描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT0
	mov	word [LABEL_DESC_LDT0 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT0 + 4], al
	mov	byte [LABEL_DESC_LDT0 + 7], ah

	; 初始化LDT1在GDT中的描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT1
	mov	word [LABEL_DESC_LDT1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT1 + 4], al
	mov	byte [LABEL_DESC_LDT1 + 7], ah

	; 初始化LDT0中的描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT0_CODE_A
	mov	word [LABEL_LDT0_DESC_CODEA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT0_DESC_CODEA + 4], al
	mov	byte [LABEL_LDT0_DESC_CODEA + 7], ah

	; 初始化LDT1中的描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT1_CODE_A
	mov	word [LABEL_LDT1_DESC_CODEA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT1_DESC_CODEA + 4], al
	mov	byte [LABEL_LDT1_DESC_CODEA + 7], ah

	; 还需初始化Stack与TSS的描述符
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

	; 还需初始化两个任务数据段的描述符
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


	; 为加载 GDTR 作准备，此段代码的解释在pmtest1中
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; 准备加载 IDTR 
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_IDT		; eax <- idt 基地址
	mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt 基地址

	; 保存 IDTR
	sidt	[_SavedIDTR]

	; 保存中断屏蔽寄存器
	in	al, 21h
	mov	[_SavedIMREG], al
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; 加载 GDTR
	lgdt	[GdtPtr]

	; 关中断
	cli


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; 加载 IDTR
	lidt	[IdtPtr]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式，代码解释在pmtest1中
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 执行这一句会把 SelectorCode32 装入 cs, 并跳转到 Code32Selector:0  处

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:		; 从保护模式跳回到实模式就到了这里
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	sp, [_wSPValueInRealMode] ; 由于在实模式所以使用实模式的标志

	; 修改开始
	lidt	[_SavedIDTR]	; 恢复 IDTR 的原值

	mov	al, [_SavedIMREG]	; ┓恢复中断屏蔽寄存器(IMREG)的原值
	out	21h, al			    ; ┛
	; 修改结束

	in	al, 92h		    ; ┓
	and	al, 11111101b	; ┣ 关闭 A20 地址线
	out	92h, al		    ; ┛

	sti			; 开中断

	mov	ax, 4c00h	; ┓
	int	21h		    ; ┛回到 DOS
; END of [SECTION .s16]


[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS	32]

LABEL_SEG_CODE32:
	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	es, ax
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子

	mov	ax, SelectorStack
	mov	ss, ax			; 堆栈段选择子

	mov	esp, TopOfStack


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	call	Init8259A ; 286-289为启动中断并触发080H号中断
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; 下面显示一个字符串
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4

	call	DispMemSize		; 显示内存信息

	call PagingDemo ; 仅调用了SetupPaging


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	sti ; 避免中断屏蔽

	mov		ax, SelectorTSS0	; ┳ 加载 TSS
	ltr		ax					; ┛

	mov		ax, SelectorLDT0	; ┳ 加载 LDT
	lldt	ax					; ┛

	mov	eax, PageDirBase0
	mov	cr3, eax   ; 保存当前页目录
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax  ; 
	jmp	short .5
.5:
	nop

	; 使用iretd指令切换至任务0
	push SelectorStack3_0 ; SS  目标：rang3栈
	push TopOfStack3_0	; ESP 改为压入ring3的用户栈
	pushfd				; 压入EFLAGS（标志寄存器）
	pop eax
	or eax, 0x200		; IF位置1，开启中断
	push eax
	push SelectorLDT0CodeA ; CS
	push 0				; EIP

	iretd ; 返回到SelectorLDT0CodeA

	call	SetRealmode8259A ; 恢复8259A以返回实模式
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	; 到此停止
	jmp	SelectorCode16:0 ; 结束后跳至LABEL_DESC_CODE16处

; Init8259A ---------------------------------------------------------------------------------------------
Init8259A:
	mov	al, 011h
	out	020h, al	; 主8259, ICW1.
	call	io_delay

	out	0A0h, al	; 从8259, ICW1.
	call	io_delay

	mov	al, 020h	; IRQ0 对应中断向量 0x20
	out	021h, al	; 主8259, ICW2.
	call	io_delay

	mov	al, 028h	; IRQ8 对应中断向量 0x28
	out	0A1h, al	; 从8259, ICW2.
	call	io_delay

	mov	al, 004h	; IR2 对应从8259
	out	021h, al	; 主8259, ICW3.
	call	io_delay

	mov	al, 002h	; 对应主8259的 IR2
	out	0A1h, al	; 从8259, ICW3.
	call	io_delay

	mov	al, 001h
	out	021h, al	; 主8259, ICW4.
	call	io_delay

	out	0A1h, al	; 从8259, ICW4.
	call	io_delay

	mov	al, 11111110b	; 仅仅开启定时器中断，定时器中断的对应的位置为0
	;mov	al, 11111111b	; 屏蔽主8259所有中断
	out	021h, al	; 主8259, OCW1.
	call	io_delay ; 该函数的内容是几个nop指令，即跳过几个时钟周期

	mov	al, 11111111b	; 屏蔽从8259所有中断
	out	0A1h, al	; 从8259, OCW1.
	call	io_delay

	ret
; Init8259A ---------------------------------------------------------------------------------------------


; SetRealmode8259A ---------------------------------------------------------------------------------------------
SetRealmode8259A:
	mov	ax, SelectorData
	mov	fs, ax

	mov	al, 017h
	out	020h, al	; 主8259, ICW1.
	call	io_delay

	mov	al, 008h	; IRQ0 对应中断向量 0x8
	out	021h, al	; 主8259, ICW2.
	call	io_delay

	mov	al, 001h
	out	021h, al	; 主8259, ICW4.
	call	io_delay

	mov	al, [fs:SavedIMREG]	; ┓恢复中断屏蔽寄存器(IMREG)的原值
	out	021h, al		; ┛
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
_ClockHandler: ; 时间中断处理程序，需要修改成切换任务的函数
ClockHandler	equ	_ClockHandler - $$

	push ds
	push eax

	inc	byte [gs:((80 * 0 + 70) * 2)]	; 屏幕第 0 行, 第 70 列。
	mov		eax, SelectorData			; ┳ 设置 DS 以读取 dwCurrentTask
	mov		ds, ax

	mov	al, 20h
	out	20h, al				; 发送 EOI 


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cmp dword [CurTask], 0
	je ll1
	mov dword [CurTask], 0
	
	call PSwitchToZero

	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, '1'
	mov	[gs:((80 * 0 + 61) * 2)], ax

	jmp SelectorTSS0:0
	;call SelectorFlatC:ProcPagingDemo ; 此处不可直接调用对应函数，否则陷入死循环，无法发送EOI
	jmp ll2
	
ll1:
	mov dword [CurTask], 1
	call PSwitchToOne

	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, '0'
	mov	[gs:((80 * 0 + 60) * 2)], ax

	jmp SelectorTSS1:0

ll2:
	pop eax
	pop ds
	iretd

_UserIntHandler:
UserIntHandler	equ	_UserIntHandler - $$
	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, 'I'
	mov	[gs:((80 * 0 + 70) * 2)], ax	; 屏幕第 0 行, 第 70 列。
	iretd

_SpuriousHandler:
SpuriousHandler	equ	_SpuriousHandler - $$
	mov	ah, 0Ch				; 0000: 黑底    1100: 红字
	mov	al, '!'
	mov	[gs:((80 * 0 + 75) * 2)], ax	; 屏幕第 0 行, 第 75 列。
	jmp	$
	iretd
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; 启动分页机制 --------------------------------------------------------------
SetupPaging: ; 此处已经将所有页表初始化，无需在切换页表时重新初始化
	; 根据内存大小计算应初始化多少PDE以及多少页表
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, 一个页表对应的内存大小
	div	ebx
	mov	ecx, eax	; 此时 ecx 为页表的个数，也即 PDE 应该的个数
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; 如果余数不为 0 就需增加一个页表
.no_remainder:
	mov	[PageTableNumber], ecx	; 暂存页表个数

	; 为简化处理, 所有线性地址对应相等的物理地址. 并且不考虑内存空洞.

	; 首先初始化页目录
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase0	; 此段首地址为 PageDirBase0
	xor	eax, eax
	mov	eax, PageTblBase0 | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	mov	eax, [PageTableNumber]	; 页表个数，与7的区别在于7没有在一开始规定页表的个数，而是通过实际内存的大小使页表的个数最大化
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase0	; 此段首地址为 PageTblBase0
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; 初始化页目录
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase1	; 此段首地址为 PageDirBase1
	xor	eax, eax
	mov	eax, PageTblBase1 | PG_P  | PG_USU | PG_RWW
	mov	ecx, [PageTableNumber]
.3:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.3

	; 再初始化所有页表
	mov	eax, [PageTableNumber]	; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase1	; 此段首地址为 PageTblBase1
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.4:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.4
	ret
; 分页机制启动完毕
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 将代码填充进第13-17行的内存地址 
PagingDemo: 
	mov	ax, cs
	mov	ds, ax ; 源数据在ds段中
	mov	ax, SelectorFlatRW
	mov	es, ax ; 目的数据在es段中

	push	LenFoo
	push	OffsetFoo
	push	ProcFoo
	call	MemCpy ; memcpy(ProcFoo, OffsetFoo, LenFoo); 此处memcpy假设源数据在ds段中，目的数据在es段中
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
	mov	ds, ax			; 数据段选择子
	mov	es, ax

	call	SetupPaging		; 启动分页

	ret
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PSwitchToZero:
	mov	ax, SelectorFlatRW
	mov	es, ax ; 目的数据在es段中
	mov	eax, LinearAddrDemo ; 将LinearAddrDemo映射至Bar处（改变线性地址对应的物理地址）
	shr	eax, 22
	mov	ebx, 4096
	mul	ebx
	mov	ecx, eax
	mov	eax, LinearAddrDemo
	shr	eax, 12
	and	eax, 03FFh	; 1111111111b (10 bits)
	mov	ebx, 4
	mul	ebx
	add	eax, ecx ; eax的值为对应页表项相对于整个页表区域的初始地址
	add	eax, PageTblBase0 ; eax的值为对应页表项在这个段中的绝对地址
	mov	dword [es:eax], ProcFoo | PG_P | PG_USU | PG_RWW ; 这里地址变化的过程没怎么看懂（后来看懂了）

	mov	eax, PageDirBase0
	mov	cr3, eax
	jmp	short .3
.3:
	nop

	ret
PSwitchToOne:
	mov	ax, SelectorFlatRW
	mov	es, ax ; 目的数据在es段中
	mov	eax, LinearAddrDemo ; 将LinearAddrDemo映射至Bar处（改变线性地址对应的物理地址）
	shr	eax, 22
	mov	ebx, 4096
	mul	ebx
	mov	ecx, eax
	mov	eax, LinearAddrDemo
	shr	eax, 12
	and	eax, 03FFh	; 1111111111b (10 bits)
	mov	ebx, 4
	mul	ebx
	add	eax, ecx ; eax的值为对应页表项相对于整个页表区域的初始地址
	add	eax, PageTblBase1 ; eax的值为对应页表项在这个段中的绝对地址
	mov	dword [es:eax], ProcBar | PG_P | PG_USU | PG_RWW ; 这里地址变化的过程没怎么看懂（后来看懂了）

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
	mov	eax, LinearAddrDemo ; LinearAddrDemo与Bar，Foo相等
	call	eax
	retf
LenPagingDemoAll	equ	$ - PagingDemoProc
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
foo:
OffsetFoo	equ	foo - $$
FooTag:
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'H'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; 屏幕第 17 行, 第 0 列。
	mov	al, 'U'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; 屏幕第 17 行, 第 1 列。
	mov	al, 'S'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; 屏幕第 17 行, 第 2 列。
	mov	al, 'T'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; 屏幕第 17 行, 第 3 列。
	jmp FooTag
LenFoo	equ	$ - foo
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bar:
OffsetBar	equ	bar - $$
BarTag:
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'M'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; 屏幕第 17 行, 第 0 列。
	mov	al, 'R'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; 屏幕第 17 行, 第 1 列。
	mov	al, 'S'
	mov	[gs:((80 * 17 + 2) * 2)], ax	; 屏幕第 17 行, 第 2 列。
	mov	al, 'V'
	mov	[gs:((80 * 17 + 3) * 2)], ax	; 屏幕第 17 行, 第 3 列。	
	jmp BarTag
LenBar	equ	$ - bar
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


; 显示内存信息 --------------------------------------------------------------
DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi, MemChkBuf
	mov	ecx, [dwMCRNumber]	;for(int i=0;i<[MCRNumber];i++) // 每次得到一个ARDS(Address Range Descriptor Structure)结构
.loop:					;{
	mov	edx, 5			;	for(int j=0;j<5;j++)	// 每次得到一个ARDS中的成员，共5个成员
	mov	edi, ARDStruct		;	{			// 依次显示：BaseAddrLow，BaseAddrHigh，LengthLow，LengthHigh，Type
.1:					;
	push	dword [esi]		;
	call	DispInt			;		DispInt(MemChkBuf[j*4]); // 显示一个成员
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

%include	"lib.inc"	; 库函数

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 此处为LDT0
[SECTION .ldt0]
ALIGN	32
LABEL_LDT0:
;                                         段基址       段界限     ,   属性
LABEL_LDT0_DESC_CODEA:	Descriptor	       0,     LDT0CodeALen - 1,   DA_C + DA_32 + DA_DPL3	; Code, 32 位 段基址在实模式的代码中可以填充
LABEL_LDT0_DESC_DATA:	Descriptor		   0,	Task0DataLen - 1, DA_DRWA + DA_DPL3
LABEL_DESC_STACK0:	Descriptor	       0,        TopOfStack0, DA_DRWA | DA_32		; Stack, 32 位
LABEL_DESC_STACK3_0:	Descriptor	       0,         TopOfStack3_0, DA_DRWA + DA_32 + DA_DPL3


LDT0Len		equ	$ - LABEL_LDT0

; LDT0 选择子
SelectorLDT0CodeA	equ	LABEL_LDT0_DESC_CODEA	- LABEL_LDT0 + SA_TIL + SA_RPL3 ; SA_TIL值为4，从右至左第二位为1表示使用局部描述符表
SelectorTask0Data		equ LABEL_LDT0_DESC_DATA	- LABEL_LDT0 + SA_TIL + SA_RPL3
SelectorStack0		equ LABEL_DESC_STACK0	- LABEL_LDT0 + SA_TIL
SelectorStack3_0		equ	LABEL_DESC_STACK3_0	- LABEL_LDT0 + SA_RPL3
; END of [SECTION .ldt0]

; 此处为LDT0对应的代码段
[SECTION .la0]
ALIGN	32
[BITS	32]
LABEL_LDT0_CODE_A:
	call	SelectorFlatC:ProcPagingDemo
	jmp $
LDT0CodeALen	equ	$ - LABEL_LDT0_CODE_A
; END of [SECTION .la0]

; 此处为LDT1
[SECTION .ldt1]
ALIGN	32
LABEL_LDT1:
;                                         段基址       段界限     ,   属性
LABEL_LDT1_DESC_CODEA:	Descriptor	       0,     LDT1CodeALen - 1,   DA_C + DA_32 + DA_DPL3	; Code, 32 位 段基址在实模式的代码中可以填充
LABEL_LDT1_DESC_DATA:	Descriptor		   0,	Task1DataLen - 1, DA_DRWA + DA_DPL3
LABEL_DESC_STACK1:	Descriptor	       0,        TopOfStack1, DA_DRWA | DA_32		; Stack, 32 位
LABEL_DESC_STACK3_1:	Descriptor	       0,         TopOfStack3_1, DA_DRWA + DA_32 + DA_DPL3

LDT1Len		equ	$ - LABEL_LDT1

; LDT0 选择子
SelectorLDT1CodeA	equ	LABEL_LDT1_DESC_CODEA	- LABEL_LDT1 + SA_TIL + SA_RPL3 ; SA_TIL值为4，从右至左第二位为1表示使用局部描述符表
SelectorTask1Data		equ LABEL_LDT1_DESC_DATA	- LABEL_LDT1 + SA_TIL + SA_RPL3
SelectorStack1		equ LABEL_DESC_STACK1	- LABEL_LDT1 + SA_TIL
SelectorStack3_1		equ	LABEL_DESC_STACK3_1	- LABEL_LDT1 + SA_RPL3
; END of [SECTION .ldt1]

; 此处为LDT1对应的代码段
[SECTION .la1]
ALIGN	32
[BITS	32]
LABEL_LDT1_CODE_A:
	call	SelectorFlatC:ProcPagingDemo
	jmp $
LDT1CodeALen	equ	$ - LABEL_LDT1_CODE_A
; END of [SECTION .la0]
; 修改结束

; 16 位代码段. 由 32 位代码段跳入, 跳出后到实模式
[SECTION .s16code]
ALIGN	32
[BITS	16]
LABEL_SEG_CODE16:
	; 跳回实模式:
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
	jmp	0:LABEL_REAL_ENTRY	; 段地址会在程序开始处被设置成正确的值

Code16Len	equ	$ - LABEL_SEG_CODE16
; END of [SECTION .s16code]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
