.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================

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

matmul:
    addi t0 x0 1    #used to store 1 to compare in error checks
    blt a1 t0 error
    blt a2 t0 error
    blt a4 t0 error
    blt a5 t0 error
    bne a2 a4 error

    jal ra SaveToStack      #saves all prior content of s registers onto stack

    mv s0 a0           #set new ptr
    mv s3 a3           #new ptr for arr1
    add s6 x0 x0        #col index 
    jal ra Save

    ### FOR DOT ####
    addi a3 1       #initalizing stride of matrix0 to one!
    add a4 s2 x0    #initalizing stride of matrix1 to be equal to num of cols of matrix0. 
    ##############

    j Outer_Loop

    ##THINGS I NEED TO SAVE: all a0 - a4 plus any t's I use here
    ##s11 USED TO STORE OLD RA
    ##list of s registers used: s0, s1, s2, s3, s4, s5, s6, s11

SaveToStack:
    addi sp sp -32
    sw s11 28(sp)
    sw s6 24(sp)
    sw s5 20(sp)
    sw s4 16(sp)
    sw s3 12(sp)
    sw s2 8(sp)
    sw s1 4(sp)
    sw s0 0(sp)

    jr ra

error: 
    li a0 38
    j exit

Outer_Loop:
    beq s1 x0 end_loop
    jal ra InnerLoop

    addi t4 x0 4    #temp store imm of 4
    mul t5 s2 t4    #t5 = num of cols * 4 (offset)
    add s0 s0 t5    #matrix0 ptr gets incremented by the num of cols * 4

    mv s6 x0        #reset index col counter

    addi t4 x0 1    #temp store imm of 1
    sub s1 t4       #s1 -= 1
    j Outer_Loop

Save:
    mv s1 a1 
    mv s2 a2
    mv s4 a4
    mv s5 a5
    jr ra

InnerLoop:
    bge s6 s5 Continue   #if col index >= num of cols of matrix1, break
    mv s11 ra           #stores ra into a safe register for later use because it will be overriden
    mv a0 s0        #initalizing ptrs for call to dot
    mv a1 s3        #initalizing ptrs for call to dot

                    #num of cols in matrix0 == num of elements to use !
    jal ra dot      #call dot

                    #a0 should now contain the value of the prev call to dot

    sw a0 0(a6)     #store a0 into our result matrix

    
    addi s3 s3 4    #index of matrix1 gets incremented by 1 element
    addi s6 s6 1    #increment col index by 1
    addi a6 a6 4    #increment ptr to result matrix by one element
    j InnerLoop

Continue:
    jr s11  #JUMP BACK TO OUTERLOOP!


end_loop:
    lw s11 28(sp)
    lw s6 24(sp)
    lw s5 20(sp)
    lw s4 16(sp)
    lw s3 12(sp)
    lw s2 8(sp)
    lw s1 4(sp)
    lw s0 0(sp)

