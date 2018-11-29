main.cpp:
	Has the main procedure which will initialize MPI. Processor 0 will then 
	read the input file listed in the CLI arguments and scatter it to the other processes. 
	Then in a loop to the k-th generation the game of life will be 
	executed and each processor will exchange their halos. Finally whenever the 
	generation is a multiple of m, processor 0 will gather and output the 
	board's state.

catch.cpp:
	Main config/runner for the catch.hpp

catch.hpp:
	Unit testing library - https://github.com/catchorg/Catch2/releases/tag/v2.4.2

test.cpp:
	Test cases for some functions that were a little tricky to check correctness 
	in the middle of an MPI program.

compile: $ make
execute: $ ./_run
	The output generated from each run is deleted or else it will append the files.
	However, they are identical to the ones in the data directory proven by the
	diff command executing without displaying any errors to the console.


Example output:
	--------------------------------------------
	MPI Settings: p = 4, p1 = 2, p2 = 2
	Game of Life: N = 10, k = 10, m = 10
	Time Elapsed: 0.00238705 seconds.
	--------------------------------------------
	MPI Settings: p = 4, p1 = 2, p2 = 2
	Game of Life: N = 20, k = 10, m = 10
	Time Elapsed: 0.00146914 seconds.
	--------------------------------------------
	MPI Settings: p = 4, p1 = 2, p2 = 2
	Game of Life: N = 20, k = 10, m = 10
	Time Elapsed: 0.00179601 seconds.
	--------------------------------------------
	MPI Settings: p = 4, p1 = 2, p2 = 2
	Game of Life: N = 1000, k = 100, m = 0
	Time Elapsed: 8.96928 seconds.
	--------------------------------------------

Test 3 Runtime: N = 20, k = 100
	| p | Time (s) |
	---------------|
	| 1 | 0.009881 |
	| 2 | -SIGSEV- |
	| 4 | 0.006268 |

Comments:
	The splitting into quadrants was actually quite difficult, it only seems to work 
	when all processors are given the same amount of data exactly, i.e. given a 10x10 
	grid, there must be processor grid of 1x1 or 2x2 or 5x5. 

	If the documentation isn't great, simple examples are given in the test.cpp file.
	Displaying the expected outcome given certain input should be. All are passing.

	Speedup is more noticeable when used with larger grids.

Test 4 Runtime: N = 1000, k = 100
	| p | Time (s) |
	---------------|
	| 1 | 26.5619  |
	| 4 | 8.96928  |
	Speedup = 2.96, with a theoretical 4.0 maximum


These were run on the same machine, so smaller or larger speedups would be experienced
when running on multiple seperate computers. This would depend on whether the program 
is being bottlenecked by data transmission of the borders or the calculations each 
processor has to make to decide if its local cells are going to die or continue living.