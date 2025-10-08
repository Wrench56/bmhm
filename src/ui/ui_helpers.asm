section .bss
    _linebuf    resw 256
    _echobuf    resq 1

section .code

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
;  Scope      : Local                           ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   void                                        ;
;                                               ;
;  Arguments:                                   ;
;   RCX - ptr message                           ;
;                                               ;
; ============================================= ;
showprompt:
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


; ============================================= ;
;  > readline16                                 ;
; --------------------------------------------- ;
;                                               ;
;  Read a UTF-16 line with echo/backspace       ;
;  support. Stop on enter.                      ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
;  Extensions : None                            ;
;  Libraries  : None                            ;
;  ABI used   : Microsoft x64                   ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Scope      : Local                           ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   uint64 length in bytes                      ;
;                                               ;
;  Arguments:                                   ;
;   RCX - char16* dest buffer                   ;
;   RDX - uint64 max chars                      ;
;                                               ;
; ============================================= ;
readline16:
    push            rbx
    push            r15
    push            r14
    push            r13
    push            rdi
    sub             rsp, 32 + 8

    ; RDI = destination buffer
    mov             rdi, rcx
    ; R13 = max characters
    mov             r13, rdx

    ; R14 = current length
    xor             r14, r14
.rl_loop:
    call            getchar
    movzx           ebx, al

    ; Enter pressed
    cmp             bl, 0x0D
    je              .finish
    cmp             bl, 0x0A
    je              .finish

    ; Handle backspace
    cmp             bl, 0x08
    jne             .check_char
    test            r14, r14
    jz              .rl_loop
    dec             r14

    ; Erase character
    mov             rax, 0x0000000800200008
    mov             [_echobuf], rax
    lea             rcx, [_echobuf]
    call            printf
    jmp             .rl_loop

.check_char:
    ; Check if char is within printable ASCII range
    cmp             bl, 0x20
    jb              .rl_loop
    cmp             bl, 0x7E
    ja              .rl_loop

    ; Check if there is enough space in buffer
    cmp             r14, r13
    jae             .rl_loop

    ; Store & echo
    mov             word [rdi + r14*2], bx
    mov             word [_echobuf], bx
    mov             word [_echobuf+2], 0
    lea             rcx, [_echobuf]
    call            printf
    inc             r14
    jmp             .rl_loop

.finish:
    ; Print newline
    mov             word [rdi + r14*2], 0
    mov             rax, 0x00000000000D000A
    mov             [_echobuf], rax
    lea             rcx, [_echobuf]
    call            printf

    mov             rax, r14

    add             rsp, 32 + 8
    pop             rdi
    pop             r13
    pop             r14
    pop             r15
    pop             rbx
    ret


; ============================================= ;
;  > readcopy16                                 ;
; --------------------------------------------- ;
;                                               ;
;  A wrapper for readline16() that prints the   ;
;  separator, a custom prompt and copies the    ;
;  final readings into a new allocated buffer.  ;
;                                               ;
;  Author(s)  : Mark Devenyi                    ;
;  Created    :  7 Oct 2025                     ;
;  Updated    :  7 Oct 2025                     ;
;  Extensions : None                            ;
;  Libraries  : None                            ;
;  ABI used   : Microsoft x64                   ;
;                                               ;
; --------------------------------------------- ;
;                                               ;
;  Scope      : Local                           ;
;  Effects    : None                            ;
;                                               ;
;  Returns:                                     ;
;   ptr buffer on the heap                      ;
;                                               ;
;  Arguments:                                   ;
;   RCX - char16* prompt text                   ;
;                                               ;
; ============================================= ;
readcopy16:
    push            rbp
    sub             rsp, 32

    ; Show prompt
    mov             rbp, rcx
    lea             rcx, [rel separator]
    call            printf
    mov             rcx, rbp
    call            printf

    ; Read entered text
    lea             rcx, [rel _linebuf]
    mov             rdx, 255
    call            readline16
    mov             r10, rax

    ; Allocate the copy buffer
    lea             rcx, [r10*2 + 2]
    call            malloc
    mov             rdi, rax
    lea             rsi, [rel _linebuf]

    ; Copy
    mov             rcx, r10
    inc             rcx
    cld
    rep             movsw

    add             rsp, 32
    pop             rbp
    ret
