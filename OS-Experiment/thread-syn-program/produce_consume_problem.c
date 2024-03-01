#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <sys/syscall.h>
#include <semaphore.h>

int buffer[10];
int head = 0;
int rear = 0;
sem_t spa_sem;
sem_t pro_sem;
pthread_mutex_t mutex;

//produce 
void* produce(void* arg){
    while(1){
        int add =(int) arg;
        struct timespec ts;
        sem_wait(&spa_sem);
        pthread_mutex_lock(&mutex);//p
        clock_gettime(CLOCK_MONOTONIC, &ts);
        int data = ts.tv_nsec%1000+add;
        buffer[rear]=data;

        float sleepTime=0.001*(ts.tv_nsec%900)+0.1;
        printf("producer %d fill buffe [%d] with %d\n",syscall(SYS_gettid),rear,data);
        rear = (rear+1)%10;
        pthread_mutex_unlock(&mutex);//v
        sem_post(&pro_sem);
        sleep(sleepTime);

    }
}
//consume
void* consume(void){
    while(1){
        sem_wait(&pro_sem);
        struct timespec ts;
        clock_gettime(CLOCK_MONOTONIC,&ts);
        float sleepTime=0.001*(ts.tv_nsec%900)+0.1;
        pthread_mutex_lock(&mutex);
        printf("consumer %d get %d from buffer[%d]\n",syscall(SYS_gettid),buffer[head],data);
        head = (head+1)%10;
        pthread_mutex_unlock(&mutex);
        sem_post(&spa_sem);
        sleep(sleepTime);

    }
}

int main(){
    sem_init(&pro_sem,0,0);
    sem_init(&spa_sem,0,9);
    pthread_t idc1,idc2,idc3;
    pthread_t idp1,idp2;
    pthread_create(&idp1,NULL,(void*)produce,(void*)10000);
    pthread_create(&idp2,NULL,(void*)produce,(void*)20000);
    pthread_create(&idc1,NULL,(void*)consume,NULL);
    pthread_create(&idc2,NULL,(void*)consume,NULL);
    pthread_create(&idc3,NULL,(void*)consume,NULL);
    pthread_join(idc1,NULL);
    pthread_join(idc2,NULL);
    pthread_join(idc3,NULL);
    pthread_join(idp1,NULL);
    pthread_join(idp2,NULL);
    return 0;

}