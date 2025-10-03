; ============================================= ;
;  > malloc.asm                                 ;
; --------------------------------------------- ;
;                                               ;
;  Provides a simple malloc() implementation.   ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
;  Updated    :  2 Oct 2025                     ;
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
;   > [F] malloc                                ;
;                                               ;
; ============================================= ;

default rel
bits 64

%include "efilib.inc"
%include "efi_funcs.inc"

extern efi_funcs


section .text

; ============================================= ;
;  > malloc                                     ;
; --------------------------------------------- ;
;                                               ;
;  A simple malloc implementation based on      ;
;  AllocatePool().                              ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
;  Updated    :  2 Oct 2025                     ;
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
;   ptr - pointer to memory region or NULL on   ;
;         error                                 ;
;                                               ;
;  Arguments:                                   ;
;   > RCX - uint64 size                         ;
;                                               ;
; ============================================= ;
global malloc
malloc:
    sub             rsp, 32 + 8 + 8

    lea             r9, [rel efi_funcs]
    mov             rdx, rcx
    mov             rcx, EfiBootServicesData
    lea             r8, [rsp + 32]
    call            [r9 + efi_func_table.AllocatePool]
    test            rax, rax
    je              .done
    mov             qword [rsp + 32], 0

.done:
    mov             rax, [rsp + 32]

    add             rsp, 32 + 8 + 8
    ret
