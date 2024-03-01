#include<iostream>
#include<time.h>
#include<stdlib.h>

#define commandnumber 640  //最大页面个数
#define MAXRAM 32 //最大能拥有的页框数
int command[commandnumber];
int op;			//选择访问方式
char page[commandnumber];//模拟页面，如A,B,C...
char RAM[MAXRAM];	//模拟页框
using namespace std;
int FIFO(char page[], int pageNum, int use)
{
	for (int i = 0; i < use; i++)
	{
		RAM[i] = NULL;
	}

	int count = 0;
	int location = 0;
	for (int i = 0; i < pageNum; i++)
	{
		bool flag = true;
		for (int j = 0; j < use; j++)
		{
			if (RAM[j] == page[i])
			{
				flag = false;
				break;
			}
		}

		if (flag == true)
		{
			count++;
			RAM[location] = page[i];
			location = (location + 1) % use;
		}
	}
	return count;
}

int LRU(char page[], int pageNum, int use)
{
	for (int i = 0; i < use; i++)
	{
		RAM[i] = NULL;
	}

	int lasttime[MAXRAM] = { 0 };
	int count = 0;
	for (int i = 0; i < pageNum; i++)
	{
		for (int t = 0; t < use; t++)
		{
			lasttime[t]++;
		}

		bool flag = true;
		for (int j = 0; j < use; j++)
		{
			if (RAM[j] == page[i])
			{
				flag = false;
				lasttime[j] = 0;
				break;
			}
		}

		if (flag == true)
		{
			count++;
			int x = 0;
			int distance = 0;
			for (int j = 0; j < use; j++)
			{
				if (RAM[j] == NULL)
				{
					x = j;
					break;
				}

				if (lasttime[j] > distance)
				{
					distance = lasttime[j];
					x = j;
				}
			}
			RAM[x] = page[i];
		}
	}
	return count;
}

void initialize(int op)
{
	//随机
	if (op == 1) {
		for (int i = 0; i < commandnumber; i++)
		{
			command[i] = rand() % 260;
			page[i] = command[i] / 10 + 'A';
		}
	}
	//顺序
	if (op == 2) {
		for (int i = 0; i < commandnumber; i++)
		{
			command[i] = i % 26;
			page[i] = command[i]  + 'A';
		}
	}
	//循环
	if (op == 3) {
		for (int i = 0; i < 8; i++) {
			command[i] = rand() % 260;
			for (int j = 0; j < commandnumber / 8; j++) {
				page[i + j * 8] = command[i] / 10 + 'A';
			}
		}
	}
}

int main()
{
	while (1) {
		srand((unsigned)time(NULL));
		int num_of_box = 7;
		printf("选择访问模式:(1.随机,2.顺序,3,循环,0.退出) ");
		cin >> op;
		cin.get();
		if (op == 0)break;
		printf("\t\t\t     FIFO\t\t\t     LRU\n");
		printf("分配页框数   |   平均缺页次数\t平均缺页率   |   平均缺页次数\t平均缺页率\n");
		for (; num_of_box <= MAXRAM; num_of_box++)
		{
			float sum[3] = { 0 };
			float loss_rate[3] = { 0 };
			for (int i = 0; i < 6; i++)
			{
				initialize(op);
				sum[1] += FIFO(page, commandnumber, num_of_box);
				sum[2] += LRU(page, commandnumber, num_of_box);
			}
			sum[1] /= 6;
			loss_rate[1] = (float)(100 * ((float)sum[1] / (float)commandnumber));
			sum[2] /= 6;
			loss_rate[2] = (float)(100 * ((float)sum[2] / (float)commandnumber));
			if (loss_rate[1] == 100) {
				printf("    %d\t     |\t   %.2f\t %.2f%%     |\t   %.2f\t %.2f%%\t     |\t\n",
					num_of_box, sum[1], loss_rate[1], sum[2], loss_rate[2]);
			}
			else if (sum[1] < 10 && sum[2] < 10) {
				printf("    %d\t     |\t   %.2f\t\t %.2f%%\t     |\t   %.2f\t\t %.2f%%\t     |\t\n",
					num_of_box, sum[1], loss_rate[1], sum[2], loss_rate[2]);
			}
			else {
				printf("    %d\t     |\t   %.2f\t %.2f%%\t     |\t   %.2f\t %.2f%%\t     |\t\n",
					num_of_box, sum[1], loss_rate[1], sum[2], loss_rate[2]);
			}
		}
	}
}
