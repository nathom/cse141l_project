
// r0 - holds index i
// r1 - general use
// r2 - holds variable “count”
// r3 - holds variable byte_count
// r4 - holds variable totalCount
// OUT - default output register

// Initialize variables
mov r0, 0                // int i = 0
mov r1, 32
mov r2, 0                // count = 0
mov r3, 0                // byte_count = 0

// For loop 
set loop_end
beq r0, r1               //  Stop when r0(i) = r1(32)

// parts a and b
// If ((b & (1111_1000)) == pattern) {count++; occurred = 1}
mov r3, 0b11111000      // byte_count not needed for 1st If, can use r3
and r4, r3              // OUT = b & (1111_1000)

mov r5, 32
ldr r1, r5              // r1 = pattern = mem[32]
set if1
beq OUT, r1             // b & (1111_1000) == pattern               

if1:
mov r0, r0
set 1                   // OUT = 1
add r2, OUT             // OUT = r2 + 1
mov r2, OUT             // count++
mov r1, 1               // r1 = occurred = 1 (Remember to return r1 to 32 for the for loop)

set if2
beq r1, 1               // If (occurred) byte_count++

if2:
mov r0, r0
add r3, 1               // OUT = r3 + 1
mov r3, OUT             // byte_count++

// part c		
mov r1, 0               // totalCount = 0
set if3
beq r0, 31              // if(i != 31), branch when i = 31

// If(((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001) == pattern)
set 1
add r0, OUT             // OUT = i + 1
ldr r1, r0              // r1 = mem[OUT] = mem[i+1]
set 7                   // OUT = 7
rot r1, OUT             // mem[i + 1] rrt(7)
set 0b00000001
and r1, OUT             // OUT = C = (mem[i + 1] rrt(7) & 0b00000001) 
mov r1, OUT             // (mem[i + 1] rrt(7) & 0b00000001)

// (b & 0000_1111) << 1
ldr r5, r0              // b = mem[i]
set 0b00001111
and r5, OUT             // OUT = b & 0b00001111
mov r5, 7
rot OUT, r5             // OUT = (b & 0000_1111) << 1

or OUT, r1              // OUT = (((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001)

mov r5, 32
ldr r1, r5
set if4
beq OUT, r1             // ((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001) == pattern)

if4:
mov r0, r0
set 1                   // OUT = 1
add r4, OUT             // OUT = r4 + 1
mov r4, OUT             // r4 = r4 + 1 = totalCount++

// Fourth if statement
// (mem[i + 1] rrt(7) & 0b00000001)
set 1
add r0, OUT             // OUT = i + 1
ldr r1, OUT             // r1 = mem[OUT] = mem[i+1]
set 6                   // OUT = 6
rot r1, OUT                                  
set 0b00000011
and r1, OUT             // OUT = C = (mem[i + 1] rrt(6) & 0b00000011)
mov r1, OUT             // r1 holds OUT for later OR 

// ((b & 0000_0111) << 2)
ldr r5, r0              // b = mem[i]
set 0b00000111
and r5, OUT             // OUT = b & 0b00000111
mov r5, 6
rot OUT, r5             // OUT = ((b & 0000_0111) << 2)

// ((b & 0000_0111) << 2) | (mem[i + 1] rrt(6) & 0b00000011)
or OUT, r1

mov r5, 32
ldr r1, r5
set if5
beq OUT, r1             // (((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001) == pattern)

// Increment totalCount
if5:
mov r0, r0
set 1                   // OUT = 1
add r4, OUT             // OUT = r4 + 1
mov r4, OUT             // r4 = r4 + 1 = totalCount++

// Fifth if statement
// (mem[i + 1] rrt(5) & 0b00000111)
set 1
add r0, OUT             // OUT = i + 1
ldr r1, OUT             // r1 = mem[OUT] = mem[i+1]
set 5                   // OUT = 5
rot r1, OUT                                        
set 0b00000111
and r1, OUT             // OUT = C = (mem[i + 1] rrt(5) & 0b00000111) 
mov r1, OUT             // r1 = mem[i + 1] rrt(5) & 0b00000111

// ((b & 0000_0011) << 3)
ldr r5, r0
set  0b00000011
and r5, OUT             // OUT = (b & 0000_0011)
mov r5, 5
rot OUT, r5             // OUT = (b & 0b00000011) << 3

//((b & 0000_0011) << 3) | (mem[i + 1] rrt(5) & 0b00000111)
or OUT, r1

mov r5, 32
ldr r1, r5              // r1 = pattern = mem[32]
set if6
beq OUT, r1             // (((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001) == pattern)

// Increment totalCount
if6:
mov r0, r0
set 1                   // OUT = 1
add r4, OUT             // OUT = r4 + 1
mov r4, OUT             // r4 = r4 + 1 = totalCount++

// Sixth if statement
// (mem[i + 1] rrt(4) & 0b00001111)
set 1
add r0, OUT             // OUT = i + 1
ldr r1, r0              // r1 = mem[OUT] = mem[i+1]
set 4                   // OUT = 4
rot r1, OUT                                        
set 0b00001111
and r1, OUT             // OUT = C = (mem[i + 1] rrt(4) & 0b00001111)
mov r1, OUT             // r1 = mem[i + 1] rrt(4) & 0b00001111

// (b & 0000_0001) << 4
ldr r5, r0
set 0b00000001
and r5, OUT             // OUT = b & 0000_0001
mov r5, 4
rot OUT, r5             // (b & 0000_0001) << 4

// ((b & 0000_0001) << 4) | (mem[i + 1] rrt(4) & 0b00001111)
or OUT, r1

mov r5, 32
ldr r1, r5              // r1 = pattern = mem[32]
set if7
beq OUT, r1             // (((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001) == pattern)

// Increment totalCount
if7:
mov r0, r0
set 1                   // OUT = 1
add r4, OUT             // OUT = r4 + 1
mov r4, OUT             // r4 = r4 + 1 = totalCount++

if3:
mov r0, r0
add r4 r2               // OUT = totalCount + count           
mov r4, OUT             // totalCount = totalCount + count

// increment r0 by 1 for next loop
mov r1, 1
add r0, r1              // r1 can be used after assigning b (OUT = increment i by 1)
mov r0, OUT             // i is incremented for next loop (r0 = i + 1)
mov r1, 1               // Return r1 to 32 for for loop

loop_end:
mov r0, r0