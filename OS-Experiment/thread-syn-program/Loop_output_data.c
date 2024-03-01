#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

//定义线程1运行函数
void* th_f1(void *arg) //传入void*数值 a
{
	for(int i=1;i<=1000;i++){
		printf("A:%d\n",i);
		sleep(1);
	}
}

//定义线程2运行函数
void* th_f2(void *arg) //传入void*数值 r
{
	for(int i=1000;i>0;i--){
		printf("B:%d\n",i);
		sleep(1);
	}
}

int main()
{
	int err;//定义错误存储
   	pthread_t  tid1,tid2;//定义线程标识符

   	//创建tid1线程
   	if(err=pthread_create(&tid1,NULL,th_f1,NULL)){
		perror("pthread_create error");
	}


   	//创建tid2线程
   	if(err=pthread_create(&tid2,NULL,th_f2,NULL)){
		perror("pthread_create error");
	}
	pthread_join(tid1, NULL);
	pthread_join(tid2, NULL);
	return 0;
}


