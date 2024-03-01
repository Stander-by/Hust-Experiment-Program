#include<graphics.h>
#include<stdio.h>
#include<Windows.h>
#include<math.h>
#define pi  3.1415926535897932

//定义画方的线程  顺时针画
DWORD WINAPI drawSquare(LPVOID)
{
	//分为720个点 180*4   
	for (int i = 0; i < 180; i++)
	{	putpixel(50 + i, 50, RED);
		Sleep(100);
	}
	for (int i = 0; i < 180; i++)
	{	putpixel(50 + 180, 50 + i, RED);
		Sleep(100);
	}
	for (int i = 0; i < 180; i++)
	{	putpixel(50 + 180 - i, 50 + 180, RED);
		Sleep(100);
	}
	for (int i = 0; i < 180; i++)
	{	putpixel(50, 50 + 180 - i, RED);
		Sleep(100);
	}
	return 0;
}

//定义画圆的函数
DWORD WINAPI drawCircle(LPVOID)
{
	//同样分为720个点
	for (int i = 0; i < 720; i++)
	{
		putpixel(350 + 100 * cos(-pi / 2 + (double)((i * pi) / 360)), 140 + 100 * sin(-pi / 2 + (double)((i * pi) / 360)), GREEN);
		Sleep(100);
	}
	return 0;
}
int main()
{
	initgraph(640, 480);
	HANDLE hThread[2];//记录新线程句柄
	DWORD threadID;//记录线程ID
	if ((hThread[0] = CreateThread(NULL, 0, drawSquare, 0, 0, &threadID)) == NULL)
	{
		printf("线程创建失败!");
	}
	if ((hThread[1] = CreateThread(NULL, 0, drawCircle, 0, 0, &threadID)) == NULL)
	{
		printf("线程创建失败!");
	}
	WaitForMultipleObjects(2, hThread, TRUE, INFINITE);

	CloseHandle(hThread[0]);
	CloseHandle(hThread[1]);

	getchar();
	closegraph();
	return 0;
}