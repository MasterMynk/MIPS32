.data
prompt:                 .asciiz "Enter the number to check: "
subject:                .asciiz " is"
ending:                 .asciiz " a palindrome."
negation:               .asciiz "n't"
adios:                  .asciiz "Bye Byee..."
continuation_prompt:    .asciiz "\nDo you want to check another? [y/n]: "
continutation_resp:     .space  2

.text
                        .globl  main

main:
    la      $a0,                prompt
    jal     ShowText                                                        # ShowText(prompt)

    jal     GetInt                                                          # GetPromptedInt(prompt)
    move    $a0,                $v0                                         # $s0 = GetInt()
    jal     ShowInt

    move    $t0,                $a0
    la      $a0,                subject
    jal     ShowText                                                        # ShowText(subject)

    move    $a0,                $t0
    jal     CheckPalindrome                                                 # CheckPalindrome(GetPromptedInt(prompt))
    bne     $v0,                $zero,                  conclude            # if $v0 != $zero then goto negate

negate:
    la      $a0,                negation
    jal     ShowText                                                        # ShowText(negation)

conclude:
    la      $a0,                ending
    jal     ShowText                                                        # ShowText(ending)

    la      $a0,                continuation_prompt
    jal     ShowText                                                        # ShowText(continuation_prompt)

    la      $a0,                continutation_resp
    li      $a1,                2
    jal     GetText                                                         # GetText(continutation_resp, 2)

    la      $t0,                continutation_resp
    lb      $t1,                0($t0)
    beq     $t1,                'y', main                                   # If $1 == 'y' then goto main
    beq     $t1,                'Y', main                                   # If $1 == 'Y' then goto main

    j       exit                                                            # exit()


CheckPalindrome:                                                            # Expects the number to check in $a0 returns true/false through $v0
    blt     $a0,                $zero,                  false_cp            # if $a0 < $zero then goto false_cp

    move    $t0,                $zero
    move    $t1,                $a0
loop_cp:
    bne     $a0,                0,                      loop_cp_impl        # if $a0 != 0 then goto loop_cp_impl
    move    $v0,                $zero
    seq     $v0,                $t0,                    $t1                 # $v0 = $t0 == $s2
    jr      $ra

loop_cp_impl:
    rem     $t2,                $a0,                    10                  # $t2 = $a0 % 10
    div     $a0,                $a0,                    10                  # $a0 /= 10
    mul     $t0,                $t0,                    10                  # $t0 *= 10
    addu    $t0,                $t0,                    $t2                 # $t0 += $t2
    b       loop_cp                                                         # branch to loop_cp

false_cp:
    move    $v0,                $zero
    jr      $ra


GetInt:                                                                     # Reads an integer from the keyboard, output will be in $v0
    li      $v0,                5                                           # read_int syscall
    syscall
    jr      $ra


ShowInt:                                                                    # Prints int stored in $a0
    li      $v0,                1                                           # Syscall for print_int
    syscall
    jr      $ra


ShowText:                                                                   # Displays text pointed to by $a0
    li      $v0,                4                                           # Syscall for print_text
    syscall
    jr      $ra


GetText:                                                                    # Reads $a1 characters from input into $a0
    li      $v0,                8                                           # Syscall for read_text
    syscall
    jr      $ra


exit:
    la      $a0,                adios
    jal     ShowText                                                        # ShowText(adios)
    li      $v0,                10                                          # Syscall for exit
    syscall