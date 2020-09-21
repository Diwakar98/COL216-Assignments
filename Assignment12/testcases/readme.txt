1: Sample Input in the description

2: Cache_Size = 1024 , associativity = 4 and block_size = 32, 50 accesses

3: same as 2, cache size reduced to 64, associativity = 1, block_size = 32, hit ratio remain same

4: 	500 access
	small cache, block_size = 2, ass=2
	low hit ratio

5:	same input as of 4
	cache size increased to 64, block_size = 2, same ass
	hit ratio increases

6:	same input as of 4
	cache size = 64, block_size = 8 ,ass = 4,
	hit ratio still increased

7:	same input as of 4
	cache size = 64, block_size = 16 , ass = 4, full associativity
	not much effect(infact little less)

8:	same input as of 6
	cache size = 64, block_size = 8 , ass = 1, 
	hit ratio increased

9:	same input as of 4
	cache size = 64, block_size = 8 ,ass = 8,
	not much affect

10:	same input as of 4
	cache size = 64, block_size = 8 ,ass = 8,
	not much affect

11:	same input as of 4
	cache size = 64, block_size = 4,ass = 4,
	little bit increase

13: 500 accesses.....with 80 % peobability that new address being access belong to the same block as last address
	and 20 % probability that it comes from anywhere.
	cache size 64, block size = 8 and associativity = 4
	very high hit ratio	

14: same input as of 15, even if reducing cache size to 16 bytes still getting high hit ratio.

15: same input as of 15, but this time probability of fetching new address from same block is 20%
	Hence low hit ratio.

16: 

17: very low hit ratio because small cache + current address has only 20 percent probability that it comes from same block as of last address.

18: Being a small cache there is very high hit ration.....becoz current address has 80 percent probability that it comes from same block as of last address.

19: Asscess = 50, Cache=16, ass=1, block_size=1, low hit ratio.

20: Asscess = 500, Cache=16, ass=1, block_size=1, low hit ratio. almost same hit ratio

21: Asscess = 500, Cache=16, ass=8, block_size=1, low hit ratio. little bit increase in hit ratio.

22: Asscess = 500, Cache=16, ass=8, block_size=1, inst_prob = 90% little in hit ratio.

23: Access = 500, Cache = 32, block_size = 4, ass=8, 

24: Access = 500, Cache = 32, block_size = 4, ass=8, int_prob = 90, very high hit ratio


25: Access = 5000, Cache = 1024, block_size = 64, ass = 8, T=10, Main Memory = 10000, very low hit ratio

26: Access = 5000, Cache = 1024, block_size = 64, ass = 8, T=10, Main Memory = 1000, very high hit ratio

27: Access = 5000, Cache = 1024, block_size = 64, ass = 8, T=10, Main Memory = 10000, inst_prob = 90 , very high hit ratio

28: Access = 5000, Cache = 1024, block_size = 64, ass = 8, T=10, Main Memory = 10, inst_prob = 20 , still very high hit ratio

29: Access = 5000, Cache = 1024, block_size = 64, ass = 8, T=10000, Main Memory = 10000, inst_prob = 20 , low hit ratio, inspite of T being 10000, still getting LOW in every blocks.

30: Access = 5000, Cache = 1024, block_size = 64, ass = 8, T=10, Main Memory = 10000, inst_prob = 50 , descent hit ratio,
		Increasing T to 10000 , increases the HIGH priority blocks.





