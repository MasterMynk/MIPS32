.data
data:               .space  40
state:              .space  12
prompt:             .asciiz "Enter 10 integers:\n"
sum_label:          .asciiz "\nSum: "
min_label:          .asciiz "\nMinimum: "
max_label:          .asciiz "\nMaximum: "
avg_label:          .asciiz "\nAverage: "
ask_continue:       .asciiz "Do you want to try another? [y/n]: "

.text
                    .globl  main

main:
    la      $a0,                prompt
    jal     ShowText                                                # ShowText(prompt)

    li      $a0,                10                                  # $a0 = 10
    la      $a1,                IntoData
    jal     ForCount                                                # ForCount(10, IntoData)

    la      $s0,                state                               # state: sum, min, max
    sw      $zero,              0($s0)                              # sum = 0
    li      $t1,                2147483647
    sw      $t1,                4($s0)                              # min = 2147483647
    li      $t1,                -2147483648
    sw      $t1,                8($s0)                              # max = -2147483648

    li      $a0,                10                                  # $a0 = 10
    la      $a1,                ComputeStat
    jal     ForCount                                                # ForCount(10, ComputeStat)

    la      $a0,                sum_label
    lw      $a1,                0($s0)
    jal     ShowLabelled                                            # ShowLabelled(sum_label, sum)

    la      $a0,                min_label
    lw      $a1,                4($s0)
    jal     ShowLabelled                                            # ShowLabelled(min_label, min)

    la      $a0,                max_label
    lw      $a1,                8($s0)
    jal     ShowLabelled                                            # ShowLabelled(max_label, max)

    la      $a0,                avg_label
    lw      $t0,                0($s0)
    li      $t1,                10                                  # $t0 = 10
    div     $t0,                $t1                                 # $t0 / $t1
    mflo    $a1                                                     # $a1 = floor($t0 / $t1)
    jal     ShowLabelled                                            # jump to ShowLabelled and save position to $ra

    la      $a0,                ask_continue
    jal     GetPromptedChar                                         # GetPromptedChar(ask_continue)
    move    $t0,                $v0                                 # $t0 = $v0

    beq     $t0,                'y', main                           # if $t0 == 'y' then goto main
    beq     $t0,                'Y', main                           # if $t0 == 'y' then goto main

    j       Exit


ShowText:                                                           # ($a0: str) -> void
    li      $v0,                4                                   # $v0 = 4
    syscall
    jr      $ra                                                     # return


IntoData:                                                           # (i($a0): int) -> void
    move    $t0,                $a0                                 # $t0 = $a0
    move    $a0,                $ra                                 # $a0 = $ra
    jal     Push                                                    # Push($ra)

    la      $t1,                data
    sll     $t0,                $t0,            2                   # $t0 = $t0 << 2
    add     $t1,                $t1,            $t0                 # $t1 = $t1 + $t0

    jal     GetInt
    sw      $v0,                0($t1)                              # data[i] = GetInt()

    jal     Pop
    jr      $v0                                                     # return to Pop()


ComputeStat:                                                        #(i($a0): int) -> void
    move    $t0,                $a0                                 # $t0 = $a0
    move    $a0,                $ra                                 # $a0 = $ra
    jal     Push                                                    # Push($ra)

    la      $t1,                data
    sll     $t0,                $t0,            2                   # $t0 = $t0 << 2
    add     $t1,                $t1,            $t0                 # $t1 = $t1 + $t0
    lw      $t0,                0($t1)

    la      $t2,                state
    lw      $t1,                8($t2)

    bgt     $t0,                $t1,            cs_setmax           # if data[i] > max then goto cs_setmax

cs_maxchecked:
    lw      $t1,                4($t2)
    blt     $t0,                $t1,            cs_setmin           # if data[i] < min then goto cs_setmin

cs_minchecked:
    lw      $t1,                0($t2)
    add     $t1,                $t1,            $t0                 # $t1 = $t1 + $t0
    sw      $t1,                0($t2)                              # sum = sum + data[i]

    jal     Pop
    jr      $v0                                                     # return to Pop()

cs_setmax:
    sw      $t0,                8($t2)                              # max = data[i]
    b       cs_maxchecked                                           # branch to cs_maxchecked

cs_setmin:
    sw      $t0,                4($t2)                              # min = data[i]
    b       cs_minchecked                                           # branch to cs_minchecked


ForCount:                                                           # (count($a0): int, fn($a1): (i($a0): int) -> void) -> void
    move    $t0,                $a0                                 # $t0 = $a0
    move    $a0,                $ra                                 # $a0 = $ra
    jal     Push                                                    # Push($ra)

    move    $a0,                $s0                                 # $a0 = $s0
    jal     Push                                                    # Push($s0)
    move    $s0,                $zero                               # $s0 = $zero

    move    $a0,                $s1                                 # $a0 = $s1
    jal     Push                                                    # Push($s1)
    move    $s1,                $t0                                 # $s1 = $t0

    move    $a0,                $s2                                 # $a0 = $s2
    jal     Push                                                    # Push($s2)
    move    $s2,                $a1                                 # $s2 = $a1

fc_condn:
    blt     $s0,                $s1,            fc_loop             # if $s0 < $s1 then goto fc_loop

    jal     Pop
    move    $s2,                $v0                                 # $s2 = Pop()

    jal     Pop
    move    $s1,                $v0                                 # $s1 = Pop()

    jal     Pop
    move    $s0,                $v0                                 # $s0 = Pop()

    jal     Pop
    jr      $v0                                                     # return to Pop()

fc_loop:
    move    $a0,                $s0                                 # $a0 = $s0
    jalr    $s2
    addi    $s0,                $s0,            1                   # $s0 = $s0 + 1
    b       fc_condn                                                # branch to fc_condn


ShowInt:                                                            # ($a0: int) -> void
    li      $v0,                1                                   # $v0 = 1
    syscall
    jr      $ra                                                     # jumpt to $ra


GetInt:                                                             # () -> $v0: int
    li      $v0,                5                                   # $v0 = 5
    syscall
    jr      $ra                                                     # return

Push:                                                               # ($a0) -> void
    subi    $sp,                $sp,            4                   # $sp = $sp - 4
    sw      $a0,                0($sp)
    jr      $ra                                                     # return


Pop:                                                                # () -> $v0
    lw      $v0,                0($sp)
    addi    $sp,                $sp,            4                   # $sp = $sp + 4
    jr      $ra                                                     # return


ShowLabelled:                                                       # (label($a0): str, value($a1): int) -> void
    move    $t0,                $a0                                 # $s0 = $a0

    move    $a0,                $ra                                 # $a0 = $ra
    jal     Push                                                    # Push($ra)

    move    $a0,                $a1                                 # $s1 = $a1
    jal     Push                                                    # Push(value)


    move    $a0,                $t0                                 # $a0 = $t0
    jal     ShowText                                                # ShowText(label)

    jal     Pop                                                     # Pop()
    move    $a0,                $v0
    jal     ShowInt                                                 # ShowInt(Pop())

    jal     Pop
    jr      $v0                                                     # return to Pop()

GetChar:                                                            # () -> $v0: char
    li      $v0,                12                                  # $v0 = 12
    syscall
    jr      $ra                                                     # jump to $ra


GetPromptedChar:                                                    # (prompt($a0): str) -> $v0: char
    subi    $sp,                $sp,            4                   # $sp = $sp - 4
    sw      $ra,                0($sp)

    jal     ShowText
    jal     GetChar

    lw      $ra,                0($sp)
    addi    $sp,                $sp,            4                   # $sp = $sp + 4
    jr      $ra                                                     # jump to $ra

Exit:                                                               # () -> !
    li      $v0,                10                                  # $v0 = 10
    syscall