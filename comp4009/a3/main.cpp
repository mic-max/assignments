#include <fstream>
#include "mpi.h"

using namespace std;

int N;
bool *X; // used by p0 only for storing the entire game board

int neigbours(bool *spot) {
	int nb = 0;
	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++)
			if (spot[i*N + j]) nb++;	
	}
	return nb;
}

void evolve(bool *spot) {
	int nb = neigbours(spot);
	*spot = nb == 3 || nb == 2 && *spot;
}

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

void convert(int *X, int *Xt) {

}

int main(int argc, char **argv) {
	int id, p, p1, p2;
	double wtime;
	int k = 1;
	int m = 0;
	ofstream output;

	MPI::Init(argc, argv);
	p = MPI::COMM_WORLD.Get_size();
	id = MPI::COMM_WORLD.Get_rank();

	if (argc != 7) {
		cout << argc << endl;
		cout << "Usage: life <input> <N> <p1> <p2> <k> <m>" << endl;
		return 1;
	}

	// Initializing all variables from CLI arguments
	// TODO error check, p1xp2 == p, no negatives
	// k = 100, m = 51. dont bother computing k[52-100] ??
	N = stoi(argv[2]);
	p1 = stoi(argv[3]);
	p2 = stoi(argv[4]);
	k = stoi(argv[5]);
	m = stoi(argv[6]);

	// Y and Z are the sections for working on the cells
	const int N2 = N+2; // side length of original grid + 2 for padding
	const int PW = N/p1; // number of processors that divide the data vertically
	const int PH = N/p2; // ^^ horizontally
	const int PW2 = PW + 2;
	const int PH2 = PH + 2;
	const int NP = PW * PH; // total size of data each processor is given
	const int NP2 = PW2 * PH2; // including the padding values
	bool Y[NP2], Z[NP2];
	bool *Xt; // Data and halos for each processor

	if (id == 0) {
		// TODO handle file read error
		X = (bool*) calloc(N2*N2, sizeof(bool));
		bool err = import(argv[1], N2);

		// output.open("output.txt");
		display(X, N, N, cout, 1);
		// display(X, N2, N2, cout, 0);

		cout << "--- The number of processes is " << p << endl;
		wtime = MPI::Wtime();
	}

	// int dims[] = {p1, p2};
	// bool periods[] = {false, false};
	// MPI::COMM_WORLD.Create_cart(2, dims, periods, true);

	if (id == 0) {
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

		display(Xt, NP2, p, cout, 0); // data to give each processor
	}
	MPI::COMM_WORLD.Barrier();

	// p0 send entire segment and its padding to respective processor
	MPI::COMM_WORLD.Scatter(Xt, NP2, MPI::BOOL, Y, NP2, MPI::BOOL, 0);

	MPI::COMM_WORLD.Barrier();

	if (id == 0) {
		X = (bool*) realloc(X, N*N * sizeof(bool));
		Xt = (bool*) realloc(Xt, N*N * sizeof(bool));
	}

	// cout << "Processor " << id << " received: ";
	// display(Y, PW2, PH2, cout, 0);

	// for (int i = 0; i < k; i++) {
	// 	// TODO play game of life here
	// 	for () {
	// 		evolve();
	// 	}
	// 	// share borders with neighbours
	// 	MPI::COMM_WORLD.Alltoallv(
	// 		sbuf, scounts, sdispls, MPI::BOOL,
	// 		rbuf, rcounts, rdispls, MPI::BOOL
	// 	);

	// 	if (m && i % m == 0) {
	// 		// send everything to p0
	//		bool Yt[NP2];
	// 		MPI::COMM_WORLD.Gather(Yt, NP, MPI::BOOL, X, NP, MPI::BOOL, 0);
	//      display(&output);
	// 	}
	// }

	bool *Yt = (bool*) malloc(NP * sizeof(bool));
	// fill Yt with segments base data values
	// ie. Y[1,1]..Y[NW-1, NH-1]
	for (int i = 0; i < PH; i++) {
		for (int j = 0; j < PW; j++) {
			// cout << i*PW + j << " --> " << (i+1)*PW2 + j+1 << endl;
			Yt[i*PW + j] = Y[(i+1)*PW2 + j+1];
		}
	}

	// display(Yt, PW, PH, cout, 0);

	MPI::COMM_WORLD.Barrier();
	MPI::COMM_WORLD.Gather(Yt, NP, MPI::BOOL, Xt, NP, MPI::BOOL, 0);
	MPI::COMM_WORLD.Barrier();

	// CONVERT Xt stuff into X
	if (id == 0) {
		for (int pi = 0; pi < p1; pi++) {
			for (int pj = 0; pj < p2; pj++) {
				int offset = pi*p1*NP + pj*NP;
				for (int y = 0; y < PH; y++) {
					for (int x = 0; x < PW; x++) {
						int Xt_p = offset + y * PW + x;
						int X_p = (y * N + x) + (pj * PW) + (pi * PH * N);
						// cout << X_p << " --> " << Xt_p << endl;
						X[X_p] = Xt[Xt_p];
					}
					// int Xt_p = offset + i;
					// int X_p = y * N + x;
					// // int Xt_p = (y * N + x) + (pj * PW) + (pi * PH * N);
					// // int X_p = NP * (pi * p2 + pj) + i;
					// cout << X_p << " --> " << Xt_p << endl;
					// X[X_p] = Xt[Xt_p];
				}
			}
		}

		// CHANGE TO X not Xt
		display(X, N, N, cout, 0);
	}

	free(Yt);
	if (id == 0) {
		free(X);
		free(Xt);
		// output.close();
		wtime = MPI::Wtime() - wtime;
		cout << "Elapsed wall clock time = " << wtime << " seconds." << endl;
	}

	MPI::Finalize();
	return 0;
}