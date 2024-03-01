#pragma once
#include "struct.cpp"
#include "Account.h"
#include "function.h"
#include "Cantine.h"
void open_account_mass(Student** stu) {
	cout << "******************����***********************" << endl;
	ofstream file("out//open_account.txt");
	for (int i = 0; i < Num; i++) {
		//cout << stu[i]->stuname << "�����ɹ�������" << endl;
		stu[i]->flag = 1;
		file << "20210901" << stu[i]->stuname << stu[i]->stunum << "�����ɹ���" << endl;
	}
	file.close();
	cout << "******************����***********************" << endl << endl;
}
void issue_card_mass(Student** stu) {
	cout << "******************����***********************" << endl;
	ofstream file("out//issue_card.txt");
	for (int i = 0; i < Num; i++) {
		//cout << stu[i]->stuname << "�����ɹ�" << stu[i]->stucard << endl;
		stu[i]->flag_card = 1;
		file << "20210903" << stu[i]->stuname << stu[i]->stunum << "�����ɹ�" << stu[i]->stucard << endl;
	}
	file.close();
	cout << "******************����***********************" << endl << endl;
}
string destr_account_mass(Student** stu, char* stunum_input, char* time) {
	cout << "******************����***********************" << endl;
	string str, idnum, ti;
	cout << "����ѧ��:" << stunum_input << endl;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		cout << stu[i]->stuname << stu[i]->stunum << endl;
		cout << "���ڽ�����������......" << endl;
		stu[xh.check_num]->flag = 0;
		stu[xh.check_num]->flag_card = 0;
		idnum = stu[xh.check_num]->stunum;
		ti = time;
		str = ti + stu[xh.check_num]->stuname + idnum + "�����ɹ�";
		cout << stu[xh.check_num]->stuname << "�����ɹ���" << endl;
		
	}
	else {
		if (stu[xh.check_num]->flag == 0)cout << "���û�������" << endl;
	}
	cout << "******************����***********************" << endl << endl;
	return str;
}
string report_loss(Student** stu, char* stunum_input, char* time) {
	cout << "******************��ʧ***********************" << endl;
	cout << "����ѧ��:" << stunum_input << endl;
	string str, card, ti;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		if (stu[i]->flag_card == 1) {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "��У԰������,���ڽ��й�ʧ..." << endl;
				stu[i]->flag_card = 0;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "��ʧ�ɹ�";
			}
		else {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "��У԰����ֹ,�޷����й�ʧ..." << endl;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "��ʧʧ��";

			}
		
	}
	else {
		cout << "���û�������" << endl;
	}
	cout << "******************��ʧ***********************" << endl << endl;
	return str;
}
string canel_report_loss(Student** stu, char* stunum_input, char* time) {
	cout << "******************���***********************" << endl;
	cout << "����ѧ��:" << stunum_input << endl;
	string str, card, ti;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		if (stu[i]->flag_card == 0) {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "��У԰����ֹ,���ڽ��н��..." << endl;
				stu[i]->flag_card = 1;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "��ҳɹ�";
			}
		else {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "��У԰������,�޷����н��..." << endl;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "���ʧ��";
			}

	}
	else {
		cout << "���û�������" << endl;
	}
	cout << "******************���***********************" << endl << endl;
	return str;
}
string reissue_card_mass(Student** stu, int& serial_num, char* stunum_input, char* time) {
	cout << "******************����***********************" << endl;
	string str, card, idnum, ti;
	cout << "����ѧ��(����q�˳�):" << stunum_input << endl;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		
		
		cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
		if (stu[i]->flag_card == 0) {
				cout << "�ÿ�����" << endl;
				cout << "���ڽ��в�������..." << endl;

			}
		else if (stu[i]->flag_card == 1) {
				cout << "�ÿ�����" << endl;
				cout << "���ڽ��й�ʧ�Ͳ�������..." << endl;
				stu[i]->flag_card = 0;
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
		card = stu[i]->stucard;
		idnum = stu[i]->stunum;
		ti = time;
		str = ti + stu[i]->stuname + idnum + "������ѧ��" + card + "�����ɹ�";
		
	}
	else {
		cout << "���û�������" << endl;
	}
	cout << "******************����***********************" << endl << endl;
	return str;
}
string recharge_mass(Student** stu, char* stunum_input, double dollar, char* time) {
	cout << "******************��ֵ***********************" << endl;
	string str, card, ti;
	cout << "����ѧ��:" << stunum_input << endl;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		cout << stu[i]->stuname << stu[i]->stunum << endl;
		cout << "�����ֵ�Ľ��:" << dollar << endl;
		card = stu[i]->stucard;
		ti = time;
		if (dollar + stu[i]->money >= 999.99) {
				cout << "����ʧ�ܣ�" << endl;
				str = ti + stu[i]->stuname + card + "��ֵʧ��";
			}
		else if (dollar + stu[i]->money < 999.99) {
				stu[i]->money = stu[i]->money + dollar;
				cout << "��ֵ�ɹ������Ϊ:" << stu[i]->money << endl;
				str = ti + stu[i]->stuname + card + "��ֵ�ɹ�" + to_string(dollar) + "���Ϊ:" + to_string(stu[i]->money);


			}
		
	}
	else {
		cout << "���û�������" << endl;
	}
	cout << "******************��ֵ***********************" << endl << endl;
	return str;
}
string consume_mass_node(Pnode*& f, Student** stu,  string time2, int unit,Win* can) {
	string result;
	string ss, key_input;
	while (f->next!= NULL && atoi(f->next->date_p.c_str()) < atoi(time2.c_str())) {
		f = f->next;
		int sta1 = f->state;
		int sta2;
		if (f->next != NULL)  sta2 = f->next->state;
		else if (f->next == NULL)  sta2 = sta1;
		
		Check che = Check_card(stu, f->card_p);
		if (che.choice) {
			ss = stu[che.check_num]->stucard;
			int t = atoi(f->time_p.c_str());
			if (f->state == 0) {
				/*while (1) {
							cout << "����������:";
							key_input = "8888";
							cout << key_input << endl;
							//cin >> key_input;
							if (key_input == stu[che.check_num]->key)break;
							else {
								cout << "����������������룡" << endl;
							}
						}*/
				if (stu[che.check_num]->money >= f->money_p) {
					stu[che.check_num]->money -= f->money_p;
					result += f->date_p+ f->time_p + stu[che.check_num]->stuname + "���ѳɹ�" + stu[che.check_num]->stunum + "���ѽ��" + to_string(f->money_p) + "///" + stu[che.check_num]->stucard + "���:" + to_string(stu[che.check_num]->money) + '\n';
					
					
					can[f->Can].remain_sum += f->money_p;
					stu[che.check_num]->record2.push_back(*f);
				}
				else {
					result += f->date_p + f->time_p +stu[che.check_num]->stuname + "����ʧ��" + stu[che.check_num]->stunum + "���ѽ��-" + to_string(f->money_p)+"///" + stu[che.check_num]->stucard + "���:" + to_string(stu[che.check_num]->money) + '\n';
					f->last_money = stu[che.check_num]->money;
					stu[che.check_num]->record.push_back(*f);
				}
			}
			else {
				if (stu[che.check_num]->money >= f->money_p) {
					stu[che.check_num]->money -= f->money_p;
					stu[che.check_num]->sum += f->money_p;
					if (stu[che.check_num]->sum > 20) {
						/*while (1) {
							cout << "����������:";
							key_input = "8888";
							cout << key_input << endl;
							//cin >> key_input;
							if (key_input == stu[che.check_num]->key)break;
							else {
								cout << "����������������룡" << endl;
							}
						}*/
						stu[che.check_num]->sum = 0;
					}
					result += f->date_p + f->time_p + stu[che.check_num]->stuname + "���ѳɹ�" + stu[che.check_num]->stunum + "���ѽ��" + to_string(f->money_p) + "///" + stu[che.check_num]->stucard + "���:" + to_string(stu[che.check_num]->money) + '\n';
					can[f->Can].remain_sum += f->money_p;
					stu[che.check_num]->record2.push_back(*f);
				}
				else {
					result += f->date_p + f->time_p + stu[che.check_num]->stuname + "����ʧ��" + stu[che.check_num]->stunum + "���ѽ��-" + to_string(f->money_p) + "///" + stu[che.check_num]->stucard + "���:" + to_string(stu[che.check_num]->money) + '\n';
					f->last_money = stu[che.check_num]->money;
					stu[che.check_num]->record.push_back(*f);
				}
			}
			if (sta1 != sta2) {
				stu[che.check_num]->sum = 0;
			}
		}
	}
	return result;
}	
void operate_card_mass(Student** stu, int& serial_num, Win* can_win,int unit,Pnode* f) {
	ifstream fin("in//cz002.txt");
	ofstream rocin("out//M-report_or_cancel_loss.txt");
	ofstream oin("out//M-operate_card.txt");
	ofstream din("out//M-destr_account.txt");
	ofstream rin("out//M-recharge.txt");
	ofstream rcin("out//M-reissue_card.txt");
	ofstream xfin("out//M-consume.txt");
	int stop = 1;
	int flag1 = 1, flag2 = 1, flag3 = 1, flag4 = 1, flag5 = 1;
	char ch = '0';
	char time[17] = { '\0' };
	char id_num[11] = { '\0' };
	double charge_money;
	string charge_time[6] = {
		"20210904",
		"20211014",
		"20211104",
		"20211125",
		"20211216",
		"20211232"
	};
	open_account_mass(stu);//9.1
	cout << "�����������" << endl;
	issue_card_mass(stu);//9.1
	cout << "�����������" << endl;
	while (stop) {
		string op, money;
		string date_cz, time_cz;
		for (int i = 0; i < 16; i++) {
			fin.get(ch);
			time[i] = ch;
		}
		for (int m = 0; m < 8; m++) {
			date_cz += time[m];
			time_cz += time[m + 8];
		}
		oin << time;
		fin.get(ch);
		for (int j = 0; j < 4; j++) {
			fin.get(ch);
			op += ch;
		}
		fin.get(ch);
		oin << op;
		for (int k = 0; k < 10; k++) {
			fin.get(ch);
			id_num[k] = ch;
		}
		fin.get(ch);
		oin << id_num;

		if (ch == ',') {
			fin.get(ch);
			while (ch != ';') {
				money += ch;
				fin.get(ch);
			}
			charge_money = atof(money.c_str());
			oin << charge_money << endl;
			fin.get(ch);
		}
		else if (ch == ';') {
			oin << endl;
			fin.get(ch);
		}

		if (date_cz == "20210903") {
			if (op == "��ʧ") {
				rocin << report_loss(stu, id_num, time) << endl;
			}
			else if (op == "���") {
				rocin << canel_report_loss(stu, id_num, time) << endl;
			}
			else if (op == "����") {
				din << destr_account_mass(stu, id_num, time) << endl;
			}
		}
		else if (date_cz == charge_time[0]) {
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;

		}
		else if (date_cz == "20210906") {
			if (op == "��ʧ") {
				rocin << report_loss(stu, id_num, time) << endl;
			}
			else if (op == "����") {
				rcin << reissue_card_mass(stu, serial_num, id_num, time) << endl;
			}
		}
		else if (date_cz == charge_time[1]) {
			if (flag1 == 1) {
				xfin << consume_mass_node(f, stu, charge_time[1], unit,can_win) << endl;
				flag1 = 0;
				cout << "��һ���������" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
		}
		else if (date_cz == charge_time[2]) {
			if (flag2 == 1) {
				xfin << consume_mass_node(f, stu, charge_time[2], unit,can_win) << endl;
				flag2 = 0;
				cout << "�ڶ����������" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
		}
		else if (date_cz == charge_time[3]) {
			if (flag3 == 1) {
				
				xfin << consume_mass_node(f, stu, charge_time[3], unit,can_win) << endl;
				flag3 = 0;
				cout << "�������������" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
		}
		else if (date_cz == charge_time[4]) {
			if (flag4 == 1) {
				
				xfin << consume_mass_node(f, stu, charge_time[4], unit,can_win) << endl;
				flag4 = 0;
				cout << "���Ĳ��������" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
			

		}
		if (ch == '.')stop = 0;
	}
	if (flag5 == 1) {
		xfin << consume_mass_node(f, stu, charge_time[5], unit,can_win) << endl;
		flag5 = 0;
		cout << "���岨�������" << endl;
	}
	cout << "bye";

}