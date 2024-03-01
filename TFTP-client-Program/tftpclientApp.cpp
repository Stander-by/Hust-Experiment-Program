
#include <iostream>
#include <string>
#include <WinSock2.h>
#include <windows.h>
#pragma comment(lib,"ws2_32.lib")
using namespace std;

#define max_data 512
#define PKT_RCV_TIMEOUT 500
#define PKT_MAX_RXMT 5
#define RRQ (short)1
#define WRQ (short)2
#define DATA (short)3
#define ACK (short)4
#define ERROR (short)5

struct tftp_message {
	uint16_t op;
	union {
		uint16_t num;     //DATA ACK
		uint16_t error_code;
		char filename[2];
	};
	char data[max_data];
};
class tftp {
private:
public:
	tftp(void);
	unsigned int IP_len;
	unsigned long Opt;
	double transbyte, consumetime;
	tftp_message send_packet, recv_packet;
	sockaddr_in server_IP, client_IP;
	SOCKET sock;
	FILE* tftp_log;
	time_t rawTime;
	tm* info;
	char logbuf[1024];
	clock_t start, end;
	WSADATA wsadata;
	int nRc, choose;


	bool init_Winsock();
	bool create_socket(char* s_ip, char* c_ip);
	bool bind_socket();
	bool log_open();
	void log_write();
	bool upload(char* filename);
	bool download(char* remotefname, char* localfname);


};
//tftp初始化
tftp::tftp() {
	Opt = 1;
	transbyte = 0;
	consumetime = 0;
	tftp_log = NULL;
}
//Winsock创建
bool tftp::init_Winsock() {
	IP_len = sizeof(struct sockaddr_in);
	nRc = WSAStartup(0x0101, &wsadata);
	if (nRc) {
		cout << "INFO—————error——————Winsock init" << endl;
		return 0;
	}
	if (wsadata.wVersion != 0x0101) {
		cout << "INFO—————error——————Version not support" << endl;
		WSACleanup();
		return 0;
	}
	cout << "INFO—————success——————Winsock init" << endl;
	return 1;
}
//创建套接字
bool tftp::create_socket(char* s_ip, char* c_ip) {
	server_IP.sin_family = AF_INET;
	server_IP.sin_port = htons(69);
	server_IP.sin_addr.S_un.S_addr = inet_addr(s_ip);
	client_IP.sin_family = AF_INET;
	client_IP.sin_port = htons(0);
	client_IP.sin_addr.S_un.S_addr = inet_addr(c_ip);
	sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	//设置socket为阻塞
	ioctlsocket(sock, FIONBIO, &Opt);
	if (sock == INVALID_SOCKET) {
		cout << "INFO—————error——————client create socket" << endl;
		WSACleanup();
		return 0;
	}
	else {
		cout << "INFO—————success——————client create socket " << endl;
		return 1;
	}
}
//创建连接
bool tftp::bind_socket() {
	int nrc = bind(sock, (LPSOCKADDR)&client_IP, sizeof(client_IP));
	if (nrc == SOCKET_ERROR) {
		cout << "INFO—————error——————client socket bind " << endl;
		closesocket(sock);
		WSACleanup();
		return 0;
	}
	else {
		cout << "INFO—————success——————client socket bind" << endl;
		return 1;
	}
}
//文件操作
bool tftp::log_open() {
	tftp_log = fopen("tftp_error.log", "a");
	if (tftp_log == NULL) {
		cout << "INFO—————error——————open log file" << endl;
		return 0;
	}
	else {
		cout << "INFO—————success——————open log file" << endl;
		return 1;
	}
}
void tftp::log_write() {
	for (int i = 0; i < 512; i++) {
		if (logbuf[i] == '\n') {
			logbuf[i] = ' ';
			break;
		}
	}
	fwrite(logbuf, strlen(logbuf), 1, tftp_log);
}

bool tftp::upload(char* filename) {
	int ack_wait, size;
	sockaddr_in sender;
	cout << "choose the file format(1.netascii 2.octet)-";
	cin >> choose;
	cin.get();
	FILE* fp = NULL;
	if (choose == 1) {
		fp = fopen(filename, "r");
	}
	else {
		fp = fopen(filename, "rb");
	}
	if (fp == NULL) {
		cout << "INFO—————error——————File not exists!" << endl;
		time(&rawTime);
		info = localtime(&rawTime);
		sprintf(logbuf, "%s Error: upload %s, mode: %s, %s\n", asctime(info), filename, choose == 1 ? ("netascii") : ("octet"), "File not exists!");
		log_write();
		return 0;
	}

	send_packet.op = htons(WRQ);
	//temp用来记录文件名的位置
	int temp = 0;
	for (int i = 0; i < strlen(filename); i++) {
		if (filename[i] == '//') {
			temp = i + 1;
		}
	}
	//直接输入文件名字的话temp =0
	memset(send_packet.data, 0, sizeof(send_packet.data));
	if (choose == 1) {
		sprintf(send_packet.filename, "%s%c%s%c", filename + temp, 0, "netascii", 0);
	}
	else {
		sprintf(send_packet.filename, "%s%c%s%c", filename + temp, 0, "octet", 0);
	}
	int count = 0;
	for (count = 0; count < PKT_MAX_RXMT; count++) {
		sendto(sock, (char*)&send_packet, sizeof(tftp_message), 0, (struct sockaddr*)&server_IP, IP_len);
		cout << endl << "=========================" << endl << "Establish connection and send first data block. " << endl << "resend times: " << count << endl << "=========================" << endl;
		for (ack_wait = 0; ack_wait < PKT_RCV_TIMEOUT; ack_wait += 5) {
			size = recvfrom(sock, (char*)&recv_packet, sizeof(tftp_message), 0, (struct sockaddr*)&sender, (int*)&IP_len);
			if (size >= 4 && recv_packet.op == htons(ACK) && recv_packet.num == htons(0)) {
				time(&rawTime);
				info = localtime(&rawTime);
				sprintf(logbuf, "%s !!!!!!success: Establish connection %s,mode:%s, %s\n", asctime(info), filename, choose == 1 ? ("netascii") : ("octet"), "send first data block");
				log_write();
				break;
			}
			Sleep(5);
		}
		if (ack_wait < PKT_RCV_TIMEOUT) {
			break;
		}
	}
	if (count >= PKT_MAX_RXMT) {
		cout << "INFO—————error——————could not receive from server" << endl;
		time(&rawTime);
		info = localtime(&rawTime);
		sprintf(logbuf, "%s Error: upload %s,mode:%s, %s\n", asctime(info), filename, choose == 1 ? ("netascii") : ("octet"), "Could not receive from server!");
		log_write();
		fclose(fp);
		return 0;
	}
	cout << "INFO—————success——————get first packet" << endl;
	uint16_t block_num = 1;
	transbyte = 0;
	int read_size;
	start = clock();
	do {
		memset(send_packet.data, 0, sizeof(send_packet.data));
		send_packet.op = htons(DATA);
		send_packet.num = htons(block_num);
		read_size = fread(send_packet.data, 1, max_data, fp);
		transbyte += read_size;
		for (count = 0; count < PKT_MAX_RXMT; count++) {
			cout << endl << "=========================" << endl << "send number:" << block_num << " data block. " << endl << "resend times: " << count << endl << "=========================" << endl;
			sendto(sock, (char*)&send_packet, read_size + 4, 0, (struct sockaddr*)&sender, IP_len);
			for (ack_wait = 0; ack_wait < PKT_RCV_TIMEOUT; ack_wait += 5) {
				size = recvfrom(sock, (char*)&recv_packet, sizeof(tftp_message), 0, (struct sockaddr*)&sender, (int*)&IP_len);
				if (size >= 4 && recv_packet.op == htons(ACK) && recv_packet.num == htons(block_num)) {
					time(&rawTime);
					info = localtime(&rawTime);
					sprintf(logbuf, "%s success: upload %s,mode:%s, %s %d %s\n", asctime(info), filename, choose == 1 ? ("netascii") : ("octet"), "send ", block_num ," data block");
					log_write();
					break;
				}
				Sleep(5);
			}
			if (ack_wait < PKT_RCV_TIMEOUT) {
				break;
			}
			//如果ack_wait大于PKT的话说明发送超时，需要继续循环进行发送
		}
		if (count >= PKT_MAX_RXMT) {
			cout <<endl << "INFO—————error——————can't receive from server" << endl;
			time(&rawTime);
			info = localtime(&rawTime);
			sprintf(logbuf, "%s Error: upload %s,mode:%s, %s\n", asctime(info), filename, choose == 1 ? ("netascii") : ("octet"), "Could not receive from server.");
			log_write();
			fclose(fp);
			return 0;
		}
		//传输下一个数据块
		block_num++;
	} while (read_size == max_data);
	end = clock();
	cout << endl << "INFO—————success——————upload file successfully" << endl;
	fclose(fp);
	//计算耗时
	consumetime = ((double)(end - start)) / CLK_TCK;
	cout << endl << "******************************" << endl << "file size: " << transbyte << " Bytes" << endl << "time: " << consumetime << " s" << endl;
	cout << "upload speed:" << transbyte / consumetime / 1024 << " kB/s" << endl << "******************************" << endl;
	time(&rawTime);
	info = localtime(&rawTime);
	sprintf(logbuf, "%s !!!!!!success: upload file successfully: upload %s,mode:%s \n",asctime(info), filename, choose == 1 ? ("netascii") : ("octet"));
	log_write();
	return 1;
}
bool tftp::download(char* remotefname, char* localfname) {
	int ack_wait, size;
	sockaddr_in sender;
	cout << "choose the file format(1.netascii 2.octet)-";
	cin >> choose;
	cin.get();
	FILE* fp = NULL;
	if (choose == 1) {
		fp = fopen(localfname, "w");
	}
	else {
		fp = fopen(localfname, "wb");
	}
	if (fp == NULL) {
		cout << "INFO—————error——————open/create file" << endl;
		time(&rawTime);
		info = localtime(&rawTime);
		sprintf(logbuf, "%s Error: download %s, mode: %s, %s\n", asctime(info), localfname, choose == 1 ? ("netascii") : ("octet"), "open/create file error");
		log_write();
		return 0;
	}

	//发送初始数据包
	memset((char*)&send_packet, 0, sizeof(tftp_message));
	send_packet.op = htons(RRQ);
	if (choose == 1) {
		sprintf(send_packet.filename, "%s%c%s%c", remotefname, 0, "netascii", 0);
	}
	else {
		sprintf(send_packet.filename, "%s%c%s%c", remotefname, 0, "octet", 0);
	}
	//发送第一个RRQ的时候也会发生超时的情况
	int count = 0;
	for (count = 0; count < PKT_MAX_RXMT; count++) {
		int err = sendto(sock, (char*)&send_packet, sizeof(tftp_message), 0, (struct sockaddr*)&server_IP, IP_len);
		cout << endl << "=========================" << endl << "Establish connection and get first data block. " << endl << "resend times: " << count << endl << "=========================" << endl;
		for (ack_wait = 0; ack_wait < PKT_RCV_TIMEOUT; ack_wait += 5) {
			//memset((char*)&recv_packet, 0, sizeof(recv_packet));
			size = recvfrom(sock, (char*)&recv_packet, sizeof(tftp_message), 0, (struct sockaddr*)&sender, (int*)&IP_len);
			fwrite(recv_packet.data, size - 4, 1, fp);
			if (size >= 4 && recv_packet.op == htons(DATA) && recv_packet.num == htons(1)) {
				time(&rawTime);
				info = localtime(&rawTime);
				sprintf(logbuf, "%s !!!!!!success: Establish connection %s,mode:%s, %s\n", asctime(info), remotefname, choose == 1 ? ("netascii") : ("octet"), "get first data block");
				log_write();
				break;
			}
			Sleep(5);
		}
		if (ack_wait < PKT_RCV_TIMEOUT) {
			break;
		}
	}
	if (count >= PKT_MAX_RXMT) {
		cout << "INFO—————error——————could not receive from server" << endl;
		time(&rawTime);
		info = localtime(&rawTime);
		sprintf(logbuf, "%s Error: download %s,mode:%s, %s \n", asctime(info), remotefname, choose == 1 ? ("netascii") : ("octet"), "Could not receive from server!");
		log_write();
		fclose(fp);
		return 0;
	}
	cout << "INFO—————success——————get first packet" << endl;

	//接受数据包
	transbyte = 0;
	uint16_t block = 1;
	start = clock();
	do {
		for (count = 0; count < PKT_MAX_RXMT; count++) {
			send_packet.op = htons(ACK);
			send_packet.num = htons(block);
			int err = sendto(sock, (char*)&send_packet, sizeof(tftp_message), 0, (struct sockaddr*)&sender, IP_len);
			cout << endl << "=========================" << endl << "get number:" << block << " data block. " << endl << "reget times: " << count << endl << "=========================" << endl;
			for (ack_wait = 0; ack_wait < PKT_RCV_TIMEOUT; ack_wait += 5) {
				size = recvfrom(sock, (char*)&recv_packet, sizeof(tftp_message), 0, (struct sockaddr*)&sender, (int*)&IP_len);
				if (size >= 4 && recv_packet.op == htons(DATA) && recv_packet.num == htons(block+1)) {
					fwrite(recv_packet.data, size - 4, 1, fp);
					time(&rawTime);
					info = localtime(&rawTime);
					sprintf(logbuf, "%s success: download %s,mode:%s, %s %d %s\n", asctime(info), remotefname, choose == 1 ? ("netascii") : ("octet"), "get " , block , " data block");
					log_write();
					break;
				}
				Sleep(5);
			}
			if (ack_wait < PKT_RCV_TIMEOUT) {
				break;
			}
			//如果ack_wait大于PKT的话说明发送超时，需要继续循环进行发送
		}
		if (count >= PKT_MAX_RXMT) {
			cout << endl << "INFO—————error——————can't receive from server" << endl;
			time(&rawTime);
			info = localtime(&rawTime);
			sprintf(logbuf, "%s Error: download %s,mode:%s, %s\n", asctime(info), remotefname, choose == 1 ? ("netascii") : ("octet"), "Could not receive from server.");
			log_write();
			fclose(fp);
			return 0;
		}
		transbyte += (size - 4);
		block++;
	} while (size == max_data + 4);
	end = clock();
	consumetime = ((double)(end - start)) / 1000;
	cout << endl << "******************************" << endl << "file size: " << transbyte << " Bytes" << endl << "time: " << consumetime << " s" << endl;
	cout << "download speed:" << transbyte / consumetime / 1024 << " kB/s" << endl << "******************************" << endl;
	time(&rawTime);
	info = localtime(&rawTime);
	sprintf(logbuf, "%s !!!!!!success: download file successfully: download from %s to %s,mode:%s \n",asctime(info), remotefname, localfname, choose == 1 ? ("netascii") : ("octet"));
	log_write();
	fclose(fp);
	return 1;
}
int main() {
	tftp inter;
	char s_ip[20], c_ip[20];
	cout << "Input server IP:";//10.12.174.93
	cin >> s_ip;
	cin.get();
	cout << "Input client IP:";//10.12.173.220
	cin >> c_ip;
	cin.get();
	if (inter.init_Winsock() && 
		inter.create_socket(s_ip,c_ip) && 
		inter.bind_socket() && 
		inter.log_open()) {
		char buf[256];
		int flag;
		
		while (1) {
			string str;
			cout << endl  << "Please choose what do you want to do(1.upload 2.download, 3.exit)-";
			cin >> flag;
			cin.get();
			if (flag == 1) {
				char* temp = new char;
				cout << "Input filename:";
				cin >> str;
				strcpy(temp, str.c_str());
				cin.get();
				inter.upload(temp);
			}
			else if (flag == 2) {
				string str1, str2;
				char* temp1 = new char;
				char* temp2 = new char;
				cout << "Input remote filename:";
				cin >> str1;
				cin.get();
				cout << "Input local filename:";
				cin >> str2;
				cin.get();
				strcpy(temp1, str1.c_str());
				strcpy(temp2, str2.c_str());
				inter.download(temp1, temp2);
			}
			else if (flag == 3) {
				cout << "good bye!" << endl;
				fclose(inter.tftp_log);
				break;
			}
		}
	}

}
