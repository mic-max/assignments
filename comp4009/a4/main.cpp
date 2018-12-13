#include <fstream>
#include <stdio.h>
#include "mpi.h"

#define MASTER 0

using namespace std;

void printArray(int *arr, int n) { 
    for (int i = 0; i < n; i++)
        printf("%d ", arr[i]);
    printf("\n");
}

void heapify(int *arr, int n, int i) {
    int largest = i;
    int l = 2*i + 1;
    int r = 2*i + 2;

    if (l < n && arr[l] > arr[largest])
        largest = l;
    if (r < n && arr[r] > arr[largest])
        largest = r;
    if (largest != i) { 
        swap(arr[i], arr[largest]);
        heapify(arr, n, largest);
    }
}

void heapSort(int *arr, int n) {
    for (int i = n/2 - 1; i >= 0; i--)
        heapify(arr, n, i);
    for (int i = n-1; i >= 0; i--) {
        swap(arr[0], arr[i]);
        heapify(arr, i, 0);
    }
}

// n is size of the data, p is size of psample
void make_psample(int *x, int *y, int n, int p) {
  const int d = n/p;
  for (int i = 0; i < p; i++)
    y[i] = x[i*d];
}

void create_displacements(const int *counts, int *displs, int n) {
  int cur = 0;
  for (int i = 0; i < n; i++) {
    displs[i] = cur;
    cur += counts[i];
  }
}

void read_file(const char *filename, int *data) {
  ifstream input(filename);

  input.close();
}

void write_file(const char *filename, const int *data, int n) {
  ofstream output(filename);
  for (int i = 0; i < n; i++)
    output << data[i] << endl;
  output.close();
}

int main(int argc, char **argv) {
  int *data, *psample, *gpsample;
  double wtime, xtime;
  char filename[50];
  int n, m;
  ifstream input;

  MPI::Init(argc, argv);
  const int p = MPI::COMM_WORLD.Get_size();
  const int id = MPI::COMM_WORLD.Get_rank();

  // Load data from file
  sprintf(filename, "data/input-%02d.txt", id);
  read_file(filename, data); // TODO implement
  input.open(filename);
  input >> n >> m; // useless p value stored in m
  m = n/p;
  data = (int*) malloc(m * sizeof(int));
  for (int i = 0; i < m; i++)
    input >> data[i];
  input.close();

  wtime = MPI::Wtime();

  // Sort
  heapSort(data, m);

  // Create p sample
  psample = (int*) malloc(p * sizeof(int));
  make_psample(data, psample, m, p);

  if (id == MASTER) {
    gpsample = (int*) malloc(p*p * sizeof(int));
  }

  // MASTER process receives all individual p-samples
  MPI::COMM_WORLD.Gather(
    psample, p, MPI::INT,
    gpsample, p, MPI::INT, MASTER
  );

  if (id == MASTER) {
    heapSort(gpsample, p*p);
    make_psample(gpsample, psample, p*p, p);
    printf("gpsample: ");
    printArray(psample, p);
  }

  MPI::COMM_WORLD.Bcast(psample, p, MPI::INT, MASTER);

  // create count and displ to  simulate the buckets
  int scount[p] = {0};
  int sdispl[p];
  int rbuf[m]; // each processor receives at most n/p data items
  int rcount[p];
  int rdispl[p];
  
  int pid = 0;
  // calculate the scounts
  for (int i = 0; i < m; i++) {
    // dont check right bound for the last processor
    if (data[i] >= psample[pid] && (pid == p-1 || data[i] < psample[pid+1])) {
      scount[pid]++;
    } else {
      pid++;
      i--;
    }
  }
  // calculate the sdispl from the scounts
  create_displacements(scount, sdispl, p);

  // printf("p%d scount: \n", id);
  // printArray(scount, p);

  // printf("p%d sdispl: \n", id);
  // printArray(sdispl, p);

  int range0p[p];
  int only1s[p];
  for (int i = 0; i < p; i++) {
    only1s[i] = 1;
    range0p[i] = i;
  }
  // shares send counts to processors
  MPI::COMM_WORLD.Alltoallv(
    scount, only1s, range0p, MPI::INT,
    rcount, only1s, range0p, MPI::INT
  );

  create_displacements(rcount, rdispl, p);

  // create rcount and rdispl
  // printf("p%d rcount: \n", id);
  // printArray(rcount, p);
  // printf("p%d rdispl: \n", id);
  // printArray(rdispl, p);

  int sumc = 0; // TODO check if this is the same as rdispl[p-1]+rcount[p-1]
  for (int i = 0; i < p; i++)
    sumc += rcount[i];

  MPI::COMM_WORLD.Alltoallv(
    data, scount, sdispl, MPI::INT,
    rbuf, rcount, rdispl, MPI::INT
  );

  heapSort(rbuf, sumc);
  printf("p%d rbuf: ", id);
  printArray(rbuf, sumc);

  sprintf(filename, "data/output-%02d.txt", id);
  write_file(filename, rbuf, sumc);

  free(data);
  free(psample);
  if (id == MASTER) {
    free(gpsample);
  }
  // TODO print it as a table here
  wtime = MPI::Wtime() - wtime;

  MPI::COMM_WORLD.Barrier();
  printf("Time Elapsed: %g seconds.\n", wtime);

  MPI::Finalize();
  return 0;
}