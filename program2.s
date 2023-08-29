//TODO update to include LSB AND MSB
/*
r0 - counter
r1 - MSB
r2 - LSB
r3 - Parity
r5 - Immediate register for XOR

IMPORTANT NOTE - For r3, the format is going to be the XOR of p0 and the expected
 */
Mov r0, 30 // set r0 = 30
Mov r1, 62
Set loop_end // set addr to OUT
Beq r0, r1

// r1 for msb, r2 for lsb
Ldr r1, r0          // r1 = mem[i] replaces MSB
Mov r2, 1
Add r0, r2          // OUT = i + 1
Ldr r2, OUT         // r2 = mem[OUT] = mem[i+1] replaces LSb

//Format p8_p4_p2_p1_p0_000

//p0
Mov r4, 0b00000001
And r2, r4          //OUT = lsb & 0b00000001
Mov r4, OUT
Rot r4, 5
Orr OUT, r3         //Stores p0 bit in 4th bit position


//p1
Mov r4, 0b00000010
And r2, r4          //OUT = lsb & 0b00000010
Mov r4, OUT

//Is this ok? I'm rotating the output register to reassign OUT
//This is so that I don't have to move into r4 again
Rot OUT, 1
Mov r4, OUT         //r4 now holds (lsb & 0b00000010) rrt(1)

//This is irrelevant?
Mov OUT, 0b01111111 //Tempoarily storing output register with value
And r4, OUT         //Reassigns OUT to (lsb & 0b00000010) rrt(1) & 0b01111111
Rot OUT, 4          //Places in p1 bit position
Mov r4, OUT
Orr r4, r3          //Stores bit in parity register p3


//p2
Mov r4, 0b00000100
And r4, r2          
Rot OUT, 2          //(lsb & 0b00000100) rrt(2)
Mov r4, OUT         
Mov OUT, 0b00111111 
And r4, OUT         //(lsb & 0b00000100) rrt(2) & 0b00111111
Rot OUT, 3          //Places in p2 bit position
Orr OUT, r3         //Stores in r3


//p4
Mov r4, 0b00010000  
And r4, r2
Rot OUT, 4          
Mov r4, OUT
Mov OUT, 0b00001111
And OUT, r4         //(lsb & 0b00000100) rrt(2) & 0b00111111
Rot OUT, 2
Orr OUT, r3


//p8
Mov r4, 0b00000001
And r1, r4          //msb & 0b00000001
Rot OUT, 1
Orr OUT, r3         //stores in p8 bit position in p3

//Expected Parity Bits

//p0_exp
Mov r4, 0b11111110
And r4, r2          //lsb & 0b11110000
Xor OUT, r1         //msb ^ lsb & 11111110
Mov r4, par         //r4 holds p0_exp
Rot r4, 5           //r4 is now 0000_p0exp_000
Mov r4, OUT
Xor r4, r3          //If its the same then the equivalent bit in r3 should be 0
Mov r3, OUT

//TODO p1_exp
Mov r4, 0b10101010
And r4, r1          //msb & 0b10101010
Mov r4, OUT         //stores in r4
Mov OUT, 0b10101000 //temporarily storing in output register
And OUT, r2         //lsb & 0b10101000
XOR OUT, r4         //(msb & 0b10101010) ^ (lsb & 0b10101000)
Mov r4, par         //r4 now holds p1_exp
Rot r4, 4           //p1_exp in proper bit position
Mov r4, OUT
Xor r4, r3          //Xor just the p1 bit position
Mov r3, OUT

//TODO p2_exp
Mov r4, 0b11001100
And r4, r1          //msb & 0b11001100
Mov r4, OUT         //stores in r4
Mov OUT, 0b11001000 //temporarily storing in output register
And OUT, r2         //lsb & 0b11001000
XOR OUT, r4         //(msb & 0b11001100) ^ (lsb & 0b11001000)
Mov r4, par         //r4 now holds p2_exp
Rot r4, 3           //p2_exp in proper bit position
Mov r4, OUT
Xor r4, r3          //Xor just the p2 bit position
Mov r3, OUT


//TODO p4_exp
Mov r4, 0b00001111
Rot r1, 4
And OUT, r4         //msb rrt(4) & 0b00001111
Mov r4, OUT         //r4 now has ^^
Mov OUT, 0b10101000
And OUT, r2         //lsb & 0b10101000
Xor OUT, r4         //(lsb & 0b10101000) ^ (msb rrt(4) & 0b00001111)
Mov r4, par
Rot r4, 2
Mov r4, OUT
Xor r4, r3          //Xor just the p4 bit position
Mov r3, OUT

//TODO p8_exp
Mov r4, 0b01111111
Rot r1, 1
And r1, r4          //OUT = msb rrt(1) & 0b01111111
Mov r4, par         //r4 now holds p8
Rot r4, 1           //p8 in proper bit position
Mov r4, OUT
Xor r4, r3          //Xor just the p8 bit position
Mov r3, OUT

//Idk if its smart to set something to zero here but i'm going to do it anyways
//line 25
Mov r4, 0b00011111
Rot r2, 3
And OUT, r4          //lsb rrt(3) & 0b00011111
Mov r4, 0b00000001   
And r4, OUT          //(lsb rrt(3) & 0b00011111) & 0b00000001
//line 26
Mov r1, OUT          //Temporarily replacing MSB with AND result
Mov r4, 0b00001111
Rot r2, 4
And OUT, r4         //OUT = lsb rrt(4) & 0b00001111
Mov r4, 0b00001110
And r4, OUT         //(lsb rrt(4) & 0b00001111) & 0b00001110
Orr OUT, r1         //Or operation from line 25 operations
Mov r2, OUT         //Temporarily storing the new or operation in r2
Ldr r1, r0          // r1 = mem[i] returns MSB to original value
//line 27
Mov r4, 0b11111000
Rot r1, 5
And r1, r4          //msb rrt(5) & 0b11111000
Mov r4, 0b11110000
And OUT, r4
Orr OUT, r2         
Mov r2, OUT         //r2 now holds the final lout

//hout
Mov r4, 0b00000111
Rot r1, 5
And OUT, r4
Mov r1, OUT         //r1 now holds hout

//Registers we can touch r4, r5, OUT
Mov r4, 0b00000000

//TODO if --> Beq r4,r3 STARTS AT LINE 32
//Str r2, r0


Mov r1, 2
Add r0, r1 //  OUT = i + 2
Mov r0, OUT // set i = OUT
Loop_end: