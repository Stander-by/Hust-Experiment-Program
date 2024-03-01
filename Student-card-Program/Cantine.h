#pragma once
#include "struct.cpp"
#include "function.h"
using namespace std;
class Cantine {
public:
	Win can_win[Cnum];
	int unit = 0;
	Cantine();
	void read_comsume();
	void read_comsume2();
	void consume(Student** stu);
	void input_info();
};
Cantine::Cantine() {
	cout << "窗口初始化" << endl;
	string str;
	char c[6] = { '\0' };
	int count = 0;
	char ch = '0';
	ifstream ift("in//wz003.txt");
	getline(ift, str);
	while (ch != '.') {
		for (int i = 0; i < 2; i++) {
			ift.get(ch);
			can_win[count].place_num[i] = ch;
		}
		ift.get();
		ift.get(ch);
		string str1;
		for (int j = 0; ch != ';'; j++) {
			str1 += ch;
			ift.get(ch);
		}
		strcpy_s(c, str1.c_str());
		can_win[count].consum_num = atoi(c);
		ift.get(ch);
		//cout << can_win[count].place_num << ',' << can_win[count].consum_num << endl;
		count++;

	}
	cout << "窗口初始化完毕" << endl;


}
//把消费记录与每个窗口相链接
void Cantine::read_comsume2() {
	ifstream xf("in//xf014.txt");
	string str, place;
	char sig[3] = { '\0' };
	char ch = '0';
	getline(xf, str);
	xf.get(ch);
	while (ch == 'W' && unit <= Cnum - 1) {
		xf.getline(sig, 3);
		//cout << sig << endl;
		xf.get(ch);
		Pnode* ss = new Pnode;
		can_win[unit++].next = ss;
		int i = 0;
		while (ch == '3') {
			i++;
			if (i <= 60000) {
				Pnode* pp = new Pnode;
				while (ch != ',') {
					pp->card_p += ch;
					xf.get(ch);
				}
				xf.get(ch);
				while (ch != ',') {
					pp->date_p += ch;
					xf.get(ch);
				}
				xf.get(ch);
				while (ch != ',') {
					pp->time_p += ch;
					xf.get(ch);
				}
				if (atoi(pp->time_p.c_str()) > 7000000 && atoi(pp->time_p.c_str()) < 9000000)pp->state = 1;
				else if (atoi(pp->time_p.c_str()) > 11000000 && atoi(pp->time_p.c_str()) < 13000000)pp->state = 2;
				else if (atoi(pp->time_p.c_str()) > 17000000 && atoi(pp->time_p.c_str()) < 19000000)pp->state = 3;
				xf.get(ch);
				string dol;
				while (ch != ';') {
					dol += ch;
					xf.get(ch);
				}
				pp->money_p = atof(dol.c_str());

				pp->next = NULL;
				//cout << pp->card_p << ',' << pp->date_p << ',' << pp->time_p << ',' << pp->money_p << ';' << endl;
				ss->next = pp;
				ss = pp;
				xf.get(ch);//读取换行符
				xf.get(ch);
			}
			else if (i == 60000) break;
			

		}
		ss->next = can_win[unit - 1].next->next;
		ss = ss->next;
		while (ch == '3') {
			while (ch != ',') {
				ss->card_p += ch;
				xf.get(ch);
			}
			xf.get(ch);
			while (ch != ',') {
				ss->date_p += ch;
				xf.get(ch);
			}
			xf.get(ch);
			while (ch != ',') {
				ss->time_p += ch;
				xf.get(ch);
			}
			if (atoi(ss->time_p.c_str()) > 7000000 && atoi(ss->time_p.c_str()) < 9000000)ss->state = 1;
			else if (atoi(ss->time_p.c_str()) > 11000000 && atoi(ss->time_p.c_str()) < 13000000)ss->state = 2;
			else if (atoi(ss->time_p.c_str()) > 17000000 && atoi(ss->time_p.c_str()) < 19000000)ss->state = 3;
			xf.get(ch);
			string dol;
			while (ch != ';') {
				dol += ch;
				xf.get(ch);
			}
			ss->money_p = atof(dol.c_str());

			ss = ss->next;
			xf.get(ch);//读取换行符
			xf.get(ch);
		}
	}


}
void Cantine::read_comsume() {
	ifstream xf("in//xf014.txt");
	string str, place;
	char sig[3] = { '\0' };
	char ch = '0';
	getline(xf, str);
	xf.get(ch);
	while (ch == 'W' && unit <= Cnum - 1) {
		xf.getline(sig, 3);
		//cout << sig << endl;
		xf.get(ch);
		Pnode* ss = new Pnode;
		can_win[unit++].next = ss;
		while (ch == '3') {
			Pnode* pp = new Pnode;
			//can_win[unit - 1].consum_num++;
			while (ch != ',') {
				pp->card_p += ch;
				xf.get(ch);
			}
			xf.get(ch);
			while (ch != ',') {
				pp->date_p += ch;
				xf.get(ch);
			}
			xf.get(ch);
			while (ch != ',') {
				pp->time_p += ch;
				xf.get(ch);
			}
			if (atoi(pp->time_p.c_str()) > 7000000 && atoi(pp->time_p.c_str()) < 9000000)pp->state = 1;
			else if (atoi(pp->time_p.c_str()) > 11000000 && atoi(pp->time_p.c_str()) < 13000000)pp->state = 2;
			else if (atoi(pp->time_p.c_str()) > 17000000 && atoi(pp->time_p.c_str()) < 19000000)pp->state = 3;
			xf.get(ch);
			string dol;
			while (ch != ';') {
				dol += ch;
				xf.get(ch);
			}
			pp->money_p = atof(dol.c_str());
			pp->Can = unit - 1;
			int dt = atoi((pp->date_p + pp->time_p).c_str());
			int stu = atoi(pp->card_p.c_str());
			pp->c_num = (dt % 9973 + stu % 9973 + (int)pp->money_p * 997 + unit) % 10000;///校验码
			pp->next = NULL;
			//cout << pp->card_p << ',' << pp->date_p << ',' << pp->time_p << ',' << pp->money_p << ';' << pp->Can <<endl;
			ss->next = pp;
			ss = pp;
			xf.get(ch);//读取换行符
			xf.get(ch);
		}
	}
	

}
//写入消费记录
void Cantine::input_info() {
	ofstream xout("out//consume.txt");
	xout << "XF" << endl;
	for (int i = 0; i < Cnum; i++) {
		Pnode* tt = new Pnode;
		tt = can_win[i].next->next;
		xout << "W" << i + 1 << endl;
		while (tt->next != NULL) {
			xout << tt->card_p << ',' << tt->date_p << ',' << tt->time_p << ',' << tt->money_p << ';' << endl;
			tt = tt->next;
		}
	}
}
//单独操作，进行消费并将每一次消费的记录链接再每一个窗口结构后面
void Cantine::consume(Student** stu) {
	cout << "====================欢迎进入食堂消费系统！！！====================" << endl;
	int win = 0;
	string card_input, date_input, time_input, key_input;
	double doll_input;
	while (1) {
		cout << "请选择窗口(0退出):";
		cin >> win;
		if (win == 0)break;
		Pnode* s = new Pnode;
		can_win[win - 1].next = s;
		while (1) {
			cout << "读取您的卡号(输入q退出):";
			cin >> card_input;
			cin.get();
			if (card_input == "q")break;
			Check che = Check_card(stu, card_input);
			if (che.choice) {
				Pnode* p = new Pnode;
				cout << stu[che.check_num]->stunum << "您好！" << endl;
				cout << "输入消费金额:";
				cin >> doll_input;
				cin.get();
				cout << "输入消费日期:";
				cin >> date_input;
				cin.get();
				cout << "输入消费时间:";
				cin >> time_input;
				cin.get();
				int t = atoi(time_input.c_str());
				if (stu[che.check_num]->money >= doll_input) {
					Pnode kk;
					if (t > 7000000 && t < 9000000)kk.state = 1;
					else if (t > 11000000 && t < 13000000)kk.state = 2;
					else if (t > 17000000 && t < 19000000)kk.state = 3;
					kk.card_p = card_input;
					kk.date_p = date_input;
					kk.time_p = time_input;
					kk.money_p = doll_input;
					kk.next = NULL;
					p->card_p = card_input;
					p->date_p = date_input;
					p->time_p = time_input;
					p->money_p = doll_input;
					p->state = kk.state;
					p->next = NULL;
					stu[che.check_num]->record.push_back(kk);
					vector<Pnode>::iterator iter = stu[che.check_num]->record.end();
					if (stu[che.check_num]->record.size() == 1) {
						iter--;
					}
					else {
						iter--;
						iter--;
					}
					if (iter->state!=kk.state&&iter->date_p == kk.date_p) {
						stu[che.check_num]->sum = 0;
					}
					stu[che.check_num]->sum += kk.money_p;
					stu[che.check_num]->money -= kk.money_p;
					if (stu[che.check_num]->sum > 20) {
						while (1) {
							cout << "请输入密码:";
							cout << key_input << endl;
							cin >> key_input;
							if (key_input == stu[che.check_num]->key)break;
							else {
								cout << "密码错误！请重新输入！" << endl;
							}
						}
						stu[che.check_num]->sum = 0;
					}
					cout << stu[che.check_num]->stuname << "消费成功" << endl;
					cout << "date:" << date_input << "   " << "time:" << time_input << endl;
					cout << stu[che.check_num]->stuname << stu[che.check_num]->stunum << "消费了" << p->money_p << endl;
					cout << stu[che.check_num]->stucard << "余额:" << stu[che.check_num]->money << endl;
					can_win[win - 1].consum_num++;
					can_win[win - 1].remain_sum += doll_input;
					cout << win << "号窗口消费总额是" << can_win[win - 1].remain_sum << "消费总数是" << can_win[win - 1].consum_num << endl;
				}
				else {
					cout << stu[che.check_num]->stuname << "消费失败" << endl;
					cout << stu[che.check_num]->stucard << "余额不足,请充值！" << endl;
				}
				s->next = p;
				s = p;
			}
			else if (che.choice == 1 && stu[che.check_num]->flag_card == 0) {
				cout << "该卡片已经禁无法进行消费" << endl;
			}
			else {
				cout << "卡号输入错误,请重新输入" << endl;
			}
		}
	}
	//input_info();
	cout << "====================欢迎进入食堂消费系统！！！====================" << endl;
}
