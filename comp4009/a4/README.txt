main.cpp:
	Performs the deterministic sample sort on n processors, reading data from 
	data/input-<id>.txt and outputing to data/output-<id>.txt.
	The lower numbered processors will have all the smallest values.
	
util.h:
	Includes heapsort functions and other utilities for creating psamples.

Stopwatch.h / Stopwatch.cpp
	Includes functions to keep track of time for communication and computation.

compile: $ make
execute: $ ./_run 1000000

Performance Test:

	Time in seconds.
	n = 1,000,000

	-------------------------------------------
	| p  | Comp Time | Comm Time | Total Time |
	|----|-----------|-----------|------------|
	|  1 |  3.540728 |  0.001790 |   3.542610 |
	|  2 |  1.631738 |  0.019083 |   1.650853 |
	|  3 |  1.212464 |  0.022301 |   1.234803 |
	|  4 |  1.043868 |  0.001840 |   1.045745 |
	|  5 |  0.807008 |  0.491499 |   1.298543 |
	|  6 |  1.217446 |  0.266554 |   1.484037 |
	|  7 |  1.064648 |  0.038859 |   1.103548 |
	|  8 |  0.898615 |  0.054413 |   0.953086 |
	-------------------------------------------

Notes:
	The _run script will run longer than the total time output because it 
	creates a new set of input files each time which takes a bit of time.

	The speedup was decent, around 3.7 for the 8 processor run. This speedup
	will vary quite a bit though due to communication and computation time.
	This was done on the localhost only so only 2 cores of the VM were in use,
	whereas on 8 distinct computers, each process would be running with a full cpu.
	So in that regard the distributed would be much faster than on localhost, but
	there is the drawback of communication between these machines which may not be
	very fast or responsive (e.g. all 8 are in different places around the world). 

	If you wish to generate and sort files with more than 1,000,000 values the _gen
	script must be edited to have a larger range for its -i option. shuf will only
	generate a maximum number of values defined in the range regardless of the -n value.