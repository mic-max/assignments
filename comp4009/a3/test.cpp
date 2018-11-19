#define CATCH_CONFIG_MAIN
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

TEST_CASE( "Edges of a rectangle", "[get_edges]" ) {
	const int N = 4;
	bool b[12]; // or use perimeter func
	bool c[6];
	bool a[] = {
		1,0,1,1,
		0,0,1,0,
		1,0,0,0,
		1,1,1,0
	};
	bool exp1[] = {
		1,0,1,1,
		1,1,1,0,
		0,1,
		0,0
	};
	bool exp2[] = {
		0,1,
		1,1,
		0,
		0,
	};
	get_edges(a, b, N, 4, 4);

	for (int i = 0; i < 12; i++) {
		REQUIRE( b[i] == exp1[i] );
	}

	get_edges(a+5, c, N, 2, 3);
	for (int i = 0; i < 6; i++) {
		REQUIRE( c[i] == exp2[i] );	
	}

	// TODO add test for 2x2, because sides would have nothing
}

TEST_CASE( "Edges and corners", "[xx_edge, yy_zz_corner]" ) {
	// TODO add tests for rects smaller or equal to 2x2
	bool a[] = {
		1,0,1,1,
		1,1,1,0,
		0,1,
		0,0
	};
	bool b[] = {
		0,1,
		1,1,
		0,
		0,
	};

	REQUIRE (  );
}