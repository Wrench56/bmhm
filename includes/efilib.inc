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
;   > [S] efi_simple_text_input_protocol        ;
;   > [S] efi_input_key                         ;
;   > [S] efi_boot_services                     ;
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

%define efi_table_header_r resb sizeof(efi_table_header)

struc efi_system_table
    .Hdr:                               efi_table_header_r   ; EFI_TABLE_HEADER
    .FirmwareVendor:                    ptr                  ; CHAR16*
    .FirmwareRevision:                  uint32               ; UINT32
    alignb 8
    .ConsoleInHandle:                   ptr                  ; EFI_HANDLE
    .ConIn:                             ptr                  ; EFI_SIMPLE_TEXT_INPUT_PROTOCOL*
    .ConsoleOutHandle:                  ptr                  ; EFI_HANDLE
    .ConOut:                            ptr                  ; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL*
    .StandardErrorHandle:               ptr                  ; EFI_HANDLE
    .StdErr:                            ptr                  ; EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL*
    .RuntimeServices:                   ptr                  ; EFI_RUNTIME_SERVICES*
    .BootServices:                      ptr                  ; EFI_BOOT_SERVICES*
    .NumberOfTableEntries:              uint64               ; UINTN (64-bit on x64)
    .ConfigurationTable:                ptr                  ; EFI_CONFIGURATION_TABLE*
endstruc

struc efi_simple_text_output_protocol
    .Reset:                             ptr                  ; EFI_TEXT_RESET
    .OutputString:                      ptr                  ; EFI_TEXT_STRING
    .TestString:                        ptr                  ; EFI_TEXT_TEST_STRING
    .QueryMode:                         ptr                  ; EFI_TEXT_QUERY_MODE
    .SetMode:                           ptr                  ; EFI_TEXT_SET_MODE
    .SetAttribute:                      ptr                  ; EFI_TEXT_SET_ATTRIBUTE
    .ClearScreen:                       ptr                  ; EFI_TEXT_CLEAR_SCREEN
    .SetCursorPosition:                 ptr                  ; EFI_TEXT_SET_CURSOR_POSITION
    .EnableCursor:                      ptr                  ; EFI_TEXT_ENABLE_CURSOR
    .Mode:                              ptr                  ; SIMPLE_TEXT_OUTPUT_MODE*
endstruc

struc efi_simple_text_input_protocol
        .Reset:                         ptr                  ; EFI_INPUT_RESET
        .ReadKeyStroke:                 ptr                  ; EFI_INPUT_READ_KEY
        .WaitForKey                     ptr                  ; EFI_EVENT
endstruc

struc efi_input_key
        .ScanCode:                      uint16
        .UnicodeChar:                   char16
endstruc

struc efi_boot_services
    .Hdr:                               efi_table_header_r 

    ; Task Priority Services
    .RaiseTPL:                          ptr
    .RestoreTPL:                        ptr

    ; Memory Services
    .AllocatePages:                     ptr
    .FreePages:                         ptr
    .GetMemoryMap:                      ptr
    .AllocatePool:                      ptr
    .FreePool:                          ptr

    ; Event & Timer Services
    .CreateEvent:                       ptr
    .SetTimer:                          ptr
    .WaitForEvent:                      ptr
    .SignalEvent:                       ptr
    .CloseEvent:                        ptr
    .CheckEvent:                        ptr

    ; Protocol Handler Services
    .InstallProtocolInterface:          ptr
    .ReinstallProtocolInterface:        ptr
    .UninstallProtocolInterface:        ptr
    .HandleProtocol:                    ptr
    .Reserved:                          ptr                  ; VOID*
    .RegisterProtocolNotify:            ptr
    .LocateHandle:                      ptr
    .LocateDevicePath:                  ptr
    .InstallConfigurationTable:         ptr

    ; Image Services
    .LoadImage:                         ptr
    .StartImage:                        ptr
    .Exit:                              ptr
    .UnloadImage:                       ptr
    .ExitBootServices:                  ptr

    ; Miscellaneous Services (EFI 1.0+)
    .GetNextMonotonicCount:             ptr
    .Stall:                             ptr
    .SetWatchdogTimer:                  ptr

    ; DriverSupport Services (EFI 1.1+)
    .ConnectController:                 ptr
    .DisconnectController:              ptr

    ; Open/Close Protocol Services (EFI 1.1+)
    .OpenProtocol:                      ptr
    .CloseProtocol:                     ptr
    .OpenProtocolInformation:           ptr

    ; Library Services (EFI 1.1+)
    .ProtocolsPerHandle:                ptr
    .LocateHandleBuffer:                ptr
    .LocateProtocol:                    ptr
    .InstallMultipleProtocolInterfaces: ptr
    .UninstallMultipleProtocolInterfaces: ptr

    ; 32-bit CRC Services (EFI 1.1+)
    .CalculateCrc32:                    ptr

    ; Miscellaneous Services (EFI 1.1+ / UEFI 2.0+)
    .CopyMem:                           ptr
    .SetMem:                            ptr
    .CreateEventEx:                     ptr                  ; UEFI 2.0+
endstruc

%define EfiReservedMemoryType           0
%define EfiLoaderCode                   1
%define EfiLoaderData                   2
%define EfiBootServicesCode             3
%define EfiBootServicesData             4
%define EfiRuntimeServicesCode          5
%define EfiRuntimeServicesData          6
%define EfiConventionalMemory           7
%define EfiUnusableMemory               8
%define EfiACPIReclaimMemory            9
%define EfiACPIMemoryNVS                10
%define EfiMemoryMappedIO               11
%define EfiMemoryMappedIOPortSpace      12
%define EfiPalCode                      13
%define EfiPersistentMemory             14
%define EfiUnacceptedMemoryType         15
%define EfiMaxMemoryType                16

%endif ; EFILIB_H
