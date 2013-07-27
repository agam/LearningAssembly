# Finds the largest in a set of numbers
# Since it uses the 'exit code' to return the number, this can't be greater than 255
# (see http://man7.org/linux/man-pages/man3/exit.3.html)

.section .data

data_items:
.long  123,12,234,34,45,23,65,109,2,0

.section .text

.global _start
_start:

movl $0, %edi                       # Our loop counter (say 'i')
movl data_items(,%edi, 4), %eax     # Get the i'th number
movl %eax, %ebx                     # EBX stores the current Max

start_loop:
cmpl $0, %eax                       # Assumes 0-terminated set of numbers
je loop_exit
incl %edi                           # Next number
movl data_items(,%edi, 4), %eax

cmpl %ebx, %eax
jle start_loop                      # Not bigger

movl %eax, %ebx                     # Store new 'largest' value
jmp start_loop

loop_exit:
  movl $1, %eax
  int $0x80

# as maximum.s -o maximum.o
# ld maximum.o
# ./a.out; echo $?
# ----> should print '234'

