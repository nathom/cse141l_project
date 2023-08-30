r0 (index “i”), r1 (max loop 32), r2 (count), r3 (byte_count), r4 (Char b) , r5, parity, OUT
count(r0), b(r4), totalCount, and byte_count(r3) CANNOT be reassigned

// Initialize variables
Char mem[32]; 
Mov r0, 0 // int i = 0
Mov r1, 32
Mov r2, 0 // count = 0
Mov r3, 0 // byte_count = 0



// For loop 
Set loop_end
Beq r0, r1 //  Stop when r0(i) = r1(32)
Ldr r1, r0 // r1 = mem[i]
Mov r4, r1 // b = mem[i]
Mov r1, 1
Add r0, r1 // r1 can be used after assigning b (OUT = increment i by 1)

// parts a and b
// If ((b & (1111_1000)) == pattern) {count++; occurred = 1}
Mov r3, 0b1111_1000 // byte_count not needed for 1st If, can use r3
And r4, r3  // OUT = b & (1111_1000)

Set if1
Beq OUT, =mem // b & (1111_1000)) == pattern 
if1:
Add r2, 1 // count++
Mov r1, 1// r1 = occurred = 1 (Remember to return r1 to 32 for the for loop)

Set if2
Beq r1, 1 // If (occurred) byte_count++;
if2:
Add r3, 1 // byte_count++

// part c		
Mov r1, 0 // totalCount = 0
Set if3
Beq r0, 31    // if(i != 31) 



(TODO) // If(((b & 0000_1111) << 1)...)
Mov OUT, 1
Add r0, OUT // OUT = i + 1
Ldr r1, r0 // r1 = mem[OUT] = mem[i+1]
Rot r1, 7
Mov OUT, 0b00000001
And r1, OUT // Out = (mem[i + 1] rrt(7) & 0b00000001) = A
Mov rX, OUT // rX holds OUT for an OR

Mov r1, 0b00001111 
And r4, r1 // OUT = (b & 0000_1111)
Rot OUT, 7 // (b & 0000_1111) << 1)
Or OUT, rX


Beq rX, =mem // A == pattern


(TODO) // If(((b & 0000_0111) << 2)...)

Mov r1, 0b00000111 
And r4, r1 // OUT = (b & 0b00000111)
Rot OUT, 6 // OUT = (b & 0b00000111) << 2)

// mem[i + 1] rrt(7) & 0b00000001) == pattern



(TODO) // If(((b & 0000_0011) << 3)...)
Mov r1, 0000_0011
And r4, r1 // OUT = b & 0000_0011
Rot OUT, 5 // (b & 0000_0011) << 3



(TODO) // If(((b & 0000_0001) << 4)...)
Mov r1, 0000_0001
And r4, r1 // OUT = b & 0000_0001
Rot OUT, 4 // (b & 0000_0001) << 4)


if3:
Add X r2// totalCount += count


Mov r1, 1 // Return r1 to 32 for for loop
Loop_end:
