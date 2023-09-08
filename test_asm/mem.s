# Works
mov r0, 1
mov r1, 3
# store 3 to mem[1]
str r1, r0
# load value (3) from mem[1]
ldr r2, r0
# should be
# r0: 1
# r1: 3
# r2: 3
