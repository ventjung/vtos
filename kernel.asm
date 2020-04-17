	BITS 16

	; set stack segment

	mov ax, 0
	mov ss, ax
	mov ax, 1000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; welcome message

	call clear_screen
	mov si, welcome_text
	call print_string
	mov si, help_text
	call print_string

	; command line interface loop

get_command:
	mov di, command
	mov cx, 32
	rep stosb
	mov si, prompt
	call print_string
	mov ax, input
	mov bx, 64
	call input_string
	call print_newline
	mov si, input
	cmp byte [si], 0
	je get_command
	mov ax, input
	mov si, input
	mov di, cls_string
	call string_compare
	jc near clear_screen_command	; if CLS command is entered
	mov si, invalid_msg
	call print_string
	jmp get_command

; CLS command

clear_screen_command:
	call clear_screen
	jmp get_command

; command - clear screen

clear_screen:
	pusha
	mov dx, 0
	call move_cursor
	mov ah, 6
	mov al, 0
	mov bh, 7
	mov cx, 0
	mov dh, 24
	mov dl, 79
	int 10h
	popa
	ret

; helper - print screen

print_string:
	pusha
	mov ah, 0Eh
.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat
.done:
	popa
	ret

; helper - move cursor

move_cursor:
	pusha
	mov bh, 0
	mov ah, 2
	int 10h
	popa
	ret

; helper - get cursor position

get_cursor_pos:
	pusha
	mov bh, 0
	mov ah, 3
	int 10h
	mov [.tmp], dx
	popa
	mov dx, [.tmp]
	ret
	.tmp dw 0

; helper - print newline

print_newline:
	pusha
	mov ah, 0Eh
	mov al, 13
	int 10h
	mov al, 10
	int 10h
	popa
	ret

; helper - wait for key (used in input string)

wait_for_key:
	mov ah, 0x11
	int 0x16
	jnz .key_pressed
	hlt
	jmp wait_for_key
.key_pressed:
	mov ah, 0x10
	int 0x16
	ret

; helper - input string

input_string:
	pusha
	cmp bx, 0
	je .done
	mov di, ax
	dec bx
	mov cx, bx
.get_char:
	call wait_for_key
	cmp al, 8
	je .backspace
	cmp al, 13
	je .end_string
	jcxz .get_char
	cmp al, ' '
	jb .get_char
	cmp al, 126
	ja .get_char
	call .add_char
	dec cx
	jmp .get_char
.end_string:
	mov al, 0
	stosb
.done:
	popa
	ret
.backspace:
	cmp cx, bx 
	jae .get_char
	inc cx
	call .reverse_cursor
	mov al, ' '
	call .add_char
	call .reverse_cursor
	jmp .get_char
.reverse_cursor:
	dec di
	call get_cursor_pos
	cmp dl, 0
	je .back_line
	dec dl
	call move_cursor
	ret
.back_line:
	dec dh
	mov dl, 79
	call move_cursor
	ret
.add_char:
	stosb
	mov ah, 0x0E
	mov bh, 0
	push bp
	int 0x10
	pop bp
	ret

; helper - string compare

string_compare:
	pusha
.more:
	mov al, [si]
	mov bl, [di]
	cmp al, bl
	jne .not_same
	cmp al, 0
	je .terminated
	inc si
	inc di
	jmp .more
.not_same:
	popa
	clc
	ret
.terminated:
	popa
	stc
	ret

; variables

	input			times 64 db 0
	command			times 32 db 0
	prompt			db '> ', 0
	welcome_text	db 'Welcome to VTOS!', 13, 10, 0
	help_text		db 'Commands: CLS', 13, 10, 0
	invalid_msg		db 'No such command or program', 13, 10, 0
	cls_string		db 'CLS', 0
