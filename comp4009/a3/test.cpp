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

TEST_CASE( "Perimeter of rectangle", "[perimeter]" ) {
	REQUIRE ( perimeter(1, 1) == 4 );
	REQUIRE ( perimeter(2, 2) == 8 );
	REQUIRE ( perimeter(3, 3) == 12 );
	REQUIRE ( perimeter(4, 4) == 16 );
	REQUIRE ( perimeter(5, 5) == 20 );
	REQUIRE ( perimeter(7, 9) == 32 );
	REQUIRE ( perimeter(1, 12) == 26 );
}

TEST_CASE( "Halo of a rectangle", "[create_halo]" ) {
	bool abuf[14];
	const bool a[] = {
		0,0,0,0,0,0,
		0,1,0,1,1,0,
		0,0,0,1,0,0,
		0,1,0,0,0,0,
		0,0,1,1,0,0,
		0,0,0,0,0,0
	};

	const bool exp[] = {
		1,0,1,1, // top
		0,0,0,   // right
		1,0,1,0, // left
		1,1,0    // bottom
	};

	create_halo(a+7, abuf, 6, 4, 4);
	for (int i = 0; i < 14; i++) {
		REQUIRE ( abuf[i] == exp[i] );
	}
}

TEST_CASE ( "Remove padding" , "[remove_pad]" ) {
	bool abuf[16];
	const bool a[] = {
		0,0,0,0,0,0,
		0,1,0,1,1,0,
		0,0,0,1,0,0,
		0,1,0,0,0,0,
		0,1,1,1,0,0,
		0,0,0,0,0,0
	};

	const bool exp[] = {
		1,0,1,1,
		0,0,1,0,
		1,0,0,0,
		1,1,1,0
	};

	remove_pad(a, abuf, 4, 4);
	for (int i = 0; i < 16; i++) {
		REQUIRE ( abuf[i] == exp[i] );
	}
}

TEST_CASE ( "Counts to send/receive", "[make_counts]" ) {
	const int P = 4;
	const int p1 = 2;
	const int p2 = 2;
	int count[P][P];
	int exp[P][P] = {
		{ 0, 5, 5, 1 },
		{ 5, 0, 1, 5 },
		{ 5, 1, 0, 5 },
		{ 1, 5, 5, 0 }
	};

	for (int i = 0; i < P; i++) {
		make_counts(count[i], i, p1, p2, 10);
		for (int j = 0; j < P; j++) {
			REQUIRE ( count[i][j] == exp[i][j] );
		}
	}
}

TEST_CASE ( "Send buffer displacements" "[]" ) {
	const int P = 4;
	const int p1 = 2;
	const int p2 = 2;
	int displ[P][P] = { 0 };
	int offsets[9];
	get_offsets(offsets, 5, 5);
	int exp[P][P] = {
		{ 0, 4, 13, 18 },
		{ 9, 0, 13, 13 },
		{ 0, 4,  0,  4 },
		{ 0, 0,  9,  0 },
	};

	for (int i = 0; i < P; i++) {
		make_displs(displ[i], offsets, i, p1, p2);
		for (int j = 0; j < P; j++) {
			REQUIRE ( displ[i][j] == exp[i][j] );
		}
	}
}

TEST_CASE ( "Receive buffer displacements" "[]" ) {
	const int P = 4;
	const int p1 = 2;
	const int p2 = 2;
	int displ[P][P] = { 0 };
	int offsets[9];
	get_offsets_r(offsets, 7, 7);
	int exp[P][P] = {
		{ 0, 12, 18, 23 },
		{ 7,  0, 17, 18 },
		{ 1,  6,  0, 12 },
		{ 0,  1,  7,  0 },
	};

	for (int i = 0; i < P; i++) {
		make_displs(displ[i], offsets, i, p1, p2);
		for (int j = 0; j < P; j++) {
			REQUIRE ( displ[i][j] == exp[i][j] );
		}
	}
}