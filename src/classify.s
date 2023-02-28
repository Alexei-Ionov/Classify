.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    li t0 5
    bne a0 t0 args_error
    addi sp sp -52
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)        #
    sw s5 24(sp)        # s3 - s8 store ptrs to row/cols of m0, m1, input matrices
    sw s6 28(sp)        #
    sw s7 32(sp)
    sw s8 36(sp)
    sw s9 40(sp)
    sw s10 44(sp)
    sw s11 48(sp)

    mv s0 a0 
    mv s1 a1
    mv s2 a2

    ##allocates memory for pointers #####
    
    jal malloc_work
    mv s3 a0            #row ptr for m0
    jal malloc_work
    mv s4 a0            #col ptr for m0
    jal malloc_work
    mv s5 a0            #row ptr for m1
    jal malloc_work
    mv s6 a0            #col ptr for m1
    jal malloc_work
    mv s7 a0            #row ptr for input
    jal malloc_work 
    mv s8 a0            #col ptr for input
    j Save_ptrs

malloc_work:

    addi sp sp -4
    sw ra 0(sp)

    li a0 4 
    jal malloc 
    beq a0 x0 malloc_error

    lw ra 0(sp)
    addi sp sp 4
    ret 
    
    ###############
Save_ptrs:

    lw a0 4(s1)     #stores file path of m0 in a0
    mv a1 s3
    mv a2 s4
    jal read_matrix

    mv s9 a0        #stores pointer to matrix m0 in s9

    lw a0 12(s1)
    mv a1 s7
    mv a2 s8
    jal read_matrix 
    mv s11 a0        #storing input matrix ptr into s11


ComputeH:
    mul t0 s3 s8        #num rows of m0 * num cols of input
    slli t0 t0 2        #num elements * 4 for total num of bytes needed to be malloced

    mv a0 t0
    jal malloc 
    beq a0 x0 malloc_error
    mv s10 a0                #s10 to store ptr to h matrix (result of mul)

    mv a0 s9                #move m0 ptr into a0
    mv a1 s3                #move num of rows of m0
    mv a2 s4                #move num of cols of m1
    mv a3 s11               #move input ptr to a3
    mv a4 s7                #move num of rows of input
    mv a5 t0                #move num of cols of input
    mv a6 s10               #move h ptr space to a6

    jal matmul      #will update s10 representing h in-place
    mv a0 s10
    mul a1 s3 s8    #num of integers in the h-arr = num rows of m0 * num cols of input
    jal relu        #performed in-place

ComputeO:

    ###SETS UP ptr to m1######
    lw a0 8(s1)     #storing file path of m1 in a0
    mv a1 s5
    mv a2 s6
    jal read_matrix
    mv s9 a0        #PTR TO m1 will be stored in s9 since the previous value (ptr to m0) is no longer needed
    ##################
    mul t0 s5 s8    #o will have #rows of m1 and #cols of h (#h cols = # input cols)
    slli t0 t0 2
    mv a0 t0 
    jal malloc      #allocating memory for o
    beq a0 x0 malloc_error
    mv s11 a0           #store o ptr into s11 which was prev ptr to input

    mv a0 s9        #ptr to m1 into a0
    mv a1 s5 
    mv a2 s6
    mv a3 s10       #ptr to h
    mv a4 s3        #rows of h (rows of m0)
    mv a5 s8        #cols of h (cols of input)
    mv a6 s11
    jal matmul      #resulting matrix o is stored in s11


Write_to_output:
    lw t0 16(s1)    
    mv a0 t0        #store output path into arg a0
    mv a1 s11       #mv ptr to o into a1
    mv a2 s5
    mv a3 s8
    jal write_matrix

Argmax_work:
    mv a0 s11
    mul a1 s5 s8    #num elements = s5 * s8 (num rows of m1 * num cols of input)

    jal argmax
    mv s9 a0    #save the value returned by argmax as it is what should be returned in the end
    li t0 1
    beq s2 t0 Free_Data
    jal print_int           #prints the value returned by argmax
    li a0 '\n'
    jal print_char

Free_Data:

end_of_function:
    mv a0 s9        #store return value of argmax
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)        #
    lw s5 24(sp)        # s3 - s8 store ptrs to row/cols of m0, m1, input matrices
    lw s6 28(sp)        #
    lw s7 32(sp)
    lw s8 36(sp)
    lw s9 40(sp)
    lw s10 44(sp)
    lw s11 48(sp)
    addi sp sp 52

    ret

malloc_error:
    li a0 26
    j exit

args_error:
    li a0 31
    j exit



