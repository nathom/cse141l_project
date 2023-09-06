

mov r0, 0                
mov r1, 32
mov r2, 0                
mov r3, 0               


set loop_end
beq r0, r1               


mov r3, 0b11111000      
and r4, r3              

mov r5, 32
ldr r1, r5              
set if1
beq OUT, r1                           

if1:
mov r0, r0
set 1                   
add r2, OUT             
mov r2, OUT             
mov r1, 1               

set if2
mov r5, 1
beq r1, r5               

if2:
mov r0, r0
mov r5, 1
add r3, r5               
mov r3, OUT             
	
mov r1, 0               
set if3
mov r5, 31
beq r0, r5           


set 1
add r0, OUT             
ldr r1, r0              
set 7                   
rot r1, OUT             
set 0b00000001
and r1, OUT             
mov r1, OUT           

ldr r5, r0              
set 0b00001111
and r5, OUT             
mov r5, 7
rot OUT, r5           

orr OUT, r1             

mov r5, 32
ldr r1, r5
set if4
beq OUT, r1            

if4:
mov r0, r0
set 1                 
add r4, OUT            
mov r4, OUT             

set 1
add r0, OUT             
ldr r1, OUT           
set 6                 
rot r1, OUT                                  
set 0b00000011
and r1, OUT             
mov r1, OUT              

ldr r5, r0             
set 0b00000111
and r5, OUT             
mov r5, 6
rot OUT, r5           

orr OUT, r1

mov r5, 32
ldr r1, r5
set if5
beq OUT, r1             

if5:
mov r0, r0
set 1                  
add r4, OUT             
mov r4, OUT           

set 1
add r0, OUT             
ldr r1, OUT            
set 5                  
rot r1, OUT                                        
set 0b00000111
and r1, OUT             
mov r1, OUT             


ldr r5, r0
set  0b00000011
and r5, OUT            
mov r5, 5
rot OUT, r5             

orr OUT, r1

mov r5, 32
ldr r1, r5              
set if6
beq OUT, r1            

if6:
mov r0, r0
set 1                   
add r4, OUT             
mov r4, OUT             


set 1
add r0, OUT             
ldr r1, r0              
set 4                  
rot r1, OUT                                        
set 0b00001111
and r1, OUT             
mov r1, OUT             


ldr r5, r0
set 0b00000001
and r5, OUT             
mov r5, 4
rot OUT, r5             

orr OUT, r1

mov r5, 32
ldr r1, r5              
set if7
beq OUT, r1          


if7:
mov r0, r0
set 1                  
add r4, OUT             
mov r4, OUT             

if3:
mov r0, r0
add r4 r2                      
mov r4, OUT             


mov r1, 1
add r0, r1              
mov r0, OUT            
mov r1, 1               

loop_end:
mov r0, r0