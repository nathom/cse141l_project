// TODO update to include LSB AND MSB
# r0 - counter
# r1 - MSB
# r2 - LSB
# r3 - Parity
# r5 - Immediate register for XOR

# IMPORTANT NOTE - For r3, the format is going to be the XOR of p0 and the expected
mov r0, 0   // set r0 = i = 0
loop_start:
mov r0, r0


// r1 = msb, r2 = lsb
set 31
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 31] replaces MSB
set 30
add r0, OUT
ldr r2, OUT // r2 = mem[i + 30]

// Format r3 = p8_p4_p2_p1_p0_000

// p0
mov r4, 0b00000001
and r2, r4          // OUT = lsb & 0b00000001
mov r4, OUT
set 5
rot r4, OUT
mov r3, OUT         // r3 = 0000 p0 000


// p1
mov r4, 0b00000010
and r2, r4          
mov r4, OUT         // r4 = lsb & 0b00000010
set 5
rot r4, OUT         //OUT = (lsb & 0b00000010) rrt(5)
orr OUT, r3
mov r3, OUT ; r3 = 000 p1 p0 000


// p2
mov r4, 0b00000100
and r4, r2          //(lsb & 0b00000100)
mov r4, OUT         //r4 = (lsb & 0b00000100)
set 5      
rot r4, OUT         // OUT = 00 p2 0 0000 
orr OUT, r3 
mov r3, OUT ; r3 = 00 p2 p1 p0 000


// p4
set 0b00000001
mov r4, OUT
set 4
rot r4, OUT
mov r4, OUT ; r4 = 0b00010000, fewer instructions than mov imm
and r4, r2          //(lsb & 0b00010000)
mov r4, OUT         //r4 = ^^
set 6
rot r4, OUT           ; r4 = 0 p4 00 0000
orr OUT, r3
mov r3, OUT ; r3 = 0 p4 p2 p1 p0 000


// p8
mov r4, 0b00000001
and r1, r4          // msb & 0b00000001
mov r4, OUT
set 1
rot r4, OUT         //Rotates into p8 posittion
orr OUT, r3         // stores in p8 bit position in p3
mov r3, OUT ; r3 = p8 p4 p2 p1 p0 000

// Done with found parity bits

// Start Expected Parity Bits

// Format r4 = p8exp p4exp p2exp p1exp p0exp 000

// p0_exp
mov r4, 0b11111110
and r4, r2         // OUT = lsb & 0b11111110
mov r4, OUT
xor r4, r1         // msb ^ lsb & 11111110
mov r4, par        // r4 holds p0_exp
set 5
rot r4, OUT         // r4 is now 0000_p0exp_000
mov r4, OUT


// p1_exp
set 0b10101010
and OUT, r1          // OUT = msb & 0b10101010
mov r1, OUT ; r1 = msb & 0b10101010
set 0b10101000     
and OUT, r2
mov r2, OUT ; r2 = lsb & 0b10101000     
xor r1, r2
mov r1, par ; r1 = p1_exp
set 4
rot r1, OUT
orr OUT, r4 ; r4 = 000 p1exp p0exp 000

// Restore r1 and r2 to msb, lsb
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB
set 31
add r0, OUT // OUT = i + 30
ldr r2, OUT // r1 = mem[i + 30] replaces MSB

// p2_exp
set 0b11001100
and OUT, r1     
mov r1, OUT ; r1 = msb & 0b11001100
set 0b11001000
and OUT, r2
mov r2, OUT ; r2 = lsb & 0b11001000
xor r1, r2
mov r1, par ; r1 = p2_exp
set 3
rot r1, OUT
orr OUT, r4 ; r4 = 00 p2exp p1exp p0exp 000

// Restore r1 and r2 to msb, lsb
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB
set 31
add r0, OUT // OUT = i + 30
ldr r2, OUT // r1 = mem[i + 30] replaces MSB

// p4_exp
set 4
rot r1, OUT
mov r1, OUT ; r1 = msb rot(4)
set 0b00001111
and OUT, r1     
mov r1, OUT ; r1 = msb rot(4) & 0b00001111
set 0b11100000
and OUT, r2
mov r2, OUT ; r2 = lsb & 0b11001000
xor r1, r2
mov r1, par ; r1 = p2_exp
set 2
rot r1, OUT
orr OUT, r4 ; r4 = 0 p4exp p2exp p1exp p0exp 000

// Restore r1 and r2 to msb, lsb
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB
set 31
add r0, OUT // OUT = i + 30
ldr r2, OUT // r1 = mem[i + 30] replaces MSB

// p8_exp
set 1
rot r1, OUT
mov r1, OUT
set 0b01111111
and r1, OUT
mov r1, par ; r1 = parity(msb rrt(1) & 0b01111111);
set 1
rot r1, OUT
orr OUT, r4
mov r4, OUT ; r4 = p8exp p4exp p2exp p1exp p0exp 000

// Restore r1 to msb
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB

// compute r3 = r3 ^ r4
xor r3, r4
mov r3, OUT

// if all the parity bits are equal it will be 0b00000000
// if any are not equal one of the high bits will be 1
mov r4, 0
set else_if_p0_eq_p0_exp
bne r3, r4

// r4 is free

// register state:
// r1: msb
// r2: lsb
// r3: parity XORed with expected parity
// r4: lout

set 3
rot r2, OUT
mov r4, OUT
set 1
and r4, OUT
mov r4, OUT ; r4 (lout) = (lsb >> 3) & 1

set 4
rot r2, OUT
mov r2, OUT ; r2 = (lout >> 4)
set 0b00001110
and r2, OUT ; OUT = (lout >> 4) & 0b00001110
orr OUT, r4
mov r4, OUT ; lout |= r2

// r2 NO LONGER lsb

mov r2, 0b00001111
set 4
rot r2, OUT
mov r2, OUT ; r2 = 0b11110000
set 5
rot r1, OUT
and OUT, r2 ; OUT = msb rrt(5) & 0b11110000
orr OUT, r4
mov r4, OUT ; lout |= msb rrt(5) & 0b11110000

// Restore r2 to lsb
set 31
add r0, OUT // OUT = i + 31
ldr r2, OUT // r2 = mem[i + 31] replaces lsb

str r4, r0 ; mem[i] = lout

// compute hout
set 5
rot r1, OUT
mov r4, OUT
set 0b00000111
and r4, OUT
mov r4, OUT ; r4 (hout) = msb rrt(5) & 00000111

set 1
add r0, OUT
str r4, OUT ; mem[i+1] = r4 (hout)

mov r4, 33
set loop_end
bne r0, r4 ; unconditional branch to end, i never equal 33

else_if_p0_eq_p0_exp:
mov r0, r0 ; nop
// HANDLE `else if (p0 == p0_exp)`
// register state:
// r1: msb
// r2: lsb
// r3: parity XORed with expected parity,  p8_p4_p2_p1_p0_000
// r4: free

// check if p0 bit is on
set 0b00001000
and r3, OUT
mov r4, OUT
mov r5, 0 ; safe to use because no and, xor, or orr
set else
bne r4, r5

set 1
mov r4, OUT
set 1
rot r4, OUT
mov r4, OUT ; r4 = 0b10000000
set 1
add r0, OUT
str r4, OUT ; mem[i+1] = 0b1000_0000

mov r4, 1
mov r5, 0
set loop_end
bne r4, r5 ; unconditional branch to end of loop

// END OF ELSE IF STATEMENT
// START OF first ELSE STATEMENT

//TODO else
else:
mov r0, r0 ; nop


set 4
rot r3, OUT
mov r4, OUT ; r4 = r3 rot(4)
set 0b00001111 ; r4 = p0 000 p8 p4 p2 p1
and r4, OUT ; get rid of p0
mov r4, OUT ; r4 = hamming

// make sure r1 = msb, r2 = lsb
ldr r1, r0          // r1 = mem[i] replaces MSB
set 1
add r0, OUT          // OUT = i + 1
ldr r2, OUT         // r2 = mem[OUT] = mem[i+1] replaces LSb

set 0b00001000      // < 8 check
and OUT, r4         // OUT now has hamming & 0b1111_1000
mov r3, OUT
mov r5, 0
set ge_eight
bne r5, r3         // checks if r4 == 0 which determines whether it is greater   

// Case < 8
nand r4, r4         // OUT = inverted bits of hamming
mov r4, OUT
set 1
add r4, OUT ; OUT = ~hamming + 1
mov r4, OUT         // r4 is now negative (2s complement)
mov r3, 8
add r3, r4          // 8 - hamming
mov r3, OUT         // r3 = 8 - hamming

set 0b00000001
rot OUT, r3         //(1 rrt(8 - hamming))
mov r4, OUT
xor r2, r4
mov r2, OUT ; r2 = lsb but with bit at position `hamming` flipped

mov r3, 0
mov r4, 1
set end_if_else
bne r3, r4

//Case: GE Eight
ge_eight:
mov r0, r0 ; nop
// r4 is still hamming
nand r4, r4         // OUT = inverted bits of hamming
mov r4, OUT
set 1
add r4, OUT ; OUT = -hamming
mov r4, OUT
set 16
add r4, OUT
mov r4, OUT ; r4 = 16 - hamming
set 1
rot OUT, r4
mov r4, OUT ; r4 = 1 >> (16-hamming)
xor r1, r4
mov r1, OUT ; msb = msb ^ (1 rrt(16 - hamming));

end_if_else:
mov r0, r0

// goal: put lout into r4
//r1 = msb; r2 = lsb (bit flipped versions)
mov r4, 0
set 3
rot r2, OUT
mov r4, OUT
set 1
and r4, OUT
mov r4, OUT ; r4 (lout) = (lsb >> 3) & 1

set 4
rot r2, OUT
mov r2, OUT ; r2 = (lout >> 4)
set 0b00001110
and r2, OUT ; OUT = (lout >> 4) & 0b00001110
orr OUT, r4
mov r4, OUT ; lout |= r2

// r2 NO LONGER lsb

mov r2, 0b00001111
set 4
rot r2, OUT
mov r2, OUT ; r2 = 0b11110000
set 5
rot r1, OUT
and OUT, r2 ; OUT = msb rrt(5) & 0b11110000
orr OUT, r4
mov r4, OUT ; lout |= msb rrt(5) & 0b11110000

str r4, r0 ; mem[i] = lout

// put hout in r4
set 5
rot r1, OUT
mov r4, OUT
set 0b00000111
and r4, OUT
mov r4, OUT ; hout = msb rot(5) & 0b111
set 0b01000000
orr OUT, r4
mov r4, OUT ; set high 2 bits to 01

set 1
add r0, OUT
str r4, OUT

loop_end:
mov r0, r0 ; nop

set 2
add r0, OUT
mov r0, OUT ; increment i

mov r4, 32
set loop_start
bne r0, r4
