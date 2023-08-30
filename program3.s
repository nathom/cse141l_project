/*
r0 - holds index i
r1 -
r2 - holds variable “count”
r3 - holds variable byte_count
r4 - holds variable b
OUT - default output register
*/

// Initialize variables
; Char mem[32]; 
mov r0, 0 // int i = 0
mov r1, 32
mov r2, 0 // count = 0
mov r3, 0 // byte_count = 0

// For loop 
set Loop_end
beq r0, r1 //  Stop when r0(i) = r1(32)
ldr r1, r0 // r1 = mem[i]
mov r4, r1 // b = mem[i]
mov r1, 1
add r0, r1 // r1 can be used after assigning b (OUT = increment i by 1)

// parts a and b
// If ((b & (1111_1000)) == pattern) {count++; occurred = 1}
mov r3, 0b1111_1000 // byte_count not needed for 1st If, can use r3
and r4, r3  // OUT = b & (1111_1000)

set if1
beq OUT, =mem // b & (1111_1000) == pattern 
if1:
add r2, 1 // count++
mov r1, 1// r1 = occurred = 1 (Remember to return r1 to 32 for the for loop)

set if2
beq r1, 1 // If (occurred) byte_count++;
if2:
add r3, 1 // byte_count++

// part c		
mov r1, 0 // totalCount = 0
set if3
beq r0, 31    // if(i != 31) 



(TODO) // If(((b & 0000_1111) << 1)...)
set OUT, 1
add r0, OUT // OUT = i + 1
ldr r1, r0 // r1 = mem[OUT] = mem[i+1]
rot r1, 7
set OUT, 0b00000001
and r1, OUT // Out = (mem[i + 1] rrt(7) & 0b00000001) = A
mov rX, OUT // rX holds OUT for an OR

mov r1, 0b00001111 
and r4, r1 // OUT = (b & 0b00001111)
rot OUT, 7 // (b & 0b00001111) << 1)
or OUT, rX // OUT = OUT | rX

set if4
beq rX, =mem // A == pattern

if4:
add rX, rY// totalcount++

(TODO) // If(((b & 0000_0111) << 2)...)
set OUT, 1
add r0, OUT // OUT = i + 1
ldr r1, r0 // r1 = mem[OUT] = mem[i+1]
rot r1, 7
set OUT, 0b00000011
and r1, OUT // Out = (mem[i + 1] rrt(6) & 0b00000011) = A
mov rX, OUT // rX holds OUT for an OR 

mov r1, 0b00000111 
and r4, r1 // OUT = (b & 0b00000111)
rot OUT, 6 // OUT = (b & 0b00000111) << 2)
or OUT, rX // OUT = (OUT | rX)

set if5
beq rX, =mem // A == pattern

if5:
add rX, rY// totalcount++

set if6
beq rX, =mem // A == pattern

if6:
add rX, rY// totalcount++

(TODO) // If(((b & 0000_0011) << 3)...)
set OUT, 1
add r0, OUT // OUT = i + 1
ldr r1, r0 // r1 = mem[OUT] = mem[i+1]
rot r1, 7
set OUT, 0b00000111
and r1, OUT // Out = (mem[i + 1] rrt(5) & 0b00000111) = A
mov rX, OUT // rX holds OUT for an OR

mov r1, 0b00000011
and r4, r1 // OUT = b & 0b00000011
rot OUT, 5 // (b & 0b00000011) << 3

set if6
beq rX, =mem // A == pattern

if6:
add rX, rY// totalcount++

(TODO) // If(((b & 0000_0001) << 4)...)
mov OUT, 1
add r0, OUT // OUT = i + 1
ldr r1, r0 // r1 = mem[OUT] = mem[i+1]
rot r1, 7
set OUT, 0b00001111
and r1, OUT // Out = (mem[i + 1] rrt(4) & 0b00001111) = A
mov rX, OUT // rX holds OUT for an OR

mov r1, 0000_0001
and r4, r1 // OUT = b & 0000_0001
rot OUT, 4 // OUT = (b & 0000_0001) << 4

set if7
beq rX, =mem // A == pattern

if7:
add rX, rY// totalcount++

if3:
add rX r2// totalCount += count


mov r1, 1 // Return r1 to 32 for for loop
loop_end:
