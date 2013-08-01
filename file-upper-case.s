# Copies from one file to another, while converting characters to uppercase
.code32
.section .data

## Constants

## System calls
.equ OPEN, 5
.equ WRITE, 4
.equ READ, 3
.equ CLOSE, 6
.equ EXIT, 1

## File modes
.equ RD_ONLY, 0
.equ WR_ONLY_TRUNC, 03101
.equ FILE_PERM, 066

## File descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

## Misc global constants
.equ SYSCALL, 0x80
.equ EOF, 0
.equ ARGC, 2

## Storage
.equ BUFSIZE, 500

## Local variable info
.equ PROGRAM_VARIABLE_SIZE, 8
.equ STACK_OFFSET_INPUT_FD, -4
.equ STACK_OFFSET_OUTPUT_FD, -8
.equ STACK_OFFSET_ARGC, 0
.equ STACK_OFFSET_ARGV_0, 4
.equ STACK_OFFSET_ARGV_1, 8
.equ STACK_OFFSET_ARGV_2, 12

# Define the buffer
.section .bss
.lcomm  BUFFER, BUFSIZE

.section .text
.global _start
_start:
movl %esp, %ebp
subl $PROGRAM_VARIABLE_SIZE, %esp

# Open input file
movl $OPEN, %eax
movl STACK_OFFSET_ARGV_1(%ebp), %ebx
movl $RD_ONLY, %ecx
movl $FILE_PERM, %edx
int $SYSCALL

movl %eax, STACK_OFFSET_INPUT_FD(%ebp)

# Open output file
movl $OPEN, %eax
movl STACK_OFFSET_ARGV_2(%ebp), %ebx
movl $WR_ONLY_TRUNC, %ecx
movl $FILE_PERM, %edx
int $SYSCALL

movl %eax, STACK_OFFSET_OUTPUT_FD(%ebp)

# Read input file

read_file_loop:

movl $READ, %eax
movl STACK_OFFSET_INPUT_FD(%ebp), %ebx
movl $BUFFER, %ecx
movl $BUFSIZE, %edx
int $SYSCALL

# If no more data, then exit
cmpl $EOF, %eax
je end_read_file_loop

# Call the conversion function
pushl $BUFFER
pushl %eax
call convert_to_upper
addl $8, %esp

# Get the amount to write
movl %eax, %edx

# Copy the amount needed to the output file
movl $WRITE, %eax
movl STACK_OFFSET_OUTPUT_FD(%ebp), %ebx
movl $BUFFER, %ecx
int $SYSCALL

# Continue ...
jmp read_file_loop

end_read_file_loop:
# Close both files
movl $CLOSE, %eax
movl STACK_OFFSET_INPUT_FD(%ebp), %ebx
int $SYSCALL

movl $CLOSE, %eax
movl STACK_OFFSET_OUTPUT_FD(%ebp), %ebx
int $SYSCALL

# Return success
movl $0, %ebx
movl $EXIT, %eax
int $SYSCALL


##
## Function to conver to uppercase
##
## Args:
##   buffer and the size of the buffer
##
## Returns:
##   The number of characters converted
.type convert_to_upper, @function
convert_to_upper:

# Constants
.equ LOWER_BOUND, 'a'
.equ UPPER_BOUND, 'z'
.equ ASCII_DIFF, 'A' - 'a'
.equ STACK_OFFSET_BUFFER, 12
.equ STACK_OFFSET_BUFSIZE, 8

# Initial bookkeeping
pushl %ebp
movl %esp, %ebp

# Get buffer location
movl STACK_OFFSET_BUFFER(%ebp), %ebx
movl STACK_OFFSET_BUFSIZE(%ebp), %ecx

# Initialize loop variables
movl $0, %edi

convert_loop:
cmpl %edi, %ecx
je end_convert_loop

# Load given byte
movb (%ebx, %edi, 1), %cl

# Check if byte needs to be converted
cmpb $LOWER_BOUND, %cl
jl continue_convert_loop
cmpb $UPPER_BOUND, %cl
jg continue_convert_loop

# Convert it
addb $ASCII_DIFF, %cl
movb %cl, (%ebx, %edi, 1)

continue_convert_loop:
# Move to next byte
incl %edi
jmp convert_loop

end_convert_loop:

# Return number of bytes converted
movl %edi, %eax

# Final bookkeeping
movl %ebp, %esp
popl %ebp
ret

# To run,
# as --32 --gstabs+ file-upper-case.s -o file-upper-case.o
# ld -m elf_i386 file-upper-case.o
# <Create a file in /tmp/foo>
# ./a.out /tmp/foo /tmp/blah
# Verify output with: diff /tmp/blah <(tr '[:lower:]' '[:upper:]' < /tmp/foo)
