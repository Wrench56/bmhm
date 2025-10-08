; ============================================= ;
;  > main.asm                                   ;
; --------------------------------------------- ;
;                                               ;
;  Entry point for EFI.                         ;
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
;   > [F] efi_main                              ;
;                                               ;
; ============================================= ;

default rel
bits 64

%include "efilib.inc"
%include "efi_funcs.inc"

extern efi_init_func_table
extern efi_funcs

extern printf_init
extern printf

extern clearscreen_init
extern clearscreen

extern getchar_init

extern ui_mainloop


section .data
    header_msg dw __?utf16?__("> Baremetal Hashmap"), 0x000A, 0x000D, __?utf16?__("> Compiled on "), __?utf16?__(__DATE__), __?utf16?__(" "), __?utf16?__(__TIME__), 0x000A, 0x000D, __?utf16?__("> Source code @ https://github.com/Wrench56/bmhm"), 0x000A, 0x000D, __?utf16?__("> Press H for [H]elp"), 0x000A, 0x000D, 0x0000


section .text

; ============================================= ;
;  > efi_main                                   ;
; --------------------------------------------- ;
;                                               ;
;  Entry point of EFI.                          ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
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
;   int                                         ;
;                                               ;
;  Arguments:                                   ;
;   > RCX - void* handle                        ;
;   > RDX - efi_system_table* system_table      ;
;                                               ;
; ============================================= ;
global efi_main
efi_main:
    push            rbp
    push            r15
    sub             rsp, 32 + 8

    ; Initializations
    mov             rbp, rdx
    call            efi_init_func_table
    lea             r15, [rel efi_funcs]

    mov             rcx, rbp
    call            printf_init

    mov             rcx, rbp
    call            getchar_init

    mov             rcx, rbp
    call            clearscreen_init

    ; Clear the screen
    call            clearscreen

    ; Print header
    lea             rcx, [rel header_msg]
    call            printf

    call            ui_mainloop

    xor             rax, rax
    add             rsp, 32 + 8
    pop             r15
    pop             rbp
    ret
