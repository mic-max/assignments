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
	bool atop[4] ,btop[2];
	bool abot[4], bbot[2];
	bool aleft[4], bleft[3];
	bool aright[4], bright[3];
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

	// Testing A (4x4)
	top_edge(a, atop, 4);
	REQUIRE ( atop[0] == 1 );
	REQUIRE ( atop[1] == 0 );
	REQUIRE ( atop[2] == 1 );
	REQUIRE ( atop[3] == 1 );

	bottom_edge(a, abot, 4);
	REQUIRE ( abot[0] == 1 );
	REQUIRE ( abot[1] == 1 );
	REQUIRE ( abot[2] == 1 );
	REQUIRE ( abot[3] == 0 );

	left_edge(a, aleft, 4, 4);
	REQUIRE ( aleft[0] == 1 );
	REQUIRE ( aleft[1] == 0 );
	REQUIRE ( aleft[2] == 1 );
	REQUIRE ( aleft[3] == 1 );

	right_edge(a, aright, 4, 4);
	REQUIRE ( aright[0] == 1 );
	REQUIRE ( aright[1] == 0 );
	REQUIRE ( aright[2] == 0 );
	REQUIRE ( aright[3] == 0 );

	REQUIRE ( top_left_corner(a) == 1 );
	REQUIRE ( top_right_corner(a, 4) == 1 );
	REQUIRE ( bottom_left_corner(a, 4) == 1 );
	REQUIRE ( bottom_right_corner(a, 4) == 0 );

	// Testing B (2x3)
	top_edge(b, btop, 2);
	REQUIRE ( btop[0] == 0 );
	REQUIRE ( btop[1] == 1 );

	bottom_edge(b, bbot, 2);
	REQUIRE ( bbot[0] == 1 );
	REQUIRE ( bbot[1] == 1 );

	left_edge(b, bleft, 2, 3);
	REQUIRE ( bleft[0] == 0 );
	REQUIRE ( bleft[1] == 0 );
	REQUIRE ( bleft[2] == 1 );

	right_edge(b, bright, 2, 3);
	REQUIRE ( bright[0] == 1 );
	REQUIRE ( bright[1] == 0 );
	REQUIRE ( bright[2] == 1 );

	REQUIRE ( top_left_corner(b) == 0 );
	REQUIRE ( top_right_corner(b, 2) == 1 );
	REQUIRE ( bottom_left_corner(b, 2) == 1 );
	REQUIRE ( bottom_right_corner(b, 2) == 1 );
}

TEST_CASE( "Halo of a rectangle", "[create_halo]" ) {
	bool abuf[20];
	bool bbuf[24];
	const bool aedge[] = {
		1,0,1,1,
		1,1,1,0,
		0,1,
		0,0
	};

	const bool expa[] = {
		1, 1,0,1,1, 1,
		1,0,1,1,
		1,0,0,0,
		1, 1,1,1,0, 0
	};

	const bool bedge[] = {
		0,0,0,0,0,
		0,0,0,1,0,
		0,0,0,
		0,0,1
	};

	const bool expb[] = {
		0, 0,0,0,0,0, 0,
		0,0,0,0,0,
		0,0,0,1,0,
		0, 0,0,0,1,0, 0
	};

	create_halo(aedge, abuf, 4, 4);
	for (int i = 0; i < 20; i++) {
		REQUIRE ( abuf[i] == expa[i] );
	}

	create_halo(bedge, bbuf, 5, 5);
	for (int i = 0; i < 24; i++) {
		REQUIRE ( bbuf[i] == expb[i] );
	}
}

TEST_CASE ( "Counts to send/receive", "make_counts" ) {
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

TEST_CASE ( "Receive buffer displacements" "[]" ) {
	const int P = 4;
	const int p1 = 2;
	const int p2 = 2;
	int displ[P][P];
	int expd[P][P] = {
		{ 0, 0, 2, 4 },
		{ 0, 2, 2, 3 },
		{ 0, 2, 3, 3 },
		{ 0, 1, 3, 5 },
	};

	for (int i = 0; i < P; i++)
		recv_displs(displ[i], i, p1, p2, 4);

	for (int i = 0; i < P; i++) {
		for (int j = 0; j < P; j++) {
			REQUIRE ( count[i][j] == expc[i][j] );
			REQUIRE ( displ[i][j] == expd[i][j] );
		}
	}
}