; ============================================= ;
;  > num2str.asm                                 ;
; --------------------------------------------- ;
;                                               ;
;  Provides implementations for converting      ;
;  numbers to UTF-16 strings.                   ;
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
;   > [F] u64_to_hex                            ;
;                                               ;
; ============================================= ;

default rel
bits 64


section .text

; ============================================= ;
;  > u64_to_hex                                 ;
; --------------------------------------------- ;
;                                               ;
;  Convert a uint64 to its hexadecimal          ;
;  representation in UTF-16 string.             ;
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
;   ptr memory region with the UTF-16 string    ;
;                                               ;
;  Arguments:                                   ;
;   > RCX - the uint64 number                   ;
;   > RDX - ptr memory region (min 32 bytes)    ;
;                                               ;
; ============================================= ;
global u64_to_hex
u64_to_hex:
    ; R8 = number
    mov             r8, rcx
    ; R9 = number of nibbles to convert
    mov             r9, 16

.loop:
    mov             rax, r8
    and             eax, 0xF

    add             al, '0'
    cmp             al, '9'
    jbe             .store
    add             al, 7

.store:
    movzx           eax, al
    mov             [rdx + (r9 - 1) * 2], ax
    shr             r8, 4
    dec             r9
    jnz             .loop

    mov             rax, rdx
    ret
