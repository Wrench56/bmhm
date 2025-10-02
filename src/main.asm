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
;  Extensions : SHA-NI                          ;
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
    sub             rsp, 32 + 8
    
    ; Clear the screen
    mov             rcx, [rdx + efi_system_table.ConOut]
    mov             r11, [rcx + efi_simple_text_output_protocol.ClearScreen]
    call            r11

    add             rsp, 32 + 8
    xor             rax, rax
    ret
