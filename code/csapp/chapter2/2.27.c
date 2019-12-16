#include <stdio.h>

/* Determine whether arguments can be added without overflow */
int uadd_ok(unsigned x, unsigned y);

int uadd_ok(unsigned x, unsigned y){
    unsigned s = x + y;
    return s>x&&s>y;
}

int main(){
    unsigned x = 1024;
    unsigned y =1024;
    
    printf("%d\n",uadd_ok(x,y));
    return 0;
}
