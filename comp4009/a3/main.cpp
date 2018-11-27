#include <iostream>
#include <fstream>
#include "mpi.h"
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
		bool err = import(argv[1], N2);
		if (err) {
			// TODO kill all other mpi processes
		}

		if (m) output.open("output.txt");
		display(X, N, N, cout, 1);

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
				}
			}
		}
		// convert(Xt, X, N2, p1, p2); // try to reuse this function
	}

	bool Y[NP2], Z[NP2];
	bool *curPtr = Y;
	bool *setPtr = Z;
	// p0 send entire segment and its padding to respective processor
	// TODO make this not send the padding
	MPI::COMM_WORLD.Scatter(Xt, NP2, MPI::BOOL, Y, NP2, MPI::BOOL, MASTER);

	if (id == MASTER) {
		X = (bool*) realloc(X, N*N * sizeof(bool));
		Xt = (bool*) realloc(Xt, N*N * sizeof(bool));
	}

	const int PRMT = perimeter(PW, PH);
	bool *sbuf = (bool*) calloc(PRMT-2, sizeof(bool));
	bool *rbuf = (bool*) calloc(PRMT+4, sizeof(bool));
	int counts[p] = { 0 }; // TODO improve make counts func
	int sdispls[p] = { 0 };
	int rdispls[p] = { 0 };

	make_counts(counts, id, p1, p2, N);
	int offsets[9];
	get_offsets(offsets, PW, PH);
	send_displs(sdispls, offsets, id, p1, p2);
	get_offsets_r(offsets, PW2, PH2);
	send_displs(rdispls, offsets, id, p1, p2);

	for (int i = 0; i < k; i++) {
		create_halo(curPtr+PW2+1, sbuf, PW2, PW, PH);

		// share borders with neighbours
		MPI::COMM_WORLD.Alltoallv(
			sbuf, counts, sdispls, MPI::BOOL,
			rbuf, counts, rdispls, MPI::BOOL
		);

		overwrite_halo(curPtr, rbuf, counts, rdispls, id, p1, p2, PW2, PH2);

		for (int y = 0; y < PH; y++) {
			for (int x = 0; x < PW; x++) {
				int offset = (y+1)*PW2 + (x+1);
				evolve(curPtr, setPtr, offset, PW2);
			}
		}

		// if (m && i % m == 0) {
			remove_pad(curPtr, Yt, PW, PH);
			MPI::COMM_WORLD.Gather(Yt, NP, MPI::BOOL, Xt, NP, MPI::BOOL, MASTER);
			if (id == MASTER) {
				cout << "---------------" << endl;
				cout << "Generation: " << i + 1 << endl;
				convert(X, Xt, N, p1, p2);
				display(X, N, N, cout, 0);
			}
		// }

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