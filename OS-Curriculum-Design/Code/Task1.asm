; ==========================================
; 任务一
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

ProcPagingDemo	equ	00301000h ; 在该地址上写函数，该函数负责调用线性地址上对应的函数

org	0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT
;                                         段基址,       段界限     , 属性
LABEL_GDT:		Descriptor	       0,                 0, 0				; 空描述符
LABEL_DESC_NORMAL:	Descriptor	       0,            0ffffh, DA_DRW			; Normal 描述符
LABEL_DESC_FLAT_C:	Descriptor             0,           0fffffh, DA_CR | DA_32 | DA_LIMIT_4K | DA_DPL3; 0 ~ 4G，代码？可能要考虑改为ring3
LABEL_DESC_FLAT_RW:	Descriptor             0,           0fffffh, DA_DRW | DA_LIMIT_4K | DA_DPL3	; 0 ~ 4G，读写内存？
LABEL_DESC_CODE32:	Descriptor	       0,  SegCode32Len - 1, DA_CR | DA_32		; 非一致代码段, 32
LABEL_DESC_CODE16:	Descriptor	       0,            0ffffh, DA_C			; 非一致代码段, 16


;#######################################################################################################################
; 两个ring3代码段
LABEL_DESC_CODE_RING3_1:	Descriptor	       0, SegCodeRing3_1Len - 1, DA_C + DA_32 + DA_DPL3
LABEL_DESC_CODE_RING3_2:	Descriptor	       0, SegCodeRing3_2Len - 1, DA_C + DA_32 + DA_DPL3

LABEL_DESC_DATA:	Descriptor	       0,	DataLen - 1, DA_DRW			; Data
LABEL_DESC_STACK:	Descriptor	       0,        TopOfStack, DA_DRWA | DA_32		; Stack, 32 位
LABEL_DESC_STACK3_1:	Descriptor	       0,         TopOfStack3_1, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 位，ring3堆栈段
LABEL_DESC_STACK3_2:	Descriptor	       0,         TopOfStack3_2, DA_DRWA + DA_32 + DA_DPL3; Stack, 32 位，ring3堆栈段
LABEL_DESC_VIDEO:	Descriptor	 0B8000h,            0ffffh, DA_DRW | DA_DPL3		; 显存首地址

; 两个调用门
LABEL_DESC_CODE_DEST_1:	Descriptor	       0,  SegCodeDestLen_1 - 1, DA_C + DA_32
LABEL_CALL_GATE_TEST_1:	Gate		  SelectorCodeDest_1,          0,      0, DA_386CGate + DA_DPL3
LABEL_DESC_CODE_DEST_2:	Descriptor	       0,  SegCodeDestLen_2 - 1, DA_C + DA_32
LABEL_CALL_GATE_TEST_2:	Gate		  SelectorCodeDest_2,          0,      0, DA_386CGate + DA_DPL3

; TSS
LABEL_DESC_TSS:		Descriptor	       0,          TSSLen - 1, DA_386TSS		; TSS

; GDT 结束
;#######################################################################################################################


GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		dd	0		; GDT基地址

; GDT 选择子
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT + SA_RPL3 
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT + SA_RPL3 
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT


;#######################################################################################################################
; 两个ring3代码段的选择子
SelectorCodeRing3_1	equ	LABEL_DESC_CODE_RING3_1	- LABEL_GDT + SA_RPL3
SelectorCodeRing3_2	equ	LABEL_DESC_CODE_RING3_2	- LABEL_GDT + SA_RPL3

SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT

SelectorStack3_1		equ	LABEL_DESC_STACK3_1	- LABEL_GDT + SA_RPL3       ;这个选择子跳转到下面的堆栈段(ring3级)
SelectorStack3_2		equ	LABEL_DESC_STACK3_2	- LABEL_GDT + SA_RPL3       ;这个选择子跳转到下面的堆栈段(ring3级)

; 调用门相关选择子
SelectorCodeDest_1	equ	LABEL_DESC_CODE_DEST_1	- LABEL_GDT
SelectorCallGateTest_1	equ	LABEL_CALL_GATE_TEST_1	- LABEL_GDT + SA_RPL3
SelectorCodeDest_2	equ	LABEL_DESC_CODE_DEST_2	- LABEL_GDT
SelectorCallGateTest_2	equ	LABEL_CALL_GATE_TEST_2	- LABEL_GDT + SA_RPL3
;#######################################################################################################################


; TSS
SelectorTSS		equ	LABEL_DESC_TSS		- LABEL_GDT

SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT + SA_RPL3
; END of [SECTION .gdt]

[SECTION .data1]	 ; 数据段
ALIGN	32
[BITS	32]
LABEL_DATA:
; 实模式下使用这些符号
; 字符串
_szPMMessage:			db	"this is rang0 protection mode :) ", 0Ah, 0Ah, 0	; 进入保护模式后显示此字符串
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

_MemChkBuf:	times	256	db	0

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
PageTableNumber		equ	_PageTableNumber- $$

DataLen			equ	$ - LABEL_DATA
; END of [SECTION .data1]


; 全局堆栈段
[SECTION .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times 512 db 0

TopOfStack	equ	$ - LABEL_STACK - 1

; END of [SECTION .gs]


;#######################################################################################################################
[SECTION .s3_1]
ALIGN	32          ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]         ;32位模式的机器运行
LABEL_STACK3_1:       ;定义LABEL_STACK3
	times 512 db 0
TopOfStack3_1	equ	$ - LABEL_STACK3_1 - 1  ;外层ring3级堆栈段的大小
; END of [SECTION .s3]            //外层ring3级堆栈段

[SECTION .s3_2]
ALIGN	32          ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]         ;32位模式的机器运行
LABEL_STACK3_2:       ;定义LABEL_STACK3
	times 512 db 0
TopOfStack3_2	equ	$ - LABEL_STACK3_2 - 1  ;外层ring3级堆栈段的大小
; END of [SECTION .s3]            //外层ring3级堆栈段
;#######################################################################################################################


[SECTION .tss]          ;求得各段的大小
ALIGN	32              ;align是一个让数据对齐的宏。通常align的对象是1、4、8等。这里的align 32是没有意义的，因为本来就是只有32b的地址总线宽度。
[BITS	32]             ;32位模式的机器运行
LABEL_TSS:              ;定义LABEL_TSS
		DD	0			; Back
		DD	TopOfStack		; 0 级堆栈   //内层ring0级堆栈放入TSS中
		DD	SelectorStack		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			;               //TSS中最高只能放入Ring2级堆栈，ring3级堆栈不需要放入
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
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSSLen		equ	$ - LABEL_TSS   ;求得段的大小

[SECTION .s16] ; 代码应该是从这里开始执行的
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


;#######################################################################################################################
	; 两个ring3堆栈的初始化代码
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

	; 初始化两个Ring3描述符
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

	; 调用门初始化
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE_DEST_1              ;调用门的代码段
	mov	word [LABEL_DESC_CODE_DEST_1 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE_DEST_1 + 4], al
	mov	byte [LABEL_DESC_CODE_DEST_1 + 7], ah

	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE_DEST_2               ;调用门的代码段
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


	; 为加载 GDTR 作准备，此段代码的解释在pmtest1中
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt 基地址

	; 加载 GDTR
	lgdt	[GdtPtr]

	; 关中断
	cli

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

	in	al, 92h		; ┓
	and	al, 11111101b	; ┣ 关闭 A20 地址线
	out	92h, al		; ┛

	sti			; 开中断

	mov	ax, 4c00h	; ┓
	int	21h		; ┛回到 DOS
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


	; 下面显示一个字符串
	push	szPMMessage
	call	DispStr
	add	esp, 4

	push	szMemChkTitle
	call	DispStr
	add	esp, 4

	call	DispMemSize		; 显示内存信息

	call	PagingDemo		; 演示改变页目录的效果，会调用SetupPaging函数

	jmp	SelectorCode16:0 ; 结束后跳至LABEL_DESC_CODE16处

; 启动分页机制 --------------------------------------------------------------
SetupPaging:
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

	mov	eax, PageDirBase0
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short .3
.3:
	nop

	ret
; 分页机制启动完毕 ----------------------------------------------------------


; 测试分页机制 
PagingDemo: ; 将代码填充进第13-17行的内存地址
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


;#######################################################################################################################
	mov	ax, SelectorTSS         ;ltr 是ring0级指令，只能运行在ring0级代码段中。在ring0中需要手动加载tss实现堆栈切换。在call中是系统自动调用tss切换的
	ltr	ax

	push	SelectorStack3_1      ;执行retf指令时系统会调用选择子(ring3级)
	push	TopOfStack3_1         ;执行retf指令时系统会自动在第四步切换到ring3级的这个堆栈
	push	SelectorCodeRing3_1   ;retf 时，需要检查该选择子得rpl，看是否需要变换特权级
	push	0                   ;特权转换使用retf使用之前，压入ss，sp，cs，ip 到内层Ring0堆栈  push 0 表示ip为0.    0为偏移量
	retf
	; 修改结束

LABEL_DESC1:
	call	PSwitch			; 切换页目录，改变地址映射关系

	push	SelectorStack3_2      ;执行retf指令时系统会调用选择子(ring3级)
	push	TopOfStack3_2         ;执行retf指令时系统会自动在第四步切换到ring3级的这个堆栈
	push	SelectorCodeRing3_2   ;retf 时，需要检查该选择子得rpl，看是否需要变换特权级
	push	0                   ;特权转换使用retf使用之前，压入ss，sp，cs，ip 到内层Ring0堆栈  push 0 表示ip为0.    0为偏移量
	retf
LABEL_DESC2:
	ret
;#######################################################################################################################



; PagingDemoProc ------------------------------------------------------------
PagingDemoProc:
OffsetPagingDemoProc	equ	PagingDemoProc - $$
	mov	eax, LinearAddrDemo ; LinearAddrDemo与ProcFoo相等
	call	eax
	retf
; ---------------------------------------------------------------------------
LenPagingDemoAll	equ	$ - PagingDemoProc
; ---------------------------------------------------------------------------


;#######################################################################################################################
; foo 
foo:
OffsetFoo	equ	foo - $$
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'P'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; 屏幕第 17 行, 第 0 列。
	mov	al, 'A'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; 屏幕第 17 行, 第 1 列。
	ret
LenFoo	equ	$ - foo

; bar 
bar:
OffsetBar	equ	bar - $$
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'P'
	mov	[gs:((80 * 18 + 0) * 2)], ax	; 屏幕第 18 行, 第 0 列。
	mov	al, 'B'
	mov	[gs:((80 * 18 + 1) * 2)], ax	; 屏幕第 18 行, 第 1 列。
	ret
LenBar	equ	$ - bar
;#######################################################################################################################


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


;#######################################################################################################################
; 两个目标代码段
[SECTION .sdest1]; 调用门目标段，[SECTION .sdest]段是非一致32位段，而且DPL=0，并且当前CPL=0。而此后用到的“DPL”和“选择子中的RPL”都为0，均在最高特权级上跳转，不需要设计权限检查了
[BITS	32]
LABEL_SEG_CODE_DEST_1:    ;ring0级代码段
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 8 + 0) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, '0'
	mov	[gs:edi], ax    

	call	PSwitch			; 切换页目录，改变地址映射关系  

	push	SelectorStack3_2      ;执行retf指令时系统会调用选择子(ring3级)
	push	TopOfStack3_2         ;执行retf指令时系统会自动在第四步切换到ring3级的这个堆栈
	push	SelectorCodeRing3_2   ;retf 时，需要检查该选择子得rpl，看是否需要变换特权级
	push	0                   ;特权转换使用retf使用之前，压入ss，sp，cs，ip 到内层Ring0堆栈  push 0 表示ip为0.    0为偏移量
	retf

PSwitch:
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov ax, SelectorData
	mov ds, ax
	mov	edi, PageDirBase1	; 此段首地址为 PageDirBase1
	xor	eax, eax
	mov	eax, PageTblBase1 | PG_P  | PG_USU | PG_RWW
	mov	ecx, [ds:PageTableNumber]
	
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	mov	eax, [ds:PageTableNumber]	; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase1	; 此段首地址为 PageTblBase1
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2

	; 在此假设内存是大于 8M 的
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
	jmp	short .3
.3:
	nop

	
	ret

SegCodeDestLen_1	equ	$ - LABEL_SEG_CODE_DEST_1   ;计算调用门目标段的大小
;#######################################################################################################################


;#######################################################################################################################
[SECTION .sdest2]; 调用门目标段，[SECTION .sdest]段是非一致32位段，而且DPL=0，并且当前CPL=0。而此后用到的“DPL”和“选择子中的RPL”都为0，均在最高特权级上跳转，不需要设计权限检查了
[BITS	32]

LABEL_SEG_CODE_DEST_2:    ;ring0级代码段
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 10 + 0) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, '0'
	mov	[gs:edi], ax    
	
	jmp	SelectorCode16:0

SegCodeDestLen_2	equ	$ - LABEL_SEG_CODE_DEST_2   ;计算调用门目标段的大小
;#######################################################################################################################


;#######################################################################################################################
; 第一个ring3代码段
[SECTION .ring3_1]
LABEL_CODE_RING3_1:
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 7 + 0) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, '3'
	mov	[gs:edi], ax    
	mov	edi, (80 * 7 + 2) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'P'
	mov	[gs:edi], ax 
	mov	edi, (80 * 7 + 3) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'A'
	mov	[gs:edi], ax    

	call	SelectorFlatC:ProcPagingDemo
	call	SelectorCallGateTest_1:0
	jmp $
SegCodeRing3_1Len	equ $ - LABEL_CODE_RING3_1

[SECTION .ring3_2]
LABEL_CODE_RING3_2:
	mov	edi, (80 * 9 + 0) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, '3'
	mov	[gs:edi], ax    
	mov	edi, (80 * 9 + 2) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'P'
	mov	[gs:edi], ax 
	mov	edi, (80 * 9 + 3) * 2	
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'B'
	mov	[gs:edi], ax     

	call	SelectorFlatC:ProcPagingDemo
	call	SelectorCallGateTest_2:0
	jmp $
SegCodeRing3_2Len	equ $ - LABEL_CODE_RING3_2
;#######################################################################################################################


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
