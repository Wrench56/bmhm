; ============================================= ;
;  > hashing.asm                                ;
; --------------------------------------------- ;
;                                               ;
;  Provides hashing algorithm(s) for buffers.   ;
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
;   > [F] fnv1a64_hash                          ;
;                                               ;
; ============================================= ;


%define FNV64_OFFSET 0xcbf29ce484222325
%define FNV64_PRIME  0x00000100000001B3


section .text

; ============================================= ;
;  > fnv1a64_hash                               ;
; --------------------------------------------- ;
;                                               ;
;  Implementation of the FNV-1A hashing         ;
;  algorithm.                                   ;
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
;   int                                         ;
;                                               ;
;  Arguments:                                   ;
;   > RCX - uint8* buffer                       ;
;   > RDX - size_t length                       ;
;                                               ;
; ============================================= ;
global fnv1a64_hash
fnv1a64_hash:
    mov             rax, FNV64_OFFSET
    mov             r9,  FNV64_PRIME

    test            rdx, rdx
    jz              .done
.loop:
    movzx           r8, byte [rcx]
    xor             rax, r8
    imul            rax, r9
    inc             rcx
    dec             rdx
    jnz             .loop
.done:
    ret
