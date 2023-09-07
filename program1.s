# r0: i
# r1: msb
# r2: lsb

mov r0, 0    // set r0 = 0

loop_start:
mov r0, r0 ; nop

// r1 for msb, r2 for lsb
ldr r2, r0  // r1 = mem[i]
set 1
add r0, OUT  // OUT = i + 1
ldr r1, OUT // r2 = mem[OUT] = mem[i+1]


// Move p8 value into r3 (*each bit in r3 will hold a parity bit)

// set r3 to mask
mov r3, 0b00001111
set 4
rot r3, OUT
mov r3, OUT

// WORKING TAG

and r2, r3         // OUT = lsb & 11110000, parity = ^OUT
mov r4, OUT
xor r4, r1        // (msb ^ (lsb & 11110000))
mov r3, par		   //r3 now has p8 in lsb
mov r4, 1
rot r3, r4
mov r3, OUT ; r3 = p8 000_0000


mov r4, 0b10001110
and r2, r4 // OUT = lsb & 10001110, parity = ^OUT
mov r4, OUT
xor r1, r4 // parity = ^(msb ^ (lsb & 10001110))
mov r4, par //r4 now has p4
set 2 
rot r4, OUT
orr OUT, r3 // Combines r3 with OUT(holds p4) and output to OUT
mov r3, OUT ; r3 = p8 p4 00_0000

// Temporarily use r1 and r2

// Moving p2 value into r3  (*Remember: r1 holds msb and r2 holds lsb)
set 0b00000110 // mask for upper bits
and r1, OUT         // OUT register = msb & 0b01101101
mov r1, OUT        // r1 = OUT register = parity(msb & 0b01101101)
set 0b01101101 // mask for lower bits
and r2, OUT         
mov r4, OUT   // r4 = lsb & 0b01101101
xor r1, r4        // OUT = (msb & 0b00000110) ^ (lsb & 0b01101101)
mov r1, par ; r1 = parity(OUT)
set 3
rot r1, OUT ; rotate and mask
orr OUT, r3
mov r3, OUT ; r3 = p8 p4 p2 0_0000

// Reload r1 
set 1
add r0, OUT
ldr r1, OUT  // Return r1 back to mem[i+1]


// int p1 = parity((msb & 0b00000101) ^ (lsb & 0b01011011));
// p1
set 0b00000101
and r1, OUT         // sets OUT register to (msb & 0b00000101)
mov r1, OUT        // Override r1 to r1 = parity(msb & 0b0000_0101)
set 0b01011011 // temporary register for r2
and r2, OUT         // OUT = (lsb & 0b01011011)
mov r4, OUT
xor r1, r4       
mov r1, par // r1 = parity((msb & 0b00000101) ^ (lsb & 0b01011011))

set 4
rot r1, OUT  // Turns OUT to 0b0001_0000
orr OUT, r3 // Combines parity with OUTput register from XOR
mov r3, OUT ; r3 = p8 p4 p2 p1 0000

set 1
add r0, OUT
ldr r1, OUT  // Return r1 back to mem[i+1]


// int p0 = parity(msb ^ lsb ^ p8 ^ p4 ^ p2 ^ p1);
// p0
xor r1, r2 
mov r4, par   // r4 = parity(msb ^ lsb)
xor r4, r3   
mov r4, par    // r4 now holds parity(msb ^ lsb ^ p8 ^ p4 ^ p2 ^ p1)

// Fix with parity register par
set 5
rot r4, OUT
orr OUT, r3
mov r3, OUT ; r3 = p8 p4 p2 p1 p0 000

// TRANSLATE msb rrt(3) & 11100000 | lsb rrt(3) & 00011110 | p8	output MSW
set 3
rot r1, OUT
mov r1, OUT ; r1 = msb rrt(3)
; set 0b11100000
; and OUT, r1
; mov r1, OUT  ; r1 = msb rrt(3) & 1110_0000

set 3
rot r2, OUT
mov r2, OUT ; r2 = lsb rrt(3)
set 0b00011110
and r2, OUT  
mov r2, OUT ; r2 = lsb rrt(3) & 0b0001_1110
set 7
rot r3, OUT         
mov r4, OUT    // Stores r3 rotated by 7 in r4
set 0b00000001
and r4, OUT
mov r4, OUT        // R4 now holds p8 BIT
orr r1, r2         // OUT now holds the first or statement
orr OUT, r4        // Final Or
mov r1, OUT		   // r1 should hold out_msw

; write r1 to mem
set 31
add r0, OUT ; OUT = i + 31
str r1, OUT
; r1 is free

ldr r2, r0        // r2 = mem[OUT] = mem[i+1] R2 now has LSB


// output LSW
// lsb rrt(4) & 11100000 | p4 rrt(4) & 11110000 | ((lsb & 00000001) rrt(5) & 11111000 | 
// p2 rrt(6) & 11111100 | p1 rrt(7) & 11111110 | p0

//TODO fix rotates Blue Bold
set 4
rot r2, OUT
mov r4, OUT ; r4 = lsb rrt(4)

set 0b00000111
mov r1, OUT
set 3
rot r1, OUT
mov r1, OUT ; r1 = 0b1110_0000

and r1, r4         // OUT = lsb rrt(4) & 11110000
mov r4, OUT         // r4 = lsb rrt(4) & 11110000
set 0b00000001
and r2, OUT
mov r2, OUT ; r2 = lsb & 0000_0001

set 5
rot r2, OUT
mov r2, OUT         // Replaces lsb with (lsb & 00000001) rrt(5)
orr r2, r4
mov r2, OUT         // Now r2 holds lsb rrt(4) & 11110000 |((lsb & 00000001) rrt(5) & 11111000
				    // r4 is free again


//Red Bold
set 0b01000000
and r3, OUT		//Mask parity bits to grab p4 bit
mov r4, OUT ; r4 = 0b0100_0000 & r3 == p4
set 2
rot r4, OUT ; out = 000 p4 0000
orr OUT, r2
mov r2, OUT	// r2 now holds the first 3 or statements (r4 free again)


//Handling p2 bit
set 0b00100000
and r3, OUT		//Mask parity bits to grab p2 bit
mov r4, OUT ; r4 = 00 p2 00000
set 3
rot r4, OUT
mov r4, OUT 	// r4 = 00000 p2 00
orr r2, r4
mov r2, OUT	// r2 now holds the first 4 or statements (r4 free again)


// Handling p1 bit
set 0b00010000
and r3, OUT		// Mask parity bits to grab p1 bit
mov r4, OUT ; r4 = 000 p1 0000
set 3
rot r4, OUT ; OUT = 0000 00 p1 0
orr OUT, r2
mov r2, OUT	// r1 now holds the first 4 or statements (r4 free again)


//Handling p0 case
set 0b00001000
and r3, OUT
mov r4, OUT ; r4 = 0000 p0 000
set 3
rot r4, OUT ; OUT = 0000 000 p0
orr OUT, r2
mov r2, OUT		//r2 now holds out_lsw

# store out_lsw in mem
set 30
add r0, OUT
str r2, OUT ; mem[i+30] = out_lsw


# r0 += 2 or i += 2
set 2
add r0, OUT
mov r0, OUT

mov r4, 30
set loop_start
bne r0, r4
