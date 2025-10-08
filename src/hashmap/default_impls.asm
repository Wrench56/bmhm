; ============================================= ;
;  > default_impls.asm                          ;
; --------------------------------------------- ;
;                                               ;
;  Provides sane default callbacks for a        ;
;  UTF-16 string - UTF-16 string hashmap.       ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
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
;   > [F] init_default_hashmap                  ;
;                                               ;
; ============================================= ;


extern malloc
extern free
extern printf

extern fnv1a64_hash

extern hashmap_init
extern hashmap_set_frees

section .text

; ============================================= ;
;  > hashmap_default_init                       ;
; --------------------------------------------- ;
;                                               ;
;  Create the default hashmap.                  ;
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


global hashmap_default_init
hashmap_default_init:
    push            rbp
    sub             rsp, 32

    lea             rcx, [rel eq_callback]
    lea             rdx, [rel hash_callback]
    lea             r8, [rel printk_callback]
    lea             r9, [rel printv_callback]
    call            hashmap_init
    mov             rbp, rax

    mov             rcx, rax
    lea             rdx, [rel freek_callback]
    lea             r8, [rel freev_callback]
    call            hashmap_set_frees

    add             rsp, 32
    pop             rbp
    ret


; ============================================= ;
;  > hash_callback                              ;
; --------------------------------------------- ;
;                                               ;
;  Generates the hash of a UTF-16 key.          ;
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
;  Scope      : Local                           ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   uint64 hash                                 ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - char16* key                        ;
;                                               ;
; ============================================= ;

hash_callback:
    push            rax
    mov             r9, rcx
    xor             edx, edx
.hash_len_loop:
    movzx           eax, word [r9 + rdx*2]
    test            ax, ax
    je              .len_done
    inc             rdx
    jmp             .hash_len_loop
.len_done:
    shl             rdx, 1
    mov             rcx, r9
    call            fnv1a64_hash
    ror             rax, 32
    pop             rcx
    ret


; ============================================= ;
;  > eq_callback                                ;
; --------------------------------------------- ;
;                                               ;
;  Compares two keys together. Returns 0 if     ;
;  they match, non-null if they don't.          ;
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
;  Scope      : Local                           ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   uint8 match                                 ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - char16* key1                       ;
;    > RDX - char16* key2                       ;
;                                               ;
; ============================================= ;

eq_callback:
    cmp     rcx, rdx
    je      .eq
.eq_loop:
    movzx   eax, word [rcx]
    movzx   r8d, word [rdx]
    cmp     ax, r8w
    jne     .ne
    test    ax, ax
    je      .eq
    add     rcx, 2
    add     rdx, 2
    jmp     .eq_loop
.eq:
    xor     rax, rax
    ret
.ne:
    mov     rax, 1
    ret


; ============================================= ;
;  > printk_callback                            ;
; --------------------------------------------- ;
;                                               ;
;  Returns the given key string as-is.          ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
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
;   char16* string                              ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - char16* key                        ;
;                                               ;
; ============================================= ;

printk_callback:


; ============================================= ;
;  > printv_callback                            ;
; --------------------------------------------- ;
;                                               ;
;  Returns the given value string as-is.        ;
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
;  Scope      : Local                           ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   char16* string                              ;
;                                               ;
;  Arguments:                                   ;
;    > RCX - char16* value                      ;
;                                               ;
; ============================================= ;

printv_callback:
    mov             rax, rcx
    ret


; ============================================= ;
;  > freek_callback                             ;
; --------------------------------------------- ;
;                                               ;
;  Frees the resources associated with the      ;
;  key.                                         ;
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
;    > RCX - char16* value                      ;
;                                               ;
; ============================================= ;

freek_callback:


; ============================================= ;
;  > freev_callback                             ;
; --------------------------------------------- ;
;                                               ;
;  Frees the resources associated with the      ;
;  value.                                       ;
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
;    > RCX - char16* value                      ;
;                                               ;
; ============================================= ;

freev_callback:
    sub             rsp, 32 + 8

    call            free

    add             rsp, 32 + 8
    ret
