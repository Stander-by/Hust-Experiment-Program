#pragma once
#include "struct.cpp"
#include "Account.h"
#include "function.h"
#include "Cantine.h"
void open_account_mass(Student** stu) {
	cout << "******************开户***********************" << endl;
	ofstream file("out//open_account.txt");
	for (int i = 0; i < Num; i++) {
		//cout << stu[i]->stuname << "开户成功！！！" << endl;
		stu[i]->flag = 1;
		file << "20210901" << stu[i]->stuname << stu[i]->stunum << "开户成功！" << endl;
	}
	file.close();
	cout << "******************开户***********************" << endl << endl;
}
void issue_card_mass(Student** stu) {
	cout << "******************发卡***********************" << endl;
	ofstream file("out//issue_card.txt");
	for (int i = 0; i < Num; i++) {
		//cout << stu[i]->stuname << "发卡成功" << stu[i]->stucard << endl;
		stu[i]->flag_card = 1;
		file << "20210903" << stu[i]->stuname << stu[i]->stunum << "发卡成功" << stu[i]->stucard << endl;
	}
	file.close();
	cout << "******************发卡***********************" << endl << endl;
}
string destr_account_mass(Student** stu, char* stunum_input, char* time) {
	cout << "******************销户***********************" << endl;
	string str, idnum, ti;
	cout << "输入学号:" << stunum_input << endl;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		cout << stu[i]->stuname << stu[i]->stunum << endl;
		cout << "正在进行销户操作......" << endl;
		stu[xh.check_num]->flag = 0;
		stu[xh.check_num]->flag_card = 0;
		idnum = stu[xh.check_num]->stunum;
		ti = time;
		str = ti + stu[xh.check_num]->stuname + idnum + "销户成功";
		cout << stu[xh.check_num]->stuname << "销户成功！" << endl;
		
	}
	else {
		if (stu[xh.check_num]->flag == 0)cout << "该用户不存在" << endl;
	}
	cout << "******************销户***********************" << endl << endl;
	return str;
}
string report_loss(Student** stu, char* stunum_input, char* time) {
	cout << "******************挂失***********************" << endl;
	cout << "输入学号:" << stunum_input << endl;
	string str, card, ti;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		if (stu[i]->flag_card == 1) {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "该校园卡正常,现在进行挂失..." << endl;
				stu[i]->flag_card = 0;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "挂失成功";
			}
		else {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "该校园卡禁止,无法进行挂失..." << endl;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "挂失失败";

			}
		
	}
	else {
		cout << "该用户不存在" << endl;
	}
	cout << "******************挂失***********************" << endl << endl;
	return str;
}
string canel_report_loss(Student** stu, char* stunum_input, char* time) {
	cout << "******************解挂***********************" << endl;
	cout << "输入学号:" << stunum_input << endl;
	string str, card, ti;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		if (stu[i]->flag_card == 0) {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "该校园卡禁止,现在进行解挂..." << endl;
				stu[i]->flag_card = 1;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "解挂成功";
			}
		else {
				cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
				cout << "该校园卡正常,无法进行解挂..." << endl;
				card = stu[i]->stucard;
				ti = time;
				str = ti + stu[i]->stuname + card + "解挂失败";
			}

	}
	else {
		cout << "该用户不存在" << endl;
	}
	cout << "******************解挂***********************" << endl << endl;
	return str;
}
string reissue_card_mass(Student** stu, int& serial_num, char* stunum_input, char* time) {
	cout << "******************补卡***********************" << endl;
	string str, card, idnum, ti;
	cout << "输入学号(输入q退出):" << stunum_input << endl;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		
		
		cout << stu[i]->stunum << stu[i]->stuname << stu[i]->stucard << endl;
		if (stu[i]->flag_card == 0) {
				cout << "该卡禁用" << endl;
				cout << "现在进行补卡操作..." << endl;

			}
		else if (stu[i]->flag_card == 1) {
				cout << "该卡正常" << endl;
				cout << "现在进行挂失和补卡操作..." << endl;
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
		card = stu[i]->stucard;
		idnum = stu[i]->stunum;
		ti = time;
		str = ti + stu[i]->stuname + idnum + "申请新学号" + card + "补卡成功";
		
	}
	else {
		cout << "该用户不存在" << endl;
	}
	cout << "******************补卡***********************" << endl << endl;
	return str;
}
string recharge_mass(Student** stu, char* stunum_input, double dollar, char* time) {
	cout << "******************充值***********************" << endl;
	string str, card, ti;
	cout << "输入学号:" << stunum_input << endl;
	string strnum(stunum_input);
	Check xh = Check_stunum(stu, strnum);
	if (xh.choice) {
		int i = xh.check_num;
		cout << stu[i]->stuname << stu[i]->stunum << endl;
		cout << "输入充值的金额:" << dollar << endl;
		card = stu[i]->stucard;
		ti = time;
		if (dollar + stu[i]->money >= 999.99) {
				cout << "操作失败！" << endl;
				str = ti + stu[i]->stuname + card + "充值失败";
			}
		else if (dollar + stu[i]->money < 999.99) {
				stu[i]->money = stu[i]->money + dollar;
				cout << "充值成功！余额为:" << stu[i]->money << endl;
				str = ti + stu[i]->stuname + card + "充值成功" + to_string(dollar) + "余额为:" + to_string(stu[i]->money);


			}
		
	}
	else {
		cout << "该用户不存在" << endl;
	}
	cout << "******************充值***********************" << endl << endl;
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
							cout << "请输入密码:";
							key_input = "8888";
							cout << key_input << endl;
							//cin >> key_input;
							if (key_input == stu[che.check_num]->key)break;
							else {
								cout << "密码错误！请重新输入！" << endl;
							}
						}*/
				if (stu[che.check_num]->money >= f->money_p) {
					stu[che.check_num]->money -= f->money_p;
					result += f->date_p+ f->time_p + stu[che.check_num]->stuname + "消费成功" + stu[che.check_num]->stunum + "消费金额" + to_string(f->money_p) + "///" + stu[che.check_num]->stucard + "余额:" + to_string(stu[che.check_num]->money) + '\n';
					
					
					can[f->Can].remain_sum += f->money_p;
					stu[che.check_num]->record2.push_back(*f);
				}
				else {
					result += f->date_p + f->time_p +stu[che.check_num]->stuname + "消费失败" + stu[che.check_num]->stunum + "消费金额-" + to_string(f->money_p)+"///" + stu[che.check_num]->stucard + "余额:" + to_string(stu[che.check_num]->money) + '\n';
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
							cout << "请输入密码:";
							key_input = "8888";
							cout << key_input << endl;
							//cin >> key_input;
							if (key_input == stu[che.check_num]->key)break;
							else {
								cout << "密码错误！请重新输入！" << endl;
							}
						}*/
						stu[che.check_num]->sum = 0;
					}
					result += f->date_p + f->time_p + stu[che.check_num]->stuname + "消费成功" + stu[che.check_num]->stunum + "消费金额" + to_string(f->money_p) + "///" + stu[che.check_num]->stucard + "余额:" + to_string(stu[che.check_num]->money) + '\n';
					can[f->Can].remain_sum += f->money_p;
					stu[che.check_num]->record2.push_back(*f);
				}
				else {
					result += f->date_p + f->time_p + stu[che.check_num]->stuname + "消费失败" + stu[che.check_num]->stunum + "消费金额-" + to_string(f->money_p) + "///" + stu[che.check_num]->stucard + "余额:" + to_string(stu[che.check_num]->money) + '\n';
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
	cout << "批量开户完成" << endl;
	issue_card_mass(stu);//9.1
	cout << "批量发卡完成" << endl;
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
			if (op == "挂失") {
				rocin << report_loss(stu, id_num, time) << endl;
			}
			else if (op == "解挂") {
				rocin << canel_report_loss(stu, id_num, time) << endl;
			}
			else if (op == "销户") {
				din << destr_account_mass(stu, id_num, time) << endl;
			}
		}
		else if (date_cz == charge_time[0]) {
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;

		}
		else if (date_cz == "20210906") {
			if (op == "挂失") {
				rocin << report_loss(stu, id_num, time) << endl;
			}
			else if (op == "补卡") {
				rcin << reissue_card_mass(stu, serial_num, id_num, time) << endl;
			}
		}
		else if (date_cz == charge_time[1]) {
			if (flag1 == 1) {
				xfin << consume_mass_node(f, stu, charge_time[1], unit,can_win) << endl;
				flag1 = 0;
				cout << "第一波消费完成" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
		}
		else if (date_cz == charge_time[2]) {
			if (flag2 == 1) {
				xfin << consume_mass_node(f, stu, charge_time[2], unit,can_win) << endl;
				flag2 = 0;
				cout << "第二波消费完成" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
		}
		else if (date_cz == charge_time[3]) {
			if (flag3 == 1) {
				
				xfin << consume_mass_node(f, stu, charge_time[3], unit,can_win) << endl;
				flag3 = 0;
				cout << "第三波消费完成" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
		}
		else if (date_cz == charge_time[4]) {
			if (flag4 == 1) {
				
				xfin << consume_mass_node(f, stu, charge_time[4], unit,can_win) << endl;
				flag4 = 0;
				cout << "第四波消费完成" << endl;
			}
			rin << recharge_mass(stu, id_num, charge_money, time) << endl;
			

		}
		if (ch == '.')stop = 0;
	}
	if (flag5 == 1) {
		xfin << consume_mass_node(f, stu, charge_time[5], unit,can_win) << endl;
		flag5 = 0;
		cout << "第五波消费完成" << endl;
	}
	cout << "bye";

}