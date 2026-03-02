#include <stdint.h>

const uint16_t increment = 7;
uint16_t var = 11;

uint16_t inc(uint16_t x)
{
    return x + increment;
}

uint16_t inc2(uint16_t x)
{
    return inc(x) + inc(x);
}


int main(void)
{
    int step = 2;
    int s = 0;
    uint8_t c = 0;

    while(1){
        var = inc2(s);
        s += step;
        c += 1;
    }

    return 0;
}

