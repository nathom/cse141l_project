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
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB
set 31
add r0, OUT
ldr r2, OUT // r2 = mem[i + 31]

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

// p0_exp
mov r4, 0b11111110
and r4, r2         // OUT = lsb & 0b11111110
mov r4, OUT
xor r4, r1         // msb ^ lsb & 11111110
mov r4, par        // r4 holds p0_exp
set 5
rot r4, OUT         // r4 is now 0000_p0exp_000
mov r4, OUT
xor r4, r3          // If its the same then the equivalent bit in r3 should be 0
mov r3, OUT
//parity(msb) ^ parity(lsb & 11111110);

// TODO p1_exp
mov r4, 0b10101010
and r4, r1          // OUT = msb & 0b10101010
mov r4, OUT         // stores in r4
set 0b10101000      // temporarily storing in output register
and OUT, r2         // lsb & 0b10101000
mov r1, OUT
xor r1, r4          // (msb & 0b10101010) ^ (lsb & 0b10101000)
mov r4, par         // r4 now holds p1_exp
set 4
rot r4, OUT         // p1_exp in proper bit position
mov r4, OUT
xor r4, r3          // Xor just the p1 bit position
mov r4, OUT         
set 0b00010000      
and OUT, r4         //Mask to get ONLY p1
mov r4, OUT
set 0b11101111      //r3 clears out garbage data
and OUT, r3
mov r3, OUT
orr r4, r3         //Inserts into p3
mov r3, OUT
//Returns r1 to initial state since we needed it for a temp reg
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB
//parity(msb & 0b10101010) ^ parity(lsb & 0b10101000);

// TODO p2_exp
mov r4, 0b11001100
and r4, r1          // msb & 0b11001100
mov r4, OUT         // stores in r4
set 0b11001000 // temporarily storing in output register
and OUT, r2         // lsb & 0b11001000
mov r1, OUT
xor r1, r4          // (msb & 0b11001100) ^ (lsb & 0b11001000)
mov r4, par         // r4 now holds p2_exp
set 3
rot r4, OUT         // p2_exp in proper bit position
mov r4, OUT
xor r4, r3          // Xor just the p2 bit position
mov r4, OUT         
set 0b00100000      
and OUT, r4         //Mask to get ONLY p2
mov r4, OUT
set 0b11011111      //r3 clears out garbage data
and r3, OUT
mov r3, OUT
orr r3, r4
mov r3, OUT         //Inserts into p3


//Replaces r1 back to original
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB

// TODO p4_exp
mov r4, 0b00001111
set 4
rot r1, OUT
and OUT, r4         // msb rrt(4) & 0b00001111
mov r4, OUT         // r4 now has ^^
set 0b11100000
and OUT, r2         // lsb & 0b11100000
mov r1, OUT
xor r1, r4         // (lsb & 0b10101000) ^ (msb rrt(4) & 0b00001111)
mov r4, par        //r4 now has p4_exp
set 2
rot r4, OUT
mov r4, OUT
xor r4, r3          // Xor just the p4 bit position
mov r4, OUT         
set 0b01000000      
and OUT, r4         //Mask to get ONLY p4
mov r4, OUT
set 0b10111111      //r3 clears out garbage data
and r3, OUT
mov r3, OUT
orr r3, r4
mov r3, OUT         //Inserts p4 into r3

//Replaces r1 again
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB

// TODO p8_exp
mov r4, 0b01111111
set 1
rot r1, OUT         //msb rrt(1)
mov r1, OUT         //r1 = ^^
and r1, r4          // OUT = msb rrt(1) & 0b01111111
mov r4, par         // r4 now holds p8
set 1
rot r4, OUT         // p8 in proper bit position
mov r4, OUT
xor r4, r3          // Xor just the p8 bit position
mov r4, OUT         
set 0b10000000      
and OUT, r4         //Mask to get ONLY p8
mov r4, OUT
set 0b01111111      //r3 clears out garbage data
and r3, OUT         
mov r3, OUT
orr r3, r4          //inserts r8 into bit position
mov r3, OUT         //Inserts into p3

//Replaces r1 again
set 30
add r0, OUT // OUT = i + 30
ldr r1, OUT // r1 = mem[i + 30] replaces MSB

// Idk if its smart to set something to zero here but i'm going to do it anyways
// line 25 lout |= (lsb rrt(3) & 0b00011111) & 0b00000001;
mov r4, 0b00011111
set 3
rot r2, OUT
and OUT, r4          // lsb rrt(3) & 0b00011111
mov r4, OUT          //r4 = ^^
set 0b00000001   
and r4, OUT          // (lsb rrt(3) & 0b00011111) & 0b00000001

// line 26           lout |= (lsb rrt(4) & 0b00001111) & 0b00001110;
mov r1, OUT          // Temporarily replacing MSB with AND result
mov r4, 0b00001111
set 4
rot r2, OUT
and OUT, r4         // OUT = lsb rrt(4) & 0b00001111
mov r4, OUT
set 0b00001110
and r4, OUT         // (lsb rrt(4) & 0b00001111) & 0b00001110
orr OUT, r1         // Or operation from line 25 operations
mov r2, OUT         // Temporarily storing the new or operation in r2

//Replaces r1 again
set 30
add r0, OUT 
ldr r1, OUT        // r1 = mem[i] returns MSB to original value

// line 27
mov r4, 0b11111000
set 5
rot r1, OUT
and OUT, r4          // msb rrt(5) & 0b11111000
mov r4, OUT         //r4 = ^^
set 0b11110000
and OUT, r4
orr OUT, r2         
mov r2, OUT         // r2 now holds the final lout

// hout
mov r4, 0b00000111
set 5
rot r1, OUT
and OUT, r4
mov r1, OUT         // r1 now holds hout

// Registers we can touch r4, r5, OUT
mov r4, 0b00000000

//if --> bne r4,r3
set p0exp_loop
bne r4, r3

//TODO else if (p0 == p0_exp)
hammingCheck:
mov r0, r0
set 3           
rot r3, OUT         //Rotating parity comparison by 3
mov r4, OUT
set 0b00000001      //Isolating the p0_exp bit
and r4, OUT     
mov r4, OUT         //r4 holds p0_exp
mov r5, 0b00000000
set else_hamming
bne r4, r5

//TODO else
else_hamming:
mov r4, 0b00000000          //Int hamming = 0;

//First checking if p8 bit is bad
set 7
rot r3, OUT
mov r1, OUT         //r1 now holds the temporary shifted r3 
set 0b00000001      //OUT now has the mask
and r1, OUT         //masks the rotation so that its only one bit
mov r1, OUT 
mov r2, 0b00000001  //r2 holds the "one" value to represent a mismatch bit
//Logic : (p8 != p8_exp) hamming += 8
//if p8 != p8_exp, that means the corresponding bit in r3 will be 1
//So if the bit in r3 is 1, then you add 8, if its 0, then branch to p4
//In other words, if r1 doesn't equal r2, then r3 = 0 meaning branch
set parityfour
bne r1, r2          //checks if the p8 bit is 
set 0b00001000
add r4, OUT
mov r4, OUT


//Checking p4 bit
parityfour:
mov r0, r0
set 6
rot r3, OUT
mov r1, OUT
set 0b00000001
and r1, OUT
mov r1, OUT     //r1 holds isolated p4 from r3
mov r2, 0b00000001  //r2 holds the "one" value to represent a mismatch bit
set paritytwo
bne r1, r2
set 0b00000100
add r4, OUT
mov r4, OUT

//Checking p2 bit
paritytwo:
mov r0, r0
set 5
rot r3, OUT
mov r1, OUT
set 0b00000001
and r1, OUT
mov r1, OUT
mov r2, 0b00000001  //r2 holds the "one" value to represent a mismatch bit
set parityone
bne r1, r2
set 0b00000010
add r4, OUT
mov r4, OUT

//Checking p1 bit
parityone:
mov r0, r0
set 4
rot r3, OUT
mov r1, OUT
set 0b00000001
and r1, OUT
mov r1, OUT
mov r2, 0b00000001  //r2 holds the "one" value to represent a mismatch bit
set lsb_out_set
bne r1, r2
set 0b00000001
add r4, OUT
mov r4, OUT         //r4 now holds hamming total

//From here on out we don't need the parity bits until the next cycle
//They will be recalculated anyways so i'm using it here
lsb_out_set:
mov r0, r0
// r1 for msb, r2 for lsb
ldr r1, r0          // r1 = mem[i] replaces MSB
mov r2, 1
add r0, r2          // OUT = i + 1
ldr r2, OUT         // r2 = mem[OUT] = mem[i+1] replaces LSb

set 0b11111000      //< 8 check
and OUT, r4         //OUT now has hamming & 0b1111_1000
mov r3, OUT
mov r5, 0b00000000
set ge_eight
bne r5, r3         //checks if r4 == 0 which determines whether it is greater   

//r1 = msb_out ; r2 = lsb_out
lt_eight:
mov r0, r0
//Case LT Eight
nand r4, r4         //OUT = flipped bits of hamming
mov r4, 0b00000001
add OUT, r4         
mov r4, OUT         //r4 is now negative
mov r3, 0b00001000
add r3, r4          //8 - hamming
mov r3, OUT         //r3 = ^^
set 0b00000001
rot OUT, r3         //(1 rrt(8 - hamming))
mov r4, OUT
xor r2, r4
mov r2, OUT
mov r3, 0
mov r4, 1
set end_if_else
bne r3, r4

//Case: GE Eight
ge_eight:
mov r0, r0
mov r3, 0b11110000  //should be -16?
add r3, r4          //OUT = hamming - 16
mov r3, OUT         //r3 = ^^
set 0b00000001
rot OUT, r3
mov r4, OUT
xor r1, r4
mov r1, OUT         //r1 now has msb_out

//r1 = msb_out ; r2 = lsb_out
end_if_else:
mov r0, r0
mov r4, 0b00000000
set 3
rot r2, OUT
mov r4, OUT         //r4 now holds lsb_out rrt(3)
set 0b00011111
and r4, OUT         //r4 = lsb_out rrt(3) & 0b00011111
mov r4, OUT
set 0b00000001
and OUT, r4
mov r4, OUT         //r4 now holds the first lout expression
//we don't have to do the orr function for the first one because or'ing with zero is always itself
 
//second lout expression
set 4
rot r2, OUT
mov r2, OUT         //we are using r2 now because we no longer need lsb_out for this cycle
set 0b00001111
and r2, OUT         //OUT now contains lsb_out rrt(4) & 0b00001111
mov r2, OUT
set 0b00001111
and r2, OUT
orr OUT, r4         //orring with previous lout 
mov r4, OUT

//third lout expression
set 5
rot r1, OUT         //rotating msb_out by 5
mov r2, OUT         //still storing in r2 because we need r1 eventually for hout
set 0b11111000
and r2, OUT
mov r2, OUT
set 0b11110000
and r2, OUT
orr OUT, r4         
mov r4, OUT         //r4 now has final lout

# So quick recap
# r0 is your counter, do not touch
# r2 holds garbage data (previously lsb_out), will now hold hout
# r1 holds msb_out
# r3 holds garbage data (previously parity bits)
# r4 holds lout
# r5 is the tempoarary XOR register

 //Using r1 for hout
 mov r1, 0b00000000
 set 5
 rot r1, OUT
 mov r3, OUT
 set 0b00000111
 and r3, OUT
 mov r1, OUT        //r1 holds hout


str r1, r0 ; mem[i] = r1
set 1
add r0, OUT ; OUT = i + 1
str r4, OUT ; mem[i+1] = r4

mov r4, 32
mov r3, 1
add r0, r3
mov r0, OUT
set loop_start
bne r0, r4

// set loop_start remember to add the b back in
// eq r0, r0 ; unconditional branch back up

equalParity:
mov r0, r0
str r2, r0
mov r4, 1
add r0, r4
str r1, OUT

//Bne branch back up
mov r4, 32
mov r3, 1
add r0, r3
mov r0, OUT
set loop_start
bne r0, r4
// set loop_start remember to add the b back in
// eq r4, r4

p0exp_loop:
mov r0, r0
mov r4, 0b10000000
set 1
add r0, OUT
str r4, OUT

//BNE Loop back up
mov r4, 32
mov r3, 1
add r0, r3
mov r0, OUT
set loop_start
bne r0, r4
// set loop_start remember to add the b back in
// eq r4, r4 ; unconditional branch back up

