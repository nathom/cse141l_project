// Current Issues: program 1 just does the xors but doesn't grab the parity bit

mov r0, 0    // set r0 = 0
mov r1, 30
set loop_end // set addr to OUT
beq r0, r1


// r1 for msb, r2 for lsb
ldr r1, r0  // r1 = mem[i]
mov r2, 1
add r0, r2  // OUT = i + 1
ldr r2, OUT // r2 = mem[OUT] = mem[i+1]


// This is not done line 21 is incorrect
// Move p8 value into r3 (*each bit in r3 will hold a parity bit)
mov r3, 0b11110000
and r2, r3         // OUT = lsb & 11110000, parity = ^OUT
xor r1, OUT        // parity = ^(msb ^ (lsb & 11110000))

// Fix with parity register par
mov r3, 1
rot OUT, r3
mov r3, OUT


// Move p4 value into r3
mov r4, 0b10001110
and r2, r4 // OUT = lsb & 10001110, parity = ^OUT
xor r1, OUT // parity = ^(msb ^ (lsb & 10001110))

// Fix with parity register par
rot OUT, 2  // Right rotate to 0b0100_0000
orr r3, OUT // Combines r3 with OUT(holds p4) and output to OUT
mov r3, OUT // Update r3 to hold p4


// Moving p2 value into r3  (*Remember: r1 holds msb and r2 holds lsb)
mov r4, 0b00000110 // mask for upper bits
and r1, r4         // OUT register = msb & 0b01101101
mov r1, OUT        // r1 = OUT register = msb & 0b01101101
mov r4, 0b01101101 // mask for lower bits
and r2, r4         // lsb & 0b01101101
xor OUT, r1        // OUT = parity(msb & 0b00000110) ^ (lsb & 0b01101101)

// Fix with parity register par
rot OUT, 3  // Right rot OUT to 0b0010_0000
orr r3, OUT // Combines p2 into r3 and sends output to OUT
mov r3, OUT // Update r3 to hold p2
ldr r1, r2  // Return r1 back to original value


// int p1 = parity((msb & 0b00000101) ^ (lsb & 0b01011011));
// p1
mov r4, 0b00000101
and r1, r4         // sets OUT register to (msb & 0b00000101)
mov r1, out        // Override r1
mov r4, 0b01011011 // temporary register for r2
and r2, R4         // OUT = (lsb & 0b01011011)
xor OUT, r1        // OUT = parity((msb & 0b00000101) ^ (lsb & 0b01011011))

// Fix with parity register par
rot OUT, 4  // Turns OUT to 0b0001_0000
orr r3, OUT // Combines parity with OUTput register from XOR
mov r3, OUT
ldr r1, r0  // Returns original value


// int p0 = parity(msb ^ lsb ^ p8 ^ p4 ^ p2 ^ p1);
// p0
xor r1, r2 // OUT = msb ^ lsb
mov r4, OUT 
xor r4, r3 // OUT now holds msb ^ lsb ^ p8 ^ p4 ^ p2 ^ p1

// Fix with parity register par
rot OUT, 5
orr r3, OUT
mov r3, OUT


// TRANSLATE msb rrt(3) & 11100000 | lsb rrt(3) & 00011111 | p8	output MSW
rot r1, 3
mov r4, 0b11100000
and OUT, r4
mov r1, OUT        // Replaces r1 with msb rrt(3) & 11100000
rot r2, 3
mov r4, 0b00011111
and OUT, r4        // OUT now holds lsb rrt(3) & 00011111
mov r2, OUT
rot r3, 7          // Stores r3 rotated by 7 in OUT
mov r4, 0b00000001
and r4, OUT
mov r4, OUT        // R4 now holds p8 BIT
orr r1, r2         // OUT now holds the first or statement
orr OUT, r4        // Final Or
ldr r1, r0         // Returns original value for MSB
mov r2, 1
add r0, r2         // OUT = i + 1
ldr r2, OUT        // r2 = mem[OUT] = mem[i+1] R2 now has LSB


// What does this do? -> output LSW
/*lsb rrt(4) & 11110000 | p4 rrt(4) & 11110000 | ((lsb & 00000001) rrt(5) & 11111000 | 
p2 rrt(6) & 11111100 | p1 rrt(7) & 11111110 | p0
*/

// Blue Bold
rot r2, 4
mov r4, 0b11110000
and OUT, r4         // OUT = lsb rrt(4) & 11110000
mov r4, OUT         // r4 holds lsb rrt(4) & 11110000
mov OUT, 0b00000001
and r2, OUT
rot OUT, 5
mov r2, OUT         // Replaces lsb with (lsb & 00000001) rrt(5)
mov OUT, 0b11111000
and r2, OUT         // r2 holds ((lsb & 00000001) rrt(5) & 11111000)
orr r2, r4
mov r2, OUT         // Now r2 holds lsb rrt(4) & 11110000 |((lsb & 00000001) rrt(5) & 11111000
				    // r4 is free again


//Red Bold
Mov r4, 01000000
And r3, r4		//Mask parity bits to grab p4 bit
Rot OUT, 10	//Rotates by 10 to get into lowest bit first
Mov r4, OUT 	//r4 now holds p4 rrt(4)
Mov OUT, 11110000
And OUT, r4
Mov r4, OUT	//Finishes p4 rrt(4) & 11110000
Orr r2, r4
Mov r2, OUT	//r2 now holds the first 3 or statements (r4 free again)


//Handling p2 bit
Mov r4, 00100000
And r3, r4		//Mask parity bits to grab p2 bit
Rot OUT, 3
Mov r4, OUT 	//r4 now holds p2 rrt(6)since it rotates twice
Mov OUT, 11111100
And OUT, r4
Mov r4, OUT	//Finishes p2 rrt(6) & 11111100
Orr r2, r4
Mov r2, OUT	//r2 now holds the first 4 or statements (r4 free again)


//Handling p1 bit
Mov r4, 00010000
And r3, r4		//Mask parity bits to grab p1 bit
Rot OUT, 7
Mov r4, OUT 	//r4 now holds p2 rrt(6)since it rotates twice
Mov OUT, 11111110
And OUT, r4
Mov r4, OUT	//Finishes p1 rrt(7) & 11111110
Orr r2, r4
Mov r2, OUT	//r1 now holds the first 4 or statements (r4 free again)


//Handling p0 case
Mov r4, 00001000
And r4, r3
Rot OUT, 3
Mov r4, OUT		//p4 now holds p0
Orr r2, r4
Mov r2, OUT		//r2 now holds the entire expression

// TODO Must bring result back into mem[]
// What does this mean? -> OUT, parity Is this translating properly?
mov r1, 2
add r0, r1  // OUT = i + 2
mov r0, OUT // set i = OUT
loop_end:

