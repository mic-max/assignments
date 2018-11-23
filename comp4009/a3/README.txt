main.cpp:
	Has the main procedure which will initialize MPI. Processor 0 will then read the input file listed in the CLI arguments and scatter it to the other processes. Then in a loop to the k-th generation the game of life will be executed and each processor will exchange their halos. Finally whenever the generation is a multiple of m, processor 0 will gather and output the board's state.

catch.cpp:
	Main config/runner for the catch.hpp

catch.hpp:
	Unit testing library - https://github.com/catchorg/Catch2/releases/tag/v2.4.2


compile: $ make
execute: $ ./_run


Example output:


Comments:
