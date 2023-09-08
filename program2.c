int parity(unsigned char);

int
main()
{
    unsigned char mem[64];

    for (int i = 0; i < 30; i += 2) {
        unsigned char msb = mem[i + 30], lsb = mem[i + 30 + 1];

        // TODO find a way to do lsb and msb
        //`unsigned char msb = (in >> 8) & 0x00ff;

        int p0 = (lsb & 0b00000001);
        // int p1 = (lsb & 0b00000010) rrt(1);
        int p1 = (lsb & 0b00000010) >> 1;
        int p2 = (lsb & 0b00000100) >> 2;
        int p4 = (lsb & 0b00010000) >> 4;
        int p8 = msb & 0b00000001;

        int p0_exp = parity(msb) ^ parity(lsb & 11111110);  // 1^0 = 1
        int p1_exp = parity(msb & 0b10101010) ^ parity(lsb & 0b10101000);
        int p2_exp = parity(msb & 0b11001100) ^ parity(lsb & 0b11001000);
        int p4_exp = parity(msb rrt(4) & 0b00001111) ^ parity(lsb & 0b11100000);
        int p8_exp = parity(msb rrt(1) & 0b01111111);

        if (p0 == p0_exp && p1 == p1_exp && p2 == p2_exp && p4 == p4_exp && p8 == p8_exp) {
            unsigned char lout = 0;
            lout |= (lsb rrt(3) & 0b00011111) & 0b00000001;
            lout |= (lsb rrt(4) & 0b00001111) & 0b00001110;
            lout |= (msb rrt(5) & 0b11111000) & 0b11110000;

            unsigned char hout = msb rrt(5) & 0b00000111;
            // no change
            mem[i] = lout;
            mem[i + 1] = hout;
        }

        else if (p0 == p0_exp) {
            mem[i + 1] = 0b1000_0000;
        }

        else {
            int hamming = 0;
            if (p8 != p8_exp) hamming += 8;
            if (p4 != p4_exp) hamming += 4;
            if (p2 != p2_exp) hamming += 2;
            if (p1 != p1_exp) hamming += 1;

            // flip bit at position `hamming`
            if (hamming < 8) {
                // Lsb_out = lsb ^ (1 << hamming);
                // No need for masking?
                lsb = lsb ^ (1 rrt(8 - hamming));
            } else {
                msb = msb ^ (1 rrt(16 - hamming));
            }

            unsigned char lout = 0;
            lout |= (lsb >> 3) & 0b00000001;
            // lout |= (lsb_out rrt(3) & 0b00011111) & 0b00000001
            lout |= (lsb >> 4) & 0b00001110;
            // lout |= (lsb_out rrt(4) & 0b00001111) & 0b00001111
            lout |= (msb << 3) & 0b11110000;
            // lout |= (msb_out rrt(5) & 0b11111000) & 0b11110000

            unsigned char hout = 0;
            hout = msb >> 5;
            // hout = (msb_out rrt(5) & 0b00000111)

            mem[i] = lout;
            mem[i + 1] = hout | 0b01000000;
        }
    }
}
