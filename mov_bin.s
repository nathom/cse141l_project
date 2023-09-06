# Test whether binary immediates work
mov r0, 0b10101010 ; 170
mov r1, 10
set 0b00001111 ; 15
mov r2, 32
# results:
# r0: 170
# r1: 10
# out: 15
