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
    addi sp sp -24
    sw ra 0(sp)
    sw s0 4(sp)    #will save file descriptor
    sw s1 8(sp)    #will save pointers to heap
    sw s2 12(sp)    #saves amount of memory needed in bytes over function calls
    sw s3 16(sp)    #s3 will be our pointer to num rows
    sw s4 20(sp)    #s4 will be our pinter to num cols


fopenWork:
    mv a1 x0
    mv s3 a1        #row pointer
    mv s4 a1        #col pointer
    jal fopen   #call fopen --> returns file descriptor in a0. else -1 if failed

    addi t0 x0 -1     #to be used in comparing for failure
    beq a0 t0 fopen_error   #check for failure in f open

    mv s0 a0    #save the file descriptor
    li a0 8     #argument for malloc 

    jal malloc  #should return A pointer to the allocated memory. If the allocation failed, this value is 0.
    beq a0 x0 malloc_error
    
    mv s1 a0    #to store pointer that will be used to load row & col later
   
    

    j findRowCol

findRowCol:
    li s2 8         #we need to read 8 bytes of memory: 4 for row int and 4 for col int. store for after fn call
    mv a2 s2        #load the 8 bytes that will be needed for comparison for error
    mv a0 s0        #reload file descriptor
    mv a1 s1        #moves pointer to a1 for first use of fread
    jal fread
   
    bne a0 s2 fread_error

                #a1 does not contain the pointer anymore! but s1 does:D
    lw s3 0(s1) #load num of rows into t0
    lw s4 4(s1) #load num of cols into t1

    j malloc_matrix

malloc_matrix:
    
    mul s2 s3 s4   
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
    lw s0 4(sp)    
    lw s1 8(sp)    
    lw s2 12(sp)    
    lw s3 16(sp)    
    lw s4 20(sp)    

    addi sp sp 24
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


