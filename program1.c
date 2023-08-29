For (int i = 0; i < 30; i += 2) {

	char *b = mem + i;
	Char msb = mem[i], lsb = mem[i+1];
	
        int p8 = parity(msb) ^ parity(lsb & 0b11110000);
    	int p4 = parity(msb) ^ parity(lsb & 0b10001110);
    	int p2 = parity((msb & 0b00000110) ^ (lsb & 0b01101101))
    	int p1 = parity((msb & 0b00000101) ^ (lsb & 0b01011011));
    	int p0 = parity(msb ^ lsb ^ p8 ^ p4 ^ p2 ^ p1);
	//char out_msw = (msb << 5) | ((lsb >> 3) & 0b11111110) | p8;
    //char out_lsw =(lsb << 4) & (11100000) | (p4 << 4) | ((lsb & 00000001) << 3) | (p2 << //2)|    (p1 << 1) | p0;

	Mem[i+30] = out_lsw;
	Mem[i+31] = out_msw;
}
