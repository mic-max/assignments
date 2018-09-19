#include <iostream>
#include <fstream>
#include <math.h>
#include <cilk/cilk.h>

using namespace std;

int m, n, k;
int **X, **Y;

void median_filter(int minX, int minY, int maxX, int maxY) {
	if (minX > maxX || minY > maxY) return; // Or stop these from spawning below ?
	if (minX == maxX && minY == maxY) {
		// cout << minX << "," << minY << " ---> " << maxX << ',' << maxY << endl;
		// cout << flush;
		// one pixel to compute the median of the surrounding values
		int r = X[minX][minY];
		// Y[minX][minY] = r;
		return;
	}

	int midX = floor((minX + maxX) / 2);
	int midY = floor((minY + maxY) / 2);

	// cout << minX << "," << minY << " ---> " << maxX << ',' << maxY << endl;
	// cout << flush;
	// spawn 4 threads, each working on an equal amount of the input 
	cilk_spawn median_filter(minX    , minY    , midX, midY); // top-left
	cilk_spawn median_filter(midX + 1, minY    , maxX, midY); // top-right
	cilk_spawn median_filter(minX    , midY + 1, midX, maxY); // bottom-left
	cilk_spawn median_filter(midX + 1, midY + 1, maxX, maxY); // bottom-right
	cilk_sync;
}

int main(int argc, char* argv[]) {
	if (argc != 3) {
		cout << "Usage: median-filter <input> <output>" << endl;
		return 1;
	}
	
	// read input file
	ifstream input(argv[1]);
	if(input.is_open()) {
		input >> m >> n >> k;

		// initialize arrays
		X = new int*[n];
		Y = new int*[n];
		for (int i = 0; i < n; i++) {
			X[i] = new int[m];
			Y[i] = new int[m];
		}

		for (int i = 0; i < n; i++) {
			for (int j = 0; j < m; j++) {
				input >> X[i][j];

			}
		}
		input.close();
	} else {
		cout << "Input file: '" << argv[1] << "' could not be opened.";
		return 2;
	}

	median_filter(0, 0, m - 1, n - 1);
	
	// write output file
	ofstream output(argv[2]);
	if(output.is_open()) {
		for (int i = 0; i < n; i++) {
			// If the last space is not allower, only do j < m-1, and then after the for loop print Y[i, m-1] to stream
			// or is there a way to insert a delete char to the stream
			for (int j = 0; j < m; j++) {
				output << Y[i][j] << ' ';
			}
			output << endl;
		}
		output.close();
	} else {
		cout << "Output file: '" << argv[2] << "' could not be opened.";
		return 3;
	}
	
	return 0;
}