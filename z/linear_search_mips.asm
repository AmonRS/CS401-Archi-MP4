# MIPS test program - LINEAR SEARCH
# Amon , Tersa


# data
.data
    array:      .word   45 56 75 55 86 42 58 55
                .word   19 52 55 44 
    len:        .word   12
    target:     .word   55

    found:      .asciiz "\n Found! "
    fndindx:    .asciiz "\n found at index: "
    cur_elem:   .asciiz "\n current element: "
    aryend:     .asciiz "\n end of array reached"


# program
.text
.globl main
.ent main
main:
    # initialization
    addi $sp, $sp, -4   # stack frame
    sw $ra, 0($sp)      # store $ra

    # LINEAR SEARCH

    # counter
    addi $t0, $0, 0
    # array address
    la $s1, array
    # array length
    lw $t2, len
    # target
    lw $t3, target
    # found_or_not ?
    li $t7, 0

    loop:
        # if counter == len -> exit   ( while counter < len )
        beq $t0, $t2, ended

        # load current element
        lw $t5, 0($s1)
        # print current element
        li $v0, 4
        la $a0, cur_elem
        syscall
        li $v0, 1
        move $a0, $t5
        syscall
        
        # if target found -> 
        beq $t5, $t3, fndelm

        # next element
        nexelm:
        addi $s1, $s1, 4    # array address + 4
        addi $t0, $t0, 1    # counter + 1

        j loop

    fndelm:
        # found target in array
        # print found!
        li $v0, 4
        la $a0, found
        syscall
        # print index at found
        li $v0, 4
        la $a0, fndindx
        syscall
        li $v0, 1
        move $a0, $t0
        syscall
        # set flag -> true
        li $t7, 1

        j nexelm

    ended:
        # end of array reached
        li $v0, 4
        la $a0, aryend
        syscall

        j end

    end:
    # restore
    # lw $ra, 0($sp)
    # addi $sp, $sp, 4
    # jr $ra
    # done , terminate program
    li $v0, 10
    syscall
.end main