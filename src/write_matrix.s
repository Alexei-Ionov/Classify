.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue

    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
   
    

    mv s0 a0 
    mv s1 a1 
    mv s2 a2
    mv s3 a3
    #a's that have been changed: a0, a1, a2, a3

    li a1 1
    
    jal fopen
    addi t0 x0 -1
    beq a0 t0 fopen_error

    li a0 8
    jal malloc
    mv s4 a0        #save the pointer of the row,col into s4

    sw s2 0(s4)     #save num of rows onto heap
    sw s3 4(s4)     #save num of cols onto heap

    mv a0 s0        #load back file descriptor
    mv a1 s4        #pointer for row,col
    li a2 2         #will tell it to only write 2 elements 
    li a3 4         #bytes per element

    jal fwrite

    li t0 2

    bne a0 t0 fwrite_error1

    mul s5 s2 s3
    mv a2 s5        #num of elements to write to file = num rows * num cols
    li a3 4         #size of integer = 4 bytes

    mv a0 s0        #restore file descriptor
    mv a1 s1        #pointer to matrix 

    jal fwrite 

    bne s5 a0 fwrite_error2

    mv a0 s0 

    jal fclose
    bne a0 x0 fclose_error

    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)

    addi sp sp 28

    ret


malloc_error:
    li a0 26
    j exit



fopen_error:
    li a0 27
    j exit

    

fwrite_error1:
    li a0 30
    j exit

fwrite_error2:
    li a0 100
    j exit



fclose_error:
    li a0 28 
    j exit
    
















    # Epilogue


    jr ra
