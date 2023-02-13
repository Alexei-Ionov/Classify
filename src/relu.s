.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    addi t0 x0 1 ##creates a temp register with value of 1 to be used in the if statement below
    mv t1 a0 #copy pointer over 
    add t2 x0 x0 #initalizing start index
    bge a1 t0 Loop
    li a0 36
    j exit



Loop:
    bge t2 a1 quitLoop
    lw t0 0(a0)
    jal rd Absoluteify
    addi t2 t2 1
    addi t1 t1 4
    j Loop




Absoluteify:
    bge t0 x0 exit
    sub t2 x0 t1
    sw t2 0(a0)
    j exit 

exit: 
    jr ra

quitLoop:




