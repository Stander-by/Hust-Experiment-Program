#pragma once
#include <iostream>
#include <vector>
#include <map>
using namespace std;
const int Num = 8120;
const int Cnum = 99;
typedef struct Pnode {
	string card_p;
	string date_p;
	string time_p;
	int c_num;
	int state = 0;//1早上,2中午，3晚上
	int Can = 0;//消费记录的窗口数
	double last_money;
	double money_p;
	struct Pnode* next = NULL;
	struct Pnode* front = NULL;
}Pnode;
typedef struct Student {
	char stunum[11] = { '\0' };
	char stucard[8] = { '\0' };
	string stuname;
	string key = "8888";
	double money = 0;
	double sum = 0;
	int state = 0;
	int flag = 0;//被使用了变成1
	int flag_card = 0;
	Student* next = NULL;
	vector<Pnode> record;//记录失败的消费记录
	vector<Pnode> record2;//记录成功消费记录
}Student;
typedef struct Win {
	char place_num[3] = { '\0' };
	int consum_num;
	double remain_sum = 0;
	struct Pnode* next;
}Win;
struct Check {
	bool choice;
	int check_num;
};