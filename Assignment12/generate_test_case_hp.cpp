#include <iostream>
#include <bits/stdc++.h>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sstream>
#include <tuple>
#include <time.h>
using namespace std;

int main(){
	srand (time(NULL));
	int n=2000-1;
	int main_memory = 1000;
	int block_size = 2;
	int inst_prob=50;
	int data_variation=100;
	cout << "16\n" << block_size << "\n4\n" << "100\n" ;
	int last = rand() % main_memory;
	if(rand()%2==0) cout << last << " R " << endl;
	else cout << last << " W " << rand()%data_variation << endl;

	while(n-->0){
		int type = rand()%2;
		// int type = 1;
		int p1 = rand()%100;
		int address;
		if(p1<inst_prob){
			int t1 = last/block_size;
			address = t1*block_size + rand()%block_size;
		}
		else{
			address = rand() % main_memory;
		}
		last=address;
		if(type==0){
			cout << address << " R " << endl;
		}
		else{
			cout << address << " W " << rand()%data_variation << endl;
		}
	}
}