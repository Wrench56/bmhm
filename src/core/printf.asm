; ============================================= ;
;  > printf.asm                                 ;
; --------------------------------------------- ;
;                                               ;
;  Provides a simple printf() implementation.   ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  4 Oct 2025                     ;
;  Updated    :  4 Oct 2025                     ;
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
;   > [F] printf                                ;
;                                               ;
; ============================================= ;

default rel
bits 64


extern efi_funcs


%include "efilib.inc"
%include "efi_funcs.inc"

section .bss
    _efi_system_table resq 1


section .text


; ============================================= ;
;  > printf_init                                ;
; --------------------------------------------- ;
;                                               ;
;  Initialize the printf() function.            ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  4 Oct 2025                     ;
;  Updated    :  4 Oct 2025                     ;
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
global printf_init
printf_init:
    push            rax

    mov             [rel _efi_system_table], rcx

    pop             rcx
    ret

; ============================================= ;
;  > printf                                     ;
; --------------------------------------------- ;
;                                               ;
;  A simple printf() implementation.            ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  4 Oct 2025                     ;
;  Updated    :  4 Oct 2025                     ;
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
;   > RCX - ptr null-terminated message string  ;
;                                               ;
; ============================================= ;
global printf
printf:
    sub             rsp, 32 + 8

    mov             r8, [rel _efi_system_table]
    lea             r9, [efi_funcs]
    lea             rdx, [rcx]
    mov             rcx, [r8 + efi_system_table.ConOut]
    call            [r9 + efi_func_table.OutputString]

    add             rsp, 32 + 8
    ret
