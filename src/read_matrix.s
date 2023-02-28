.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -28
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw s0 16(sp)    #will save file descriptor
    sw s1 20(sp)    #will save pointers to heap
    sw s2 24(sp)    #saves amount of memory needed in bytes over function calls


fopenWork:
    mv a1 x0
    jal fopen   #call fopen --> returns file descriptor in a0. else -1 if failed

    addi t0 x0 -1     #to be used in comparing for failure
    beq a0 t0 fopen_error   #check for failure in f open

    mv s0 a0    #save the file descriptor
    li a0 8     #argument for malloc 

    jal malloc  #should return A pointer to the allocated memory. If the allocation failed, this value is 0.
    beq a0 x0 malloc_error
    mv s1 a0    #to store pointer that will be used to load row & col later
    mv a1 a0    #moves pointer to a1 for use in first use of fread

    j findRowCol

findRowCol:
    li s2 8         #we need to read 8 bytes of memory: 4 for row int and 4 for col int. store for after fn call
    addi a2 x0 8    #load the 8 bytes that will be needed for comparison for error
    mv a0 s0        #reload file descriptor
    jal fread
   
    bne a0 s2 fread_error

                #a1 does not contain the pointer anymore! but s1 does:D
    lw t0 0(s1) #load num of rows into t0
    lw t1 4(s1) #load num of cols into t1

    j malloc_matrix

malloc_matrix:
    
    mul s2 t0 t1    
    slli s2 s2 2   #num bytes needed for matrix = rows * cols * 4! will be used in fread
    mv a0 s2
    jal malloc 
    beq a0 x0 malloc_error  #a0 now contains pointer or 0 if error
    mv s1 a0                #store final pointer in s1 for later use as return value

    mv a1 s1    #move pointer from malloc into a1
    mv a0 s0    #move file descriptor back into a0
                
    mv a2 s2    #move num of bytes needed into a2

    jal fread
    bne a0 s2 fread_error

    j close


close:
    mv a0 s0    #restore file descriptor into a0 
    jal fclose
    bne a0 x0 fclose_error

    #END
    mv a0 s1        #move matrix pointer into a0

    lw ra 0(sp)
    lw a0 4(sp)
    lw a1 8(sp)
    lw a2 12(sp)
    lw s0 16(sp)
    lw s1 20(sp)
    lw s2 24(sp)
    addi sp sp 28
                    #return 
    ret
    
fopen_error: 
    li a0 27
    j exit

malloc_error:
    li a0 26 
    j exit

fread_error:
    li a0 29 
    j exit

fclose_error:
    li a0 28
    j exit


