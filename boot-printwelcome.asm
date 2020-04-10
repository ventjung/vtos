[ORG 0x7c00]                        ; set our program to run at 0x0000 - 0x7c00 
        
    cli                             ; clear interupt

    mov ax, 0                       ; set ax to 0
    mov ds, ax                      ; initialize data segment from 0
    mov si, msg                     ; set si to msg (source index register) will be used by lodsb

ch_loop:
    lodsb                           ; load character of msg to al
    or al, al                       ; check if al zero then
    jz end                          ; goto end (if al zero)
    mov ah, 0x0E                    ; set ah to 0e (bios service code to print character)
    int 0x10                        ; call interupt 10
    jmp ch_loop                     ; goto ch_loop
    
end:
    jmp end                         ; trap the process after print all characters

    ; declare and set variable msg with double bytes 'Hello World' + newline
    msg db 'Welcome To Ventjung Technology Operating System!', 13, 10

    times 510-($-$$) db 0           ; fill the rest with 0 except last two bytes
    db 0x55                         ; 0x55 (second last byte)
    db 0xAA                         ; 0xAA (last byte)