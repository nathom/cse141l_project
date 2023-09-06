Char pattern = mem[32];
Int count = 0, byte_count = 0;
For (int i = 0; i < 32; i++) {
	Char b = mem[i];
	
	// parts a and b
	//In ARM use “occurred” flag
	Int occurred = 0;
	If ((b & (1111_1000)) == pattern) {count++; occurred = 1}	// IF 1
	//If ((b & (0111_1100)) == (pattern >> 1)) {count++; occurred = 1}
    //If ((b & (0011_1110)) == (pattern >> 2)) {count++; occurred = 1}
    //If ((b & (0001_1111)) == (pattern >> 3)) {count++; occurred = 1}
    If (occurred){byte_count++;}	// IF 2

    // part c

    Int totalCount = 0;
    //pattern >>= 3;
    If (i != 31) {	// IF 3

    //If(((b & 0000_1111) << 1) | (mem[i + 1] >> 7) == pattern) {totalCount++;}
    If(((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001) == pattern){totalCount++;} IF4
    //If(((b & 0000_0111) << 2) | (mem[i + 1] >> 6) == pattern) {totalCount++;}
    If(((b & 0000_0111) << 2) | (mem[i + 1] rrt(6) & 0b00000011) == pattern){totalCount++;} IF5
    //If(((b & 0000_0011) << 3) | (mem[i + 1] >> 5) == pattern) {totalCount++;}
    If(((b & 0000_0011) << 3) | (mem[i + 1] rrt(5) & 0b00000111) == pattern){totalCount++;} IF6
    //If(((b & 0000_0001) << 4) | (mem[i + 1] >> 4) == pattern) {totalCount++;}
    If(((b & 0000_0001) << 4) | (mem[i + 1] rrt(4) & 0b00001111) == pattern){totalCount++;} IF7

    }
    totalCount += count;
}
Mem
