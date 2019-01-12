#include <fstream>
#include <stdio.h>
#include "mpi.h"
#include "Stopwatch.h"
#include "util.h"

#define MASTER 0

using namespace std;

// Reads the file named filename in the specified input format
// n - number of total data to be processed
// p - number of processors working on this task
// n/p... - n over p integers seperated by newlines or whitespace
int read_file(const char *filename, int *&data) {
  int n, p;
  ifstream input(filename);

  input >> n >> p;
  n /= p;
  data = (int*) malloc(n * sizeof(int));
  for (int i = 0; i < n; i++)
    input >> data[i];

  input.close();
  return n;
}

// Writes values from an array to a file, seperated by newlines
void write_file(const char *filename, const int *data, int n) {
  ofstream output(filename);
  for (int i = 0; i < n; i++)
    output << data[i] << endl;
  output.close();
}

// Pauses the first stopwatch, and resumes the second stopwatch
void toggle_timers(Stopwatch *stop, Stopwatch *start) {
  stop->Stop();
  start->Start();
}

int main(int argc, char **argv) {
  char filename[50];
  Stopwatch *wtime = new Stopwatch();
  Stopwatch *xtime = new Stopwatch();
  Stopwatch *ttime = new Stopwatch();

  MPI::Init(argc, argv);
  const int p = MPI::COMM_WORLD.Get_size();
  const int id = MPI::COMM_WORLD.Get_rank();

  // Load data from file
  int *data = nullptr;
  sprintf(filename, "data/input-%02d.txt", id);
  int n = read_file(filename, data);

  int *gpsample;
  int *psample = (int*) malloc(p * sizeof(int));
  // Allocate memory for the master process to receive all other local p-samples
  if (id == MASTER)
    gpsample = (int*) malloc(p*p * sizeof(int));

  // Creating some simple arrays needed for a future Alltoallv call
  int range0p[p];
  int only1s[p];
  for (int i = 0; i < p; i++) {
    only1s[i] = 1;
    range0p[i] = i;
  }

  ttime->Start();
  wtime->Start();

  heapSort(data, n); // sort local data, that was read from file
  make_psample(data, psample, n, p); // creates the local p-sample

  toggle_timers(wtime, xtime);
  // Master process receives all individual p-samples
  MPI::COMM_WORLD.Gather(
    psample, p, MPI::INT,
    gpsample, p, MPI::INT, MASTER
  );
  toggle_timers(xtime, wtime);

  // Master process creates the global p-sample from the p-samples it received
  if (id == MASTER) {
    heapSort(gpsample, p*p);
    make_psample(gpsample, psample, p*p, p);
  }

  // Master process broadcasts the global p-sample to all processes,
  // it is written to their original p-sample array
  toggle_timers(wtime, xtime);
  MPI::COMM_WORLD.Bcast(psample, p, MPI::INT, MASTER);
  toggle_timers(xtime, wtime);

  // Create count and displ to simulate the buckets
  int scount[p] = {0};
  int sdispl[p];
  int rbuf[n*2]; // each processor should receive no more than double
  int rcount[p];
  int rdispl[p];
  
  create_scounts(scount, data, psample, n, p); // creates the send counts
  create_displacements(scount, sdispl, p); // use counts to calculate displacements

  toggle_timers(wtime, xtime);
  // Shares send counts to processors so they can know how much data they will receive
  MPI::COMM_WORLD.Alltoallv(
    scount, only1s, range0p, MPI::INT,
    rcount, only1s, range0p, MPI::INT
  );
  toggle_timers(xtime, wtime);

  // Generate the receive displacements for data to be saved into rbuf
  create_displacements(rcount, rdispl, p);

  toggle_timers(wtime, xtime);
  // Sends the bucketized data to its respective process
  MPI::COMM_WORLD.Alltoallv(
    data, scount, sdispl, MPI::INT,
    rbuf, rcount, rdispl, MPI::INT
  );
  toggle_timers(xtime, wtime);

  // Sorts the received values, which should have a much smaller range of values
  int sumc = rdispl[p-1] + rcount[p-1]; // number of values in rbuf, past this is garbage
  heapSort(rbuf, sumc);

  wtime->Stop();
  ttime->Stop();

  // Write the output file
  sprintf(filename, "data/output-%02d.txt", id);
  write_file(filename, rbuf, sumc);

  // Cleanup memory and output timings from the 3 stopwatches
  free(data);
  free(psample);
  if (id == MASTER) {
    free(gpsample);

    printf("| %2d | %9f | %9f | %10f |\n",
      p, wtime->Elapsed(), xtime->Elapsed(), ttime->Elapsed()
    );
  }

  MPI::Finalize();
  return 0;
}