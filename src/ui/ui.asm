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

%include "efilib.inc"


extern printf
extern getchar
extern efi_funcs


section .data
    separator dw __?utf16?__("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"), 0x000A, 0x000D, 0x000
    help_msg dw __?utf16?__("-=-= HELP =-=-"), 0x000A, 0x000D, __?utf16?__(" * [Q]uit"), 0x000A, 0x000D, __?utf16?__(" * [H]elp"), 0x000A, 0x000D, 0x0000
    ask_quit dw __?utf16?__(" Do you want to quit? [Y/N]: "), 0x0000


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
    sub             rsp, 32 + 8

.poll:
    call            getchar
    
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
    ret
.help
    lea             rcx, [rel help_msg]
    call            printf
    jmp             .poll

; ============================================= ;
;  > showprompt                                 ;
; --------------------------------------------- ;
;                                               ;
;  Show a prompt with a separator.              ;
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
;   RCX - ptr message                           ;
;                                               ;
; ============================================= ;
showmsg:
    push            rbp
    sub             rsp, 32

    mov             rbp, rcx

    lea             rcx, [rel separator]
    call            printf

    mov             rcx, rbp
    call            printf

    add             rsp, 32
    pop             rbp
    ret
