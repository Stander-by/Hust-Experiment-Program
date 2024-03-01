#pragma once
#include <cstdlib>
#include <fstream> 
#include <string>
#include <time.h>
#include <ctime>
#include <algorithm>
#include "struct.cpp"
using namespace std;
string date() {
	string date;
	string day;
	string month[12] = { "01","02","03","04","05","06","07","08","09","10","11","12" };
	int  now_year;
	time_t tn;
	tn = time(NULL);
	tm tt;
	localtime_s(&tt, &tn);
	now_year = tt.tm_year + 1900;
	if (tt.tm_mday < 10) {
		day = '0' + to_string(tt.tm_mday);
	}
	else {
		day = to_string(tt.tm_mday);
	}
	date = to_string(now_year) + month[rand() % 12] + day;
	return date;
}
string sys_time() {
	string sys_time;
	string hh[24] = {
		"00","01","02","03","04","05","06","07","08","09",
		"10","11","12","13","14","15","16","17","18","19",
		"20","21","22","23"
	};
	string tim[60] = { "00","01","02","03","04","05","06","07","08","09",
					"10","11","12","13","14","15","16","17","18","19",
					"20","21","22","23","24","25","26","27","28","29",
					"30","31","32","33","34","35","36","37","38","39",
					"40","41","42","43","44","45","46","47","48","49",
					"50","51","52","53","54","55","56","57","58","59" };
	sys_time = hh[rand() % 24] + tim[rand() % 60] + tim[rand() % 60] + tim[rand() % 60];
	return sys_time;
}

bool cmp(pair<string, int> a, pair<string, int> b) {
	return a.second < b.second;
}
struct Check Check_card(Student** stu, string card_input) {
	Check s;
	s.check_num = -1;
	s.choice = false;
	int low = 0;
	int high = Num-1;
	int mid;
	while (low <= high) {
		mid = (low + high) / 2;
		string str(stu[mid]->stucard);
		if (str == card_input && stu[mid]->flag_card == 1) {
			s.choice = true;
			s.check_num = mid;
			break;
		}
		
		else if (atoi(card_input.c_str()) < atoi(stu[mid]->stucard)) {
			high = mid - 1;
		}
		else {
			low = mid + 1;
		}

	}
	return s;
}
struct Check Check_stunum(Student** stu, string stunum_input) {
	Check s;
	s.check_num = -1;
	s.choice = false;
	int low = 0;
	int high = Num - 1;
	int mid;
	while (low <= high) {
		mid = (low + high) / 2;
		string str(stu[mid]->stunum);
		if (str == stunum_input && stu[mid]->flag == 1) {
			s.choice = true;
			s.check_num = mid;
			break;
		}

		else if (atoi(stunum_input.c_str()) < atoi(stu[mid]->stunum)) {
			high = mid - 1;
		}
		else {
			low = mid + 1;
		}

	}
	return s;
}
bool fuzzy_match(string s, string p) {
	int m = s.size();
	int n = p.size();
	while (m && n && p[n - 1] != '*') {
		if (s[m - 1] == p[n - 1]) {
			m--;
			n--;
		}
		else if (p[n - 1] == '?') {
			if (s[m - 1] >= 0 && s[m - 1] <= 127) {
				m--;
			}
			else {
				m -= 2;
			}
			n--;
		}
		else {
			return false;
		}
	}
	if (n == 0) {
		return m == 0;
	}
	int sIndex = 0, pIndex = 0;
	int sRecord = -1, pRecord = -1;
	while (sIndex < m && pIndex < n) {
		if (p[pIndex] == '*') {
			pIndex++;
			sRecord = sIndex;
			pRecord = sIndex;
		}
		else if (s[sIndex] == p[pIndex]) {
			pIndex++;
			sIndex++;
		}
		else if (p[pIndex] == '?') {
			if (s[sIndex] >= 0 && s[sIndex] <= 127) {
				sIndex++;
			}
			else {
				sIndex += 2;
			}
			pIndex++;
		}
		else if (sRecord != -1 && sRecord + 1 < m) {
			++sRecord;
			sIndex = sRecord;
			pIndex = pRecord;
		}
		else {
			return false;
		}
	}
	for (int i = pIndex; i < n; i++) {
		if (p[i] != '*') {
			return false;
		}
	}
	return true;
}
double dishes() {
	srand(static_cast <unsigned>(time(0)));
	float r = 10 + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / 20));
	return r;
}
void data_mining( Student** stu, int unit, Win* can) {
	while (1) {
		string stunum;
		cout << "输入学号(q退出)";
		cin >> stunum;
		if (stunum == "q")break;
		cin.get();
		Check s;
		s = Check_stunum(stu, stunum);
		map<string, int> side;
		for (int i = 0; i < unit; i++) {
			Pnode* xx = new Pnode;
			xx = can[i].next;
			while (xx->next != NULL) {
				xx = xx->next;
				if (xx->card_p == stu[s.check_num]->stucard) {
					Pnode* m = new Pnode;
					Pnode* n = new Pnode;
					n = xx;
					m = xx;
					for (int j = 0; j < 5; j++) {
						n = n->front;
						if (n == NULL)break;
						if (n->state == xx->state) {
							if (side.end() != side.find(n->card_p))side[n->card_p]++;
							else side.insert(pair<string, int>(n->card_p, 1));
						}
						else break;
					}
					for (int j = 0; j < 5; j++) {
						m = m->next;
						if (m == NULL)break;
						if (m->state == xx->state ) {
							if (side.end() != side.find(m->card_p))side[m->card_p]++;
							else side.insert(pair<string, int>(m->card_p, 1));
						}
						else break;
					}
				}
			}
		}
		vector< pair<string, int> > vec;
		for (map<string, int>::iterator it = side.begin(); it != side.end(); it++) {
			vec.push_back(pair<string, int>(it->first, it->second));
		}
		sort(vec.begin(), vec.end(), cmp);
		for (unsigned int i = vec.size()-1;i >(vec.size()-5)&&i>0; i--) {
			
			Check k;
			k = Check_card(stu, vec[i].first);
			cout << stu[k.check_num]->stuname << ends << vec[i].second << endl;
		}
	}
}
void stunum_find(Student** stu) {
	cout << "输入学号:";
	string stunum_input;
	cin >> stunum_input;
	cin.get();
	int low = 0;
	int high = Num - 1;
	int mid;
	while (low <= high) {
		mid = (low + high) / 2;
		string str(stu[mid]->stunum);
		if (str == stunum_input && stu[mid]->flag == 1) {
			cout << "您的姓名是:" << stu[mid]->stuname << endl;
			cout << "您的卡号是:" << stu[mid]->stucard << endl;
			if (stu[mid]->flag_card) {
				cout << "该卡的状态是正常" << endl;
			}
			else {
				cout << "该卡的状态是挂失" << endl;
			}
			break;
		}

		else if (atoi(stunum_input.c_str()) < atoi(stu[mid]->stunum)) {
			high = mid - 1;
		}
		else {
			low = mid + 1;
		}

	}
}
void fuzzy_find(Student** stu) {
	while (1) {
		string name, id;
		cout << "输入姓名(可模糊)(q退出)";
		cin >> name;
		cin.get();
		if (name == "q")break;
		cout << "输入学号(可模糊)";
		cin >> id;
		cin.get();
		for (int i = 0; i < Num; i++) {
			string str1 = stu[i]->stuname;
			string str2 = stu[i]->stunum;
			if (fuzzy_match(str1, name) && fuzzy_match(str2, id)) {
				cout << stu[i]->stuname << stu[i]->stunum << endl;
				cout << stu[i]->stucard << "余额:" << stu[i]->money << endl;
			}
		}
	}
}
void Can_sum(Win* can) {
	while (1) {
		cout << "输入要查询的窗口数(输入0退出)：";
		int put;
		cin >> put;
		cin.get();
		if (put == 0)break;
		cout << "窗口" << put << "总额：" << can[put - 1].remain_sum << endl;
	}
}
void default_find(Student** stu) {
	while (1) {
		Check dd;
		string xh;
		cout << "输入学号(q退出):";
		cin >> xh;
		cin.get();
		if (xh == "q")break;
		dd = Check_stunum(stu, xh);
		if (dd.choice) {

			for (vector<Pnode>::iterator it2 = stu[dd.check_num]->record.begin(); it2 != stu[dd.check_num]->record.end(); ++it2)
			{
				cout << stu[dd.check_num]->stucard << "时间" << it2->date_p << it2->time_p << "余额不足" << it2->last_money << "消费" << it2->money_p << endl;
			}
		}
	}
}
void count(Student** stu) {
	string  stuid;
	int t1, t2;
	double doll = 0;
	cout << "输入学号:";
	cin >> stuid;
	cin.get();
	cout << "输入起始时间:";
	cin >> t1;
	cin.get();
	cout << "输入结束时间:";
	cin >> t2;
	cin.get();
	Check st = Check_stunum(stu, stuid);
	for (vector<Pnode>::iterator it2 = stu[st.check_num]->record.begin(); it2 != stu[st.check_num]->record.end(); ++it2)
	{
		int tt = atoi(it2->date_p.c_str());
		if (tt >= t1 && tt < t2) {
			doll += it2->money_p;
		}
	}
	cout << stu[st.check_num]->stuname << "!!!该时间段共消费：" << doll << endl;
	
	
}
Pnode* merge() {
	ifstream inn("out//M-mergesort.txt");
	char ch = '0';
	Pnode* final = new Pnode;
	Pnode* pp = new Pnode;
	final = pp;
	inn.get(ch);
	while (ch == '2') {
		Pnode* ss = new Pnode;
		for (int i = 0; i < 8; i++) {

			ss->date_p += ch;
			inn.get(ch);
		}
		for (int i = 0; i < 8; i++) {

			ss->time_p += ch;
			inn.get(ch);
		}
		if (atoi(ss->time_p.c_str()) > 7000000 && atoi(ss->time_p.c_str()) < 9000000)ss->state = 1;
		else if (atoi(ss->time_p.c_str()) > 11000000 && atoi(ss->time_p.c_str()) < 13000000)ss->state = 2;
		else if (atoi(ss->time_p.c_str()) > 17000000 && atoi(ss->time_p.c_str()) < 19000000)ss->state = 3;


		for (int i = 0; i < 7; i++) {
			inn.get(ch);
			ss->card_p += ch;
		}

		inn.get();
		string nn;
		inn.get(ch);
		while (ch != ' ') {
			nn += ch;
			inn.get(ch);
		}
		inn.get(ch);
		string mon;
		while (ch != '\n') {
			mon += ch;
			inn.get(ch);
		}
		ss->money_p = atof(mon.c_str());
		ss->Can = atoi(nn.c_str());
		ss->next = NULL;
		pp->next = ss;
		ss->front = pp;
		pp = ss;
		inn.get(ch);
	}
	return final;
}
void Check_c_num(Win* can) {
	string str;
	char sig[3] = { '\0' };
	char ch = '0';
	int count = 0;
	ifstream ixf("in//xf015.txt");
	getline(ixf,str);
	ixf.get(ch);
	
	while (ch == 'W') {
		Pnode* kk = new Pnode;
		kk = can[count++].next->next;
		ixf.getline(sig, 3);
		double mon = 0;
		int c_num;
		ixf.get(ch);
		while (ch == '3') {
			string card, date, time;
			while (ch != ',') {
				card += ch;
				ixf.get(ch);
			}
			ixf.get(ch);
			while (ch != ',') {
				date += ch;
				ixf.get(ch);
			}
			ixf.get(ch);
			while (ch != ',') {
				time += ch;
				ixf.get(ch);
			}
	
			ixf.get(ch);
			string dol;
			while (ch != ';') {
				dol += ch;
				ixf.get(ch);
			}
			mon = atof(dol.c_str());
			int dt = atoi((date + time).c_str());
			int stu = atoi(card.c_str());
			c_num = (dt % 9973 + stu % 9973 + (int)mon * 997 + count) % 10000;///校验码
			if (c_num != kk->c_num) {
				cout << "数据:" << kk->card_p << "  " << kk->date_p << kk->time_p << "  " << kk->money_p << "被篡改" << endl;
				break;
			}
			ixf.get(ch);//读取换行符
			ixf.get(ch);
			kk = kk->next;
		}
	}




}