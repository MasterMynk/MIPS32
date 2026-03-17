.data
prompt:                 .asciiz "Enter a string: "
input:                  .space  51                                      # 1 character for null termination
info:                   .asciiz "Reversed string: "
ask_continue:           .asciiz "Do you want to try another? [y/n]: "
newline:                .asciiz "\n"

.text
                        .globl  main

main:
    la      $a0,                    prompt
    li      $a1,                    51
    la      $a2,                    input
    jal     GetPromptedText                                             # GetPromptedText(prompt, 51, input)

    la      $a0,                    input
    jal     StrLen
    move    $s0,                    $v0                                 # $s0 = StrLen(input)

    la      $a0,                    input
    move    $a1,                    $s0
    jal     RemoveTrailingNewline
    move    $s0,                    $v0                                 # $s0 = RemoveTrailingNewline(input, StrLen(input))

    la      $a0,                    input
    move    $a1,                    $s0                                 # $a1 = $s0
    jal     Reverse                                                     # Reverse(input, StrLen(input))

    la      $a0,                    info
    jal     ShowText                                                    # ShowText(info)

    la      $a0,                    input
    jal     ShowText                                                    # ShowText(input)

    la      $a0,                    newline
    jal     ShowText                                                    # ShowText(newline)

    la      $a0,                    ask_continue
    jal     GetPromptedChar                                             # GetPromptedChar(ask_continue)
    move    $t0,                    $v0                                 # $t0 = $v0

    beq     $t0,                    'y', main                           # if $t0 == 'y' then goto main
    beq     $t0,                    'Y', main                           # if $t0 == 'y' then goto main

    j       Exit


ShowText:                                                               # ($a0: str) -> void
    li      $v0,                    4                                   # $v0 = 4
    syscall
    jr      $ra                                                         # jump to $ra


GetText:                                                                # ($a0: str, $a1: int) -> void
    li      $v0,                    8                                   # $v0 = 8
    syscall
    jr      $ra                                                         # jump to $ra


GetPromptedText:                                                        # (prompt($a0): str, size($a1): int, buffer($a2): str) -> void
    subi    $sp,                    $sp,            4                   # $sp = $sp - 4
    sw      $ra,                    0($sp)

    jal     ShowText                                                    # ShowText(prompt)

    move    $a0,                    $a2                                 # $a0 = $a1
    jal     GetText                                                     # GetText(buffer, size)

    lw      $ra,                    0($sp)
    addi    $sp,                    $sp,            4                   # $sp = $sp + 4

    jr      $ra                                                         # jump to $ra


GetChar:                                                                # () -> $v0: char
    li      $v0,                    12                                  # $v0 = 12
    syscall
    jr      $ra                                                         # jump to $ra


GetPromptedChar:                                                        # (prompt($a0): str) -> $v0: char
    subi    $sp,                    $sp,            4                   # $sp = $sp - 4
    sw      $ra,                    0($sp)

    jal     ShowText
    jal     GetChar

    lw      $ra,                    0($sp)
    addi    $sp,                    $sp,            4                   # $sp = $sp + 4
    jr      $ra                                                         # jump to $ra


StrLen:                                                                 # ($a0: str) -> len($v0): int
    move    $v0,                    $a0                                 # $v0 = $a0
sl_loop:
    lb      $t1,                    0($v0)
    addi    $v0,                    $v0,            1                   # $v0 = $v0 + 1
    bne     $t1,                    0,              sl_loop             # if $t1 != 0 then goto sl_inc

    sub     $v0,                    $v0,            $a0                 # $v0 = $v0 - $a0
    sub     $v0,                    $v0,            1                   # $v0 = $v0 - 1

    jr      $ra                                                         # jump to $ra


Reverse:                                                                # (input($a0): str, size($a1): int) -> void
    add     $t0,                    $a0,            $a1                 # $t0 = $a0 + $a1

r_condn:
    bgt     $t0,                    $a0,            r_loop              # if $t0 > $a0 then goto r_loop
    jr      $ra                                                         # jump to $ra

r_loop:
    lb      $t1,                    -1($t0)
    lb      $t2,                    0($a0)

    sb      $t1,                    0($a0)
    sb      $t2,                    -1($t0)

    subi    $t0,                    $t0,            1                   # $t0 = $t0 - 1
    addi    $a0,                    $a0,            1                   # $a0 = $a0 + 1

    b       r_condn                                                     # branch to r_condn


RemoveTrailingNewline:                                                  # ($a0: str, size($a1): int) -> new_size($v0): int
    add     $a0,                    $a0,            $a1                 # $a0 = $a0 + $a1
    lb      $t0,                    -1($a0)
    move    $v0,                    $a1                                 # $v0 = $a1
    beq     $t0,                    '\n', rtn_rem                       # if $t0 == '\n' then goto rtn_rem
    jr      $ra                                                         # jump to $ra

rtn_rem:
    sb      $zero,                  -1($a0)
    subi    $v0,                    $v0,            1                   # $v0 = $v0 - 1
    jr      $ra                                                         # jump to $ra


Exit:                                                                   # () -> !
    li      $v0,                    10                                  # $v0 = 10
    syscall