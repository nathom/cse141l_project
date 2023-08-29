# The tough one
# Calculate sum of successive integers

# initialize loop
mov r0, 0 // i = 0
mov r1, 10 // bound
mov r2, 0 // running sum
mov r3, 1 # for incrementing

# branch if r0 == 10
set loop_end
beq r0, r1

# r2 += i
add r2, r0
mov r2, OUT

# i += 1
add r0, r3
mov r0, OUT
loop_end:
mov r0, r0 // nop
