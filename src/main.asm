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


section .data
    header_msg dw __?utf16?__("> Baremetal Hashmap v0.0.1"), 0x000A, 0x000D, __?utf16?__("> Boot done!"), 0x000A, 0x000D, 0x0000
    ptra dq 0
section .text

; ============================================= ;
;  > efi_main                                   ;
; --------------------------------------------- ;
;                                               ;
;  Entry point of EFI.                          ;
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

    mov             rbp, rdx
    call            efi_init_func_table
    lea             r15, [rel efi_funcs]

    ; Clear the screen
    mov             rcx, [rbp + efi_system_table.ConOut]
    call            [r15 + efi_func_table.ClearScreen]

    ; Print header
    mov             rcx, [rbp + efi_system_table.ConOut]
    lea             rdx, [rel header_msg]
    call            [r15 + efi_func_table.OutputString]

    xor             rax, rax
    add             rsp, 32 + 8
    pop             r15
    pop             rbp
    ret
