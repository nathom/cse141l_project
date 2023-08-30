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
set 0b01111111 // Tempoarily storing output register with value
and r4, OUT         // Reassigns OUT to (lsb & 0b00000010) rrt(1) & 0b01111111
rot OUT, 4          // Places in p1 bit position
mov r4, OUT
orr r4, r3          // Stores bit in parity register p3


// p2
mov r4, 0b00000100
and r4, r2          
rot OUT, 2          // (lsb & 0b00000100) rrt(2)
mov r4, OUT         
set 0b00111111 
and r4, OUT         // (lsb & 0b00000100) rrt(2) & 0b00111111
rot OUT, 3          // Places in p2 bit position
orr OUT, r3         // Stores in r3


// p4
mov r4, 0b00010000  
and r4, r2
rot OUT, 4          
mov r4, OUT
set 0b00001111
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
set 0b10101000 // temporarily storing in output register
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
set 0b11001000 // temporarily storing in output register
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
set 0b10101000
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
set 
beq r4,r3

str r2, r0, -30
str r1, r0, -31


//TODO else if (p0 == p0_exp)

//TODO else
mov r4, 0b00000000          //Int hamming = 0;

//First checking if p8 bit is bad
rot r3, 7
mov r1, OUT         //r1 now holds the temporary shifted r3 
set 0b00000001      //OUT now has the mask
and r1, OUT         //masks the rotation so that its only one bit
mov r1, OUT 
mov r2, 0b00000001  //r2 holds the "one" value to represent a mismatch bit
set parityfour
beq r1, r2          //checks if the p8 bit is 
set 0b00001000
add r4, OUT
mov r4, OUT


//Checking p4 bit
parityfour:
rot r3, 6
mov r1, OUT
set 0b00000001
and r1, OUT
mov r1, OUT
set paritytwo
beq r1, r2
set 0b00000100
add r4, OUT
mov r4, OUT

//Checking p2 bit
paritytwo:
rot r3, 5
mov r1, OUT
set 0b00000001
and r1, OUT
mov r1, OUT
set parityone
beq r1, r2
set 0b00000010
add r4, OUT
mov r4, OUT

//Checking p1 bit
parityone:
rot r3, 4
mov r1, OUT
set 0b00000001
and r1, OUT
mov r1, OUT
set lsb_out_set
beq r1, r2
set 0b00000001
add r4, OUT
mov r4, OUT         //r4 now holds hamming total

//From here on out we don't need the parity bits until the next cycle
//They will be recalculated anyways so i'm using it here
lsb_out_set:

// r1 for msb, r2 for lsb
ldr r1, r0          // r1 = mem[i] replaces MSB
mov r2, 1
add r0, r2          // OUT = i + 1
ldr r2, OUT         // r2 = mem[OUT] = mem[i+1] replaces LSb

mov r3, 8           //r1 just holds and checks if hamming is 
set ge_eight

//TODO how to check if hamming is less than 8
//TODO need to fill in liness 51-58

//At this point, r1 should hold lsb_out and r2 should hold msb_out
ge_eight:
mov r4, 0b00000000
rot r1, 3
mov r4, OUT         //r4 now holds lsb_out rrt(3)
set 0b00000001
and OUT, r4
mov r4, OUT         //r4 now holds the first lout expression
//we don't have to do the orr function for the first one because or'ing with zero is always itself
 
//second lout expression
rot r1, 4
mov r1, OUT         //we are using r1 now because we no longer need lsb_out for this cycle
set 0b00001111
and r1, OUT         //OUT now contains lsb_out rrt(4) & 0b00001111
mov r1, OUT
set 0b00001111
and r1, OUT
orr OUT, r4         //orring with previous lout 
mov r4, OUT

//third lout expression
rot r2, 5
mov r1, OUT
set 0b11111000
and r1, OUT
mov r1, OUT
set 0b11110000
and r1, OUT
orr r4, OUT
mov r4, OUT         //r4 now has final lout

/* So quick recap
r0 is your counter, do not touch
r1 holds garbage data (previously lsb_out), will now hold hout
r2 holds msb_out
r3 holds garbage data (previously parity bits)
r4 holds lout
r5 is the tempoarary XOR register
 */

 //Using r1 for hout
 mov r1, 0b00000000
 rot r2, 5
 mov r3, OUT
 set 0b00000111
 and r3, OUT
 mov r1, OUT        //r1 holds hout

//needs to decrement by 30?
//TODO lines 69 and 70


mov r1, 2
add r0, r1  //  OUT = i + 2
mov r0, OUT // set i = OUT
loop_end:
mov r0, r0
