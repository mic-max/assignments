#include <stdlib.h>

// Returns the number of neighbours spot has
// N is the total width, including padding of the "2D" array
unsigned int neighbours(const bool *spot, int N) {
	unsigned int nb = 0;
	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			if (i == 0 && j == 0) continue;
			if (spot[i*N + j]) nb++;
		}
	}
	return nb;
}

// Sets next equal to the next evolution of what spot should become
void evolve(const bool *spot, bool *next, int offset, int N) {
	unsigned int nb = neighbours(spot+offset, N);
	next[offset] = (nb == 3) || (nb == 2 && spot[offset]);
}

// Calculates perimeter of a rectangle
unsigned int perimeter(int w, int h) {
	return (w+h) * 2;
}

// Writes X to Xt except the bordering 1 cell
void remove_pad(const bool *X, bool *Xt, int W, int H) {
	const int W2 = W+2;
	for (int i = 0; i < H; i++) {
		for (int j = 0; j < W; j++)
			Xt[i*W + j] = X[(i+1)*W2 + j+1];
	}
}

// Opposite of remove pad
// Values originally in X will be set to 0
// Values that were not specified will remain unchanged!
void add_pad(bool *X, int W, int H) {
	for (int i = H-1; i >= 0; i--) {
		for (int j = W-1; j >= 0; j--) {
			X[(i+1)*(W+2) + (j+1)] = X[i*W + j];
			X[i*W + j] = 0;
		}
	}
}

// Writes the outside edge of a rectangle to a buffer
// The order of edges is important: top - right - left - bottom
// This order was used because the processor -1,-1 from the current will 
// be given the top left value, and it follows that pattern.
void create_halo(const bool *X, bool *buf, int N, int W, int H) {
	int cur = 0;
	for (int i = 0; i < W; i++) // top
		buf[cur++] = X[i];
	for (int i = 1; i < H; i++) // right
		buf[cur++] = X[i*N + W-1];
	for (int i = 0; i < H; i++) // left
		buf[cur++] = X[i*N];
	for (int i = 1; i < W; i++) // bottom
		buf[cur++] = X[i + N*(H-1)];
}

// Determines how many to send or receive to each processor
// Essentially if the processor we're looking at is on the corner give 1
// On the left or right, give it height and top or bottom, give it width
void make_counts(int *counts, int id, int p1, int p2, int N) {
	int x = id % p1;
	int y = id / p1;
	for (int pi = 0; pi < p1; pi++) {
 		for (int pj = 0; pj < p2; pj++) {
			int val = 0;
			if (abs(x-pj) == 1 && abs(y-pi) == 1)
				val = 1;
			else if (abs(x-pj) == 1)
				val = N/p2;
			else if (abs(y-pi) == 1)
				val = N/p1;

			int i = pi*p2 + pj;
			counts[i] = val;
		}
	}
}

// Xt will have all quadrants of X sequentially
void convert(bool *X, bool *Xt, int N, int p1, int p2, bool to) {
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
					if (to)
						Xt[Xt_p] = X[X_p];
					else
						X[X_p] = Xt[Xt_p];
				}
			}
		}
	}
}

// Creates displacements from the given offsets array
// Having a proper offsets array is key here
void make_displs(int *displs, const int *offs, int id, int p1, int p2) {
	int x = id % p1;
	int y = id / p1;

	int cur = -1;
	for (int pi = y-1; pi <= y+1; pi++) {
		for (int pj = x-1; pj <= x+1; pj++) {
			int i = pi*p2 + pj;
			cur++;
			if (pi < 0 || pi >= p2 || pj < 0 || pj >= p1)
				continue;
			displs[i] = offs[cur];
		}
	}
}

// Send offsets
void get_offsets(int *offs, int W, int H) {
	offs[0] = 0;
	offs[1] = 0;
	offs[2] = W-1;
	offs[3] = W+H-1;
	offs[4] = 0;
	offs[5] = W-1;
	offs[6] = 2*H+W-2;
	offs[7] = 2*H+W-2;
	offs[8] = 2*H+2*W-3;
}

// Receive offsets, could switch send offsets to be the same but would
// add extra unnecessary data transfer or memory
void get_offsets_r(int *offs, int W, int H) {
	offs[0] = 0;
	offs[1] = 1;
	offs[2] = W-1;
	offs[3] = W;
	offs[4] = 0;
	offs[5] = W+H-2;
	offs[6] = 2*H+W-4;
	offs[7] = 2*H+W-3;
	offs[8] = 2*H+2*W-5;
}

// Overwrite the outside edge of a "2D" array with the received buffer
// Wish that MPI had taken care of this in their implementation
void overwrite_halo(bool *X, const bool *rbuf, int *counts, int *rdispls, int id, int p1, int p2, int W, int H) {
	int x = id % p1;
	int y = id / p1;

	int cur = -1;
	const int offsets[9] = { 0, 1, W-1, W, 0, 2*W-1, W*(H-1), W*(H-1)+1, W*H-1 };
	const int inks[9] = {0, 1, 0, H, 0, H, 0, 1, 0};
	for (int pi = y-1; pi <= y+1; pi++) {
		for (int pj = x-1; pj <= x+1; pj++) {
			int i = pi*p2 + pj;
			cur++;
			if (pi < 0 || pi >= p2 || pj < 0 || pj >= p1 || counts[i] == 0)
				continue;
			for (int z = 0; z < counts[i]; z++)
				X[offsets[cur] + z*inks[cur]] = rbuf[rdispls[i] + z];
		}
	}
}