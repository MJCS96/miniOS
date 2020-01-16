;;-----------------_DEFINITIONS ONLY_-----------------------
;; IMPORT FUNCTIONS FROM C
%macro IMPORTFROMC 1-*
%rep  %0
    %ifidn __OUTPUT_FORMAT__, win32 ; win32 builds from Visual C decorate C names using _ 
    extern _%1
    %1 equ _%1
    %else
    extern %1
    %endif
%rotate 1 
%endrep
%endmacro

;; EXPORT TO C FUNCTIONS
%macro EXPORT2C 1-*
%rep  %0
    %ifidn __OUTPUT_FORMAT__, win32 ; win32 builds from Visual C decorate C names using _ 
    global _%1
    _%1 equ %1
    %else
    global %1
    %endif
%rotate 1 
%endrep
%endmacro

%define break xchg bx, bx
IMPORTFROMC KernelMain,irq0_handler,irq1_handler,irq2_handler,irq3_handler,irq4_handler,irq5_handler,irq6_handler,irq7_handler,irq8_handler,irq9_handler,irq10_handler,irq11_handler,irq12_handler,irq13_handler,irq14_handler,irq15_handler

%define PAGE_PRESENT    (1 << 0)
%define PAGE_WRITE      (1 << 1)
 
%define CODE_SEG     0x0008
%define DATA_SEG     48
%define pdptentrycount  3 

ALIGN 4
IDT:
    .Length       dw 0
    .Base         dd 0


TOP_OF_STACK                equ 0x200000
KERNEL_BASE_PHYSICAL        equ 0x200000
;;-----------------^DEFINITIONS ONLY^-----------------------
segment .text
[BITS 32]
ASMEntryPoint:
    cli
    MOV     DWORD [0x000B8000], 'O1S1'
%ifidn __OUTPUT_FORMAT__, win32
    MOV     DWORD [0x000B8004], '3121'                  ; 32 bit build marker
%else
    MOV     DWORD [0x000B8004], '6141'                  ; 64 bit build marker
%endif


    call __enableSSE
    MOV     ESP, TOP_OF_STACK                           ; just below the kernel
 

    ; desactivating paging
    mov eax, cr0
    and eax, 0x7FFFFFFF
    mov cr0,eax

    ; Zero out the 16KiB buffer.
    ; Since we are doing a rep stosd, count should be bytes/4.   
    push di                           ; REP STOSD alters DI.
    mov ecx, 0x1000
    xor eax, eax
    cld
    rep stosd
    pop di                            ; Get DI back.
 
 
    mov edi, 0x300000
	mov eax, edi
	add eax, 0x1000
	; PML4[0] = &PDPT[0]
	mov DWORD [edi], eax
	or DWORD [edi], 7
	
	
	mov edi, eax
	add eax, 0x1000
	xor ecx, pdptentrycount
.loop:
	; PDPT[i] = &PD[i]
	mov DWORD [edi], eax
	or DWORD [edi], 7
	add edi, 8
	add eax, 0x1000 
	loop .loop	
	 
    
	mov edi, 0x302000
	mov eax, edi
	add eax, pdptentrycount * 0x1000

	mov ecx, pdptentrycount
	.loop1:
	push ecx
	mov ecx, 512
	.loop2:
	mov [edi], eax
	add eax,0x1000
	or  DWORD[edi], 7
	add edi, 8
	loop .loop2
	pop ecx
	loop .loop1


	xor eax,eax
	mov edi, 0x300000
	add edi, 0x1000
	add edi, 0x1000
	add edi, pdptentrycount * 0x1000
	mov ecx, 1536*512 ; pdptentrycount(3)*512*512
	.loop3:
	mov [edi], eax
	or DWORD[edi],7
	add edi, 8
	add eax, 0x1000
	loop .loop3
	 
    ; Enter long mode.
    mov eax, cr4                ; Set the PAE and PGE bit.
    or eax, 10100000b
	mov cr4, eax
 
    mov edx, 0x300000                      ; Point CR3 at the PML4.
    mov cr3, edx
 
    mov ecx, 0xC0000080               ; Read from the EFER MSR. 
    rdmsr    
 
    or eax, 0x00000100                ; Set the LME bit.
    wrmsr
	
    mov ebx, cr0                      ; Activate long mode -
    or ebx,0x80000000                 ; - by enabling paging and protection simultaneously.

	mov cr0, ebx                    
    jmp 40:LongMode             ; Load CS with 64 bit segment and flush the instruction cache
	

LongMode:
[BITS 64]      
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
	
    ; Blank out the screen to a blue color.
    ;mov edi, 0xB8000
    ;mov rcx, 500                      ; Since we are clearing uint64_t over here, we put the count as Count/4.
    ;mov rax, 0x1F201F201F201F20       ; Set the value to set the screen to: Blue background, white foreground, blank spaces.
    ;rep stosq                         ; Clear the entire screen. 
 
    ; Display "Hello World!"
    ;mov edi, 0x00b8000              
 
    ;mov rax, 0x1F6C1F6C1F651F48    
    ;mov [edi],rax
 
    ;mov rax, 0x1F6F1F571F201F6F
    ;mov [edi + 8], rax
 
    ;mov rax, 0x1F211F641F6C1F72
    ;mov [edi + 16], rax

    ;TODO!!! transition to 64bits-long mode

	xor eax,eax
    MOV     eax, KernelMain     ; after 64bits transition is implemented the kernel must be compiled on x64
    CALL    rax
    
    CLI
    HLT

;;--------------------------------------------------------

__cli:
    CLI
    RET

irq0:
  call irq0_handler
  iretq
 
irq1:

  call irq1_handler
  iretq
 
irq2:
  call irq2_handler
  iretq
 
irq3:
  call irq3_handler
  iretq
 
irq4:
  call irq4_handler
  iretq
 
irq5:
  call irq5_handler
  iretq
 
irq6:
  call irq6_handler
  iretq
 
irq7:
  call irq7_handler
  iretq
 
irq8:
  call irq8_handler
  iretq
 
irq9:
  call irq9_handler
  iretq
 
irq10:
  call irq10_handler
  iretq
 
irq11:
  call irq11_handler
  iretq
 
irq12:
  call irq12_handler
  iretq
 
irq13:
  call irq13_handler
  iretq
 
irq14:
  call irq14_handler
  iretq
 
irq15:
  call irq15_handler
  iretq

__sti:
    STI
    RET

__magic:
    XCHG    BX,BX
    RET
    
__enableSSE:                ;; enable SSE instructions (CR4.OSFXSR = 1)  
[bits 32]
    MOV     EAX, CR4
    OR      EAX, 0x00000200
    MOV     CR4, EAX
    RET

    
EXPORT2C ASMEntryPoint, __cli, __sti, __magic, __enableSSE, irq0,irq1,irq2,irq3,irq4,irq5,irq6,irq7,irq8,irq9,irq10,irq11,irq12,irq13,irq14,irq15


