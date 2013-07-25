# Simple program that just exists successfully (baby steps!)

.section .data
# Empty!

.section .text

.globl _start
_start:
movl $1, %eax   # Syscall number to exit
movl $5, %ebx   # Exit code 
int $0x80       # Make the syscall


