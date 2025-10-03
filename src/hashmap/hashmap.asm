; ============================================= ;
;  > hashmap.asm                                ;
; --------------------------------------------- ;
;                                               ;
;  Provides a linear probe based hashmap        ;
;  implementation.                              ;
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
;   > [F] hashmap_init                          ;
;                                               ;
; ============================================= ;

%include "hashmap.inc"

extern efi_funcs
extern malloc

section .text

; ============================================= ;
;  > hashmap_init                               ;
; --------------------------------------------- ;
;                                               ;
;  Initialize a new hashmap.                    ;
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
;   ptr* hashmap_handle                         ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - ptr eq_callback_function           ;
; ============================================= ;
global hashmap_init
hashmap_init:
    push            r14
    push            r15
    sub             rsp, 32 + 8

    ; Save eq_callback
    mov             r14, rcx

    mov             rcx, sizeof(hashmap_t)
    call            malloc
    test            rax, rax
    je              .error
    mov             r15, rax

    mov             rcx, HASHMAP_INITIAL_CAPACITY * 8
    mov             [r15 + hashmap_t.capacity], rcx
    call            malloc
    test            rax, rax
    je              .error
    mov             [r15 + hashmap_t.entries], rax

    mov             [r15 + hashmap_t.eq_callback], rcx
    mov             qword [r15 + hashmap_t.size], 0

    mov             rax, r15

.exit:
    add             rsp, 32 + 8
    pop             r15
    pop             r14
    ret

.error:
    jmp .exit
