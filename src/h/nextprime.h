// ─────────────────────────────────────────────────────────────────────────────
// SEAM · nextprime.h
//
// Foreign function for Faust: next_pr(n) returns the smallest prime
// strictly greater than n. Used as a foreign function (`np`) in
// seam.ffunctions.lib to stagger delay-line lengths in Schroeder-style
// reverbs and, more recently, to quantize acoustic loudspeaker delays
// to mutually incommensurate values across plugin instances.
//
// Semantics:
//   next_pr(n) = min { p prime : p > n }
//
//   next_pr(0) = 2
//   next_pr(1) = 2
//   next_pr(2) = 3
//   next_pr(3) = 5
//   next_pr(4) = 5
//   next_pr(5) = 7
//
// Implementation notes:
//   - is_prime is the primality test; it correctly rejects n < 2 and
//     all even n > 2.
//   - next_pr advances by 2 from the next odd number above n and
//     scans forward until a prime is found. Iterative (no recursion).
// ─────────────────────────────────────────────────────────────────────────────

#include <math.h>

int is_prime(int num);
int next_pr(int num);

int is_prime(int num) {
    if (num < 2)         return 0;   // 0, 1 and negatives are not prime
    if (num < 4)         return 1;   // 2, 3 are prime
    if ((num & 1) == 0)  return 0;   // even numbers > 2 are not prime
    int limit = (int)sqrt((double)num);
    for (int i = 3; i <= limit; i += 2) {
        if (num % i == 0) return 0;
    }
    return 1;
}

int next_pr(int num) {
    if (num < 2) return 2;
    int c = (num & 1) ? num + 2 : num + 1;
    while (!is_prime(c)) c += 2;
    return c;
}
