cli                             ; clear interupt

mov al, 'V'                     ; set al to 'V'
mov ah, 0x0E                    ; set ah to 0e (bios service code to print character)
int 0x10                        ; interupt vector 10

times 510-($-$$) db 0           ; fill the rest with 0 except last two bytes
db 0x55                         ; 0x55 (second last byte)
db 0xAA                         ; 0xAA (last byte)