#include <iostream>
#include <bits/stdc++.h>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sstream>
using namespace std;

ifstream file1;		//Input file
ofstream file2;		//Output file


//to convert a binary to decimal
long long int todecimal(string s){
	long long int n=0;
	int c=0;
	for(int i=s.size()-1; i>=0; i--){
		if(s[i]!='.'){
			if(s[i]=='1') n += pow(2,c);
			c++;
		}
	}
	return n;
}

//to convert a decimal to binary, used to convert back exponent to binary 
string tobinary(long long int n){
	string s="";
	if(n==0) return "00000000";
	while(n>0){
		if(n%2==0){
			s = "0"+s;
		}
		else{
			s = "1"+s;
		}
		n=n/2;
	}
	while(s.size()<8){
		s = "0"+s;
	}
	return s;
}

//adding two floating binary numbers
string binarysum(string s1,string s2){
	string ans="";
	int carry=0;
	int sum=0;
	int len = s1.size();
	for(int i=len-1; i>=0; i--){
		if(s1[i]=='.' && s2[i]=='.'){ans = "." + ans; continue;}
		int d1 = s1[i]-48;
		int d2 = s2[i]-48;
		sum = d1^d2^carry;
		carry = d1&d2 | d1&carry | d2&carry;
		ans = to_string(sum) + ans;
	}
	if(carry==1) ans = to_string(carry) + ans;
	return ans;
}

//find onescomplement in case number any negative.
string onescomplement(string s){
	string ans = "";
	for(int i=0; i<s.size(); i++){
		if(s[i]=='.') ans= ans+".";
		else if(s[i]=='0') ans = ans + "1";
		else ans = ans + "0";
	}
	return ans;
}

//function to add two numbers given their sign bit, fraction, exponent
string addsignificand(string frac1,string frac2,string sign1,string sign2,string &sign){
	string sum="";
	// string one = "0.00000000000000000000001";
	string one = "0.0000000000000000000000000000001";
	if(sign1[0]=='0' && sign2[0]=='0'){ //both are positive numeber
		sign="0";
		sum = binarysum(frac1,frac2);
	}
	else if(sign1[0]=='0' && sign2[0]=='1'){ //first is positive and second is negative
		if(todecimal(frac1) < todecimal(frac2)){
			sign = "1";
			sum = binarysum(frac2,binarysum(one,onescomplement(frac1)));
		}
		else{
			sign = "0";
			sum = binarysum(frac1,binarysum(one,onescomplement(frac2)));
		}
		if(sum[0]=='1' && sum.size()>25) sum = sum.substr(1);
	}
	else if(sign1[0]=='1' && sign2[0]=='0'){ //first is negative and second is positive
		
		if(todecimal(frac1) < todecimal(frac2)){
			sign = "0";
			sum = binarysum(binarysum(one,onescomplement(frac1)),frac2);
		}
		else{
			sign = "1";
			sum = binarysum(frac1,binarysum(one,onescomplement(frac2)));
		}
		if(sum[0]=='1' && sum.size()>25) sum = sum.substr(1);
	}
	else if(sign1[0]=='1' && sign2[0]=='1'){// both are negative
		sign = "1";
		sum = binarysum(frac1,frac2);
	}
	if(frac1.compare("0.0000000000000000000000000000000")==0) return frac2;
	if(frac2.compare("0.0000000000000000000000000000000")==0) return frac1;
	return sum;
}

//normalizing the result
void normalize(string &s,long long int &dec_exp){
	string s1 = "";
	if(s[0]=='1' && s[1]=='.') return ;
	else if(s[0]=='0' && s[1]=='.'){
		// s1 = s[2]+"."+s.substr(3)+"0";
		s1 += s[2];
		s1 += ".";
		s1 += s.substr(3);
		s1 += "0";
		dec_exp--;
	}
	else if(s[0]=='1' && s[2]=='.'){
		// s1 = "1."+s[1]+s.substr(3);
		s1 = "1.";
		s1 += s[1]+s.substr(3);
		dec_exp++;
	}
	s = s1;
}

//check if normalised
bool isnormalized(string s){
	if(s[0]=='1' && s[1]=='.') return true;
	else return false;
}

//round the given number
void round(string &s){
	string s1="";
	// string one = "0.00000000000000000000001";
	string one1 = "0.0000000000000000000000100000000";
	string one2 = "0.0000000000000000000000000000001";
	if(s.size()>33){
		if(s[33]=='1'){
			s1 = binarysum(s.substr(0,33),one2);
		}
		else{
			s1 = s.substr(0,33);
		}
		s=s1;
	}
	if(s[25]=='1'){
		s1 = binarysum(s,one1);
		s = s1;
	}
}

void appendzero(string &s1){
	int len=33-s1.size();
	for(int i=0; i<len; i++) s1 += "0";

	s1 = s1.substr(0,33);
}

//add two number given their raw form
void add(string num1,string num2){

	int cycles = 0;
	string sign1 = num1.substr(0,1);
	string sign2 = num2.substr(0,1);
	string exp1 = num1.substr(1,8);
	string exp2 = num2.substr(1,8);
	string frac1 = num1.substr(9,23);
	string frac2 = num2.substr(9,23);

	long long int dec_exp1 = todecimal(exp1);
	long long int dec_exp2 = todecimal(exp2);

	string temp_frac1 = frac1, temp_frac2 = frac2;
	int temp_dec_exp1 = dec_exp1, temp_dec_exp2 = dec_exp2;


	if(dec_exp1==255 && frac1.compare("00000000000000000000000")==0 && sign1[0]=='0' && dec_exp2==255 && frac2.compare("00000000000000000000000")==0 && sign2[0]=='1'){
		// (+Inf) + (-Inf) = NaN
		file2 << "NaN" << endl;
		return;
	}
	if(dec_exp1==255 && frac1.compare("00000000000000000000000")==0 && sign1[0]=='1' && dec_exp2==255 && frac2.compare("00000000000000000000000")==0 && sign2[0]=='0'){
		// (-Inf) + (+Inf) = NaN
		file2 << "NaN" << endl;
		return;
	}

	//check if any number is NaN
	if((dec_exp1==255 && frac1.compare("00000000000000000000000")!=0) || (dec_exp2==255 && frac2.compare("00000000000000000000000")!=0)){
		file2 << "NaN" << endl;
		return;
	}

	if((dec_exp1==255 && frac1.compare("00000000000000000000000")==0) || (dec_exp2==255 && frac2.compare("00000000000000000000000")==0)) {
		//(+Inf) + (+Inf) = InF
		//(-Inf) + (-Inf) = Inf
		//(+Inf) +- n = Inf
		//(-Inf) +- n = Inf
		file2 << "INF" << endl;
		return;
	}

	int shift = 0;


	//shifting exponent
	if(dec_exp1<dec_exp2){
		shift = dec_exp2 - dec_exp1;
		dec_exp1 = dec_exp2;
		string frac1_temp = "0.";
		for(int i=0; i<shift-1; i++) frac1_temp += "0";
		frac1_temp += "1" + frac1;
		frac1 = frac1_temp;
		frac2 = "1." + frac2;
	}
	else if(dec_exp1>dec_exp2){
		shift = dec_exp1 - dec_exp2;
		dec_exp2 = dec_exp1;
		string frac2_temp = "0.";
		for(int i=0; i<shift-1; i++) frac2_temp += "0";
		frac2_temp += "1" + frac2;
		frac2 = frac2_temp;
		frac1 = "1." + frac1;
	}
	else{
		frac1 = "1." + frac1;
		frac2 = "1." + frac2;
	}
	if(temp_frac1.compare("00000000000000000000000")==0 && temp_dec_exp1==0){
		frac1 = "0.00000000000000000000000";
	}
	if(temp_frac2.compare("00000000000000000000000")==0 && temp_dec_exp2==0){
		frac2 = "0.00000000000000000000000";
	}

	cycles++;	//Cycle for shifting the exponents.

	appendzero(frac1);
	appendzero(frac2);

	string finalsign="";

	//adding significand
	string sum = addsignificand(frac1,frac2,sign1,sign2,finalsign);

	cycles++;	//Cycle for adding significands.



	//normalizing and rounding
	do{
		if(sum.compare("0.0000000000000000000000000000000")==0){
			dec_exp1 = 0;
			cycles=max(cycles+2,4);
			break;
		}

		while(!isnormalized(sum)){
			normalize(sum,dec_exp1);
		}

		cycles++; //Cycle for normalisation.

		if(dec_exp1>=255){ //check if overflow of exponent
			file2 << "OVERFLOW" << endl;
			return;
		}
		else if(dec_exp1 <=0){ //check if underflow of exponent
			file2 << "UNDERFLOW" << endl;
			return;
		}

		round(sum);	// rounding the sum.

		cycles++; //Cycle for rounding.


	}while(!isnormalized(sum));

	string str_exp = tobinary(dec_exp1);	
	string result = finalsign + str_exp + sum.substr(2,23);

	file2 << result << " " << cycles << endl;
}

int main(){

	file1.open("input.txt");
	file2.open("output.txt");
	string num1,num2;
	while(file1 >> num1 && file1 >> num2){ //reading the numbers in num1 and num2.
		add(num1,num2);
	}
}