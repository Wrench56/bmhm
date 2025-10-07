; ============================================= ;
;  > dump.asm                                   ;
; --------------------------------------------- ;
;                                               ;
;  Pretty-printer function(s) for the           ;
;  implemented hashmap.                         ;
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
;   > [F] hashmap_dump                          ;
;                                               ;
; ============================================= ;


%include "hashmap.inc"


extern u64_to_hex
extern u64_to_dec

extern printf


section .data
    hashmap_hdr dw 0x000A, 0x000D, __?utf16?__("Hashmap          @ 0x"), 0x0000
    entries_hdr dw __?utf16?__(" > Entries       @ 0x"), 0x0000
    eqcb_hdr dw __?utf16?__(" > EQ Callback   @ 0x"), 0x0000
    hashcb_hdr dw __?utf16?__(" > Hash Callback @ 0x"), 0x0000
    size_hdr dw __?utf16?__(" > Size          : "), 0x0000
    capacity_hdr dw __?utf16?__(" > Capacity      : "), 0x0000


section .text

; ============================================= ;
;  > hashmap_dump                               ;
; --------------------------------------------- ;
;                                               ;
;  Visualize the given hashmap.                 ;
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
;    > RCX - ptr hashmap_t                      ;
;                                               ;
; ============================================= ;

global hashmap_dump
hashmap_dump:
    push            rbp
    sub             rsp, 32 + 64

    ; RBP = pointer to hashmap
    mov             rbp, rcx

    ; Load common postfix
    mov             qword [rsp + 64], 0x00000000000D000A

    ; Hashmap header
    lea             rcx, [rel hashmap_hdr]
    call            printf
    mov             rcx, rbp
    lea             rdx, [rsp + 32]
    call            u64_to_hex
    lea             rcx, [rsp + 32]
    call            printf

    ; Entries
    lea             rcx, [rel entries_hdr]
    call            printf
    mov             rcx, [rbp + hashmap_t.entries]
    lea             rdx, [rsp + 32]
    call            u64_to_hex
    lea             rcx, [rsp + 32]
    call            printf

    ; Eq Callback
    lea             rcx, [rel eqcb_hdr]
    call            printf
    mov             rcx, [rbp + hashmap_t.eq_callback]
    lea             rdx, [rsp + 32]
    call            u64_to_hex
    lea             rcx, [rsp + 32]
    call            printf

    ; Hash Callback
    lea             rcx, [rel hashcb_hdr]
    call            printf
    mov             rcx, [rbp + hashmap_t.hash_callback]
    lea             rdx, [rsp + 32]
    call            u64_to_hex
    lea             rcx, [rsp + 32]
    call            printf

    ; Set new common postfix
    mov             qword [rsp + 64 + 8], 0x00000000000D000A

    ; Size (truncated to 18 characters)
    lea             rcx, [rel size_hdr]
    call            printf
    mov             rcx, [rbp + hashmap_t.size]
    lea             rdx, [rsp + 32]
    call            u64_to_dec
    lea             rcx, [rsp + 32 + 4]
    call            printf

    ; Capacity (truncated to 18 characters)
    lea             rcx, [rel capacity_hdr]
    call            printf
    mov             rcx, [rbp + hashmap_t.capacity]
    lea             rdx, [rsp + 32]
    call            u64_to_dec
    lea             rcx, [rsp + 32 + 4]
    call            printf
   
    add             rsp, 32 + 64
    pop             rbp
    ret
