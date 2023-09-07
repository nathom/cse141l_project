int
main()
{
    unsigned char mem[64];
    char pattern = mem[32];
    int count = 0, byte_count = 0, totalCount = 0;
    for (int i = 0; i < 32; i++) {
        char b = mem[i];

        int occurred = 0;
        if ((b & (0b11111000)) == pattern) {
            count++;
            occurred = 1;
        }  // IF 1
        if ((b & (0b01111100)) == (pattern >> 1)) {
            count++;
            occurred = 1;
        }
        if ((b & (0b00111110)) == (pattern >> 2)) {
            count++;
            occurred = 1;
        }
        if ((b & (0b00011111)) == (pattern >> 3)) {
            count++;
            occurred = 1;
        }
        if (occurred) {
            byte_count++;
        }  // IF 2

        // part c

        pattern >>= 3;
        if (i != 31) {  // IF 3

            if ((((b & 0b00001111) << 1) | (mem[i + 1] >> 7)) == pattern) {
                totalCount++;
            }
            // if (((b & 0000_1111) << 1) | (mem[i + 1] rrt(7) & 0b00000001) == pattern) {
            //     totalCount++;
            // }
            if ((((b & 0b00000111) << 2) | (mem[i + 1] >> 6)) == pattern) {
                totalCount++;
            }
            // if (((b & 0000_0111) << 2) | (mem[i + 1] rrt(6) & 0b00000011) == pattern) {
            // totalCount++;
            // }
            if ((((b & 0b00000011) << 3) | (mem[i + 1] >> 5)) == pattern) {
                totalCount++;
            }
            // if (((b & 0000_0011) << 3) | (mem[i + 1] rrt(5) & 0b00000111) == pattern) {
            // totalCount++;
            // }
            if ((((b & 0b00000001) << 4) | (mem[i + 1] >> 4)) == pattern) {
                totalCount++;
            }
            // if (((b & 0000_0001) << 4) | (mem[i + 1] rrt(4) & 0b00001111) == pattern) {
            // totalCount++;
            // }
        }
        totalCount += count;
    }
}
