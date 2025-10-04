; ============================================= ;
;  > memset.asm                                 ;
; --------------------------------------------- ;
;                                               ;
;  Provides a simple memset() implementation.   ;
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
;   > [F] memset                                ;
;                                               ;
; ============================================= ;

default rel
bits 64


section .text

; ============================================= ;
;  > memset                                     ;
; --------------------------------------------- ;
;                                               ;
;  A simple memset implementation.              ;
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
;   > RCX - ptr memory region                   ;
;   > RDX - uint64 size of memory region        ;
;   > R8  - uint8 value to set memory to        ;
;                                               ;
; ============================================= ;
global memset
memset:
    push            rax

    lea             rdi, [rcx]
    lea             rcx, [rdx]
    lea             rax, [r8]
    rep             stosb

    pop             rcx
    ret
