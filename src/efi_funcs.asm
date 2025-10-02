; ============================================= ;
;  > efi_funcs.asm                              ;
; --------------------------------------------- ;
;                                               ;
;  Loads UEFI functions into a table.           ;
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
;   > [F] efi_init_func_table                   ;
;                                               ;
;   > [P] efi_funcs                             ;
;                                               ;
; ============================================= ;

default rel
bits 64

%include "efilib.inc"
%include "efi_funcs.inc"

section .bss
    global efi_funcs
    efi_funcs: resb sizeof(efi_func_table)


section .text

; ============================================= ;
;  > efi_init_func_table                        ;
; --------------------------------------------- ;
;                                               ;
;  Entry point of EFI.                          ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
;  Updated    :  2 Oct 2025                     ;
;  Extensions : None                            ;
;  Libraries  : None                            ;
;  ABI used   : Microsoft x64 / custom          ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Scope      : Global                          ;
;  Effects    : Does NOT change RDX or RCX but  ;
;               does change R8, R10, R11        ;
;                                               ;
;  Returns:                                     ;
;   void                                        ;
;                                               ;
;  Arguments:                                   ;
;   > RCX - void* handle                        ;
;   > RDX - efi_system_table* system_table      ;
;                                               ;
; ============================================= ;
global efi_init_func_table
efi_init_func_table:
    lea             r8, [rel efi_funcs]

    ; Simple text output protocol functions
    mov             r10, [rdx + efi_system_table.ConOut]
    mov             r11, [r10 + efi_simple_text_output_protocol.ClearScreen]
    mov             [r8 + efi_func_table.ClearScreen], r11
    mov             r11, [r10 + efi_simple_text_output_protocol.OutputString]
    mov             [r8 + efi_func_table.OutputString], r11
    mov             r11, [r10 + efi_simple_text_output_protocol.SetCursorPosition]
    mov             [r8 + efi_func_table.SetCursorPosition], r11

    ret
