#include <unistd.h>
#include <sys/syscall.h>
#include <stdio.h>
int main(int argc, char *argv[])
{
    long ret;
    ret = syscall(498,12,18);     //Add, ret = 30
    printf("ret:%ld\n",ret);
    ret = syscall(499,7,8,9);      //Max, ret =8
    printf("ret:%ld\n",ret);
}

