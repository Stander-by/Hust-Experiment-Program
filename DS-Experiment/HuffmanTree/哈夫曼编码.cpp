#include<iostream>
#include<string>
#include<cstring>
using namespace std;
typedef char** HuffmanCode;
//用结构体存储二叉树的每个节点
typedef struct {
	int weight;
	int parent, lchild, rchild;
	string s;
}HTNode;
//建立哈夫曼树时进对权重最小的节点进行选择
void select(HTNode* HT, int n, int& s1, int& s2) {
	int i, weight1 = 0, weight2 = 0;
	for (i = 1; i < n; i++) {
		if (HT[i].parent == 0) {
			if (weight1 == 0 && weight2 == 0) {
				weight1 = HT[i].weight;
				s1 = i;
			}
			else if (weight1 != 0 && weight2 == 0) {
				if (HT[i].weight < weight1) {
					weight2 = weight1;
					weight1 = HT[i].weight;
					s2 = s1;
					s1 = i;
				}
				else {
					weight2 = HT[i].weight;
					s2 = i;
				}
			}
			else if (HT[i].weight < weight1) {
				weight2 = weight1;
				weight1 = HT[i].weight;
				s2 = s1;
				s1 = i;
			}
			else if (HT[i].weight > s1 && HT[i].weight < s2) {
				weight2 = HT[i].weight;
				s2 = i;
			}
		}
	}
}
//给每个叶子节点进行权重赋值并实现中文和英文的区别
int Weight(HTNode* HT, string& text, int n) {
	int num = 0, i, j, flag, flag1 = 0;
	string cd;
	for (i = 1; i <= n; i++) {
		HT[i].weight = 0;
	}
	for (i = 0; i < n; ) {
		for (j = 1; j <= n; j++) {
			if (text[i] >= 0 && text[i] <= 127) {
				flag = 0;
				if (HT[j].s.empty()) {
					HT[j].s = text[i];
					HT[j].weight++;
					num++;
					break;
				}
				if (HT[j].s[0] == text[i]) {
					HT[j].weight++;
					break;
				}
			}
			else {
				flag = 1;
				cd += text[i];
				cd += text[i + 1];
				if (HT[j].s.empty()) {
					HT[j].s = cd;
					HT[j].weight++;
					num++;
					break;
				}
				if (HT[j].s == cd) {
					HT[j].weight++;
					break;
				}
			}
			cd.clear();
		}
		cd.clear();
		if (flag) {
			i += 2;
		}
		else {
			i++;
		}
	}
	return num;
}
//创建哈夫曼树
HTNode* CreateHuffmanTree(string text, int &n) {
	if (n <= 1) return NULL;
	int m, i, s1, s2;
	HTNode* HT1 = new HTNode[n + 1];
	n = Weight(HT1, text, n);
	m = 2 * n - 1;
	HTNode* HT = new HTNode[m + 1];
	for (i = 1; i <= n; i++) {
		HT[i].weight = HT1[i].weight;
		HT[i].s = HT1[i].s;
	}
	delete[]HT1;
	for (i = 1; i <= m; i++) {
		HT[i].parent = 0;
		HT[i].lchild = 0;
		HT[i].rchild = 0;
		if (i > n) {
			HT[i].weight = 0;
		}
	}
	for (i = n + 1; i <= m; i++) {
		select(HT, i, s1, s2);
		HT[s1].parent = i;
		HT[s2].parent = i;
		HT[i].lchild = s1;
		HT[i].rchild = s2;
		HT[i].weight = HT[s1].weight + HT[s2].weight;
	}
	
	return HT;
}
//创建哈夫曼编码
HuffmanCode CreateHuffmanCode(HTNode* HT, int leaf) {
	HuffmanCode HC = new char* [leaf + 1];
	char* cd = new char[leaf];
	cd[leaf - 1] = '\0';
	int start, c, f, j;
	for (int i = 1; i < leaf + 1; i++) {
		start = leaf - 1;
		c = i;
		f = HT[i].parent;
		while (f != 0) {
			--start;
			if (HT[f].lchild == c) {
				cd[start] = '0';
			}
			else {
				cd[start] = '1';
			}
			c = f;
			f = HT[f].parent;
		}
		HC[i] = new char[leaf];
		for (j = 0; start <= leaf - 1; j++, start++) {
			HC[i][j] = cd[start];
		}
	}
	delete cd;
	return HC;
}
//选择根节点
int selectroot(HTNode* HT, int leaf) {
	int i = leaf + 1;
	int sum = 2 * leaf - 1;
	while (i <= sum) {
		if (HT[i].parent == 0) {
			return i;
		}
		i++;
	}
}
//编码
string encode(string text, int length, int leaf, HuffmanCode HC, HTNode* HT) {
	int i, j;
	string code;
	for (i = 0; i < length; i++) {
		for (j = 1; j <= leaf; j++) {
			if (text[i] == HT[j].s[0]) {
				code += HC[j];
				break;
			}
		}
	}
	return code;
}
//解码
string decode(string text, int length, int leaf, HTNode* HT, int rootindex) {
	int  i = 0, j;
	string code;
	if (text.empty()) {
		cout << "无法解码" << endl;
		return code;
	}
	j = rootindex;
	while (i < length) {
		if (HT[j].lchild && HT[j].rchild) {
			if (text[i] == '0') {
				j = HT[j].lchild;
			}
			else {
				j = HT[j].rchild;
			}
			i++;
		}
		else {
			code += HT[j].s;

			j = rootindex;
		}
	}
	code += HT[j].s;
	return code;
}
//中序非递归输出二叉树
void ReInorderTraverse(HTNode* HT, int leaf, int index) {
	int m = leaf * 2 - 1;
	if (index != 0) {
		ReInorderTraverse(HT,leaf, HT[index].lchild);
		if (HT[index].s.empty()) {
			cout <<'('<< "NULL"<<')'<<" ";
		}
		else {
			cout << '(' << HT[index].s << ')' << " ";
		}
		ReInorderTraverse(HT, leaf, HT[index].rchild);
	}
}
//中序递归输出二叉树
void IteInOrderTraverse(HTNode* HT, int index, int num) {
	int m = 2 * num - 1, top = -1;
	int* stack = new int[m];
	while (index != 0 || top != -1) {
		if (index) {
			stack[++top] = index;
			index = HT[index].lchild;
		}
		else {
			if (HT[stack[top]].s.empty()) {
				cout << "NULL ";
			}
			else {
				cout << "(" << HT[stack[top]].s << ")" << ' ';
			}
			index = HT[stack[top--]].rchild;
		}
	}
}
//计算每个叶子节点使用频率
void frequence(HTNode* HT, int leaf) {
	for (int i = 1; i <= leaf; i++) {
		cout << "--" << i << "--" << "//" << HT[i].s << "//" << ",次数：" << HT[i].weight << endl;
	}
}
//三叉链表表示哈夫曼树
void Trilinkedlist(HTNode* HT, HuffmanCode HC, int leaf) {
	int m = 2 * leaf - 1;
	for (int i = 1; i <= leaf; i++) {
		cout << "序号:" << i << "--" << "W" << HT[i].weight << "--" << "//P" << HT[i].parent << "//L" << HT[i].lchild << "//R" << HT[i].rchild << "//" << "==>" << HC[i] << endl;
	}
	for (int j = leaf + 1; j <= m; j++) {
		cout << "序号:" << j << "--" << "W" << HT[j].weight << "--" << "//P" << HT[j].parent << "//L" << HT[j].lchild << "//R" << HT[j].rchild << "//" << endl;
	}
}
//计算压缩率
void compress(HTNode* HT, HuffmanCode HC, int leaf, string text) {
	float com1 = 0, com2 = 0;
	string str1;
	for (int i = 1; i <= leaf; i++) {
		com1 += sizeof(HT[i].s);
		com2 += sizeof(HC[i]);
	}
	cout << "理论压缩率为:" << com2 / com1 << endl;
	int length1 = text.length();
	str1 = encode(text, length1, leaf, HC, HT);
	int length2 = str1.length();
	cout << "样例压缩率:" << float(length1) / float(length2) << endl;
}
int main() {
	int n = 0, n2 = 0, n3 = 0, line = 0, i = 0, j = 0;
	string text, text1, code, deco, text2;
	cout << "输入行数:";
	cin >> line;
	cin.ignore();
	cout << "输入文本:";
	while (i < line) {
		getline(cin, text2);
		text += text2;
		if (i != line - 1) {
			text += '\n';
		}
		i++;
	}
	n = text.length();
	cout << "构造HuffmanTree:"<<endl;
	HTNode* HT = CreateHuffmanTree(text, n);
	HuffmanCode HC = CreateHuffmanCode(HT, n);
	int index = selectroot(HT, n);
	Trilinkedlist(HT, HC, n);
	cout << "各根节点使用频率:"<<endl;
	frequence(HT, n);
	cout << "中序遍历:";
	ReInorderTraverse(HT, n, index);
	cout << endl;
	cout << "输入待编码的文本:"<<endl;
	cout << "输入行数:";
	cin >> line;
	cout << "输入文本:";
	while (j < line) {
		getline(cin, text2);
		text1 += text2;
		if (j != line - 1) {
			text1 += '\n';
		}
		j++;
	}
	getline(cin, text1);
	n2 = text1.length();
	code = encode(text1,n2, n, HC, HT);
	cout << "编码结果:"<<endl;
	cout << code << endl;
	n3 = code.length();
	cout << "解码结果为：";
	deco = decode(code, n3, n, HT, index);
	cout << deco << endl;
	compress(HT, HC, n, text1);
}