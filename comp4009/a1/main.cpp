#include <algorithm>
#include <cilk/cilk.h>
#include <fstream>
#include <iostream>
#include <math.h>

using namespace std;

int m, n, k;
int **X, **Y;
int filter_size; // size of surrounding pixel array used in median calculation

int clamp(int v, int lo, int hi) {
	return v < lo ? lo : (v > hi ? hi : v);
}

int get_value(int x, int y) {
	int x_mask = clamp(x, 0, n-1);
	int y_mask = clamp(y, 0, m-1);

	return X[y_mask][x_mask];
}

int partition(int *list, int lo, int hi, int pivot) {
	int value = list[pivot];
	swap(list[pivot], list[hi]);
	int cur = lo;
	for (int i = lo; i <= hi-1; i++) {
		if (list[i] < value) {
			swap(list[cur], list[i]);
			cur++;
		}
	}

	swap(list[hi], list[cur]);
	return cur;
}

// Finds the kth smallest element in list [lo, hi]
int quick_select(int *list, int lo, int hi, int k) {
	if (lo == hi) return list[lo];

	int pivot = lo + floor(rand() % (hi-lo+1));
	pivot = partition(list, lo, hi, pivot);

	if (k == pivot)
		return list[k];
	else if (k < pivot)
		return quick_select(list, lo, pivot-1, k);
	else
		return quick_select(list, pivot+1, hi, k);
}

void median_filter(int minX, int minY, int maxX, int maxY) {
	if (minX > maxX || minY > maxY) return;
	if (minX == maxX && minY == maxY) {
		// one pixel to compute the median of the surrounding values
		int *arr = new int[filter_size];
		int cur = 0;

		for (int i = minY - k; i <= minY + k; i++) {
			for (int j = minX - k; j <= minX + k; j++) {
				arr[cur++] = get_value(j, i);
			}
		}

		Y[minY][minX] = quick_select(arr, 0, filter_size-1, filter_size/2);
		delete[] arr;
		return;
	}

	int midX = (minX + maxX) / 2;
	int midY = (minY + maxY) / 2;

	// spawn 4 threads, each working on an equal amount of the input
	cilk_spawn median_filter(minX  , minY  , midX, midY); // top-left
	cilk_spawn median_filter(midX+1, minY  , maxX, midY); // top-right
	cilk_spawn median_filter(minX  , midY+1, midX, maxY); // bottom-left
	cilk_spawn median_filter(midX+1, midY+1, maxX, maxY); // bottom-right
	cilk_sync;
}

bool import_data(const char *file, int &m, int &n, int &k, int &filter_size) {
	ifstream input(file);
	if(input.is_open()) {
		input >> m >> n >> k;
		filter_size = 4*k*k + 4*k + 1; // (2k+1)^2

		// initialize arrays
		X = new int*[m];
		Y = new int*[m];
		for (int i = 0; i < m; i++) {
			X[i] = new int[n];
			Y[i] = new int[n];
		}

		for (int i = 0; i < m; i++) {
			for (int j = 0; j < n; j++) {
				input >> X[i][j];
			}
		}
		input.close();
		return false;
	} else {
		cout << "Input file: '" << file << "' could not be opened." << endl;
		return true;
	}
}

bool export_data(const char *file) {
	ofstream output(file);
	if(output.is_open()) {
		for (int i = 0; i < m; i++) {
			for (int j = 0; j < n-1; j++) {
				output << Y[i][j] << ' ';
			}
			output << Y[i][n-1] << endl;
		}
		output.close();
		return false;
	} else {
		cout << "Output file: '" << file << "' could not be opened." << endl;
		return true;
	}
}

void cleanup() {
	for (int i = 0; i < m; i++) {
		delete[] X[i];
		delete[] Y[i];
	}
	delete[] X;
	delete[] Y;
}

int main(int argc, char* argv[]) {
	if (argc != 3) {
		cout << "Usage: median-filter <input> <output>" << endl;
		return 1;
	}

	clock_t begin = clock();
	bool err;

	err = import_data(argv[1], m, n, k, filter_size);
	if (err) return 2;
	
	median_filter(0, 0, n-1, m-1);

	err = export_data(argv[2]);
	if (err) return 3;

	clock_t end = clock();
	double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC / 4;
	
	cout << endl << "median_filter(" << m << " x " << n << ") k = " << k << endl;
	cout << "Total time: " << elapsed_secs << "s" << endl;

	cleanup();
	
	return 0;
}
