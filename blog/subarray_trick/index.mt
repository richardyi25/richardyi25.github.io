#site-title Subarray Trick
#title Subarray Trick
#toc

#latex-preamble
$$
\newcommand{\arr}{\text{arr}}
\newcommand{\psa}{\text{psa}}
$$
#end latex-preamble

#main

#section Pre-Requisite Knowledge
Required:
<ul>
	<li>Time Comlpexity</li>
	<li>Prefix Sum Array</li>
</ul>
Nice to know:
<ul>
<li>Binary Indexed Tree</li>
</ul>

This article features example code in C++.
#end section

#section Introduction
This is a technique about counting subarrays whose sum satisfy a certain condition. There's no formal name I know for this technique, so I'm calling it "subarray trick".
#end section

#section Example Problem 1 - <a href="https://dmoj.ca/problem/dmopc17c1p2">Sharing Crayons</a>
<b>Problem summary:</b>Given an array of size $N$, count the number of subarrays whose sum is divisible by $K$. ($1 \leq N \leq 10^5, 1 \leq M \leq 10^9$).
<br/><br/>
<b>Solution:</b>

<ol>
	<li>
		Let's all the array $\arr$ and make it $1$-indexed.
	</li>
	<li>
		A subarray is uniquely defined by the leftmost and rightmost element, so we can rephrase the problem as: find how many pairs $(L, R)$ such that $1 \leq L \leq R \leq N$ and $\arr[L] + \dots + \arr[R]$ is divisible by $M$.
	</li>
	<li>
		We construct a prefix sum array $\psa$ over the array $\arr$. Specifically, $\psa[i] = \arr[1] + \arr[2] + \dots + \arr[i]$. Now, the problem becomes finding how many $1 \leq L \leq R \leq N$ such that $\psa[R] - \psa[L - 1]$ is divisible by $M$.
	</li>
	<li>
		We do a change of variable: $L' = L - 1$. The problem now becomes finding the number of $0 \leq L' < R \leq N$ such that $\psa[R] - \psa[L']$ is divisible by $M$. Implicitly, $\arr[i] = \psa[i] = 0$.
	</li>
	<li>
		We note that $\psa[R] - \psa[L]$ is divisible by $M$ iff and only if $\psa[R]\ \%\ M = \psa[L']\ \%\ M$.
	</li>
	<li>
		Now, let $\arr2[i] = \psa[i]\ \%\ M$. Now, we want to find the number of $0 \leq L' < R \leq N$ such that $\arr2[L'] = \arr2[R]$. The problem is now reduced to how many pairs of numbers are the same across an array $\arr2$. We can solve this in many ways, such as using a map data structure or sorting the array and using a bit of math.
	</li>
</ol>

<b>Code:</b>
#code
#include &lt;iostream&gt;
#include &lt;map&gt;
using namespace std;

const int MAXN = 1e5+1;
int N, M, arr[MAXN], arr2[MAXN];
long long psa[MAXN];

int main(){
	cin &gt;&gt; N &gt;&gt; M;
	for(int i = 1; i &lt;= N; i++){
		cin &gt;&gt; arr[i];
	}

	for(int i = 1; i &lt;= N; i++){
		psa[i] = psa[i - 1] + arr[i];
	}

	for(int i = 1; i &lt;= N; i++){
		arr2[i] = psa[i] % M;
	}

	long long answer = 0;
	map&lt;int, int&gt; frequency;

	// note that i = 0 here
	for(int i = 0; i &lt;= N; i++){
		answer += frequency[arr2[i]];
		++frequency[arr2[i]];
	}

	cout &lt;&lt; answer;
}
#end code
#end section

#section Example Problem 2 - <a href="https://codeforces.com/contest/1398/problem/C">Good Subarrays</a>
<b>Problem Summary:</b> Given an array of size $N$, count the number of subarrays whose sum is equal to its length. ($N \leq 10^5$)

<b>Solution:</b>

<ol>
	<li>Once again, let the array be called $\arr$ and be $1$-indexed.</li>
	<li>We note that the length of a subarray $\arr[L], \dots, \arr[R]$ is $R - L + 1$. We want to find how many pairs $(L, R)$ such that $1 \leq L \leq R \leq N$ and $\arr[L] + \dots + \arr[R] = R - L + 1]$</li>

	<li>Again, we will construct a prefix sum array $\psa[]$, and the problem becomes </li>
</ol>
#end section

#section Example Problem 3 - <a href="https://dmoj.ca/problem/hci16xorpow">Xorpow</a>
This technique works for counting subarray sums, but it also works for counting XOR-sums (the bitwise XOR of all elements) of subarrays. More generally, it works for any operation that has an inverse for each element, and in the case of bitwise XOR, since $x \text{ XOR } x = 0$ for all $x$, it is invertible.

First, let's solve an easier version of the problem. 
#end secton

// non-example: smarties

#end main
