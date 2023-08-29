// TODO update to include LSB AND MSB
/*
r0 - counter
r1 - MSB
r2 - LSB
r3 - Parity
r5 - Immediate register for XOR

IMPORTANT NOTE - For r3, the format is going to be the XOR of p0 and the expected
 */
mov r0, 30   // set r0 = 30
mov r1, 62
set loop_end // set addr to OUT
beq r0, r1

// r1 for msb, r2 for lsb
ldr r1, r0          // r1 = mem[i] replaces MSB
mov r2, 1
add r0, r2          // OUT = i + 1
ldr r2, OUT         // r2 = mem[OUT] = mem[i+1] replaces LSb

// Format p8_p4_p2_p1_p0_000

// p0
mov r4, 0b00000001
and r2, r4          // OUT = lsb & 0b00000001
mov r4, OUT
rot r4, 5
orr OUT, r3         // Stores p0 bit in 4th bit position


// p1
mov r4, 0b00000010
and r2, r4          // OUT = lsb & 0b00000010
mov r4, OUT

// Is this ok? I'm rotating the output register to reassign OUT
// This is so that I don't have to move into r4 again
rot OUT, 1
mov r4, OUT         // r4 now holds (lsb & 0b00000010) rrt(1)

// This is irrelevant?
mov OUT, 0b01111111 // Tempoarily storing output register with value
and r4, OUT         // Reassigns OUT to (lsb & 0b00000010) rrt(1) & 0b01111111
rot OUT, 4          // Places in p1 bit position
mov r4, OUT
orr r4, r3          // Stores bit in parity register p3


// p2
mov r4, 0b00000100
and r4, r2          
rot OUT, 2          // (lsb & 0b00000100) rrt(2)
mov r4, OUT         
mov OUT, 0b00111111 
and r4, OUT         // (lsb & 0b00000100) rrt(2) & 0b00111111
rot OUT, 3          // Places in p2 bit position
orr OUT, r3         // Stores in r3


// p4
mov r4, 0b00010000  
and r4, r2
rot OUT, 4          
mov r4, OUT
mov OUT, 0b00001111
and OUT, r4         // (lsb & 0b00000100) rrt(2) & 0b00111111
rot OUT, 2
orr OUT, r3


// p8
mov r4, 0b00000001
and r1, r4          // msb & 0b00000001
rot OUT, 1
orr OUT, r3         // stores in p8 bit position in p3

// Expected Parity Bits

// p0_exp
mov r4, 0b11111110
and r4, r2          // lsb & 0b11110000
xor OUT, r1         // msb ^ lsb & 11111110
mov r4, par         // r4 holds p0_exp
rot r4, 5           // r4 is now 0000_p0exp_000
mov r4, OUT
xor r4, r3          // If its the same then the equivalent bit in r3 should be 0
mov r3, OUT

// TODO p1_exp
mov r4, 0b10101010
and r4, r1          // msb & 0b10101010
mov r4, OUT         // stores in r4
mov OUT, 0b10101000 // temporarily storing in output register
and OUT, r2         // lsb & 0b10101000
xOR OUT, r4         // (msb & 0b10101010) ^ (lsb & 0b10101000)
mov r4, par         // r4 now holds p1_exp
rot r4, 4           // p1_exp in proper bit position
mov r4, OUT
xor r4, r3          // Xor just the p1 bit position
mov r3, OUT

// TODO p2_exp
mov r4, 0b11001100
and r4, r1          // msb & 0b11001100
mov r4, OUT         // stores in r4
mov OUT, 0b11001000 // temporarily storing in output register
and OUT, r2         // lsb & 0b11001000
xOR OUT, r4         // (msb & 0b11001100) ^ (lsb & 0b11001000)
mov r4, par         // r4 now holds p2_exp
rot r4, 3           // p2_exp in proper bit position
mov r4, OUT
xor r4, r3          // Xor just the p2 bit position
mov r3, OUT


// TODO p4_exp
mov r4, 0b00001111
rot r1, 4
and OUT, r4         // msb rrt(4) & 0b00001111
mov r4, OUT         // r4 now has ^^
mov OUT, 0b10101000
and OUT, r2         // lsb & 0b10101000
xor OUT, r4         // (lsb & 0b10101000) ^ (msb rrt(4) & 0b00001111)
mov r4, par
rot r4, 2
mov r4, OUT
xor r4, r3          // Xor just the p4 bit position
mov r3, OUT

// TODO p8_exp
mov r4, 0b01111111
rot r1, 1
and r1, r4          // OUT = msb rrt(1) & 0b01111111
mov r4, par         // r4 now holds p8
rot r4, 1           // p8 in proper bit position
mov r4, OUT
xor r4, r3          // Xor just the p8 bit position
mov r3, OUT

// Idk if its smart to set something to zero here but i'm going to do it anyways
// line 25
mov r4, 0b00011111
rot r2, 3
and OUT, r4          // lsb rrt(3) & 0b00011111
mov r4, 0b00000001   
and r4, OUT          // (lsb rrt(3) & 0b00011111) & 0b00000001
// line 26
mov r1, OUT          // Temporarily replacing MSB with AND result
mov r4, 0b00001111
rot r2, 4
and OUT, r4         // OUT = lsb rrt(4) & 0b00001111
mov r4, 0b00001110
and r4, OUT         // (lsb rrt(4) & 0b00001111) & 0b00001110
orr OUT, r1         // Or operation from line 25 operations
mov r2, OUT         // Temporarily storing the new or operation in r2
ldr r1, r0          // r1 = mem[i] returns MSB to original value
// line 27
mov r4, 0b11111000
rot r1, 5
and r1, r4          // msb rrt(5) & 0b11111000
mov r4, 0b11110000
and OUT, r4
orr OUT, r2         
mov r2, OUT         // r2 now holds the final lout

// hout
mov r4, 0b00000111
rot r1, 5
and OUT, r4
mov r1, OUT         // r1 now holds hout

// Registers we can touch r4, r5, OUT
mov r4, 0b00000000

// TODO if --> Beq r4,r3 STARTS AT LINE 32
// Str r2, r0


mov r1, 2
add r0, r1  //  OUT = i + 2
mov r0, OUT // set i = OUT
loop_end:
mov r0, r0
