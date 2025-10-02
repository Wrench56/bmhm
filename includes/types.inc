; ============================================= ;
;  > types.inc                                  ;
; --------------------------------------------- ;
;                                               ;
;  Common type aliases and constants.           ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
;  Updated    :  2 Oct 2025                     ;
;  Version    : 1.0.0                           ;
;  License    : MIT                             ;
;  Libraries  : None                            ;
;  ABI used   : None                            ;
;  Arch       : x64/AMD64                       ;
;  Extensions : None                            ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Exports:                                     ;
;   > [C] NULL                                  ;
;   > [C] uint64                                ;
;   > [C] int64                                 ;
;   > [C] uint32                                ;
;   > [C] int32                                 ;
;   > [C] uint16                                ;
;   > [C] int16                                 ;
;   > [C] uint8                                 ;
;   > [C] int8                                  ;
;   > [C] char16                                ;
;   > [C] char8                                 ;
;   > [C] ptr                                   ;
;                                               ;
;   > [M] sizeof                                ;
;                                               ;
; ============================================= ;

%ifndef TYPES_H
%define TYPES_H

%define NULL 0

%define uint64 resq 1
%define int64  resq 1

%define uint32 resd 1
%define int32  resd 1

%define uint16 resw 1
%define int16  resw 1

%define uint8  resb 1
%define int8   resb 1

%define char16 resw 1
%define char8  resb 1

%define ptr    resq 1

%define sizeof(struc_type_name) (struc_type_name %+ _size)

%endif ; TYPES_H
