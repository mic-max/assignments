#include <iostream>
#include <fstream>
#include <iomanip>
#include "mpi.h"
// #include "cxxopts.hpp"
#include "util.cpp"

#define MASTER 0

using namespace std;

int N;
bool *X; // used by p0 only for storing the entire game board

void display(bool *X, int W, int H, ostream &os, int pad) {
	for (int i = 0; i < H; i++) {
		for (int j = 0; j < W; j++) {
			os << X[(i+pad)*(W+2*pad) + j+pad];
		}
		os << endl;
	}
}

bool import(char *file, int N2) {
	ifstream input(file);
	if (!input.is_open()) {
		cout << "Input file: '" << file << "' could not be opened." << endl;
		return true;
	}

	char c;
	for (int i = 1; i <= N; i++) {
		for (int j = 1; j <= N; j++) {
			input >> c;
			X[i*N2 + j] = c != '0';
		}
	}

	return false;
}

// fill Yt with segments base data values
// ie. Y[1,1]..Y[NW-1, NH-1]
void remove_pad(bool *Y, bool *Yt, int PW, int PH) {
	const int PW2 = PW + 2;
	for (int i = 0; i < PH; i++) {
		for (int j = 0; j < PW; j++) {
			// cout << i*PW + j << " --> " << (i+1)*PW2 + j+1 << endl;
			Yt[i*PW + j] = Y[(i+1)*PW2 + j+1];
		}
	}
}

void convert(bool *X, bool *Xt, int N, int p1, int p2) {
	int NP = (N*N) / (p1*p2);
	int PW = N/p1;
	int PH = N/p2;
	for (int pi = 0; pi < p1; pi++) {
		for (int pj = 0; pj < p2; pj++) {
			int offset = pi*p1*NP + pj*NP;
			for (int y = 0; y < PH; y++) {
				for (int x = 0; x < PW; x++) {
					int Xt_p = offset + y * PW + x;
					int X_p = (y * N + x) + (pj * PW) + (pi * PH * N);
					X[X_p] = Xt[Xt_p];
				}
			}
		}
	}
}

int main(int argc, char **argv) {
	double wtime;
	ofstream output;

	MPI::Init(argc, argv);
	const int p = MPI::COMM_WORLD.Get_size();
	const int id = MPI::COMM_WORLD.Get_rank();

	if (argc != 7) {
		cout << "Usage: life <input> <N> <p1> <p2> <k> <m>" << endl;
		return 1;
	}

	// Initializing all variables from CLI arguments
	N = stoi(argv[2]);
	int p1 = stoi(argv[3]);
	int p2 = stoi(argv[4]);
	int k = stoi(argv[5]);
	int m = stoi(argv[6]);

	// Y and Z are the sections for working on the cells
	const int N2 = N+2; // side length of original grid + 2 for padding
	const int PW = N/p1; // number of processors that divide the data vertically
	const int PH = N/p2; // ^^ horizontally
	const int PW2 = PW + 2;
	const int PH2 = PH + 2;
	const int NP = PW * PH; // total size of data each processor is given
	const int NP2 = PW2 * PH2; // including the padding values

	bool *Xt;
	bool *Yt = (bool*) malloc(NP * sizeof(bool));

	if (id == MASTER) {
		X = (bool*) calloc(N2*N2, sizeof(bool));
		// TODO handle file read error
		bool err = import(argv[1], N2);
		if (err) {
			// TODO kill all other mpi processes
		}

		if (m) {
			output.open("output.txt");
		}
		display(X, N, N, cout, 1);
		// display(X, N2, N2, cout, 0);

		cout << "--- The number of processes is " << p << endl;
		wtime = MPI::Wtime();
	}

	if (id == MASTER) {
		Xt = (bool*) malloc(NP2*p * sizeof(bool));

		for (int pi = 0; pi < p1; pi++) {
			for (int pj = 0; pj < p2; pj++) {
				for (int i = 0; i < NP2; i++) {
					int x = i % PW2;
					int y = i / PH2;
					int Xt_p = NP2 * (pi * p2 + pj) + i;
					int X_p = (y * N2 + x) + (pj * PW) + (pi * PH * N2);
					Xt[Xt_p] = X[X_p];
					// cout << Xt_p << " --> " << X_p << endl;
				}
			}
		}
		// convert(Xt, X, N2, p1, p2); // try to reuse this function
		// display(Xt, NP2, p, cout, MASTER); // data to give each processor
	}

	bool Y[NP2], Z[NP2];
	bool *curPtr = Y;
	bool *setPtr = Z;
	// p0 send entire segment and its padding to respective processor
	MPI::COMM_WORLD.Scatter(Xt, NP2, MPI::BOOL, Y, NP2, MPI::BOOL, MASTER);

	if (id == MASTER) {
		X = (bool*) realloc(X, N*N * sizeof(bool));
		Xt = (bool*) realloc(Xt, N*N * sizeof(bool));
	}

	// cout << "Processor " << id << " received: ";
	// display(Y, PW2, PH2, cout, 0);

	const int PRMT = perimeter(PW, PH);
	const int PRMT2 = perimeter(PW2, PH2);
	bool *sbuf = (bool*) malloc((PRMT-2) * sizeof(bool));
	bool *rbuf = (bool*) malloc(PRMT2 * sizeof(bool));
	int counts[p];
	int sdispls[p];
	int rdispls[p] = { 0 };

	make_counts(counts, sdispls, id, p1, p2, N);
	const int offsets[] = {
		0        , 1        , PW+1,
		PW+2     , 0        , PW+2+PH,
		2*PH+PW+2, 2*PH+PW+3, 2*PH+2*PW+3
	};
	recv_displs(rdispls, offsets, id, p1, p2);
	// cout << "p" << id << " rdispls = ";
	// for (int q = 0; q < p; q++) {
	// 	cout << rdispls[q] << ' ';
	// }
	// cout << endl;

	for (int i = 0; i < k; i++) {
		for (int y = 0; y < PH; y++) {
			for (int x = 0; x < PW; x++) {
				int offset = (y+1)*PW2 + (x+1);
				evolve(curPtr, setPtr, offset, PW2);
			}
		}

		// curPtr or setPtr which should now contain the new values
		// bool edge[PRMT-4];
		// get_edges(, edge, PW2, PW, PH);
		create_halo(curPtr, sbuf, PW, PH, N);

		// Prints the processor's sent buffer
		cout << "p" << id << " sbuf = ";
		for (int q = 0; q < PRMT+4; q++) {
			cout << sbuf[q];
		}
		cout << endl;

		// share borders with neighbours
		MPI::COMM_WORLD.Alltoallv(
			sbuf, counts, sdispls, MPI::BOOL,
			rbuf, counts, rdispls, MPI::BOOL
		);

		// Prints the processor's received buffer
		// cout << "p" << id << " rbuf = ";
		// for (int q = 0; q < PRMT2; q++) {
		// 	cout << rbuf[q] << ',';
		// }
		// cout << endl;

		// blast the new rbuf into the border values of setPtr?

		if (m && i % m == 0) {
			remove_pad(setPtr, Yt, PW, PH);
			// display(Yt, PW, PH, cout, 0);
			MPI::COMM_WORLD.Gather(Yt, NP, MPI::BOOL, Xt, NP, MPI::BOOL, MASTER);
			if (id == MASTER) {
				cout << "---------------" << endl;
				cout << "Generation: " << i + 1 << endl;
				convert(X, Xt, N, p1, p2);
				display(X, N, N, cout, 0);
			}
		}

		swap(curPtr, setPtr);
	}

	free(Yt);
	if (id == MASTER) {
		free(X);
		free(Xt);
		if (output.is_open())
			output.close();
		wtime = MPI::Wtime() - wtime;
		cout << "Time Elapsed: " << wtime << " seconds." << endl;
	}

	MPI::Finalize();
	return 0;
}