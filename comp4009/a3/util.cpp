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

unsigned int perimeter(int w, int h) {
	return (w+h) * 2;
}

// given an array with its width and height
// return all the values that form the perimeter
// starting at top-left and going clockwise.
void get_edges(const bool *X, bool *E, int N, int W, int H) {
	int cur = 0;
	for (int i = 0; i < W; i++) // top
		E[cur++] = X[i];
	for (int i = 0; i < W; i++) // bottom
		E[cur++] = X[i + (N*(H-1))];

	// Note: vertical edges exclude both corners
	for (int i = 1; i < H-1; i++) // left
		E[cur++] = X[i*N];

	for (int i = 1; i < H-1; i++) // right
		E[cur++] = X[i*N + W-1];
}

bool top_left_corner(const bool *X) {
	return X[0];
}
bool top_right_corner(const bool *X, int W) {
	return X[W-1];
}
bool bottom_left_corner(const bool *X, int W) {
	return X[W];
}
bool bottom_right_corner(const bool *X, int W) {
	return X[2*W - 1];
}

void top_edge(const bool *X, bool *E, int W) {
	for (int i = 0; i < W; i++)
		E[i] = X[i];
}
void bottom_edge(const bool *X, bool *E, int W) {
	for (int i = 0; i < W; i++)
		E[i] = X[W+i];
}
void left_edge(const bool *X, bool *E, int W, int H) {
	E[0] = top_left_corner(X);
	for (int i = 0; i < H-2; i++)
		E[i+1] = X[W*2 + i];
	E[H-1] = bottom_left_corner(X, W);
}
void right_edge(const bool *X, bool *E, int W, int H) {
	E[0] = top_right_corner(X, W);
	for (int i = 0; i < H-2; i++)
		E[i+1] = X[W*2 + (H-2) + i];
	E[H-1] = bottom_right_corner(X, W);
}

void create_halo(const bool *edge, bool *buf, int W, int H) {
	int cur = 0;
	buf[cur++] = top_left_corner(edge);
	top_edge(edge, buf + cur, W);
	cur += W;
	buf[cur++] = top_right_corner(edge, W);
	left_edge(edge, buf + cur, W, H);
	cur += H;
	right_edge(edge, buf + cur, W, H);
	cur += H;
	buf[cur++] = bottom_left_corner(edge, W);
	bottom_edge(edge, buf + cur, W); // causes error!
	cur += W;
	buf[cur++] = bottom_right_corner(edge, W);
}

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

void recv_displs(int *displs, int id, int p1, int p2, int N) {
	
}

/*
void recv_counts(int *rcounts, int id, int p1, int p2, int N) {
	int x = id % p1;
	int y = id / p1;

	bool is_top   = y == 0;
	bool is_bot   = y == p2-1;
	bool is_left  = x == 0;
	bool is_right = x == p1-1;

	const int W = N/p1;
	const int H = N/p2;
	
	// special cases: tl, top, tr, left, right, bl, bot, br
	// make sure these cases are covered
	// i.e.
	// 	x == 0 || x == p1-1
	// 	[AND -> corner], [OR -> edge]
	// 	y == 0 || y == p2-1

	// set values to zero by using calloc.
	// memset(rcounts, 0, p1*p2); // initialize with all zeroes

	for (int pi = y-1; pi < y+1; pi++) {
		for (int pj = x-1; pj < x+1; pj++) {
			int i = pi*p2 + pj;
			int val = 1;
			if (!is_top && pi == y-1 || !is_bot && pi == y+1) // above OR below
				val = W;
			else if(!is_left && pj == x-1 || !is_right && pj == x+1) // left OR right
				val = H;
			rcounts[i] = val;
		}
	}
}
*/