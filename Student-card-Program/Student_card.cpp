#include <iostream>
#include <cstdlib>
#include <fstream> 
#include <string>
#include <time.h>
#include <ctime>
//==========================
#include "struct.cpp"
#include "function.h"
#include "Cantine.h"
#include "Account.h"
#include "merge.h"
#include "mass_ope.h"
using namespace std;
void menu() {
	int option, sign;
	sign = 1;
	cout << "====================欢迎进入校园卡管理系统！！！====================" << endl;
	while (sign != 0) {
		//个人操作系统是指个人一项一项地去操作
		//批量操作系统是指系统提供好批量操作的文件系统再进行批量处理
		cout << "选择系统(0:退出***1:进入个人操作系统***2:进入批量操作系统):";
		cin >> sign;
		cin.get();
		if (sign == 0)break;
		else if (sign == 1) {
			int sign_op = 1;
			Account alone;
			
			cout << "//////////////////////个人操作系统//////////////////////" << endl;
			while (sign_op != 0) {
				cout << "1.开户" << endl << "2.销户" << endl << "3.发卡" << endl << "4.挂失/解挂" << endl << "5.补卡" << endl << "6.充值" << endl;
				cout << "输入您的选择(输入0退出):";
				cin >> sign_op;
				cin.get();
				if (sign_op == 0)break;
				else if (sign_op == 1)alone.open_account();
				else if (sign_op == 2)alone.destr_account();
				else if (sign_op == 3)alone.issue_card();
				else if (sign_op == 4)alone.report_or_cancel_loss();
				else if (sign_op == 5)alone.reissue_card();
				else if (sign_op == 6)alone.recharge();
				else cout << "error!!!" << endl;
			}
			cout << "//////////////////////个人操作系统//////////////////////" << endl << endl;

			cout << "//////////////////////食堂//////////////////////" << endl;
			Cantine D1;
			D1.consume(alone.stu);
			cout << "//////////////////////食堂//////////////////////" << endl;
		}
		else if (sign == 2) {
			cout << "//////////////////////批量操作系统//////////////////////" << endl;
			Cantine can;
			Account batch;
			cout << "读取消费完成" << endl;
			Pnode* final = new Pnode;
			final = merge();
			cout << "排序完成" << endl;
			operate_card_mass(batch.stu, batch.serial_num, can.can_win,can.unit,final);
			cout << "//////////////////////批量操作系统//////////////////////" << endl << endl;
			cout << "//////////////////////汇总操作系统//////////////////////" << endl;
			int ss = 100;
			can.read_comsume();
			while (ss != 0) {
				cout << "选择功能(0.退出,1.模糊查询消费余额,2.统计窗口消费金额,3.数据挖掘,4.精确查看卡号状态,5.查找消费失败,6.查询学生某一时间段的消费金额,7.检测数据是否被修改)" << endl;
				cin >> ss;
				cin.get();

				if (ss == 1) {
					fuzzy_find(batch.stu);
				}
				else if (ss == 2) {
					Can_sum(can.can_win);
				}
				else if (ss == 3) {
					data_mining(batch.stu, can.unit, can.can_win);
				}
				else if (ss == 4) {
					stunum_find(batch.stu);
				}
				else if (ss == 5) {
					default_find(batch.stu);
				}
				else if (ss == 6) {
					count(batch.stu);
				}
				else if (ss == 7) {
					Check_c_num(can.can_win);
				}

				
			}
			cout << "//////////////////////汇总操作系统//////////////////////" << endl << endl;
		}
		
		else continue;
	}
	cout << "====================欢迎进入校园卡管理系统！！！====================" << endl;
}
int main() {
	menu();
	
}


