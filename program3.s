# load pattern 

mov r0, 0 ; r0 = i = 0

# count = mem[33]
# byte_count = mem[34]
# totalCount = mem[35]
# initialize mem to 0

set 33
str r0, OUT
set 34
str r0, OUT
set 35
str r0, OUT

# We will be directly using memory to keep
# track of the counts

loop_start:
mov r0, r0 ; nop


; make sure r1 contains pattern
set 32
ldr r1, OUT ; r1 = pattern = mem[32]

# load r2 with b
ldr r2, r0 ; r2 = mem[i]

mov r3, 0 ; r3 = count = 0

mov r4, 0b11111000
and r2, r4
mov r2, OUT ; r2 = b & 0b11111000
set if1
bne r2, r1

set 1
add r3, OUT
mov r3, OUT ; r3 = count += 1

if1:
mov r0, r0 ; nop
ldr r2, r0

# rotate mask
set 1
rot r4, OUT
mov r4, OUT ; r4 >>= 1

# mask byte and shift left
and r2, r4
mov r2, OUT ; r2 = b & 0b01111100
set 7
rot r2, OUT
mov r2, OUT

set if2
bne r2, r1

set 1
add r3, OUT
mov r3, OUT ; r3 = count += 1

if2:
mov r0, r0 ; nop
ldr r2, r0

set 1
rot r4, OUT
mov r4, OUT ; r4 >>= 1

# mask byte and shift left
and r2, r4
mov r2, OUT ; r2 = b & 0b00111110
set 6
rot r2, OUT
mov r2, OUT

set if3
bne r2, r1

set 1
add r3, OUT
mov r3, OUT ; r3 = count += 1

if3:
mov r0, r0 ; nop
ldr r2, r0

set 1
rot r4, OUT
mov r4, OUT ; r4 >>= 1

# mask byte and shift left
and r2, r4
mov r2, OUT ; r2 = b & 0b00011111
set 5
rot r2, OUT
mov r2, OUT

set if4
bne r2, r1

set 1
add r3, OUT
mov r3, OUT ; r3 = count += 1

if4:
mov r0, r0 ; nop

# if r3 != 0, increment byte count
mov r2, 0
set byte_count_increment
bne r3, r2

# add 1 to r2 so that it is no longer equal to r3
set 1
add r2, OUT
mov r2, OUT
set skip_byte_count_increment
bne r3, r2 ; unconditional branch

byte_count_increment:
mov r0, r0 ; nop

# load, increment, and store byte count
set 34
ldr r2, OUT ; r2 = mem[34]
set 1
add r2, OUT
mov r2, OUT ; r2 += 1
set 34
str r2, OUT ; mem[34] = r2

skip_byte_count_increment:
mov r0, r0

# mem[33] += count
set 33
ldr r4, OUT ; r4 = mem[33]
add r4, r3
mov r4, OUT ; r4 += count
set 33
str r4, OUT ; mem[33] = r4

# mem[35] += count

set 35
ldr r4, OUT ; r4 = mem[33]
add r4, r3
mov r4, OUT ; r4 += count
set 35
str r4, OUT ; mem[33] = r4

# now r3 is free

# we only want to do this if we are not in
# the last iteration, so skip to loop end
# if i == 31
mov r3, 31
set calc_totalCount
bne r0, r3

mov r3, 33
set if24
bne r0, r3 ; unconditional branch, i never equal to 33


# r0: i
# r1: pattern
# r2: b
# r3: mem[i+1]
# r4 free
calc_totalCount:
mov r0, r0 ; nop
ldr r2, r0 ; r2 = mem[i] = b

// pattern >>= 3
set 3
rot r1, OUT
mov r1, OUT

set 1
add r0, OUT
ldr r3, OUT ; r3 = mem[i+1]

set 0b00001111
and r2, OUT
mov r2, OUT
set 7
rot r2, OUT
mov r2, OUT ; r2 = b & 0b00001111 << 1

// r2 NO LONGER b

set 7
rot r3, OUT
mov r4, OUT ; r4 = mem[i+1] rot(7)
set 0b00000001
and r4, OUT ; only keep last bit
orr OUT, r2
mov r4, OUT ; r4 = ((b & 0b00001111) << 1) | (mem[i + 1] >> 7)

// restore r2
ldr r2, r0

set if21
bne r4, r1

# increment mem[35]
set 35
ldr r4, OUT
set 1
add r4, OUT
mov r4, OUT
set 35
str r4, OUT

if21:
mov r0, r0

# r0: i
# r1: b
# r2: mem[i+1]
# r3, r4 free

set 1
add r0, OUT
ldr r3, OUT ; r3 = mem[i+1]

set 0b0000111
and r2, OUT
mov r2, OUT
set 6
rot r2, OUT
mov r2, OUT ; r2 = b & 0b00001111 << 1

// r2 NO LONGER b

set 6
rot r3, OUT
mov r4, OUT ; r4 = mem[i+1] rot(7)
set 0b00000011
and r4, OUT ; only keep last bit
orr OUT, r2
mov r4, OUT ; r4 = ((b & 0b00001111) << 1) | (mem[i + 1] >> 7)

// restore r2
ldr r2, r0

set if22
bne r4, r1

# increment mem[35]
set 35
ldr r4, OUT
set 1
add r4, OUT
mov r4, OUT
set 35
str r4, OUT

if22:
mov r0, r0

# r0: i
# r1: b
# r2: mem[i+1]
# r3, r4 free

set 1
add r0, OUT
ldr r3, OUT ; r3 = mem[i+1]

set 0b0000011
and r2, OUT
mov r2, OUT
set 5
rot r2, OUT
mov r2, OUT ; r2 = b & 0b00001111 << 1

// r2 NO LONGER b

set 5
rot r3, OUT
mov r4, OUT ; r4 = mem[i+1] rot(7)
set 0b00000111
and r4, OUT ; only keep last bit
orr OUT, r2
mov r4, OUT ; r4 = ((b & 0b00001111) << 1) | (mem[i + 1] >> 7)

// restore r2
ldr r2, r0

set if23
bne r4, r1

# increment mem[35]
set 35
ldr r4, OUT
set 1
add r4, OUT
mov r4, OUT
set 35
str r4, OUT

if23:
mov r0, r0


# r0: i
# r1: b
# r2: mem[i+1]
# r3, r4 free

set 1
add r0, OUT
ldr r3, OUT ; r3 = mem[i+1]

set 0b0000001
and r2, OUT
mov r2, OUT
set 4
rot r2, OUT
mov r2, OUT ; r2 = b & 0b00001111 << 1

// r2 NO LONGER b

set 4
rot r3, OUT
mov r4, OUT ; r4 = mem[i+1] rot(7)
set 0b00001111
and r4, OUT ; only keep last bit
orr OUT, r2
mov r4, OUT ; r4 = ((b & 0b00001111) << 1) | (mem[i + 1] >> 7)

// restore r2
ldr r2, r0

set if24
bne r4, r1

# increment mem[35]
set 35
ldr r4, OUT
set 1
add r4, OUT
mov r4, OUT
set 35
str r4, OUT

if24:
mov r0, r0

set 1
add r0, OUT
mov r0, OUT ; i = r0 += 1

mov r2, 32
set loop_start
bne r0, r2
