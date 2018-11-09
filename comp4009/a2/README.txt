main.cpp:
  Has the main procedure which will run the matrix multiplication.
  Also has functions to convert to and from Z-order matrix to Row-order.
  Takes 1 command line argument which will define the size of the two matrices
  that will be multiplied together (n x n). It will then print out the
  resulting matrix and how long the multiplication function took.

compile: $ ./_compile
execute: $ ./_run

Example output:
  matrix_mult(256)
  Total time: 0.00984s
  matrix_mult(1024)
  Total time: 0.435214s
  matrix_mult(2048)
  Total time: 3.23432s
  matrix_mult(4096)
  Total time: 26.2203s

Speedup Table (16x16 base case):

N     | Sequential | 8 Cores | Speedup (x)
--------------------------------------------
256   | 0.011118   | 0.00984 | 1.13
--------------------------------------------
512   | 0.073549   | 0.07906 | 0.93
--------------------------------------------
1024  | 0.407891   | 0.43521 | 0.94
--------------------------------------------
2048  | 3.221970   | 3.23432 | 0.99
--------------------------------------------
4096  | 26.09410   | 26.2203 | 0.99
--------------------------------------------
8192  | ?          | 204.7   | xx
--------------------------------------------
16384 | N/A        | 1648.2  | No time left
--------------------------------------------

Comments:
  On average this program is getting no speedup running on 8 cores.
  This is obviously not performing as intended, I'm not sure if the extra overhead of
  running this on a VM is causing this or the cilk overhead even when performing
  multiplications of large matrices is the cause of the performance issues.
  The maximum speedup would be attainable would be by 8, since I used 8 processors.
  An acceptable speedup would be at least 2x faster, preferably around 4x.
  There could also be an issue with my programs way to tracking time since the hwtimer
  that was included in the cilk template overflowed after a short period of time.

Base Case Table (Extra):
Comparing base case with execution time of matrix size N*N

L/N | 256   | 1024  | 2048  | 4096   | 8192  | 16384 |
----------------------------------------------------
1   | 0.303 | 17.38 | 134.8 | 1068.6 | N/A   | N/A
----------------------------------------------------
2   | 0.060 | 3.131 | 22.82 | 170.06 | N/A   | N/A
----------------------------------------------------
4   | 0.022 | 0.890 | 5.808 | 46.243 | N/A   | N/A
----------------------------------------------------
8   | 0.001 | 0.492 | 3.605 | 30.541 | 234.7 | ?????????????????????
----------------------------------------------------
16  | 0.001 | 0.435 | 3.234 | 26.220 | 204.7 | 1648.2
----------------------------------------------------
32  | 0.012 | 0.449 | 3.519 | 24.799 | 196.8 | 1608.1
----------------------------------------------------