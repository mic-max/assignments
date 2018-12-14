#include <algorithm>
#include <stdio.h>
#include <math.h>

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
    std::swap(arr[i], arr[largest]);
    heapify(arr, n, largest);
  }
}

void heapSort(int *arr, int n) {
  for (int i = n/2 - 1; i >= 0; i--)
    heapify(arr, n, i);
  for (int i = n-1; i >= 0; i--) {
    std::swap(arr[0], arr[i]);
    heapify(arr, i, 0);
  }
}

// n is size of the data, p is size of psample
void make_psample(int *x, int *y, int n, int p) {
  const float d = (float)n / (float)p;
  for (int i = 0; i < p; i++)
    y[i] = x[(int) floor(i * d)];
}

void create_scounts(int *scount, const int *data, const int *psample, int n, int p) {
  int pid = 0;
  for (int i = 0; i < n; i++) {
    // Does not check right bound for the last processor
    if (data[i] >= psample[pid] && (pid == p-1 || data[i] < psample[pid+1])) {
      scount[pid]++;
    } else {
      pid++;
      i--;
    }
  }
}

void create_displacements(const int *counts, int *displs, int n) {
  int cur = 0;
  for (int i = 0; i < n; i++) {
    displs[i] = cur;
    cur += counts[i];
  }
}