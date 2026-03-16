.data
data:       .word   1, 2, 3, 4, 5, 6, 7, 8, 9, 10
plus:       .asciiz " + "
equals:     .asciiz " = "

.text
            .globl  main

main:
    la      $s1,        data                        # data + i
    move    $s4,        $zero                       # i

    lw      $s0,        0($s1)                      # accumulator
    move    $a0,        $s0
    jal     ShowInt
loop:
    addi    $s4,        $s4,    1                   # i++
    addi    $s1,        $s1,    4                   # $s1 = data + i
    lw      $s2,        0($s1)                      # $s2 = data[i]

    la      $a0,        plus
    jal     ShowText                                # ShowText(plus)
    move    $a0,        $s2
    jal     ShowInt                                 # ShowInt(data[i])

    addu    $s0,        $s0,    $s2                 # accumulate
    bne     $s4,        9,      loop                # while(i != 9)

    la      $a0,        equals
    jal     ShowText

    move    $a0,        $s0
    jal     ShowInt

    j       exit

ShowInt:                                            # Prints int stored in $a0
    li      $v0,        1                           # Syscall for print_int
    syscall
    jr      $ra

ShowText:                                           # Displays text pointed to by $a0
    li      $v0,        4                           # Syscall for print_text
    syscall
    jr      $ra

exit:
    li      $v0,        10                          # Syscall for exit
    syscall