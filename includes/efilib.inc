; ============================================= ;
;  > efilib.inc                                 ;
; --------------------------------------------- ;
;                                               ;
;  UEFI structure definitions and constants.    ;
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
;   > [S] efi_system_table                      ;
;   > [S] efi_table_header                      ;
;   > [S] efi_simple_text_output_protocol       ;
;                                               ;
; ============================================= ;

%ifndef EFILIB_H
%define EFILIB_H
%include %strcat(%substr(__FILE__, 0, %strlen(__FILE__) - %strlen("efilib.inc")), "types.inc")

struc efi_table_header
    .Signature:             uint64
    .Revision:              uint32
    .HeaderSize:            uint32
    .CRC32:                 uint32
    .Reserved:              uint32
endstruc

struc efi_system_table
    .Hdr:                   resb sizeof(efi_table_header)    ; EFI_TABLE_HEADER
    .FirmwareVendor:        ptr                              ; CHAR16*
    .FirmwareRevision:      uint32                           ; UINT32
    alignb 8
    .ConsoleInHandle:       ptr                              ; EFI_HANDLE
    .ConIn:                 ptr                              ; EFI_SIMPLE_TEXT_INPUT_PROTOCOL*
    .ConsoleOutHandle:      ptr                              ; EFI_HANDLE
    .ConOut:                ptr                              ; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL*
    .StandardErrorHandle:   ptr                              ; EFI_HANDLE
    .StdErr:                ptr                              ; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL*
    .RuntimeServices:       ptr                              ; EFI_RUNTIME_SERVICES*
    .BootServices:          ptr                              ; EFI_BOOT_SERVICES*
    .NumberOfTableEntries:  uint64                           ; UINTN (64-bit on x64)
    .ConfigurationTable:    ptr                              ; EFI_CONFIGURATION_TABLE*
endstruc

struc efi_simple_text_output_protocol
    .Reset:                 ptr                              ; EFI_TEXT_RESET
    .OutputString:          ptr                              ; EFI_TEXT_STRING
    .TestString:            ptr                              ; EFI_TEXT_TEST_STRING
    .QueryMode:             ptr                              ; EFI_TEXT_QUERY_MODE
    .SetMode:               ptr                              ; EFI_TEXT_SET_MODE
    .SetAttribute:          ptr                              ; EFI_TEXT_SET_ATTRIBUTE
    .ClearScreen:           ptr                              ; EFI_TEXT_CLEAR_SCREEN
    .SetCursorPosition:     ptr                              ; EFI_TEXT_SET_CURSOR_POSITION
    .EnableCursor:          ptr                              ; EFI_TEXT_ENABLE_CURSOR
    .Mode:                  ptr                              ; SIMPLE_TEXT_OUTPUT_MODE*
endstruc

%endif ; EFILIB_H
