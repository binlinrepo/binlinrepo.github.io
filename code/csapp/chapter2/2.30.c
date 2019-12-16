#include <stdio.h>

/* Determine whether arguments can be added without overflow */
int tadd_ok(int x,int y);

int tadd_ok(int x,int y){
    int sum=x+y;
    return !(x>0&&y>0&&sum<0)&&!(x<=0&&y<=0&&sum>0);
}
