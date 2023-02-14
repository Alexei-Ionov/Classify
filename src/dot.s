.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    addi t0 x0 1
    mv t1 a0 #copy of arr_0 ptr
    mv t2 a1 #copy of arr_1 ptr

    add a0 x0 x0 #set res = 0

    addi t4 x0 4 #constant for next mul instruction. aka jump for each word

    mul t5 a3 t4 #new jump that considers stride for arr0
    mul t6 a4 t4 #new jump that considers stride for arr1

    blt a2 t0 error_36 #less than one element to compare
    blt a3 t0 error_37
    blt a4 t0 error_37
    j Loop
    

Loop:
    beq a2 x0 quit   #used up all elements
    lw t3 0(t1)
    lw t4 0(t2)
    mul t0 t3 t4 
    add a0 a0 t0    #res += (t3 * t4)
    add t1 t1 t5    #ptr = ptr + (stride*4)
    add t2 t2 t6    #ptr = ptr + (stride*4)
    
    addi t3 x0 1    #t3 = 1
    sub a2 a2 t3    #essentially, a2 -= 1
    j Loop

error_36: 
    li a0 36 
    j exit
error_37: 
    li a0 37
    j exit
quit:
    ret
