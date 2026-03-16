.data
num1_hint:  .asciiz "Enter the first number: "
num2_hint:  .asciiz "Enter the second number: "
plus:       .asciiz " + "
equals:     .asciiz " = "

.text
            .globl  main

main:
    la      $a0,        num1_hint               # $a0 = num1_hint
    jal     ShowText                            # ShowText(num1_hint)
    jal     GetInt
    move    $s0,        $v0                     # $s0 = GetInt()

    la      $a0,        num2_hint
    jal     ShowText                            # ShowText(num2_hint)
    jal     GetInt
    move    $s1,        $v0                     # $s1 = GetInt()

    move    $a0,        $s0
    jal     ShowInt                             # ShowInt($s0)

    la      $a0,        plus
    jal     ShowText                            # ShowText(plus)

    move    $a0,        $s1
    jal     ShowInt                             # ShowInt($s1)

    la      $a0,        equals
    jal     ShowText                            # ShowText(equals)

    addu    $a0,        $s0,        $s1         # $a0 = $s0 + $s1
    jal     ShowInt                             # ShowInt($s0 + $s1)

    j       exit

GetInt:                                         # Reads an integer from the keyboard, output will be in $v0
    li      $v0,        5                       # read_int syscall
    syscall
    jr      $ra

ShowInt:                                        # Shows integer stored in $a0
    li      $v0,        1                       # print_int syscall
    syscall
    jr      $ra

ShowText:                                       # Displays text whose address is stored in $a0
    li      $v0,        4                       # print_string syscall
    syscall
    jr      $ra

exit:
    li      $v0,        10                      # exit syscall
    syscall