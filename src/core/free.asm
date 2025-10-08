; ============================================= ;
;  > free.asm                                   ;
; --------------------------------------------- ;
;                                               ;
;  Provides a simple free() implementation.     ;
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
;   > [F] free                                  ;
;                                               ;
; ============================================= ;

default rel
bits 64

%include "efilib.inc"
%include "efi_funcs.inc"

extern efi_funcs

section .text

; ============================================= ;
;  > free                                       ;
; --------------------------------------------- ;
;                                               ;
;  A simple free() wrapper using UEFI           ;
;  FreePool().                                  ;
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
;   EFI_STATUS value returned by FreePool()     ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - ptr buffer                         ;
;                                               ;
; ============================================= ;
global free
free:
    sub             rsp, 32 + 8

    test            rcx, rcx
    je              .done

    lea             r9, [rel efi_funcs]
    call            [r9 + efi_func_table.FreePool]
    jmp             .epilog

.done:
    xor             eax, eax

.epilog:
    add             rsp, 32 + 8
    ret
