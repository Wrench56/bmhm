; ============================================= ;
;  > ui.asm                                     ;
; --------------------------------------------- ;
;                                               ;
;  Implements the main UI interface.            ;
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
;   > [F] ui_mainloop                           ;
;                                               ;
; ============================================= ;

default rel

%include "efilib.inc"
%include "hashmap.inc"

extern printf
extern getchar
extern clearscreen
extern malloc

extern efi_funcs

%include "src/ui/ui_helpers.asm"

extern hashmap_default_init
extern hashmap_dump
extern hashmap_add
extern hashmap_get
extern hashmap_remove

section .data
    separator   dw __?utf16?__("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"), 0x000A, 0x000D, 0x000
    help_msg dw __?utf16?__("-=-= HELP =-=-"), 0x000A, 0x000D, \
            __?utf16?__(" * [A]dd (key, value)"), 0x000A, 0x000D, \
            __?utf16?__(" * [G]et (key)"), 0x000A, 0x000D, \
            __?utf16?__(" * [R]emove (key)"), 0x000A, 0x000D, \
            __?utf16?__(" * [D]ump hashmap"), 0x000A, 0x000D, \
            __?utf16?__(" * [M]ake new hashmap"), 0x000A, 0x000D, \
            __?utf16?__(" * [C]lear screen"), 0x000A, 0x000D, \
            __?utf16?__(" * [H]elp"), 0x000A, 0x000D, \
            __?utf16?__(" * [Q]uit"), 0x000A, 0x000D, 0x0000
    ask_quit    dw __?utf16?__(" Do you want to quit? [Y/N]: "), 0x0000
    ask_key     dw __?utf16?__(" Key: "), 0x0000
    ask_val     dw __?utf16?__(" Value: "), 0x0000
    added_msg   dw 0x000A, 0x000D, __?utf16?__("[ ok ] Added!"), 0x000A, 0x000D, 0x0000
    get_not_fnd dw 0x000A, 0x000D, __?utf16?__("[fail] Get returned NULL!"), 0x000A, 0x000D, 0x0000
    get_fnd_pre dw 0x000A, 0x000D, __?utf16?__("[ ok ] Get returned: "), 0x0000
    rm_not_fnd  dw 0x000A, 0x000D, __?utf16?__("[fail] Nothing removed (NULL returned)"), 0x0000
    rm_fnd_pre  dw 0x000A, 0x000D, __?utf16?__("[ ok ] Removed pair with value: "), 0x0000
    hm_reset    dw 0x000A, 0x000D, __?utf16?__("[ ok ] New hashmap created!"), 0x0000

section .text

; ============================================= ;
;  > ui_mainloop                                ;
; --------------------------------------------- ;
;                                               ;
;  Entry point of UI.                           ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
;  Extensions : None                            ;
;  Libraries  : None                            ;
;  ABI used   : Microsoft x64 / custom          ;
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
;   void                                        ;
;                                               ;
; ============================================= ;
global ui_mainloop
ui_mainloop:
    push            rbp
    push            r14
    sub             rsp, 32 + 8

    call            hashmap_default_init
    mov             rbp, rax

.poll:
    call            getchar
    
    cmp             ax, 'G'
    je              .get
    cmp             ax, 'A'
    je              .add
    cmp             ax, 'R'
    je              .remove
    cmp             ax, 'D'
    je              .dump
    cmp             ax, 'M'
    je              .reset
    cmp             ax, 'C'
    je              .cls
    cmp             ax, 'H'
    je              .help
    cmp             ax, 'Q'
    jne             .poll

    lea             rcx, [rel ask_quit]
    call            showprompt
    call            getchar
    cmp             ax, 'Y'
    jne             .poll

    add             rsp, 32 + 8
    pop             r14
    pop             rbp
    ret

.help:
    lea             rcx, [rel help_msg]
    call            printf
    jmp             .poll

.dump:
    mov             rcx, rbp
    call            hashmap_dump
    jmp             .poll

.add:
    lea             rcx, [rel ask_key]
    call            readcopy16
    mov             r14, rax

    lea             rcx, [rel ask_val]
    call            readcopy16
    mov             r8, rax

    mov             rcx, rbp
    mov             rdx, r14
    call            hashmap_add

    lea             rcx, [rel added_msg]
    call            printf
    jmp             .poll

.get:
    lea             rcx, [rel ask_key]
    call            readcopy16

    mov             rcx, rbp
    mov             rdx, rax
    call            hashmap_get
    test            rax, rax
    jz              .get_not_found
    mov             r14, rax

    lea             rcx, [rel get_fnd_pre]
    call            printf

    mov             rcx, r14
    call            [rbp + hashmap_t.printv_callback]
    mov             rcx, rax
    call            printf

    mov             qword [rsp + 32], 0x00000000000D000A
    lea             rcx, [rsp + 32]
    call            printf

    jmp             .poll

.get_not_found:
    lea             rcx, [rel get_not_fnd]
    call            printf
    jmp             .poll

.remove:
    lea             rcx, [rel ask_key]
    call            readcopy16

    mov             rcx, rbp
    mov             rdx, rax
    call            hashmap_remove
    test            rax, rax
    jz              .remove_null
    mov             r14, rax

    lea             rcx, [rel rm_fnd_pre]
    call            printf

    mov             rcx, r14
    call            [rbp + hashmap_t.printv_callback]
    mov             rcx, rax
    call            printf

    mov             qword [rsp + 32], 0x00000000000D000A
    lea             rcx, [rsp + 32]
    call            printf


    jmp             .poll

.remove_null:
    lea             rcx, [rel rm_not_fnd]
    call            printf
    jmp             .poll

.cls:
    call            clearscreen
    jmp             .poll

.reset:
    ; TODO: Destroy old hashmap
    call            hashmap_default_init
    mov             rbp, rax
    lea             rcx, [rel hm_reset]
    call            printf
    jmp             .poll
