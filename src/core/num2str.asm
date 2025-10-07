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
;   > [F] u64_to_dec                            ;
;   > [F] u64_dec_len                           ;
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


; ============================================= ;
;  > u64_dec_len                                ;
; --------------------------------------------- ;
;                                               ;
;  Compute the decimal digit count (unpadded    ;
;  length) of a uint64.                         ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
;  ABI used   : Microsoft x64                   ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Scope      : Global                          ;
;  Returns:                                     ;
;   uint8 number of digits (1–20)               ;
;                                               ;
;  Arguments:                                   ;
;   > RCX - uint64 value                        ;
;                                               ;
; ============================================= ;
global u64_dec_len
u64_dec_len:
    test    rcx, rcx
    jnz     .check
    mov     eax, 1
    ret

.check:
    cmp     rcx, 10
    jb      .len1
    cmp     rcx, 100
    jb      .len2
    cmp     rcx, 1000
    jb      .len3
    cmp     rcx, 10000
    jb      .len4
    cmp     rcx, 100000
    jb      .len5
    cmp     rcx, 1000000
    jb      .len6
    cmp     rcx, 10000000
    jb      .len7
    cmp     rcx, 100000000
    jb      .len8
    cmp     rcx, 1000000000
    jb      .len9
    mov     rdx, 10000000000
    cmp     rcx, rdx
    jb      .len10
    mov     rdx, 100000000000
    cmp     rcx, rdx
    jb      .len11
    mov     rdx, 1000000000000
    cmp     rcx, rdx
    jb      .len12
    mov     rdx, 10000000000000
    cmp     rcx, rdx
    jb      .len13
    mov     rdx, 100000000000000
    cmp     rcx, rdx
    jb      .len14
    mov     rdx, 1000000000000000
    cmp     rcx, rdx
    jb      .len15
    mov     rdx, 10000000000000000
    cmp     rcx, rdx
    jb      .len16
    mov     rdx, 100000000000000000
    cmp     rcx, rdx
    jb      .len17
    mov     rdx, 1000000000000000000
    cmp     rcx, rdx
    jb      .len18
    mov     rdx, 10000000000000000000
    cmp     rcx, rdx
    jb      .len19
    mov     eax, 20
    ret

.len1:  mov eax, 1
        ret
.len2:  mov eax, 2
        ret
.len3:  mov eax, 3
        ret
.len4:  mov eax, 4
        ret
.len5:  mov eax, 5
        ret
.len6:  mov eax, 6
        ret
.len7:  mov eax, 7
        ret
.len8:  mov eax, 8
        ret
.len9:  mov eax, 9
        ret
.len10: mov eax, 10
        ret
.len11: mov eax, 11
        ret
.len12: mov eax, 12
        ret
.len13: mov eax, 13
        ret
.len14: mov eax, 14
        ret
.len15: mov eax, 15
        ret
.len16: mov eax, 16
        ret
.len17: mov eax, 17
        ret
.len18: mov eax, 18
        ret
.len19: mov eax, 19
        ret
