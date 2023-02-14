.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    addi t0 x0 1
    blt a1 t0 error

    ##PROLOGUE##
    addi sp sp -4
    sw ra 0(sp)
    ############

    mv t0 x0    #index
    mv t1 x0    #res - index
    mv t2 x0    #curr_max

Loop:
    bge t0 a1 quit
    lw t3 0(a0)
    blt t2 t3 Update_Max    #if curr val > curr Max, update 

Loop_Incrementation:
    addi t0 t0 1
    addi a0 a0 4
    j Loop

Update_Max:
    mv t2 t3
    mv t1 t0
    j Loop_Incrementation

error:
    li a0 36
    j exit

quit: 
    mv a0 t1        #setting a0 to res
    lw ra 0(sp)
    addi sp sp 4
    jr ra


    