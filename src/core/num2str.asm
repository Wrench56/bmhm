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


; ============================================= ;
;  > u64_to_dec                                 ;
; --------------------------------------------- ;
;                                               ;
;  Convert a uint64 to its decimal              ;
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
;   > RDX - ptr memory region (min 40 bytes)    ;
;                                               ;
; ============================================= ;
global u64_to_dec
u64_to_dec:
    push            rdx

    ; R8  = uint64 value
    mov             r8,  rcx

    ; R9  = write cursor
    lea             r9,  [rdx + 40]

    ; R10 = magic reciprocal for /10
    mov             r10, 0xCCCCCCCCCCCCCCCD

    ; ECX = Iteration
    mov             ecx, 20

.loop:
    sub             r9, 2

    test            r8, r8
    jz              .store_zero

    ; Divide the value by 10 (black magic)
    mov             rax, r8
    mul             r10
    shr             rdx, 3

    ; Calculate its remainder
    lea             r11, [rdx + rdx * 8]
    add             r11, rdx
    mov             rax, r8
    sub             rax, r11

    lea             r11d, [eax + '0']
    mov             byte [r9], r11b
    mov             byte [r9 + 1], 0

    mov             r8,  rdx
    jmp             .cont

.store_zero:
    mov             word [r9], __?utf16?__("0")

.cont:
    sub             ecx, 1
    jnz             .loop

    pop             rdx
    mov             rax, rdx
    ret
