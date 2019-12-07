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

%define PAGE_PRESENT    (1 << 0)
%define PAGE_WRITE      (1 << 1)
 
%define CODE_SEG     0x0008
%define DATA_SEG     0x0010
%define pdptentrycount  3 

ALIGN 4
IDT:
    .Length       dw 0
    .Base         dd 0

IMPORTFROMC KernelMain

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



    MOV     ESP, TOP_OF_STACK                           ; just below the kernel
    ;TODO!!! define page tables; see https://wiki.osdev.org ,Intel's manual, http://www.brokenthorn.com/Resources/

    ;TODO!!! activate pagging

    SwitchToLongMode:
    ; Zero out the 16KiB buffer.
    ; Since we are doing a rep stosd, count should be bytes/4.   
    push di                           ; REP STOSD alters DI.
    mov ecx, 0x2000
    xor eax, eax
    cld
    rep stosd
    pop di                            ; Get DI back.
 
 
    ; Build the Page Map Level 4.
    ; es:di points to the Page Map Level 4 table.
	;xor edi, edi
    ;lea eax, [edi + 0x300000]         ; Put the address of the Page Directory Pointer Table in to EAX.
    ;or DWORD [eax], 7 ; Or EAX with the flags - present flag, writable flag.
    ;mov [edi], eax                  ; Store the value of EAX as the first PML4E.
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
	
	
 
    ; Build the Page Directory.
    ;lea eax, [es:di + 0x5000]         ; Put the address of the Page Table in to EAX.
    ;or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writeable flag.
    ;mov [es:di + 0x3000], eax         ; Store to value of EAX as the first PDE.
 
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
	break

	

	 
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
    or ebx,0x80000001                 ; - by enabling paging and protection simultaneously.
	break
	mov cr0, ebx                    
	
    lgdt [GDT.Pointer]                ; Load GDT.Pointer defined below.
	break
    jmp CODE_SEG:LongMode             ; Load CS with 64 bit segment and flush the instruction cache
 
 
    ; Global Descriptor Table
GDT:
.Null:
    dq 0x0000000000000000             ; Null Descriptor - should be present.
 
.Code:
    dq 0x00209A0000000000             ; 64-bit code descriptor (exec/read).
    dq 0x0000920000000000             ; 64-bit data descriptor (read/write).
 
ALIGN 4
    dw 0                              ; Padding to make the "address of the GDT" field aligned on a 4-byte boundary
 
.Pointer:
    dw $ - GDT - 1                    ; 16-bit Size (Limit) of GDT.
    dd GDT                            ; 32-bit Base Address of GDT. (CPU will zero extend to 64-bit)
 
 
[BITS 64]      
LongMode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
 
    ; Blank out the screen to a blue color.
    mov edi, 0xB8000
    mov rcx, 500                      ; Since we are clearing uint64_t over here, we put the count as Count/4.
    mov rax, 0x1F201F201F201F20       ; Set the value to set the screen to: Blue background, white foreground, blank spaces.
    rep stosq                         ; Clear the entire screen. 
 
    ; Display "Hello World!"
    mov edi, 0x00b8000              
 
    mov rax, 0x1F6C1F6C1F651F48    
    mov [edi],rax
 
    mov rax, 0x1F6F1F571F201F6F
    mov [edi + 8], rax
 
    mov rax, 0x1F211F641F6C1F72
    mov [edi + 16], rax

    ;TODO!!! transition to 64bits-long mode

   ; MOV     EAX, KernelMain     ; after 64bits transition is implemented the kernel must be compiled on x64
    CALL    KernelMain
    
    break
    CLI
    HLT

;;--------------------------------------------------------

__cli:
    CLI
    RET

__sti:
    STI
    RET

__magic:
    XCHG    BX,BX
    RET
    
;__enableSSE:                ;; enable SSE instructions (CR4.OSFXSR = 1)  
;    MOV     EAX, CR4
;    OR      EAX, 0x00000200
;    MOV     CR4, EAX
;    RET

    
EXPORT2C ASMEntryPoint, __cli, __sti, __magic,; __enableSSE,


