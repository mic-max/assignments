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
	next[offset] = nb == 3 || nb == 2 && spot[offset];
}

unsigned int perimeter(int w, int h) {
	return (w+h) * 2;
}

// given an array with its width and height
// return all the values that form the perimeter
// starting at top-left and going clockwise.
void get_edges(bool *X, bool *E, int N, int W, int H) {
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

// TODO helpers
// get specific corners and sides from the resulting above array.s