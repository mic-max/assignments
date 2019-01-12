#include "Stopwatch.h"
#include "mpi.h"

Stopwatch::Stopwatch()
: start(0), elapsed(0), running(false) {}

void Stopwatch::Start() {
  if (running) return;

  start = MPI::Wtime();
  running = true;
}
void Stopwatch::Stop() {
  if (!running) return;

  elapsed += MPI::Wtime() - start;
  running = false;
}

double Stopwatch::Elapsed() const {
  return (running ? MPI::Wtime() - start : 0) + elapsed;
}