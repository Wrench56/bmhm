; ============================================= ;
;  > clearscreen.asm                            ;
; --------------------------------------------- ;
;                                               ;
;  Provides a way to clear the framebuffer.     ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  8 Oct 2025                     ;
;  Updated    :  8 Oct 2025                     ;
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
;   > [F] clearscreen_init                      ;
;   > [F] clearscreen                           ;
;                                               ;
; ============================================= ;


%include "efilib.inc"
%include "efi_funcs.inc"

extern efi_funcs

section .bss
    _efi_system_table resq 1

section .text

; ============================================= ;
;  > clearscreen_init                           ;
; --------------------------------------------- ;
;                                               ;
;  Initialize the clearscreen() function.       ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  8 Oct 2025                     ;
;  Updated    :  8 Oct 2025                     ;
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
global clearscreen_init
clearscreen_init:
    push            rax

    mov             [rel _efi_system_table], rcx

    pop             rcx
    ret

; ============================================= ;
;  > clearscreen                                ;
; --------------------------------------------- ;
;                                               ;
;  A simple clearscreen() implementation.       ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  8 Oct 2025                     ;
;  Updated    :  8 Oct 2025                     ;
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
;   void                                        ;
;                                               ;
; ============================================= ;
global clearscreen
clearscreen:
    sub             rsp, 32 + 8

    mov             rcx, [rel _efi_system_table]
    mov             rcx, [rcx + efi_system_table.ConOut]
    call            [rel efi_funcs + efi_func_table.ClearScreen]

    add             rsp, 32 + 8
    ret
