# Defines and calls an exponentiation function three times and returns the sum of the results
.section .data

.section .text

.global _start

##
## The "main" program
##
_start:

# First function call
pushl $2
pushl $3
call power
addl $8, %esp

# Store result
pushl %eax

# Second function call
pushl $4
pushl $2
call power
addl $8, %esp

# Retrieve the second result
popl %ebx

# Add the two together
addl %eax, %ebx

# Store result
pushl %ebx

# Third function call
pushl $45
pushl $0
call power
addl $8, %esp

# Retrieve the last result
popl %ebx

# Add all three
addl %eax, %ebx

# Return this number as the exit code
movl $1, %eax
int $0x80

##
## Function definition
##
.type power, @function
power:

# Initial bookkeeping
pushl %ebp
movl %esp, %ebp
addl $4, %esp       # Use a local variable even though a register would've been enough

# Initialize registers used
movl 8(%ebp), %ecx     # Exponent
movl 12(%ebp), %ebx    # Base

# Initialize result
movl $1, 4(%ebp)

# Main loop (multiply until exponent reaches 0)
start_loop:
cmpl $0, %ecx
je end_loop

movl 4(%ebp), %eax
imull %ebx, %eax
movl %eax, 4(%ebp)

decl %ecx
jmp start_loop

end_loop:

# Final bookkeeping (mostly reverse) 
movl 4(%ebp), %eax       # Return value
movl %ebp, %esp
popl %ebp
ret



