# Minimal HTTP Server in x86_64 Assembly

This project implements a minimal HTTP server entirely in x86_64 Linux assembly, built as part of a pwn.college challenge. The server directly uses Linux syscalls (no libc) to handle networking and file operations.

---

## Overview

The program:
- Creates a TCP socket
- Binds to a port
- Listens for incoming connections
- Forks a new process per connection
- Handles basic HTTP requests:
  - `GET` → Reads and returns file contents
  - `POST` → Writes request body into a file

All functionality is implemented in assembly, demonstrating low-level control over:
- Networking (sockets)
- Process management (fork)
- File I/O
- HTTP parsing

---

## Features

### Socket Setup
- Uses `socket` syscall (`rax = 41`)
- IPv4 (`AF_INET`) with TCP (`SOCK_STREAM`)
- Stores socket file descriptor in `r8`

### Binding and Listening
- `bind` syscall (`rax = 49`)
- `listen` syscall (`rax = 50`)
- Binds to port 80 (0x50)

### Connection Handling
- Accepts connections using `accept` (`rax = 43`)
- Forks a child process (`fork`, `rax = 57`)
- Parent continues accepting new connections
- Child handles the request

---

## HTTP Handling

### Request Parsing
- Reads request into `request_buffer`
- Determines request type by first byte:
  - `'G'` → GET
  - Otherwise treated as POST

---

## GET Request Flow

1. Extract file path from: GET /path HTTP/1.1
2. Open file using `sys_open`
3. Read contents into `file_buffer`
4. Send:
- HTTP response header
- File contents

### Response Format

HTTP/1.0 200 OK\r\n\r\n
<file content>


## POST Request Flow

1. Extract file path from request
2. Create/open file using:
   - Flags: `O_CREAT | O_WRONLY` (0x41)
   - Permissions: `0777`
3. Locate request body using `\r\n\r\n` delimiter
4. Compute body length manually
5. Write body into file
6. Send HTTP response

---

## Key Concepts Demonstrated

### Direct Syscall Usage
All functionality is implemented via raw syscalls:
- `socket`, `bind`, `listen`, `accept`
- `fork`
- `read`, `write`, `open`, `close`
- `exit`

---

### Manual HTTP Parsing
- Byte-wise string parsing using registers
- In-place null termination of file paths
- Header-body separation via CRLF detection

---

### Process-Based Concurrency
- Each request is handled in a separate child process
- Parent continues accepting new connections

---

### Memory Management
- `.bss` buffers:
  - `request_buffer` (1024 bytes)
  - `file_buffer` (1024 bytes)

---

## File Structure

```asm
.section .bss
  request_buffer
  file_buffer

.section .data
  http_response

.section .text
  _start


_start
  ├── socket()
  ├── bind()
  ├── listen()
  └── loop:
        ├── accept()
        ├── fork()
        │     ├── parent → close client socket → loop
        │     └── child:
        │           ├── read request
        │           ├── parse method
        │           ├── GET → read file → send
        │           └── POST → write file → respond
        └── exit
