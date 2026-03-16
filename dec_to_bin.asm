.data
prompt:             .asciiz "Enter a non-negative integer: "
output:             .space  33
info:               .asciiz "Binary representation: "
another:            .space  2
ask_another:        .asciiz "\nDo you want to convert another number? [y/n]: "
negative_num_error: .asciiz "Error: negative numbers are not allowed.\n"

.text
                    .globl  main

main:
    la      $a0,        prompt
    jal     ShowText                                                            # ShowText(prompt)
    jal     GetInt
    move    $t0,        $v0                                                     # $t0 = GetInt()

    blt     $t0,        $zero,              error                               # if $t0 < $zero then goto error

    move    $a0,        $t0
    la      $a1,        output
    jal     ToBin                                                               #ToBin($t0, output)

    la      $a0,        info
    jal     ShowText                                                            # ShowText(info)

    la      $a0,        output
    jal     ShowText                                                            # ShowText(output)

    la      $a0,        ask_another
    jal     ShowText                                                            # ShowText(ask_another)

    la      $a0,        another
    li      $a1,        2
    jal     GetText                                                             # GetText(another, 2)

    la      $t0,        another
    lb      $t1,        0($t0)

    beq     $t1,        'y', main                                               # if $t1 == 'y' then goto main
    beq     $t1,        'Y', main                                               # if $t1 == 'Y' then goto main

    j       Exit

error:
    la      $a0,        negative_num_error
    jal     ShowText                                                            # ShowText(negative_num_error)
    b       main                                                                # branch to main


ToBin:                                                                          # ($a0: int, $a1: str) -> void
    beq     $a0,        0,                  tb_zero                             # if $a0 == 0 then goto tb_zero

    clz     $t0,        $a0
    li      $t1,        32
    sub     $t0,        $t1,                $t0                                 # $t0 = 32 - $t0
    add     $a1,        $a1,                $t0                                 # $a1 = $a1 + $t0
    li      $t1,        0                                                       # $t1 = 0
    sb      $t1,        0($a1)                                                  # $a1 = '\0'

tb_condn:
    bne     $a0,        $zero,              tb_loop                             # if $a0 != $zero then goto tb_loop
    jr      $ra

tb_loop:
    li      $t0,        2                                                       # $t0 = 2
    div     $a0,        $t0                                                     # $a0 / $t0
    mflo    $a0                                                                 # $a0 = floor($a0 / 2)
    mfhi    $t1                                                                 # $t1 = $a0 % 2
    addi    $t1,        $t1,                '0'                                 # $t1 = $t1 + '0'
    sub     $a1,        $a1,                1                                   # $a1--
    sb      $t1,        0($a1)                                                  # *$a1 = $t1
    b       tb_condn                                                            # branch to tb_condn

tb_zero:
    li      $t0,        '0'                                                     # $t0 = '0'
    sb      $t0,        0($a1)                                                  # a1[0] = '0'
    li      $t0,        0                                                       # $t0 = '\0'
    sb      $t0,        1($a1)                                                  # a1[1] = '\0'
    jr      $ra


ShowText:                                                                       # ($a0: str) -> void
    li      $v0,        4
    syscall
    jr      $ra


GetText:                                                                        # ($a0: str, $a1: int) -> void
    li      $v0,        8
    syscall
    jr      $ra


GetInt:                                                                         # () -> $v0: int
    li      $v0,        5
    syscall
    jr      $ra


Exit:                                                                           # () -> !
    li      $v0,        10
    syscall