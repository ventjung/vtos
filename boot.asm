	BITS 16

	jmp short start
	nop

; disk description table

OEMLabel			db "VTOS    "
BytesPerSector		dw 512
SectorsPerCluster	db 1
ReservedForBoot		dw 1
NumberOfFats		db 2
RootDirEntries		dw 224
LogicalSectors		dw 2880
MediumByte			db 0F0h
SectorsPerFat		dw 9
SectorsPerTrack		dw 18
Sides				dw 2
HiddenSectors		dd 0
LargeSectors		dd 0
DriveNo				dw 0
Signature			db 41
VolumeID			dd 00000000h
VolumeLabel			db "VTOS       "
FileSystem			db "FAT12   "

; main code

start:
	mov ax, 07C0h
	mov ds, ax

	; search floppy for kernel.bin
	
	mov ax, 19				
	call l2hts
	mov si, buffer	
	mov bx, ds
	mov es, bx
	mov bx, si
	mov ah, 2			
	mov al, 14			
	int 13h				
	mov ax, ds			
	mov es, ax			
	mov di, buffer
	mov cx, word [RootDirEntries]	
	mov ax, 0			
	xchg cx, dx			
	mov si, kernel_filename		
	mov cx, 11
	rep cmpsb
	mov ax, word [es:di+0Fh]	
	mov word [cluster], ax
	mov ax, 1			
	call l2hts
	mov di, buffer	
	mov bx, di
	mov ah, 2			
	mov al, 9			
	pusha
	int 13h
	popa
	mov bx, 0
	mov ah, 2	
	mov al, 1
	push ax

	; load kernel.bin to 1000h

load_file_sector:
	mov ax, word [cluster]
	add ax, 31
	call l2hts
	mov ax, 1000h
	mov es, ax
	mov bx, word [pointer]
	pop ax
	push ax
	stc
	int 13h
	mov ax, [cluster]
	mov dx, 0
	mov bx, 3
	mul bx
	mov bx, 2
	div bx
	mov si, buffer
	add si, ax
	mov ax, word [ds:si]
	or dx, dx
	jz even
						
odd:
	shr ax, 4			
	jmp short next_cluster_cont

even:
	and ax, 0FFFh

next_cluster_cont:
	mov word [cluster], ax
	cmp ax, 0FF8h
	jae end
	add word [pointer], 512
	jmp load_file_sector

; kernel.bin is loaded

end:					
	pop ax
	mov dl, 0
	jmp 1000h:0000h

; helper to calculate head, track and sector settings for int 13h

l2hts:
	push bx
	push ax
	mov bx, ax
	mov dx, 0
	div word [SectorsPerTrack]
	add dl, 01h
	mov cl, dl
	mov ax, bx
	mov dx, 0
	div word [SectorsPerTrack]
	mov dx, 0
	div word [Sides]
	mov dh, dl
	mov ch, al
	pop ax
	pop bx
	mov dl, 0
	ret

; variables

	kernel_filename	db "KERNEL  BIN"
	cluster		dw 0
	pointer		dw 0

; end of boot sector

	times 510-($-$$) db 0
	dw 0AA55h

; buffer

buffer: