#include <stdio.h>
#include <iostream>
#include <malloc.h>
#include <stack>
using namespace std;
typedef struct Pnode {
	float coef;//系数
	int expn;//指数
	struct Pnode* next;//指针
}Pnode, * Polyn;
//按照顺序升序创建链表
void CreatPolyn(Polyn& P, int m) {
	P = (Polyn)malloc(sizeof(Pnode));
	P->next = NULL;									
//创建一个指向NULL的Pnode
	Pnode* s, * pre, *q;
	int i;
	for (i = 0; i < m; i++) {
		cout << "输入第" << i + 1 << "项的系数和指数:";
		s = (Pnode*)malloc(sizeof(Pnode));			
//每一次都去创建一个新的结构体s
		cin >> s->coef >> s->expn;				   
//输入新的节点数据
		pre = P;									
		q = P->next;
		while (q&& q->expn < s->expn) {            
//这一步就实现了升序排序的功能
			pre = q;
			q = q->next;
		}
		pre->next = s;                             
		s->next = q;
//将s与p链接起来
	}
}
//返回链表是长度
int lengthPolyn(Pnode* p) {
	int length=0;
	Pnode* a;
	a = p->next;
	while (a) {
		if (a->coef != 0)length++;//直接排掉coef为0的项，方便后续的讨论
		a = a->next;
	}
	return length;
}
//按照升序去打印系数和指数
void PrintPolyn2(Polyn& p ) {
	Pnode* a;
	a = p->next;
	while (a) {
		if (a->coef != 0)
			cout << "," << a->coef << "," << a->expn;
		a = a->next;
	}
}
//利用栈实现将升序的多项式的系数倒序再打印
void PrintPolyn1(Polyn& p,int length) {
	Pnode* a;
	int k = 0;
	a = p->next;
	stack<float> coefstack;
	stack<int> expnstack;
	if (length == 0)cout << '0';
	else {
		while (a) {
			coefstack.push(a->coef);
			//利用堆栈push和pop，实现将指数升序多项式按照指数降序打印
			expnstack.push(a->expn);
			a = a->next;
		}
		//先开始判断第一项
		//第一项正数不带+，负数要带-
		while (k == 0) {
			//若前面几项coef一直为0，则一直执行到将所以0 pop出为止
			if (coefstack.top() == 0) {
				coefstack.pop();
				expnstack.pop();
			}
			//k实现一旦出现一个coef不为0的项，就跳出循环
			else {
				if (expnstack.top() == 0) {
					cout << coefstack.top();
					coefstack.pop();
					expnstack.pop();
					k++;
				}
				else if (expnstack.top() == 1) {
					//指数为1不显示1
					if (coefstack.top() == 1) cout << "x";
					//系数为1 or -1不显示1
					else if (coefstack.top() == -1)cout << "-x";
					else cout << coefstack.top() << "x";
					coefstack.pop();
					expnstack.pop();
					k++;
				}
				else {
					if (coefstack.top() == 1)cout << "x^" << expnstack.top();
					else if (coefstack.top() == -1)cout << "-x" << expnstack.top();
					else cout << coefstack.top() << "x^" << expnstack.top();
					coefstack.pop();
					expnstack.pop();
					k++;
				}

			}
		}
		//开始进行第一项后面项的打印
		//length是以及去掉coef为0的项的多项式的长度
		for (int i = k; i < length; i++) {
			if (coefstack.top() == 0) {
				coefstack.pop();
				expnstack.pop();
			}
			//和第一项的讨论情况相同
			//注意每一项前面符号的变化
			else {
				if (expnstack.top() == 0) {
					if (coefstack.top() > 0) {
						cout << '+' << coefstack.top();
					}
					else cout << coefstack.top();
					coefstack.pop();
					expnstack.pop();
				}
				else if (expnstack.top() == 1) {
					if (coefstack.top() > 0) {
						if (coefstack.top() != 1)cout << '+' << coefstack.top() << 'x';
						else cout << "+x";
					}
					else {
						if (coefstack.top() != -1)cout << coefstack.top() << 'x';
						else cout << "-x";
					}
					coefstack.pop();
					expnstack.pop();
				}
				else {
					if (coefstack.top() > 0) {
						if (coefstack.top() != 1)cout << '+' << coefstack.top() << "x^" << expnstack.top();
						else cout << "+x^" << expnstack.top();
					}
					else {
						if (coefstack.top() != -1)cout << coefstack.top() << "x^" << expnstack.top();
						else cout << "-x^" << expnstack.top();
					}
					coefstack.pop();
					expnstack.pop();
				}
			}
		}
		
	}
	cout << endl;
}
//对两个链表进行升序排列操作并最终将链表内容存入pa
void opPolyn(Pnode* pa, Pnode* pb, int flag) {
	Pnode* p1, * p2, * p3;
	p1 = pa->next;
	p2 = pb->next;
	p3 = pa;
	float sum = 0;
	//p2为空指针不执行任何操作
	if (p2==NULL);
	//p1是空，p2不空，分加法和减法两种情况讨论
	else if (p1 == NULL && p2 != NULL) {
		if (flag == 1)pa->next = p2;
		else {
			pa->next = p2;
			p3 = p2;
			while (p3) {
				p3->coef = -(p3->coef);
				p3 = p3->next;
			}
		}
	}
	//都不为空
	else {
		while (p3) {
			if (p1->expn == p2->expn) {
				if (flag == 1)sum = p1->coef + p2->coef;
				else if (flag == 0)sum = p1->coef - p2->coef;
				p1->coef = sum;
				p3->next = p1;
				p3 = p1;
				p1 = p1->next;
				p2 = p2->next;
			}

			else if (p1->expn > p2->expn) {
				if (flag == 1) p2->coef = p2->coef;
				else if (flag == 0) p2->coef = -(p2->coef);
				p3->next = p2;
				p3 = p2;
				p2 = p2->next;
			}

			else {
				p3->next = p1;
				p3 = p1;
				p1 = p1->next;
			}
			//直到任意一个指针为空后将另一个剩余的项链接进p1
			//判断条件为p3是否为空，所以用p3进行每一步的遍历
			p3->next = p1 ? p1 : p2;
			if (p1 == NULL || p2 == NULL) {
				if (flag == 0 && p3->next == p2) {
					p3 = p3->next;
					while (p3) {
						p3->coef = -(p3->coef);
						p3 = p3->next;
					}
				}
				else {
					while (p3)p3 = p3->next;
				}
			}
		}
	}

}
//选择加法(flag=1)或者减法(flag=0)
int choice() {
	char input;
	int flag=0;
	cout << "输入加法或者减法：";
	cin >> input;
	switch (input) {
	case '+':
		flag = 1;
		break;
	case '-':
		flag = 0;
		break;
	default:
		break;
	}
	return flag;
}
//主程序
int main() {
	Pnode* p1, * p2;
	int n1, n2, sign;
	cout << "输入第一个多项式的项数：";
	cin >> n1;
	CreatPolyn(p1, n1);
	cout << "输入第二个多项式的项数：";
	cin >> n2;
	CreatPolyn(p2, n2);
	sign = choice();
	opPolyn(p1, p2, sign);
	PrintPolyn1(p1, lengthPolyn(p1));
	cout <<"结果多项式的项数：" <<lengthPolyn(p1);
	PrintPolyn2(p1);

}
