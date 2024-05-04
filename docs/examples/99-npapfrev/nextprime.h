#include <stdio.h>
#include <math.h>

int is_prime(int num);
int next_pr(int num);

int next_pr(int num){
    int c;
    if(num < 2)
        c = 2;
    else if (num == 2)
        c = 3;
    else if(num & 1){
        num += 2;
        c = is_prime(num) ? num : next_pr(num);
    } else
        c = next_pr(num-1);

    return c;
}

int is_prime(int num){
    if((num & 1)==0)
        return num == 2;
    else {
        int i, limit = sqrt(num);
        for (i = 3; i <= limit; i+=2){
            if (num % i == 0)
                return 0;
        }
    }
    return 1;
}
