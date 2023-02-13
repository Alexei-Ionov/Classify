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
    addi t0 x0 1 ##creates a temp register with value of 1 to be used in the if statement below
    mv t1 a0 #copy pointer over 
    add t2 x0 x0 #initalizing start index
    add t3 x0 x0 #initalizing res to index 0
    add t4 x0 x0 #initalizing max value to be 0. 
    bge a1 t0 Loop
    li a0 36
    j exit
        
Loop:
    bge t2 a1 endLoop
    lw t0 0(a0)
    #bge t4 t0 Continue #if the curr max is greater than or equal to curr val, then just skip to the end of the block
    jal ra Change_Max
    addi t2 t2 1
    addi t1 t1 4
    j Loop
    
Change_Max: 
    bge t4 t0 Continue
    add t4 t0 x0 #update max register to equal the new max
    add t3 t2 x0 #updating corresponding index 
    j Continue
    
Continue: 
    jr ra

endLoop:
