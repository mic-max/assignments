#include <stdlib.h>

unsigned int neighbours(bool *spot, int N) {
	unsigned int nb = 0;
	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			if (i == 0 && j == 0) continue;
			if (spot[i*N + j]) nb++;
		}
	}
	return nb;
}

void evolve(bool *spot, bool *next, int offset, int N) {
	unsigned int nb = neighbours(spot+offset, N);
	next[offset] = (nb == 3) || (nb == 2 && spot[offset]);
}

// unsigned int perimeter(int w, int h) {
// 	return (w+h) * 2;
// }

// void create_halo(const bool *X, bool *buf, int N, int W, int H) {
// 	int cur = 0;
// 	for (int i = 0; i < W; i++) // top
// 		buf[cur++] = X[i];
// 	for (int i = 1; i < H; i++) // right
// 		buf[cur++] = X[i*N + W-1];
// 	for (int i = 0; i < H; i++) // left
// 		buf[cur++] = X[i*N];
// 	for (int i = 1; i < W; i++) // bottom
// 		buf[cur++] = X[i + N*(H-1)];
// }

void make_counts(int *counts, int *displ, int id, int p1, int p2, int N) {
	int x = id % p1;
	int y = id / p1;
	int cur = 0;
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
			displ[i] = cur;
			cur += val;
		}
	}
}

void recv_displs(int *displs, const int *offs, int id, int p1, int p2) {
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

void get_offsets(int *offs, int W, int H) {
	offs[0] = 0;
	offs[1] = 0;
	offs[2] = W-1;
	offs[3] = W+H-1;
	offs[4] = 0;
	offs[5] = W-1;
	offs[6] = 2*H+W-2;
	offs[7] = 2*H+W-2;
	offs[8] = 2*H+2*W-2;
}