; ============================================= ;
;  > hashmap.inc                                ;
; --------------------------------------------- ;
;                                               ;
;  Structs and constants related to the         ;
;  hashmap implementation.                      ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  2 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
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
;   > [C] HASHMAP_INITIAL_CAPACITY              ;
;   > [C] HASHMAP_SLOTSTATE_TOMBSTONE           ;
;   > [C] HASHMAP_SLOTSTATE_OCCUPIED            ;
;                                               ;
;   > [S] hashmap_t                             ;
;   > [S] entry_t                               ;
;                                               ;
; ============================================= ;

%ifndef HASHMAP_H
%define HASHMAP_H

%include %strcat(%substr(__FILE__, 0, %strlen(__FILE__) - %strlen("hashmap.inc")), "types.inc")

%define HASHMAP_INITIAL_CAPACITY 8

struc hashmap_t
    .entries:         ptr
    .size:            uint64
    .capacity:        uint64
    .eq_callback:     ptr
    .hash_callback:   ptr
    .printk_callback: ptr
    .printv_callback: ptr
endstruc

struc entry_t
    .key:             ptr
    .value:           ptr
    .slotstate        uint8
endstruc

%define HASHMAP_SLOTSTATE_TOMBSTONE 0
%define HASHMAP_SLOTSTATE_OCCUPIED 1

%endif ; HASHMAP_H
