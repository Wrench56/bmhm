; ============================================= ;
;  > getchar.asm                                ;
; --------------------------------------------- ;
;                                               ;
;  Provides a simple getchar() implementation.  ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
;  Version    : 1.0.0                           ;
;  License    : MIT                             ;
;  Libraries  : None                            ;
;  ABI used   : Microsoft x64                   ;
;  Arch       : x64/AMD64                       ;
;  Extensions : None                            ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Exports:                                     ;
;   > [F] getchar                               ;
;                                               ;
; ============================================= ;


%include "efilib.inc"
%include "efi_funcs.inc"

extern efi_funcs

section .bss
    _efi_ConIn resq 1
    _efi_ReadKeyStroke resq 1

section .text

; ============================================= ;
;  > getchar_init                               ;
; --------------------------------------------- ;
;                                               ;
;  Initialize the getchar() function.           ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
;  Extensions : None                            ;
;  Libraries  : None                            ;
;  ABI used   : Microsoft x64                   ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Scope      : Global                          ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   void                                        ;
;                                               ;
;  Arguments:                                   ;
;   > RCX - ptr efi_system_table                ;
;                                               ;
; ============================================= ;
global getchar_init
getchar_init:
    push            rax

    mov             rcx, [rcx + efi_system_table.ConIn]
    mov             [rel _efi_ConIn], rcx
    lea             r9, [efi_funcs]
    mov             rcx, [r9 + efi_func_table.ReadKeyStroke]
    mov             [_efi_ReadKeyStroke], rcx

    pop             rcx
    ret

; ============================================= ;
;  > getchar                                    ;
; --------------------------------------------- ;
;                                               ;
;  A simple blocking getchar() implementation.  ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
;  Extensions : None                            ;
;  Libraries  : None                            ;
;  ABI used   : Microsoft x64                   ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Scope      : Global                          ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   char8 pressed key                           ;
;                                               ;
;  Arguments:                                   ;
;   void                                        ;
;                                               ;
; ============================================= ;
global getchar
getchar:
    push            rbp
    push            r15
    push            r14
    sub             rsp, 32 + 16 + 16

    mov             r14, [_efi_ConIn]
    lea             r15, [rsp + 32]
    mov             rbp, [_efi_ReadKeyStroke]

.poll:
    mov             rcx, r14
    mov             rdx, r15
    call            rbp
    test            rax, rax
    jnz             .poll

    movzx           eax, word [r15 + efi_input_key.UnicodeChar]
    test            ax, ax
    jz              .poll

    cmp             ax, 0x007F
    ja              .poll

    movzx           eax, al

    add             rsp, 32 + 16 + 16
    pop             r14
    pop             r15
    pop             rbp
    ret
