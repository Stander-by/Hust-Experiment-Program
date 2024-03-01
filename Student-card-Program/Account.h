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
	cout << "******************����***********************" << endl;
	ofstream file("out//open_account.txt");
	char stunum_input[11] = { '\0' };
	string stuname_input;
	char choice;
	int  stop = 1;
	while (stop) {
		cout << "������ѧ��(����q�˳�):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		cout << "����������:";
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
					cout << "�Ƿ���ȷ(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'Y') {
						if (stu[i]->flag == 0) {
							cout << stu[i]->stuname << "!!!�����ɹ�!!!" << endl;
							stu[i]->flag = 1;
							file << "2021-09-01-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "�����ɹ�!" << endl;
						}
						else if (stu[i]->flag == 1) {
							cout << "���Ѿ����й������ˣ�" << endl;
							file << "2021-09-01-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "����ʧ��" << endl;
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
	cout << "******************����***********************" << endl;
}
void Account::issue_card() {
	cout << "******************����***********************" << endl;
	ofstream file("out//issue_card.txt");
	char stunum_input[11] = { '\0' };
	int count = 0, stop = 1;
	while (stop) {
		cout << "����ѧ��(����q�˳�):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "���û�������" << endl;
				else if (stu[i]->flag == 1) {
					cout << stu[i]->stuname << stu[i]->stunum << endl;
					cout << "�Ƿ���ȷ(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << "2021-09-03-" << sys_time() << "error" << endl;
					}
					else if (stu[i]->flag_card == 0 && choice == 'Y') {
						cout << "���з�����" << endl;
						stu[i]->flag_card = 1;
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "�����ɹ�" << endl;
					}
					else if (stu[i]->flag_card == 1 && choice == 'Y') {
						cout << "���û��Ѿ������ɹ�" << endl;
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "����ʧ��" << endl;
					}
				}
			}
		}
	}
	cout << "******************����***********************" << endl;
}
void Account::destr_account() {
	cout << "******************����***********************" << endl;
	ofstream file("out//destr_account.txt");
	char stunum_input[11] = { '\0' };
	int stop = 1;
	while (stop) {
		cout << "����ѧ��(����q�˳�):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "���û�������" << endl;
				else if (stu[i]->flag == 1) {
					cout << stu[i]->stuname << stu[i]->stunum << endl;
					cout << "�Ƿ���ȷ(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') cout << "error" << endl;
					else if (choice == 'Y') {
						cout << "���ڽ�����������......" << endl;
						stu[i]->flag = 0;
						stu[i]->flag_card = 0;
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "�����ɹ�" << endl;
						cout << "�����ɹ���" << endl;
					}
				}
			}
		}
	}
	cout << "******************����***********************" << endl;
}
void Account::report_or_cancel_loss() {
	cout << "******************��ʧ/���***********************" << endl;
	ofstream file("out//report_or_cancel_loss.txt");
	char stunum_input[11] = { '\0' };
	int stop = 1;
	while (stop) {
		cout << "����ѧ��(����q�˳�):";
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
					cout << "���û�������" << endl;
				}
				else {
					cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
					cout << "�Ƿ���ȷ(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << date() << "error" << endl;
					}
					else if (choice == 'Y') {
						if (stu[i]->flag_card == 0)cout << "��У԰������" << endl;
						else if (stu[i]->flag_card == 1)cout << "��У԰������" << endl;
						cout << "��ѡ�������״̬(0��ʾ����1��ʾ����):";
						cin >> adjust;
						cin.get();
						if (adjust == 0) {
							stu[i]->flag_card = 0;
							file << date() << stu[i]->stuname << stu[i]->stunum << "***" << stu[i]->stucard << "����" << endl;
						}
						else if (adjust == 1) {
							stu[i]->flag_card = 1;
							file << date() << stu[i]->stuname << stu[i]->stunum << "***" << stu[i]->stucard << "����" << endl;
						}
					}
				}
			}
		}
	}
	cout << "******************��ʧ/���***********************" << endl;
}
void Account::reissue_card() {
	cout << "******************����***********************" << endl;
	ofstream file("out//reissue_card.txt");
	char stunum_input[11] = { '\0' };
	int stop = 1;
	while (stop) {
		cout << "����ѧ��(����q�˳�):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "���û�������" << endl;
				else {
					cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
					cout << "�Ƿ���ȷ(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << "2021-09-03-" << sys_time() << "error" << endl;
					}
					else if (choice == 'Y') {
						if (stu[i]->flag_card == 0) {
							cout << "�ÿ�����" << endl;
							cout << "���ڽ��в�������..." << endl;
						}
						else if (stu[i]->flag_card == 1) {
							cout << "�ÿ�����" << endl;
							cout << "���ڽ��й�ʧ�Ͳ�������..." << endl;
							stu[i]->flag_card = 0;
							file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "***" << stu[i]->stucard << "����" << endl;
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
						//���в������ŵķ���
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
						file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stunum << "������ѧ��" << stu[i]->stucard << "�����ɹ�" << endl;

					}

				}
			}
		}
	}
	cout << "******************����***********************" << endl;
}
void Account::recharge() {
	cout << "******************��ֵ***********************" << endl;
	ofstream file("out//recharge.txt");
	char stunum_input[11] = { '\0' };
	double dollar;
	int stop = 1;
	while (stop) {
		cout << "����ѧ��(����q�˳�):";
		cin.getline(stunum_input, 11);
		if (stunum_input[0] == 'q')break;
		for (int i = 0; i < Num; i++) {
			int temp = 0;
			char choice;
			for (int j = 0; j < 11; j++) {
				if (stunum_input[j] == stu[i]->stunum[j]) temp++;
			}
			if (temp == 11) {
				if (stu[i]->flag == 0)cout << "���û�������" << endl;
				else if (stu[i]->flag == 1) {
					cout << stu[i]->stuname << stu[i]->stunum << endl;
					cout << "�Ƿ���ȷ(Y or N):";
					cin >> choice;
					cin.get();
					if (choice == 'N') {
						cout << "error" << endl;
						file << "2021-09-03-" << sys_time() << "error" << endl;
					}
					else if (choice == 'Y') {
						cout << "�����ֵ�Ľ��:";
						cin >> dollar;
						cin.get();
						if (dollar + stu[i]->money >= 999.99) {
							cout << "����ʧ�ܣ�" << endl;
							file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stucard << "��ֵʧ��" << endl;
						}
						else if (dollar + stu[i]->money < 999.99) {
							stu[i]->money = stu[i]->money + dollar;
							cout << "��ֵ�ɹ������Ϊ:" << stu[i]->money << endl;
							file << "2021-09-03-" << sys_time() << stu[i]->stuname << stu[i]->stucard << "��ֵ�ɹ�" << endl;
						}
					}
				}
			}
		}
	}
	cout << "******************��ֵ***********************" << endl;
}