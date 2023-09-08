mov r0, 0    // set r0 = 0
mov r1, 30

loop_start:

# break if i == 32
mov r1, 32
set loop_end
beq r0, r1

// r1 for msb, r2 for lsb
ldr r1, r0  // r1 = mem[i]
mov r2, 1
add r0, r2  // OUT = i + 1
ldr r2, OUT // r2 = mem[OUT] = mem[i+1]


# ...


loop_end:
mov r0, r0
