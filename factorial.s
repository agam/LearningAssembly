# Example of a recursive function

.section .data
.section .text
.global _start

_start:
# Computing factorial of 4
pushl $4
call factorial
addl $4, %esp

# Move return value to %ebx to return as exit code
movl %eax, %ebx
movl $1, %eax
int $0x80

##
## Recursive function that (ab?)uses %eax between successive function calls as an accumulator
## 
factorial:

# Standard bookkeeping at the beginning
pushl %ebp
movl %esp, %ebp

# Get our argument
movl 8(%ebp), %eax

cmpl $1, %eax
je factorial_done

# Decrement and call the function recursively
decl %eax
pushl %eax
call factorial
addl $4, %esp

# Multiple the arg by the returned value
movl 8(%ebp), %ebx
imul %ebx, %eax

factorial_done:
# Standard bookkeeping at the end
movl %ebp, %esp
popl %ebp
ret

## Run as follows:
# as --32 --gstabs+ factorial.s -o factorial.o
# ld -m elf_i386 factorial.o
# ./a.out ; echo $?
# -----> Should print 24
