; ============================================= ;
;  > hashmap.asm                                ;
; --------------------------------------------- ;
;                                               ;
;  Provides a linear probe based hashmap        ;
;  implementation.                              ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
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
;   > [F] hashmap_init                          ;
;   > [F] hashmap_get                           ;
;   > [F] hashmap_add                           ;
;   > [F] hashmap_remove                        ;
;   > [F] hashmap_set_frees                     ;
;   > [F] hashmap_resize                        ;
;   > [F] hashmap_destroy                       ;
;                                               ;
; ============================================= ;

%include "hashmap.inc"

extern efi_funcs
extern malloc
extern free
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
    lea             r15, [rel hashmap_skip_free]
    mov             qword [rax + hashmap_t.freek_callback], r15
    mov             qword [rax + hashmap_t.freev_callback], r15
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
;  > hashmap_set_frees                          ;
; --------------------------------------------- ;
;                                               ;
;  Set free callbacks for key and value.        ;
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
;   ptr value                                   ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - ptr hashmap                        ;
;    > RDX - ptr freek_callback                 ;
;    > R8  - ptr freev_callback                 ;
;                                               ;
; ============================================= ;
global hashmap_set_frees
hashmap_set_frees:
    sub             rsp, 32 + 8
    
    mov             [rcx + hashmap_t.freek_callback], rdx
    mov             [rcx + hashmap_t.freev_callback], r8

    add             rsp, 32 + 8
    ret


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
    mov             rbp, rcx

    ; R11 = pointer to key
    mov             r11, rdx

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
    je              .not_found

    movzx           r8d, byte [r14 + entry_t.slotstate]
    test            r8d, r8d
    je              .next_iter

    mov             rcx, [r14 + entry_t.key]
    mov             rdx, r11
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

    ; Check if growth is required
    mov             rax, [rbp + hashmap_t.size]
    lea             rdx, [rax * 4 + 4 * 1]
    mov             rcx, [rbp + hashmap_t.capacity]
    lea             rcx, [rcx + 2 * rcx]
    cmp             rdx, rcx
    jbe             .skip_growth

    mov             qword [rsp + 32], r11

    lea             rdx, [2 * rcx]
    mov             rcx, rbp
    call            hashmap_resize
    test            rax, rax
    jz              .add_fail

    mov             r11, [rsp + 32]

.skip_growth:
    mov             rcx, r11
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

    movzx           r8d, byte [r14 + entry_t.slotstate]
    test            r8d, r8d
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

.set_entry_fields:
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

.add_fail:
    xor             rax, rax
    jmp             .epilog

.tombstone_found:
    mov             rcx, [r14 + entry_t.key]
    call            [rbp + hashmap_t.freek_callback]
    mov             rcx, [r14 + entry_t.value]
    call            [rbp + hashmap_t.freev_callback]
    jmp             .set_entry_fields

; ============================================= ;
;  > hashmap_remove                             ;
; --------------------------------------------- ;
;                                               ;
;  Remove a key-value pair to the hashmap.      ;
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
;   ptr value (or NULL)                         ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - ptr hashmap_t                      ;
;    > RDX - ptr key                            ;
;                                               ;
; ============================================= ;

global hashmap_remove
hashmap_remove:
    push            rbp
    push            r11
    push            r12
    push            r13
    push            r14
    sub             rsp, 32

    ; RBP = pointer to hashmap
    mov             rbp, rcx

    ; R11 = pointer to key
    mov             r11, rdx

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
    je              .not_found

    movzx           r8d, byte [r14 + entry_t.slotstate]
    test            r8d, r8d
    je              .next_iter

    mov             rcx, [r14 + entry_t.key]
    mov             rdx, r11
    call            [rbp + hashmap_t.eq_callback]
    test            rax, rax
    je              .found

.next_iter:
    lea             r12, [r12 + 1]
    jmp             .floop

.found:
    mov             rax, [r14 + entry_t.value]
    mov             byte [r14 + entry_t.slotstate], 0
    sub             qword [rbp + hashmap_t.size], 1
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
;  > hashmap_skip_free                          ;
; --------------------------------------------- ;
;                                               ;
;  Skip freeing a key or a value.               ;
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
;  Scope      : Local                           ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   void                                        ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - char16* data                       ;
;                                               ;
; ============================================= ;

hashmap_skip_free:
    ret


; ============================================= ;
;  > hashmap_resize                             ;
; --------------------------------------------- ;
;                                               ;
;  Resize and clean up the hashmap.             ;
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
;    > RCX - ptr hashmap_t                      ;
;    > RDX - uint64 new capacity                ;
;                                               ;
; ============================================= ;

global hashmap_resize
hashmap_resize:
    push    rbp
    push    r12
    push    r13
    push    r14
    push    r15
    push    rdi
    push    rsi
    push    rbx
    sub     rsp, 32 + 8

    ; RBP = hashmap
    mov     rbp, rcx

    ; R13 = new capacity
    mov     r13, rdx

    ; R12 = new_capacity - 1
    lea     r12, [r13 - 1]

    ; R14 = old entries
    mov     r14, [rbp + hashmap_t.entries]
    ; R15 = old capacity
    mov     r15, [rbp + hashmap_t.capacity]

    ; Alloc new entries array
    mov     rcx, r13
    shl     rcx, 3
    call    malloc
    test    rax, rax
    jz      .fail

    ; RSI = new entries
    mov     rsi, rax

    mov     rcx, rax
    mov     rdx, r13
    shl     rdx, 3
    xor     r8,  r8
    call    memset

    ; RBX = iterator
    xor     rbx, rbx
.rehash_loop:
    cmp     rbx, r15
    jae     .done_rehash

    mov     rax, [r14 + rbx * 8]
    test    rax, rax
    jz      .next
    mov     rdi, rax

    movzx   edx, byte [rax + entry_t.slotstate]
    test    edx, edx
    jz      .tombstone

    mov     rcx, [rax + entry_t.key]
    call    [rbp + hashmap_t.hash_callback]
    ; R11 = hash
    mov     r11, rax
.probe_new:
    mov     rax, r11
    and     rax, r12
    shl     rax, 3

    mov     rdx, [rsi + rax]
    test    rdx, rdx
    jnz     .bump_and_probe
    mov     [rsi + rax], rdi
    jmp     .next

.bump_and_probe:
    add     r11, 1
    jmp     .probe_new

.tombstone:
    mov     rcx, [r14 + rbx * 8]
    mov     rcx, [rcx + entry_t.key]
    call    [rbp + hashmap_t.freek_callback]
    mov     rcx, [r14 + rbx * 8]
    mov     rcx, [rcx + entry_t.value]
    call    [rbp + hashmap_t.freev_callback]
    mov     rcx, [r14 + rbx * 8]
    call    free
    jmp     .next

.next:
    add     rbx, 1
    jmp     .rehash_loop

.done_rehash:
    ; Switch tables & cleanup
    mov     [rbp + hashmap_t.entries], rsi
    mov     [rbp + hashmap_t.capacity], r13

    test    r14, r14
    jz      .ok
    mov     rcx, r14
    call    free

.ok:
    mov     eax, 1024
    jmp     .epilog

.fail:
    xor     eax, eax

.epilog:
    add     rsp, 32 + 8
    pop     rbx
    pop     rsi
    pop     rdi
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    ret


; ============================================= ;
;  > hashmap_destroy                            ;
; --------------------------------------------- ;
;                                               ;
;  Destroy the hashmap and the underlying       ;
;  data structures.                             ;
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
;    > RCX - ptr hashmap_t                      ;
;                                               ;
; ============================================= ;

global hashmap_destroy
hashmap_destroy:
    push            rbp
    push            r15
    push            r14
    push            r13
    push            r12
    sub             rsp, 32 + 8

    ; RBP = hashmap
    mov             rbp, rcx

    ; R15 = entries
    mov             r15, [rbp + hashmap_t.entries]

    ; R14 = capacity
    mov             r14, [rbp + hashmap_t.capacity]
    ; R13 = iterator
    xor             r13, r13
.dloop:
    ; R12 = entry
    mov             r12, [r15 + r13 * 8]
    test            r12, r12
    jz              .next
    mov             rcx, [r12 + entry_t.key]
    call            [rbp + hashmap_t.freek_callback]
    mov             rcx, [r12 + entry_t.value]
    call            [rbp + hashmap_t.freev_callback]

    mov             rcx, r12
    call            free

.next:
    add             r13, 1
    cmp             r13, r14
    jb              .dloop

    mov             rcx, r15
    call            free

    mov             rcx, rbp
    call            free

    add             rsp, 32 + 8
    pop             r12
    pop             r13
    pop             r14
    pop             r15
    pop             rbp
    ret

