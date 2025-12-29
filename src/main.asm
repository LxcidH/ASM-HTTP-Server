global _start

section .bss
    socket_fd: resq 1
    accept_fd: resq 1
    buffer: resq 100

section .data
    http_response:
        ; Status line
        db "HTTP/1.1 200 OK", 0x0D, 0x0A

        ; Headers
        db "Content-Type: text/html", 0x0D, 0x0A
        db "Connection: close", 0x0D, 0x0A

        ; The blank line
        db 0x0D, 0x0A

        ; The body
        db "<h1>Hello from ASM!</h1>", 0x0D, 0x0A
        db "<p>This is insane, we're literally in ASM rn</p>", 0x0D, 0x0A

    http_response_len equ $-http_response
    
    ; The sockaddr_in struct (16 bytes)
    pop_sa:
        dw 2            ; sin_family: AF_INET (2 bytes) -> 0x0002
                        ; (x86 stores this as 02 00, which is fine for local constants)
        
        db 0x1F, 0x90   ; sin_port: port 8080 (2 bytes)
                        ; We write the high byte (1F), then the low byte (90)
                        ; so memory is [1F][90] (big endian)

        dd 0            ; sin_addr: 0.0.0.0 (4 bytes) -> 0x00000000

        dq 0            ; sin_zero: padding (8 bytes) -> all zeros

section .text
_start:
    ; SYS_SOCKET - create the endpoint
    mov rax, 41
    mov rdi, 2          ; AF_INET
    mov rsi, 1          ; SOCK_STREAM
    mov rdx, 0
    syscall

    ; Check if RAX is valid, if so,
    ; Save the file descriptor
    cmp rax, 0
    jl handle_error

    mov [socket_fd], rax


    ; SYS_BIND - Assign an address
    mov rax, 49
    mov rdi, [socket_fd]
    mov rsi, pop_sa
    mov rdx, 16         ; struct size in bytes
    syscall

    ; SYS_LISTEN - wait for connections
    mov rax, 50
    mov rdi, [socket_fd]
    mov rsi, 10
    syscall

SYS_ACCEPT:    ; Handshake
    mov rax, 43
    mov rdi, [socket_fd]
    mov rsi, 0
    mov rdx, 0
    syscall

    cmp rax, 0
    jl handle_error
    mov [accept_fd], rax
    syscall

    ; SYS_READ - recieve the request
    mov rax, 0
    mov rdi, [accept_fd]
    mov rsi, buffer
    mov rdx, 800
    syscall 

    ; SYS_WRITE - send the response
    mov rax, 1
    mov rdi, [accept_fd]
    mov rsi, http_response
    mov rdx, http_response_len
    syscall

    ; SYS_CLOSE
    mov rax, 3
    mov rdi, [accept_fd]
    syscall

exit:
    mov rax, 60
    mov rdi, 0
    syscall

handle_error:
    mov rax, 60
    mov rdi, 1
    syscall
