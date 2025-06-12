[org 0x7c00]
[bits 16]

CODE_SEG equ 0x08
DATA_SEG equ 0x10

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov [BOOT_DISK], dl          ; elmentjük a bootoló lemezt

    ; kernel betöltése 0x1000-re (32 bites kód)
    mov ah, 0x02                 ; BIOS read sector
    mov al, 1                    ; 1 szektort olvasunk
    mov ch, 0                    ; cylinder
    mov cl, 2                    ; 2. szektor
    mov dh, 0                    ; head
    mov dl, [BOOT_DISK]          ; boot drive
    mov bx, 0x1000               ; cél: 0x1000
    int 0x13
    jc disk_error

    ; GDT beállítása
    cli
    lgdt [GDT_descriptor]

    ; védett mód engedélyezése
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; jmp 32 bites kódra, flusholni kell a pipelinet
    jmp CODE_SEG:start_protected_mode

disk_error:
    mov si, disk_msg
    call print
    jmp $

print:
    mov ah, 0x0e
.repeat:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .repeat
.done:
    ret

disk_msg: db "Disk read error!", 0

; GDT szegmensek
GDT_start:
    GDT_null:
        dq 0x0000000000000000

    GDT_code:
        dw 0xFFFF              ; limit
        dw 0x0000              ; base low
        db 0x00                ; base middle
        db 10011010b           ; access
        db 11001111b           ; granularity
        db 0x00                ; base high

    GDT_data:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 10010010b
        db 11001111b
        db 0x00

GDT_end:

GDT_descriptor:
    dw GDT_end - GDT_start - 1
    dd GDT_start

[bits 32]
start_protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000           ; stack pointer beállítása

    jmp 0x08:0x1000            ; átadás a kernelnek (0x08 = CODE_SEG)

BOOT_DISK: db 0

times 510-($-$$) db 0
dw 0xAA55
