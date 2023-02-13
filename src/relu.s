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
    bge a1 t0 Loop
    li a0 36
    j exit

add t0 x0 x0 ##initalizing index

Loop:
    bge t0 a1 loop_end
    lw t1 0(a0)
    blt t1 0 Absoluteify




Absoluteify:
    sub t2 x0 t1
    sw t2 0(a0)
    

    
    




#loop_start:
#loop_continue:
loop_end:


    # Epilogue


    jr ra
