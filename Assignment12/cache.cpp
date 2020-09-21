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

const int LOW = 0;
const int HIGH = 1;

ifstream file1;				//Input file
ofstream file2,file3;		//Output file
int current_clock;
int hit,miss;
int no_of_access;
int no_of_read;
int no_of_read_hits;
int no_of_read_miss;
int no_of_write;
int no_of_write_hits;
int no_of_write_miss;
stringstream buffer;

struct block{ // Each Block or Line
	int tag, last_recent_access;
	bool valid, dirty;
	int priority;
	int block_size;
	bool first_access;
	vector<int> data; 	//Datas in a particular block
						//all have same index and tag bit
						//differs only in byte offset.
};

struct cache_set{ //Each Set 
	vector<block> _set;
};

int todecimal(string s){
	if(s.size()==0) return 0;
	int n=0;
	int c=0;
	for(int i=s.size()-1; i>=0; i--){
		if(s[i]=='1') n += pow(2,c);
		c++;
	}
	return n;
}

string tobinary(int n){ //returns 32 bit string corresponsing to a number.
	string s="";
	if(n==0) return "00000000000000000000000000000000"; 
	while(n>0){
		if(n%2==0){
			s = "0"+s;
		}
		else{
			s = "1" + s;
		}
		n=n/2;
	}
	while(s.size()<32){
		s = "0"+s;
	}
	return s;
}

//Initialize Cache with low priority and 0 valid bit and tag bit -1.
void initialize_cache(vector<cache_set> &cache, int associativity, int block_size, int no_of_set){
	for(int i=0; i<no_of_set; i++){
		vector<block> _set;
		for(int j=0; j<associativity; j++){
			struct block newblock;
			newblock.tag=-1;
			newblock.valid=0;
			newblock.dirty=0;
			newblock.priority = LOW;
			newblock.first_access=true;
			newblock.last_recent_access=0;
			newblock.block_size=block_size;
			vector<int> data(block_size);
			newblock.data = data;
			_set.push_back(newblock);
		}
		cache[i]._set = _set;
	}
}

//Print the statistics of the cache
void print_cache(vector<cache_set> &cache, int associativity, int no_of_set, int flag){
	//flag = 0 denotes printing as detailed simulation
	//flag = 1 denotes printing only final result.
	if(flag) file2 << "\n\t\t\t\tTag\t\tValid\tDirty\tAccess\tPriority\t\tData\n";
	else     file3 << "\n\t\t\t\tTag\t\tValid\tDirty\tAccess\tPriority\t\tData\n";
	for(int i=0; i<no_of_set; i++){
		if(flag) file2 << "Set " << i << ":\n";
		else file3 << "Set " << i << ":\n";
		for(int j=0; j<associativity; j++){
			vector<int> data = cache[i]._set[j].data;
			int tag = cache[i]._set[j].tag;
			int valid = cache[i]._set[j].valid;
			int dirty = cache[i]._set[j].dirty;
			int priority = cache[i]._set[j].priority;
			int lra = cache[i]._set[j].last_recent_access;
			if(flag){
				file2 << "\t\t" << j << ":\t\t" << tag << "\t\t" << valid << "\t\t" << dirty << "\t\t" << lra;
				if(priority) file2 << "\t\tHIGH";
				else file2 << "\t\tLOW  ";
				file2 << "\t\t[" << data[0];
				for(int k=1; k<data.size(); k++){
					file2 << "," << data[k];
				}
				file2 << "]" << endl;
			}
			else{
				file3 << "\t\t" << j << ":\t\t" << tag << "\t\t" << valid << "\t\t" << dirty << "\t\t" << lra;
				if(priority) file3 << "\t\tHIGH" ;
				else file3 << "\t\tLOW  " ;
				file3 << "\t\t["<< data[0];
				for(int k=1; k<data.size(); k++){
					file3 << "," << data[k];
				}
				file3 << "]" << endl;
			}
		}
	}
	if(flag){
		float hit_ratio = (float) hit / (float) (miss+hit);
		file2 << endl << "Cache Statistics" << endl;
		file2 << "Number of access: " << no_of_access << endl;
		file2 << "Number of reads: " << no_of_read << endl;
		file2 << "Number of read_hits: " << no_of_read_hits << endl;
		file2 << "Number of read_misses: " << no_of_read_miss << endl;
		file2 << "Number of write: " << no_of_write << endl;
		file2 << "Number of write_hits: " << no_of_write_hits << endl;
		file2 << "Number of write_misses: " << no_of_write_miss << endl;
		file2 << "Total Hit Count = " << hit << endl; 
		file2 << "Total Miss Count = " << miss << endl;
		file2 << "Hit Ratio = " << hit_ratio << endl;
	}
}

//Read from chache at given index;
vector<int> read_data(vector<cache_set> &cache, int address, int no_of_bits_in_byte_offset, int no_of_set, int associativity, int block_size){
	no_of_read++;
	int no_of_bits_in_index = (int)(log(no_of_set)/log(2.0));
	int no_of_bits_in_tag = 32 - no_of_bits_in_index - no_of_bits_in_byte_offset;

	string address_str = tobinary(address);

	string tag_str = address_str.substr(0,no_of_bits_in_tag);
	string index_str = address_str.substr(no_of_bits_in_tag,no_of_bits_in_index);
	string byte_offset_str = address_str.substr(no_of_bits_in_tag+no_of_bits_in_index);

	int tag_int = todecimal(tag_str);
	int index_int = todecimal(index_str);
	int byte_offset_int = todecimal(byte_offset_str);

	file3 << "address_str=[" << address_str << "]\ntag_str=[" << tag_str << "] index_str=[" << index_str << "] byte_offset=[" << byte_offset_str << "]\n";
	file3 << "INDEX=[" << index_int << "] TAG=[" << tag_int << "]\n";

	vector<block> &required_set= cache[index_int]._set;

	bool found = false;
	vector<int> data;
	for(auto &_block: required_set){ // check if already a valid block with tag is present -> HIT
		if(_block.tag==tag_int && _block.valid==1){
			hit++;
			no_of_read_hits++;
			file3 << "HIT\n";
			found = true;
			data = _block.data;
			file3 << "Address: " << address << " found in cache"<< endl;
			_block.last_recent_access = current_clock;
			if(_block.first_access){
				_block.first_access=false;
				_block.priority = LOW;
			}
			else{
				_block.priority = HIGH;
			}
			break;
		}
	}
	if(!found){
		no_of_read_miss++;
		miss++;
		file3 << "MISS\n";
		vector<int> data1(block_size);
		for(int i=0; i< block_size; i++) data1[i] = rand()%100; //Generating random data
		data = data1;
		file3 << "Read from Main Memory from address " << address << endl;
		int index_invalid = -1;
		bool found_invalid=false;
		int set_size = required_set.size();
		int farthest_accessed = current_clock;
		int index_of_farthest_accessed = -1;
		for(int i=0; i<set_size; i++){
			if(!required_set[i].valid){
				found_invalid=true;
				index_invalid=i;
				break;
			}
			if(required_set[i].last_recent_access<farthest_accessed){
				farthest_accessed = required_set[i].last_recent_access;
				index_of_farthest_accessed = i;
			}
		}
		if(found_invalid){ //If any block is invalid.
			required_set[index_invalid].data = data1;
			required_set[index_invalid].tag = tag_int;
			required_set[index_invalid].valid = 1;
			required_set[index_invalid].dirty = 0;
			required_set[index_invalid].last_recent_access = current_clock;
			required_set[index_invalid].first_access = true;
			required_set[index_invalid].priority = LOW;
		}
		else{
			//Otherwise Least Recent Used policy is used.
			if(required_set[index_of_farthest_accessed].dirty){ 
				int address1 = todecimal(tobinary(required_set[index_of_farthest_accessed].tag) + tobinary(index_int));
				address1 = address1 << no_of_bits_in_byte_offset;
				file3 << "Evict: Writing to Main Memory " << endl;
				//then evict and write to main memory;
			}
			required_set[index_of_farthest_accessed].data = data1;
			required_set[index_of_farthest_accessed].tag = tag_int;
			required_set[index_of_farthest_accessed].valid = 1;
			required_set[index_of_farthest_accessed].dirty = 0;
			required_set[index_of_farthest_accessed].last_recent_access = current_clock;
			required_set[index_of_farthest_accessed].first_access = true;
			required_set[index_of_farthest_accessed].priority = LOW;
		}
	}
	return data;
}

//Write to memory
void write_data(vector<cache_set> &cache, int address, int data, int no_of_bits_in_byte_offset, int no_of_set, int associativity, int block_size){
	no_of_write++;
	int no_of_bits_in_index = (int)(log(no_of_set)/log(2.0));
	int no_of_bits_in_tag = 32 - no_of_bits_in_index - no_of_bits_in_byte_offset;

	string address_str = tobinary(address);
	string tag_str = address_str.substr(0,no_of_bits_in_tag);
	string index_str = address_str.substr(no_of_bits_in_tag,no_of_bits_in_index);
	string byte_offset_str = address_str.substr(no_of_bits_in_tag+no_of_bits_in_index);

	file3 << "address_str=[" << address_str << "]\ntag_str=[" << tag_str << "] index_str=[" << index_str << "] byte_offset=[" << address_str.substr(no_of_bits_in_tag+no_of_bits_in_index) << "]\n";
	int tag_int = todecimal(tag_str);
	int index_int = todecimal(index_str);
	int byte_offset_int = todecimal(byte_offset_str);

	file3 << "INDEX=[" << index_int << "] TAG=[" << tag_int << "]\n";

	vector<block> &required_set = cache[index_int]._set;

	// print_cache(cache,associativity,no_of_set);
	bool found=false;
	for(auto &_block: required_set){ // check if already a valid block with same tag is present -> HIT
		if(_block.tag==tag_int && _block.valid==1){
			hit++;
			no_of_write_hits++;
			file3 << "HIT\n";
			found=true;
			(_block.data)[byte_offset_int] = data;
			_block.valid = 1;
			_block.dirty = 1;
			_block.last_recent_access = current_clock;
			if(_block.first_access){
				_block.first_access=false;
				_block.priority = LOW;
			}
			else{
				_block.priority = HIGH;
			}
			return;
		}
	}
	//Genarating random data.
	vector<int> data1(block_size);
	for(int i=0; i<block_size; i++) data1[i]=rand()%100;
	data1[byte_offset_int]=data;

	if(!found){
		miss++;
		no_of_write_miss++;
		file3 << "MISS\n";
		file3 << "Read from Main Memory from address " << address << " and inserting into cache" << endl;
		int index_invalid = -1;
		bool found_invalid=false;
		int set_size = required_set.size();
		int farthest_accessed = current_clock;
		int index_of_farthest_accessed = -1;
		for(int i=0; i<set_size; i++){
			if(!required_set[i].valid){
				found_invalid=true;
				index_invalid=i;
				break;
			}
			if(required_set[i].last_recent_access<farthest_accessed){
				farthest_accessed = required_set[i].last_recent_access;
				index_of_farthest_accessed = i;
			}
		}
		if(found_invalid){ // Write at invalid.
			required_set[index_invalid].data = data1;
			required_set[index_invalid].tag = tag_int;
			required_set[index_invalid].last_recent_access = current_clock;
			required_set[index_invalid].valid = 1;
			required_set[index_invalid].dirty = 1;
			required_set[index_invalid].first_access = true;
			required_set[index_invalid].priority = LOW;
		}
		else{
			if(required_set[index_of_farthest_accessed].dirty){
				int address1 = todecimal(tobinary(required_set[index_of_farthest_accessed].tag) + tobinary(index_int));
				address1 = address1 << no_of_bits_in_byte_offset;
				file3 << "Evict: Writing to Main Memory " << endl;
				//then evict and write to main memory;
			}
			required_set[index_of_farthest_accessed].data = data1;
			required_set[index_of_farthest_accessed].tag = tag_int;
			required_set[index_of_farthest_accessed].valid = 1;
			required_set[index_of_farthest_accessed].dirty = 1;
			required_set[index_of_farthest_accessed].last_recent_access = current_clock;
			required_set[index_of_farthest_accessed].first_access = true;
			required_set[index_of_farthest_accessed].priority = LOW;
		}
	}
}

//Converting HIGH to LOW if not accesed for T accesses.
void update_outdated(vector<cache_set> &cache, int no_of_bits_in_byte_offset, int no_of_set, int associativity, int T){
	for(int i=0; i<no_of_set; i++){
		vector<block> &set1 = cache[i]._set;
		for(int j=0; j<associativity; j++){
			if(set1[j].priority == HIGH && (current_clock - set1[j].last_recent_access) > T){
				file3 << "Making set_no:"<< i << " block_no:" << j <<" into LOW Priority" << endl;
				set1[j].priority = LOW;
				return;
			}
		}
	}
}

int main(){
	file1.open("config.txt");
	file2.open("output.txt");
	file3.open("details.txt");
	srand (time(NULL));
	// file2.open("output.txt");
	cout<<fixed<<setprecision(2);
	current_clock=0;
	hit=0;
	miss=0;
	no_of_read=0;
	no_of_read_hits=0;
	no_of_read_miss=0;
	no_of_write=0;
	no_of_write_hits=0;
	no_of_write_miss=0;

	int cache_size;
	int block_size;
	int associativity;
	int T;
	int no_of_set;
	int no_of_bits_in_byte_offset;

	file1 >> cache_size >> block_size >> associativity >> T;

	no_of_set = cache_size / (block_size * associativity);
	no_of_bits_in_byte_offset = (int)(log(block_size)/log(2.0));

	//Making cache
	vector<cache_set> cache(no_of_set);
	//Initializing the cache
	initialize_cache(cache,associativity,block_size,no_of_set);

	int address;
	char inst;
	int data;
	print_cache(cache,associativity,no_of_set,0);
	while(file1 >> address && file1 >> inst){
		no_of_access++;
		file3 << "------------------------------------------------------------------------------------\n";
		current_clock++;
		update_outdated(cache,no_of_bits_in_byte_offset, no_of_set,associativity,T);
		if(inst=='R'){
			file3 << address << " R\n";
			vector<int> num = read_data(cache,address,no_of_bits_in_byte_offset,no_of_set,associativity,block_size);
		}
		else if(inst=='W'){
			file1 >> data;
			file3 << address << " W " << data << "\n";
			write_data(cache,address,data,no_of_bits_in_byte_offset,no_of_set,associativity,block_size);
		}
		else{
			file3 << "Invalid Instruction\n";
		}
		print_cache(cache,associativity,no_of_set,0);
	}
	file3 << buffer.str() << endl;
	print_cache(cache,associativity,no_of_set,1);
	return 0;
}