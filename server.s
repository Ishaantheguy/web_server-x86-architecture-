.intel_syntax noprefix

.section .bss
.lcomm request_buffer, 1024
.lcomm file_buffer, 1024
.section .data
write_path:
.asciz "/home/hacker/server7_file2"
file_path:
.asciz "/home/hacker/server7_file"
http_response:
.asciz "HTTP/1.0 200 OK\r\n\r\n"
response_len:
.int 19

.section .text
.global _start

_start:
mov rax, 41
mov rdi, 2
mov rsi, 1
mov rdx, 0
syscall
mov r8, rax

mov rdi, rax
mov rax, 0x00000000
push rax
mov ax, 0x50
mov rbx, rax
rol bx, 8
push bx
mov ax, 2
push ax
mov rax, 49
mov rsi, rsp
mov rdx, 16
syscall

mov rax, 50
mov rsi, 0
syscall

_loop:
mov rdi, r8
mov rax, 43
mov rsi, 0x00000000
mov rdx, 0x00000000
syscall
mov r9, rax

mov rdi, rax
mov rax, 57
syscall

cmp rax, 0
jl _exit
je _child


mov rdi, r9
mov rax, 3
syscall

jmp _loop

_child:
mov rdi, r9
mov rax, 0
lea rsi, request_buffer
mov rdx, 1024
syscall
mov r15, rax


cmp byte ptr [request_buffer],'G'
je _getter

lea rsi, [request_buffer+5]
mov edi, esi

_compare:
mov al, byte ptr [edi]
cmp al, ' '
je _termination
inc edi
jmp _compare

_termination:
mov byte ptr [edi], 0

lea rbx, [edi+1]

mov rax, 2
mov rdi, rsi
mov rsi,  0x41
mov rdx, 0777
syscall
mov r8, rax
jmp _looping

_nextbyte:
inc rbx

_looping:
mov al, byte ptr [rbx]
cmp al, '\r'
jne _nextbyte
je _ch1
_ch1:
inc rbx
mov al, byte ptr [rbx]

cmp al, '\n'
jne _nextbyte
je _ch2
_ch2:
inc rbx 
mov al, byte ptr [rbx]

cmp al, '\r'
jne _nextbyte
je _ch3
_ch3:
inc rbx 
mov al, byte ptr [rbx]

cmp al, '\n'
jne _nextbyte
je _ch4
_ch4:
inc rbx 
mov al, byte ptr [rbx]

mov rdi, rbx
xor rax, rax
mov byte ptr [request_buffer+r15], 0
mov rcx, r15

_length_finder:
    cmp byte ptr [rdi], 0  
    je _termination2
    cmp rcx, 0         
    je _termination2
    inc rdi
    inc rax
    dec rcx
    jmp _length_finder



_termination2:
mov rdi, r8
mov rdx, rax
mov rsi, rbx
mov rax, 1
syscall

mov rax, 3
syscall

mov rax, 1
mov rdi, r9
lea rsi, [http_response]
mov rdx, 19
syscall
jmp _exit


_getter:

lea rsi, [request_buffer+4]
mov edi, esi

_compare2:
mov al, byte ptr [edi]
cmp al, ' '
je _termination3
inc edi
jmp _compare2

_termination3:
mov byte ptr [edi], 0

mov rax, 2
mov rdi, rsi
mov rsi, 0
syscall


mov rdi, rax
mov rax, 0
lea rsi, file_buffer
mov rdx, 1024
syscall
mov rbx, rax

mov rax, 3
syscall

mov rax, 1
mov rdi, r9
lea rsi, [http_response]
mov rdx, 19
syscall

lea rsi, [file_buffer]
mov rdx, rbx
mov rax, 1
syscall
_exit:
mov rdi, 0
mov rax, 60
syscall
