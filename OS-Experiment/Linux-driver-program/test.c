#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

#define DEV_NAME "/dev/code2"

int main()
{
	char buffer[64];
	int fd,a,b;

	fd = open(DEV_NAME, O_RDWR | O_CREAT);
	if (fd < 0) {
		printf("open device %s failded\n", DEV_NAME);
		return -1;
	}
    printf("请输入两个整数：");
    scanf("%d%d",&a,&b);
    sprintf(buffer,"%d %d",a,b);
    write(fd,buffer,64);
	read(fd, buffer, 64);
	close(fd);
	
	return 0;
}

