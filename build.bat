@echo off
nasm -O0 -f bin -o boot.bin boot.asm
nasm -O0 -f bin -o kernel.bin kernel.asm
dd count=2 seek=0 bs=512 if=.\boot.bin of=.\floppy.flp
imdisk -a -f floppy.flp -s 1440K -m B:
copy kernel.bin b:\
imdisk -D -m B: