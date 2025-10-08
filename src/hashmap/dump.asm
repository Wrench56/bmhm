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
extern u64_dec_len

extern printf


section .data
    hashmap_hdr     dw 0x000A, 0x000D, __?utf16?__("Hashmap          @ 0x"), 0x0000
    entries_hdr     dw __?utf16?__(" > Entries       @ 0x"), 0x0000
    eqcb_hdr        dw __?utf16?__(" > EQ Callback   @ 0x"), 0x0000
    hashcb_hdr      dw __?utf16?__(" > Hash Callback @ 0x"), 0x0000
    pkcb_hdr        dw __?utf16?__(" > PK Callback   @ 0x"), 0x0000
    pvcb_hdr        dw __?utf16?__(" > PV Callback   @ 0x"), 0x0000
    size_hdr        dw __?utf16?__(" > Size          : "), 0x0000
    capacity_hdr    dw __?utf16?__(" > Capacity      : "), 0x0000
    entries_section dw 0x000A, 0x000D, __?utf16?__("Entries:"), 0x000A, 0x000D, 0x0000
    entry_empty     dw __?utf16?__("[EMPTY]"), 0x0000
    entry_tombstone dw __?utf16?__("[TOMBSTONE]"), 0x0000
    kv_separator    dw __?utf16?__(" - "), 0x0000
    entries_end     dw 0x000A, 0x000D, __?utf16?__("-=-=-=-=-=-=-=-= END =-=-=-=-=-=-=-=-"), 0x000A, 0x000D, 0x000

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
    push            r15
    push            r14
    push            r13
    push            r12
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

    ; Print Key Callback
    lea             rcx, [rel pkcb_hdr]
    call            printf
    mov             rcx, [rbp + hashmap_t.printk_callback]
    lea             rdx, [rsp + 32]
    call            u64_to_hex
    lea             rcx, [rsp + 32]
    call            printf

    ; Print Value Callback
    lea             rcx, [rel pvcb_hdr]
    call            printf
    mov             rcx, [rbp + hashmap_t.printv_callback]
    lea             rdx, [rsp + 32]
    call            u64_to_hex
    lea             rcx, [rsp + 32]
    call            printf

    ; Set new common postfix
    mov             qword [rsp + 32 + 40], 0x00000000000D000A

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

    ; Print out each entry (i: key - value)
    lea             rcx, [rel entries_section]
    call            printf


    ; R12 = capacity of entries
    mov             r12, [rbp + hashmap_t.capacity]
    test            r12, r12
    jz              .done

    mov             rcx, r12
    call            u64_dec_len


    ; R13 = address of entry prefix string
    mov             r13, 20
    sub             r13, rax
    lea             r13, [rsp + 32 + 2 * r13]

    ; Set entry number postfix
    mov             qword [rsp + 32 + 40], 0x000000000020003A

    ; Set newline postfix
    mov             qword [rsp + 32 + 40 + 8], 0x00000000000D000A


    ; R14 = current entry_t address
    mov             r14, [rbp + hashmap_t.entries]

    ; R15 = iterator
    xor             r15, r15
.eloop:
    mov             rcx, r15
    lea             rdx, [rsp + 32]
    call            u64_to_dec

    mov             rcx, r13
    call            printf

    mov             rax, [r14 + r15 * 8]
    test            rax, rax
    jz              .empty
    mov             cl, [rax + entry_t.slotstate]
    test            cl, cl
    jz              .tombstone
    mov             rcx, [rax + entry_t.key]
    call            [rbp + hashmap_t.printk_callback]
    mov             rcx, rax
    call            printf

    lea             rcx, [rel kv_separator]
    call            printf


    mov             rax, [r14 + r15 * 8]
    mov             rcx, [rax + entry_t.value]
    call            [rbp + hashmap_t.printv_callback]
    mov             rcx, rax
    call            printf

.end_entry:
    lea             rcx, [rsp + 32 + 40 + 8]
    call            printf

    add             r15, 1
    cmp             r15, r12
    jne             .eloop

.done:
    lea             rcx, [rel entries_end]
    call            printf

    add             rsp, 32 + 64
    pop             r12
    pop             r13
    pop             r14
    pop             r15
    pop             rbp
    ret

.empty:
    lea             rcx, [rel entry_empty]
    call            printf
    jmp             .end_entry

.tombstone:
    lea             rcx, [rel entry_tombstone]
    call            printf
    jmp             .end_entry
