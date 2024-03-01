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
            printf("curpid = %d,parentpid = %d,now_pid(child) = %d\n",getpid(),getppid(),pid);
            msg = "children process is running";
            k = 5;
            exit_code = 55;
            break;
        }
        case -1:{
            perror("process creat failed\n");
            exit(-1);
        }
        default:{
            printf("curpid = %d ,parentpid =  %d, now_pid(child) = %d\n",getpid(),getppid(),pid);
            exit_code = 0;
            break;
        }
    }
    printf("------------------------%d\n",pid);
    if(pid != 0)
    {
        int   stat_val;                         // 值为0
        int   child_pid;

        child_pid = wait(&stat_val);     //wait函数的返回值是终止运行的子进程的pid, 遇到wait函数之后开始执行子进程.
        printf("child process has exited,pid = %d\n",child_pid);
        if(WIFEXITED(stat_val)){
            printf("child exited with code %d\n",WEXITSTATUS(stat_val));
        }
        else {
            printf("child exited abnormally\n");
        }
    }
    //让子进程暂停5秒
    else 
    {
        while(k-- > 0)
        {
            puts(msg);
            sleep(1);
        }
    }
    exit(exit_code);
}

