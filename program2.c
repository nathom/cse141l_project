For (int i = 0; i < 32; i += 2) {

    char *b = mem + i;
    char msw = mem[i+30], lsw = mem[i+30+1];


	//TODO find a way to do lsb and msb
    //`unsigned char msb = (in >> 8) & 0x00ff;
    unsigned char lsb = in & 0x00ff;

    int p0 = (lsb & 0b00000001);
	int p1 = (lsb & 0b00000010) rrt(1) & 0b01111111
	int p2 = (lsb & 0b00000100) rrt(2) & 0b00111111
	int p4 = (lsb & 0b00010000) rrt(4) & 0b00001111
    int p8 = msb & 0b00000001;


    int p0_exp = parity(msb) ^ parity(lsb & 11111110);
    int p1_exp = parity(msb & 0b10101010) ^ parity(lsb & 0b10101000);
    int p2_exp = parity(msb & 0b11001100) ^ parity(lsb & 0b11001000);
	int p4_exp = parity(msb rrt(4) & 0b00001111) ^ parity(lsb & 0b11100000);
	int p8_exp = parity(msb rrt(1) & 0b01111111)

    unsigned char lout = 0;
    lout |= (lsb rrt(3) & 0b00011111) & 0b00000001;
    lout |= (lsb rrt(4) & 0b00001111) & 0b00001110;
    lout |= (msb rrt(5) & 0b11111000) & 0b11110000;
	
	unsigned char hout = 0;
    hout = msb rrt(5) & 0b00000111

    if (p0 == p0_exp && p1 == p1_exp && p2 == p2_exp && p4 == p4_exp && p8 == p8_exp) {
            // no change
		mem[i] = lout;
		mem[i+1] = hout;

    } 
	
	else if (p0 == p0_exp) {
    mem[i+1] = 0b1000_0000;
    } 

	else {
	Int hamming = 0;
	If (p8 != p8_exp) hamming += 8;
	If (p4 != p4_exp) hamming += 4;
    If (p2 != p2_exp) hamming += 2;
	If (p1 != p1_exp) hamming += 1;
	
	// flip bit at position `hamming`
	If (hamming < 8) {
		//Lsb_out = lsb ^ (1 << hamming);
		//No need for masking?
		lsb_out = lsb ^ (1 rrt(8 - hamming));
	} else {
		lsb_out = msb ^ (1 rrt(hamming - 16));
	}

	unsigned char lout = 0;
	lout |= (lsb_out rrt(3) & 0b00011111) & 0b00000001
	lout |= (lsb_out rrt(4) & 0b00001111) & 0b00001111
    lout |= (msb_out rrt(5) & 0b11111000) & 0b11110000

	unsigned char hout = 0;
	hout = (msb_out rrt(5) & 0b00000111)


	mem[i] = lout;
	mem[i+1] = hout | 0b0100_0000;
}
}
