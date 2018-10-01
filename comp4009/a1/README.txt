main.cpp: Has the main procedure which will run a median filter using the 2 command
          line arguments for the input and output files. The median filter is being
          run on multiple threads by using cilk++. Executing the run script will do
          all five given input files and perform a diff on the expected output with
          the actual output and print how long the calculation took.

Note: - The times printed might not be accurate. I think they have to be divided by
      the number of processors... since I was using a 4 thread laptop and dividing
      the clocks time seemed very close to when I timed with a stopwatch.
      - I sadly did not end up finding a recursive function that would result in a
      short execution graph depth for partitioning the array around a pivot in my
      quick select implementation.

compile: $ ./_compile
execute: $ ./_run

Example output:
  median_filter(89 x 45) k = 6
  Total time: 0.0082995s

  median_filter(524 x 877) k = 23
  Total time: 7.04386s

  median_filter(1000 x 1000) k = 10
  Total time: 3.94268s

  median_filter(872 x 600) k = 5
  Total time: 1.00091s

  median_filter(1223 x 1254) k = 30
  Total time: 39.2683s
