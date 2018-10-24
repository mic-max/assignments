#include <cilk/cilk.h>
#include <fstream>
#include <iostream>
#include <string.h>

#define LOGGING true

using namespace std;

int N;
int N2;
int L = 16;
int *M;

// Moser–de Bruijn sequence [0, 32)
int mb[] = {
	0,1,4,5,16,17,20,21,64,65,68,69,80,81,84,85,
	256,257,260,261,272,273,276,277,320,321,324,325,336,337,340,341
};
int mb2[] = {
	0,2,8,10,32,34,40,42,128,130,136,138,160,162,168,170,
	512,514,520,522,544,546,552,554,640,642,648,650,672,674,680,682
};

void fill_value(int *M, int n, int max) {
	for (int i = 0; i < n; i++)
		M[i] = rand() % max;
}

void itr_multiply(int *C, int *A, int *B, int n) {
	if (n == 1) {
		C[0] += A[0] * B[0];
		return;
	}
	for (int i = 0; i < n; i += 2) {
		for (int j = 0; j < n; j += 2) {
			int s = mb[i] + mb2[j];
			int x1 = mb2[j];
			int x2 = mb2[j+1];
			int y1 = mb[i];
			int y2 = mb[i+1];
			for (int k = 0; k < n; k++) {
				C[s]   += A[mb[k] + x1] * B[mb2[k] + y1];
				C[s+1] += A[mb[k] + x1] * B[mb2[k] + y2];
				C[s+2] += A[mb[k] + x2] * B[mb2[k] + y1];
				C[s+3] += A[mb[k] + x2] * B[mb2[k] + y2];
			}
		}
	}
}

void multiply(int *C, int *A, int *B, int n) {
	if (n == L)
		return itr_multiply(C, A, B, n);

	int j = n/2;
	int k = n*n / 4;

	int *a12 = A+k, *a21 = A + 2*k, *a22 = A + 3*k;
	int *b12 = B+k, *b21 = B + 2*k, *b22 = B + 3*k;
	int *c12 = C+k, *c21 = C + 2*k, *c22 = C + 3*k;

	cilk_spawn multiply(C  , A  , B  , j);
	cilk_spawn multiply(c12, A  , b12, j);
	cilk_spawn multiply(c21, a21, B  , j);
	cilk_spawn multiply(c22, a21, b12, j);
	cilk_sync;

	cilk_spawn multiply(C  , a12, b21, j);
	cilk_spawn multiply(c12, a12, b22, j);
	cilk_spawn multiply(c21, a22, b21, j);
	cilk_spawn multiply(c22, a22, b22, j);
	cilk_sync;
}

void convert_row(int *R, int *Z) {
	R[0] = Z[0];
	R[1] = Z[1];
	R[N] = Z[2];
	R[N+1] = Z[3];
}

void convert_z(int *R, int *Z) {
	Z[0] = R[0];
	Z[1] = R[1];
	Z[2] = R[N];
	Z[3] = R[N+1];
}

void convert_matrix(int *R, int *Z, int n, bool back) {
	if (n == 2)
		return back ? convert_row(R, Z) : convert_z(R, Z);

	int j = n/2;
	int k = n*n / 4;

	cilk_spawn convert_matrix(R          , Z      , j, back);
	cilk_spawn convert_matrix(R + j      , Z + k  , j, back);
	cilk_spawn convert_matrix(R + j*N    , Z + 2*k, j, back);
	cilk_spawn convert_matrix(R + j*N + j, Z + 3*k, j, back);
	cilk_sync;
}

void print_matrix(ostream &os, string s, int *M, int n) {
	if (!LOGGING)
		return;
	os << s << ':' << endl;
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++)
			os << M[i*n + j] << " ";
		os << endl;
	}
	os << endl;
}

int main(int argc, char* argv[]) {
	if (argc != 3 && argc != 4) {
		cout << "Usage: matrix_mult <output-file> <matrix_size> [base_size = 1]" << endl;
		return 1;
	}

	ofstream output(argv[1]);
	if (!output.is_open()) {
		cout << "error opening file: " << argv[1] << endl;
		return 2;
	}

	N = stoi(argv[2]);
	N2 = N*N;
	if (argc == 4)
		L = stoi(argv[3]);

	if (L & (L-1) || L > N || L > 32) {
		cout << "base_size must be in the range 2^[0, 5]" << endl;
		return 4;
	}

	if (N & (N-1)) {
		cout << "matrix_size must be a power of 2" << endl;
		return 3;
	}

	M = (int*) malloc(3 * N2 * sizeof(int));
	int *A = M;
	int *B = M + N2;
	int *C = M + 2*N2;

	fill_value(B, 2*N2, 10); // fill B and C with random values
	print_matrix(output, "A", B, N);
	convert_matrix(B, A, N, false);

	print_matrix(output, "B", C, N);
	convert_matrix(C, B, N, false);

	memset(C, 0, N2 * sizeof(int)); // fill C with zeroes

	clock_t begin = clock();

	multiply(C, A, B, N);

	clock_t end = clock();
	double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC / 4;

	convert_matrix(B, C, N, true);
	print_matrix(output, "C", B, N);
	
	cout << "matrix_mult(" << N << ")" << endl;
	cout << "Total time: " << elapsed_secs << "s" << endl;

	output.close();
	free(M);

	return 0;
}
