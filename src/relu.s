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
    addi t0 x0 1
    blt a1 t0 error
    
    #PROLOGUE
    addi sp sp -4
    sw ra 0(sp)
    ###
    mv t0 x0        #index
    
    
Loop:
    bge t0 a1 quit
    lw t1 0(a0)
    blt t1 x0 Change_Val       #if val < 0, make it 0
    
Loop_Incrementation:
    addi a0 a0 4
    addi t0 t0 1        #increment index
    j Loop
    
Change_Val:
    sw x0 0(a0)
    j Loop_Incrementation

error:
    li a0 36
    j exit

quit: 
    lw ra 0(sp)
    addi sp sp 4
    jr ra