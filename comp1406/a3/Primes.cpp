/*
    Student Name:     Michael Maxwell
    Student Number:   101006277
    References:       I did not use any reference material in developing this assignment.
*/

#include "Primes.h"

int log(int b, int n) {
    int i;
    for(i = 0; n != 0; ++i)
        n /= b;
    return i;
}

int* primeFactors(int n) {
    int* a = new int[log(2, n)];
    int i = 0;
    int z = 2;
    while(z * z <= n) {
        if(n % z == 0) {
            a[i++] = z;
            n /= z;
        } else
            ++z;
    }
    a[i] = n;
    a[++i] = 1;
    return a;
}

int** allPrimeFactors(int n) {
    int** a = new int*[n - 2];
    for(int i = 0; i + 2 <= n; ++i)
        a[i] = primeFactors(i + 2);
    return a;
}

std::string displayPrimeFactors(int** factorization, int length) {
    std::stringstream s;
    int digits = log(10, length);
    for(int i = 0; i < length; ++i) {
        int k = 0;
        s << std::setfill('0') << std::setw(digits) << i + 2 << " = " << factorization[i][k];
        while(factorization[i][++k] != 1)
            s << 'x' << factorization[i][k];
        s << '\n';
    }
    return s.str();
}
