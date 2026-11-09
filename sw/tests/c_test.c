/* C-level test for the RV32I core: exercises function calls, recursion,
 * the stack, byte/word memory accesses, loops and libgcc soft multiply/divide
 * (RV32I has no M extension). Reports through `tohost` like isa_test.S.
 */
#include <stdint.h>

extern volatile uint32_t tohost;

static void report(uint32_t test_number, int ok)
{
    if (!ok) {
        tohost = (test_number << 1) | 1u;
        for (;;) {}
    }
}

static uint32_t fib(uint32_t n)                 /* iterative */
{
    uint32_t a = 0, b = 1;
    while (n--) { uint32_t t = a + b; a = b; b = t; }
    return a;
}

static uint32_t fact(uint32_t n)                /* recursive + soft multiply */
{
    return n <= 1 ? 1 : n * fact(n - 1);
}

static uint32_t crc32(const uint8_t *p, uint32_t len)
{
    uint32_t crc = 0xffffffffu;
    while (len--) {
        crc ^= *p++;
        for (int k = 0; k < 8; k++)
            crc = (crc >> 1) ^ (0xedb88320u & -(crc & 1u));
    }
    return ~crc;
}

static void bubble_sort(int32_t *v, int n)
{
    for (int i = 0; i < n - 1; i++)
        for (int j = 0; j < n - 1 - i; j++)
            if (v[j] > v[j + 1]) { int32_t t = v[j]; v[j] = v[j + 1]; v[j + 1] = t; }
}

static const uint8_t msg[9] = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
int32_t values[8] = {42, -7, 1000, 0, -1000, 13, 13, 5};

int main(void)
{
    report(1, fib(20) == 6765u);
    report(2, fact(10) == 3628800u);
    report(3, crc32(msg, 9) == 0xcbf43926u);      /* standard CRC-32 check value */
    report(4, (uint32_t)(1234567u / 89u) == 13871u && 1234567u % 89u == 48u);

    bubble_sort(values, 8);
    static const int32_t sorted[8] = {-1000, -7, 0, 5, 13, 13, 42, 1000};
    int ok = 1;
    for (int i = 0; i < 8; i++) ok &= values[i] == sorted[i];
    report(5, ok);

    tohost = 1;                                     /* all tests passed */
    for (;;) {}
}
