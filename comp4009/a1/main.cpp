
#include <cstdlib>
#include <iostream>
#include <cilk/cilk.h>
#include "hwtimer.h"
using namespace std;

int fib(int n) 
	{
		if (n < 2)
			return n;
		int a = cilk_spawn fib(n-1);
		int b = cilk_spawn fib(n-2);
		cilk_sync;
		return a + b;
	};


int main(int argc, char* argv[])
	{
		if (argc != 2) {
			cout << "Usage: fib <num>" << endl;
			return 1;
		}
	
		hwtimer_t timer;
		initTimer(&timer);
	
		int param = atoi(argv[1]);
	
		startTimer(&timer);
		int answer = fib(param);
		stopTimer(&timer);
		int fibTime = getTimerNs(&timer);
	
		cout << "fib(" << param << ") = " << answer << endl;
		cout << "Total time: " << fibTime << "ns" << endl;
	
		return 0;
	};
