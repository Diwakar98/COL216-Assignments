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
	int n=3000;
	cout << "256\n" << "16\n" << "4\n" << "50\n" ;
	while(n-->0){
		int type = rand()%2;
		// int type = 1;
		if(type==0){
			cout << rand()%50000 << " R " << endl;
		}
		else{
			cout << rand()%50000 << " W " << rand()%1000 << endl;
		}
	}
}