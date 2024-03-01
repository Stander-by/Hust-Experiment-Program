#include<stdio.h>
#include<sys/wait.h>
#include<sys/types.h>
#include<unistd.h>
#include<stdlib.h>

int main(int argc,char *argv[])
{
    int     pid;
    char    *msg;
    int     k;
    int     exit_code;

    pid = fork();
    switch(pid){
        case 0:{
            printf("curpid = %d,parentpid = %d ,now_pid is %d\n",getpid(),getppid(),pid);
            msg = "children process is running";
            k = 1000;
            exit_code = 55;
            break;
        }
        case -1:{
            perror("process creat failed\n");
            exit(-1);
        }
        default:{
            printf("curpid is %d ,parentpid is %d ,now_pid is %d\n",getpid(),getppid(),pid);
            exit_code = 0;
            break;
        }
    }
    printf("------------------------%d\n",pid);
    if(pid == 0)
    {
        while(k-- > 0)
        {
            puts(msg);
            sleep(1);
        }
    }
    exit(exit_code);
}

