#define CATCH_CONFIG_FAST_COMPILE

#include "catch.hpp"
#include "util.cpp"

TEST_CASE( "Neighbours are counted", "[neighbours]" ) {
	const int N = 4;
	bool a[] = {
		1,0,1,1,
		0,0,1,0,
		1,0,0,0,
		1,1,1,0
	};

	REQUIRE( neighbours(a+5,  N) == 4 );
	REQUIRE( neighbours(a+6,  N) == 2 );
	REQUIRE( neighbours(a+9,  N) == 5 );
	REQUIRE( neighbours(a+10, N) == 3 );
}

TEST_CASE( "Evolving life cells", "[evolve]" ) {
	const int N = 4;
	bool b[(N+2) * (N+2)];
	bool a[] = {
		0,0,0,0,0,0,
		0,1,0,1,1,0,
		0,0,0,1,0,0,
		0,1,0,0,0,0,
		0,1,1,1,0,0,
		0,0,0,0,0,0
	};
	bool exp[] = {
		0,0,0,0,0,0,
		0,0,1,1,1,0,
		0,0,0,1,1,0,
		0,1,0,1,0,0,
		0,1,1,0,0,0,
		0,0,0,0,0,0
	};

	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			int offset = (i+1)*(N+2) + (j+1);
			evolve(a, b, offset, N+2);
			REQUIRE ( b[offset] == exp[offset] );
		}
	}
}

TEST_CASE ( "Counts to send/receive", "[make_counts]" ) {
	const int P = 4;
	const int p1 = 2;
	const int p2 = 2;
	int count[P][P];
	int displ[P][P];
	int expc[P][P] = {
		{ 0, 2, 2, 1 },
		{ 2, 0, 1, 2 },
		{ 2, 1, 0, 2 },
		{ 1, 2, 2, 0 }
	};
	int expd[P][P] = {
		{ 0, 0, 2, 4 },
		{ 0, 2, 2, 3 },
		{ 0, 2, 3, 3 },
		{ 0, 1, 3, 5 },
	};

	for (int i = 0; i < P; i++)
		make_counts(count[i], displ[i], i, p1, p2, 4);

	for (int i = 0; i < P; i++) {
		for (int j = 0; j < P; j++) {
			REQUIRE ( count[i][j] == expc[i][j] );
			REQUIRE ( displ[i][j] == expd[i][j] );
		}
	}
}

TEST_CASE ( "Receive buffer displacements", "[recv_displs]" ) {
	const int P = 4;
	const int p1 = 2;
	const int p2 = 2;
	int displ[P][P] = { 0 };
	const int W = 5;
	const int H = 5;
	int offsets[9];
	get_offsets(offsets, W, H);
	int exp[P][P] = {
		{ 0,   9, 0, 0 },
		{ 4,   0, 4, 0 },
		{ 13, 13, 0, 9 },
		{ 18, 13, 4, 0 },
	};

	for (int i = 0; i < P; i++) {
		recv_displs(displ[i], offsets, i, p1, p2);
		for (int j = 0; j < P; j++) {
			REQUIRE ( displ[i][j] == exp[i][j] );
		}
	}
}