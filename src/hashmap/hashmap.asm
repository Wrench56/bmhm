; ============================================= ;
;  > hashmap.asm                                ;
; --------------------------------------------- ;
;                                               ;
;  Provides a linear probe based hashmap        ;
;  implementation.                              ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
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
;   > [F] hashmap_init                          ;
;   > [F] hashmap_get                           ;
;   > [F] hashmap_add                           ;
;                                               ;
; ============================================= ;

%include "hashmap.inc"

extern efi_funcs
extern malloc
extern memset

section .text

; ============================================= ;
;  > hashmap_init                               ;
; --------------------------------------------- ;
;                                               ;
;  Initialize a new hashmap.                    ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
;  Updated    :  5 Oct 2025                     ;
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
;    > RDX - ptr hash_callback_function         ;
;    > R8  - ptr print_key_callback_function    ;
;    > R9  - ptr print_value_callback_function  ;
;                                               ;
; ============================================= ;
global hashmap_init
hashmap_init:
    push            r12
    push            r13
    push            r14
    push            r15
    sub             rsp, 32 + 8

    ; Save callbacks
    mov             r12, rcx
    mov             r13, rdx
    mov             r14, r8
    mov             r15, r9

    mov             rcx, sizeof(hashmap_t)
    call            malloc
    test            rax, rax
    je              .error

    mov             qword [rax + hashmap_t.size], 0
    mov             [rax + hashmap_t.eq_callback], r12
    mov             [rax + hashmap_t.hash_callback], r13
    mov             [rax + hashmap_t.printk_callback], r14
    mov             [rax + hashmap_t.printv_callback], r15
    mov             qword [rax + hashmap_t.capacity], HASHMAP_INITIAL_CAPACITY
    mov             r15, rax

    mov             rcx, HASHMAP_INITIAL_CAPACITY * 8
    call            malloc
    test            rax, rax
    je              .error
    mov             [r15 + hashmap_t.entries], rax

    mov             rcx, rax
    mov             rdx, HASHMAP_INITIAL_CAPACITY * 8
    xor             r8, r8
    call            memset

    mov             rax, r15

.exit:
    add             rsp, 32 + 8
    pop             r15
    pop             r14
    pop             r13
    pop             r12
    ret

.error:
    jmp .exit


; ============================================= ;
;  > hashmap_get                                ;
; --------------------------------------------- ;
;                                               ;
;  Get a pointer to a value based on a key.     ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  4 Oct 2025                     ;
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
;   ptr value                                   ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - ptr hashmap_t                      ;
;    > RDX - ptr key                            ;
;                                               ;
; ============================================= ;

global hashmap_get
hashmap_get:
    push            rbp
    push            r11
    push            r12
    push            r13
    push            r14
    sub             rsp, 32

    ; RBP = pointer to hashmap
    lea             rbp, [rcx]

    ; R11 = pointer to key
    lea             r11, [rdx]

    lea             rcx, [rdx]
    call            [rbp + hashmap_t.hash_callback]

    ; R12 = hash result + iteration
    lea             r12, [rax]

    ; R13 = hashmap capacity - 1
    mov             r13, [rbp + hashmap_t.capacity]
    lea             r13, [r13 - 1]

.floop:
    lea             rax, [r13]
    and             rax, r12
    shl             rax, 3

    mov             r14, [rbp + hashmap_t.entries]
    mov             r14, [r14 + rax]
    test            r14, r14
    je              .not_found

    mov             r8, [r14 + entry_t.slotstate]
    test            r8, r8
    je              .next_iter

    mov             rcx, [r14 + entry_t.key]
    lea             rdx, [r11]
    call            [rbp + hashmap_t.eq_callback]
    test            rax, rax
    je              .found

.next_iter:
    lea             r12, [r12 + 1]
    jmp             .floop

.found:
    mov             rax, [r14 + entry_t.value]
    jmp             .epilog

.not_found:
    xor             rax, rax

.epilog:
    add             rsp, 32
    pop             r14
    pop             r13
    pop             r12
    pop             r11
    pop             rbp
    ret


; ============================================= ;
;  > hashmap_add                                ;
; --------------------------------------------- ;
;                                               ;
;  Add a key-value pair to the hashmap.         ;
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
;   bool success                                ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - ptr hashmap_t                      ;
;    > RDX - ptr key                            ;
;    > R8  - ptr value                          ;
;                                               ;
; ============================================= ;

global hashmap_add
hashmap_add:
    push            rbp
    push            r11
    push            r12
    push            r13
    push            r14
    push            r15
    sub             rsp, 32 + 8

    ; RBP = pointer to hashmap
    mov             rbp, rcx

    ; R11 = pointer to key
    mov             r11, rdx

    ; R15 = pointer to value
    mov             r15, r8

    mov             rcx, rdx
    call            [rbp + hashmap_t.hash_callback]

    ; R12 = hash result + iteration
    mov             r12, rax

    ; R13 = hashmap capacity - 1
    mov             r13, [rbp + hashmap_t.capacity]
    lea             r13, [r13 - 1]

.floop:
    mov             rax, r13
    and             rax, r12
    shl             rax, 3

    mov             r14, [rbp + hashmap_t.entries]
    mov             r14, [r14 + rax]
    test            r14, r14
    je              .empty_found

    mov             r8, [r14 + entry_t.slotstate]
    test            r8, r8
    je              .tombstone_found

    lea             r12, [r12 + 1]
    jmp             .floop

.empty_found:
    ; Allocate a new entry_t
    mov             r12, rax
    mov             rcx, sizeof(entry_t)
    call            malloc
    mov             rcx, [rbp + hashmap_t.entries]
    mov             [rcx + r12], rax
    mov             r14, rax

.tombstone_found:
    mov             byte [r14 + entry_t.slotstate], 1
    mov             [r14 + entry_t.key], r11
    mov             [r14 + entry_t.value], r15
    mov             rax, 1024
    add             qword [rbp + hashmap_t.size], 1

.epilog:
    add             rsp, 32 + 8
    pop             r15
    pop             r14
    pop             r13
    pop             r12
    pop             r11
    pop             rbp
    ret
