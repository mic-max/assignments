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