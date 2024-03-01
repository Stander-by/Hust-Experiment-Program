#pragma once
#include "struct.cpp"
#include "function.h"
using namespace std;
class Account {
public:
	Student* stu[Num];
	int serial_num = 0;
	Account();
	void open_account();
	void issue_card();
	void destr_account();
	void report_or_cancel_loss();
	void reissue_card();
	void recharge();

};
Account::Account() {
	ifstream fin("in//kh001.txt");
	char ch = '0';
	for (int n = 0; n < Num; n++) {
		stu[n] = new Student;
		fin.get(ch);
		for (int i = 0; ch != ','; i++) {
			stu[n]->stunum[i] = ch;
			fin.get(ch);
		}
		fin.get(ch);
		for (int j = 0; ch != ';'; j++) {
			stu[n]->stuname += ch;
			fin.get(ch);
		}
		fin.get(ch);
		int temp = 0, end = 0, sum = 0, num = 0;
		serial_num = 312346 + n;
		num = serial_num;
		for (int j = 6; j > 0; j--) {
			temp = num % 10;
			sum += temp;
			stu[n]->stucard[j - 1] = char(temp + 48);
			num = num / 10;
		}
		end = 9 - (sum % 10);
		stu[n]->stucard[6] = char(end + 48);
		//cout << stu[n]->stunum << stu[n]->stuname << stu[n]->stucard << endl;

	}
}
void Account::open_account() {
	cout << "******************开户***********************" << endl;
	ofstream file("out//open_account.txt");
	char stunum_input[11] = { '\0' };
	string stuname_input;
	char choice;
	int  stop = 1;
	while (stop) {
		cout << "请输入学号(输入q退出):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		cout << "请输入姓名:";
		cin >> stuname_input;
		cin.get();
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			for (int j = 0; j < 11; j++) {
				if (stu[i]->stunum[j] == stunum_input[j]) temp++;
			}
			if (temp == 11) {
				if (fuzzy_match(stu[i]->stuname, stuname_input)) {
					cout << stu[i]->stuname << stu[i]->stunum << endl;
					cout << "是否正确(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'Y') {
						if (stu[i]->flag == 0) {
							cout << stu[i]->stuname << "!!!开户成功!!!" << endl;
							stu[i]->flag = 1;
							file << "2021-09-01-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "开户成功!" << endl;
						}
						else if (stu[i]->flag == 1) {
							cout << "您已经进行过开户了！" << endl;
							file << "2021-09-01-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "开户失败" << endl;
						}
					}
					else if (choice == 'N') {
						cout << "error" << endl;
						file << "2021-09-01-" << sys_time() << "error" << endl;
					}
				}
				else {
					cout << "error" << endl;
					file << "2021-09-01-" << sys_time() << "error" << endl;
				}
			}
		}
	}
	file.close();
	cout << "******************开户***********************" << endl;
}
void Account::issue_card() {
	cout << "******************发卡***********************" << endl;
	ofstream file("out//issue_card.txt");
	char stunum_input[11] = { '\0' };
	int count = 0, stop = 1;
	while (stop) {
		cout << "输入学号(输入q退出):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "该用户不存在" << endl;
				else if (stu[i]->flag == 1) {
					cout << stu[i]->stuname << stu[i]->stunum << endl;
					cout << "是否正确(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << "2021-09-03-" << sys_time() << "error" << endl;
					}
					else if (stu[i]->flag_card == 0 && choice == 'Y') {
						cout << "进行发卡！" << endl;
						stu[i]->flag_card = 1;
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "发卡成功" << endl;
					}
					else if (stu[i]->flag_card == 1 && choice == 'Y') {
						cout << "该用户已经发卡成功" << endl;
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "发卡失败" << endl;
					}
				}
			}
		}
	}
	cout << "******************发卡***********************" << endl;
}
void Account::destr_account() {
	cout << "******************销户***********************" << endl;
	ofstream file("out//destr_account.txt");
	char stunum_input[11] = { '\0' };
	int stop = 1;
	while (stop) {
		cout << "输入学号(输入q退出):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "该用户不存在" << endl;
				else if (stu[i]->flag == 1) {
					cout << stu[i]->stuname << stu[i]->stunum << endl;
					cout << "是否正确(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') cout << "error" << endl;
					else if (choice == 'Y') {
						cout << "正在进行销户操作......" << endl;
						stu[i]->flag = 0;
						stu[i]->flag_card = 0;
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "销户成功" << endl;
						cout << "销户成功！" << endl;
					}
				}
			}
		}
	}
	cout << "******************销户***********************" << endl;
}
void Account::report_or_cancel_loss() {
	cout << "******************挂失/解挂***********************" << endl;
	ofstream file("out//report_or_cancel_loss.txt");
	char stunum_input[11] = { '\0' };
	int stop = 1;
	while (stop) {
		cout << "输入学号(输入q退出):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			int adjust;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0) {
					cout << "该用户不存在" << endl;
				}
				else {
					cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
					cout << "是否正确(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << date() << "error" << endl;
					}
					else if (choice == 'Y') {
						if (stu[i]->flag_card == 0)cout << "该校园卡禁用" << endl;
						else if (stu[i]->flag_card == 1)cout << "该校园卡正常" << endl;
						cout << "请选择调整的状态(0表示禁用1表示正常):";
						cin >> adjust;
						cin.get();
						if (adjust == 0) {
							stu[i]->flag_card = 0;
							file << date() << stu[i]->stuname << stu[i]->stunum << "***" << stu[i]->stucard << "禁用" << endl;
						}
						else if (adjust == 1) {
							stu[i]->flag_card = 1;
							file << date() << stu[i]->stuname << stu[i]->stunum << "***" << stu[i]->stucard << "正常" << endl;
						}
					}
				}
			}
		}
	}
	cout << "******************挂失/解挂***********************" << endl;
}
void Account::reissue_card() {
	cout << "******************补卡***********************" << endl;
	ofstream file("out//reissue_card.txt");
	char stunum_input[11] = { '\0' };
	int stop = 1;
	while (stop) {
		cout << "输入学号(输入q退出):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "该用户不存在" << endl;
				else {
					cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
					cout << "是否正确(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << "2021-09-03-" << sys_time() << "error" << endl;
					}
					else if (choice == 'Y') {
						if (stu[i]->flag_card == 0) {
							cout << "该卡禁用" << endl;
							cout << "现在进行补卡操作..." << endl;
						}
						else if (stu[i]->flag_card == 1) {
							cout << "该卡正常" << endl;
							cout << "现在进行挂失和补卡操作..." << endl;
							stu[i]->flag_card = 0;
							file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "***" << stu[i]->stucard << "禁用" << endl;
						}
						Student* p;
						p = new Student;
						stu[i]->next = p;
						p->next = NULL;
						//******************************
						strcpy_s(p->stunum, stu[i]->stunum);
						p->stuname = stu[i]->stuname;
						p->flag_card = 1;
						p->flag = 1;
						//进行补卡卡号的分配
						int temp = 0, end = 0, sum = 0, num = 0;
						serial_num++;
						num = serial_num;
						for (int j = 6; j > 0; j--) {
							temp = num % 10;
							sum += temp;
							p->stucard[j - 1] = char(temp + 48);
							num = num / 10;
						}
						end = 9 - (sum % 10);
						p->stucard[6] = char(end + 48);

						//***************************
						p = stu[i];
						stu[i] = stu[i]->next;
						delete p;
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "申请新学号" << stu[i]->stucard << "补卡成功" << endl;

					}

				}
			}
		}
	}
	cout << "******************补卡***********************" << endl;
}
void Account::recharge() {
	cout << "******************充值***********************" << endl;
	ofstream file("out//recharge.txt");
	char stunum_input[11] = { '\0' };
	double dollar;
	int stop = 1;
	while (stop) {
		cout << "输入学号(输入q退出):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "该用户不存在" << endl;
				else if (stu[i]->flag == 1) {
					cout << stu[i]->stuname << stu[i]->stunum << endl;
					cout << "是否正确(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << "2021-09-03-" << sys_time() << "error" << endl;
					}
					else if (choice == 'Y') {
						cout << "输入充值的金额:";
						cin >> dollar;
						cin.get();
						if (dollar + stu[i]->money >= 999.99) {
							cout << "操作失败！" << endl;
							file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stucard << "充值失败" << endl;
						}
						else if (dollar + stu[i]->money < 999.99) {
							stu[i]->money = stu[i]->money + dollar;
							cout << "充值成功！余额为:" << stu[i]->money << endl;
							file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stucard << "充值成功" << endl;
						}
					}
				}
			}
		}
	}
	cout << "******************充值***********************" << endl;
}