; ============================================= ;
;  > efi_funcs.inc                              ;
; --------------------------------------------- ;
;                                               ;
;  UEFI function v-table.                       ;
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
;   > [S] efi_func_table                        ;
;                                               ;
; ============================================= ;

%ifndef EFI_FUNCS_H
%define EFI_FUNCS_H

%include "efilib.inc"

struc efi_func_table
    .ClearScreen:        ptr
    .OutputString:       ptr
    .SetCursorPosition   ptr

    .AllocatePool        ptr
    .FreePool            ptr
endstruc

%endif ; EFI_FUNCS_H
