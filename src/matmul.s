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
matmul:
    addi t0 x0 1    #used to store 1 to compare in error checks
    blt a1 t0 error
    blt a2 t0 error
    blt a4 t0 error
    blt a5 t0 error
    bne a2 a4 error

SaveToStack:
    addi sp sp -44
    sw ra 40(sp)
    sw s10 36(sp)     
    sw s11 32(sp)
    sw s7 28(sp)
    sw s6 24(sp)
    sw s5 20(sp)
    sw s4 16(sp)
    sw s3 12(sp)
    sw s2 8(sp)
    sw s1 4(sp)
    sw s0 0(sp)

Save:
    mv s0 a0           #set new ptr
    mv s3 a3           #new ptr for arr1
    mv s10 s3           #create copy of ptr so I can go back to OG position later after each row iteration of the outer Loop
    mv s1 a1 
    mv s4 a4
    mv s5 a5
    mv s6 a6        #s6 is ptr of res array
    mv s7 x0        #col index
    mv s2 a2
    la s11 Outer_Loop_Work
    

Outer_Loop:
    beq s1 x0 end_loop
    j InnerLoop

Outer_Loop_Work:
    addi t4 x0 4    #temp store imm of 4
    mul t5 s2 t4    #t5 = num of cols * 4 (offset)
    add s0 s0 t5    #matrix0 ptr gets incremented by the num of cols * 4

    mv s7 x0        #reset index col counter

    addi t4 x0 1    #temp store imm of 1
    sub s1 s1 t4    #s1 -= 1
    
    mv s3 s10    #reset s3 to its OG position (i.e. pointer to first elmeent in arr1)

    j Outer_Loop

InnerLoop:
    bge s7 s5 Continue   #if col index >= num of cols of matrix1, break
    mv a0 s0        #initalizing ptrs for call to dot
    mv a1 s3        #initalizing ptrs for call to dot
    addi a3 x0 1    #initalizing stride of matrix0 to one!
    mv a4 s5        #initalizing stride of matrix1 to be equal to num of cols of matrix0. 
    mv a2 s2

                    #num of cols in matrix0 == num of elements to use !
    jal dot         #call dot
    
                    #a0 should now contain the value of the prev call to dot

                    #RESETTING a registers after calling dot ###
    
    sw a0 0(s6)     #store a0 into our result matrix
    addi s3 s3 4    #index of matrix1 gets incremented by 1 element
    addi s7 s7 1    #increment col index by 1
    addi s6 s6 4    #increment ptr to result matrix by one element
    j InnerLoop

Continue:
    jr s11  #JUMP BACK TO OUTERLOOPWORK!

error: 
    li a0 38
    j exit

end_loop:
    lw ra 40(sp)
    lw s10 36(sp)
    lw s11 32(sp)
    lw s7 28(sp)
    lw s6 24(sp)
    lw s5 20(sp)
    lw s4 16(sp)
    lw s3 12(sp)
    lw s2 8(sp)
    lw s1 4(sp)
    lw s0 0(sp)
    addi sp sp 44

    jr ra
    
