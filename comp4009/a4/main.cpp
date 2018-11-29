#include <iostream>
#include "mpi.h"

using namespace std;

int main(int argc, char **argv) {
	int N;
	double wtime;

	MPI::Init(argc, argv);
	const int p = MPI::COMM_WORLD.Get_size();
	const int id = MPI::COMM_WORLD.Get_rank();

	if (argc != 2) {
		cout << "Usage: sort <N>" << endl;
		return 1;
	}

	// Initializing all variables from CLI arguments
	N = stoi(argv[1]);

	// Load data from file
	wtime = MPI::Wtime();

	// Sort

	wtime = MPI::Wtime() - wtime;
	cout << "Time Elapsed: " << wtime << " seconds." << endl;

	MPI::Finalize();
	return 0;
}