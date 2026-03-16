.data
greeting:   .asciiz "Hello World!"

.text
            .globl  main

main:
    la      $a0,        greeting    # $a0 = greeting
    jal     ShowText                # ShowText(greeting)

    j       exit

ShowText:                           # Displays text whose address is stored in $a0
    li      $v0,        4           # Syscall for print_text
    syscall
    jr      $ra

exit:
    li      $v0,        10          # Syscall for exti
    syscall