start:
    mov ah, 0
    int 16h             ; várj billentyűre

    ; PIT programozás 440 Hz-re
    mov al, 0b6
    out 43h, al

    mov ax, 1193180
    mov bx, 440
    xor dx, dx
    div bx
    mov bx, ax

    mov al, bl
    out 42h, al
    mov al, bh
    out 42h, al

    ; speaker bekapcsolás
    in al, 61h
    or al, 3
    out 61h, al

    ; azonnal kikapcsoljuk a hangszórót
    in al, 61h
    and al, 0fc
    out 61h, al

    jmp start
