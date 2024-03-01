#pragma once
#include "struct.cpp"
#include "Cantine.h"
const string MAX_DAY = "30000000";
const string MAX_TIME = "23595959";
using namespace std;
void HeadAdjust(int s, int m, Pnode* L, int* index) {
	Pnode rc = L[s];
	int x = index[s];
	for (int j = 2 * s; j <= m; j *= 2) {
		if (j < m) {
			if (atoll(L[j].date_p.c_str()) < atoll(L[j + 1].date_p.c_str())) {
				j++;
			}
			else if (atoll(L[j].date_p.c_str()) == atoll(L[j + 1].date_p.c_str())) {
				if (atoll(L[j].time_p.c_str()) < atoll(L[j + 1].time_p.c_str())) {
					j++;
				}
			}
		}
		if (atoll(rc.date_p.c_str()) > atoll(L[j].date_p.c_str())) {
			break;
		}
		else if (atoll(rc.date_p.c_str()) == atoll(L[j].date_p.c_str())) {
			if (atoll(rc.time_p.c_str()) >= atoll(L[j].time_p.c_str())) {
				break;
			}
		}
		index[s] = index[j];
		L[s] = L[j];
		s = j;
	}
	L[s] = rc;
	index[s] = x;
}
void CreateHeap(Pnode* L, int* index,int unit) {
	int n = unit;
	for (int i = n / 2; i > 0; i--) {
		HeadAdjust(i, n, L, index);
	}
}
void HeapSort(Pnode* L, int* index,int unit) {
	CreateHeap(L, index,unit);
	for (int i = unit; i > 1; i--) {
		Pnode x;
		int y;
		x = L[1];
		L[1] = L[i];
		L[i] = x;
		y = index[i];
		index[i] = index[1];
		index[1] = y;
		HeadAdjust(1, i - 1, L, index);
	}
}
void input(int i, Pnode* L) {
	if (L[1].next != NULL) {
		L[1].card_p = L[1].next->card_p;
		L[1].date_p = L[1].next->date_p;
		L[1].money_p = L[1].next->money_p;
		L[1].time_p = L[1].next->time_p;
		L[1].Can = L[1].next->Can;
		L[1].next = L[1].next->next;
	}
	else {
		Pnode ca;
		ca.date_p = MAX_DAY;
		ca.time_p = MAX_TIME;
		ca.next = NULL;
		L[1] = ca;
	}
}
Pnode* merge_sort(Win* can_win,int unit) {
	ofstream mout("out//M-mergesort.txt");
	Pnode* final = new Pnode;
	Pnode* bb = new Pnode;
	bb = final;
	Pnode* L = new Pnode[unit + 1];
	int* index = new int[unit + 1];

	for (int i = 1; i <= unit; i++) {
		Pnode* ss = new Pnode;
		ss = can_win[i - 1].next->next;
		if (ss != NULL) {
			L[i].date_p = ss->date_p;
			L[i].time_p = ss->time_p;
			L[i].card_p = ss->card_p;
			L[i].money_p = ss->money_p;
			L[i].Can = ss->Can;
			L[i].state = ss->state;
			L[i].next = ss->next;
		}
		else {
			L[i].date_p = MAX_DAY;
			L[i].time_p = MAX_TIME;
			L[i].next = NULL;
		}
		index[i] = i;
	}
	HeapSort(L, index,unit);
	while (L[1].date_p != MAX_DAY) {
		Pnode* aa = new Pnode;
		aa->card_p = L[1].card_p;
		aa->date_p = L[1].date_p;
		aa->money_p = L[1].money_p;
		aa->time_p = L[1].time_p;
		aa->state = L[1].state;
		aa->Can = L[1].Can;
		bb->next = aa;
		aa->front = bb;
		bb = bb->next;
		mout << L[1].date_p << L[1].time_p << " " << L[1].card_p << " " << L[1].Can << " " << L[1].money_p << endl;
		input(index[1], L);
		HeapSort(L, index, unit);
	}
	bb->next = NULL;
	return final;
}