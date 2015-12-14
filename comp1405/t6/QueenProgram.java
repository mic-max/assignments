public class QueenProgram {
	public static final char E = ' ';
	public static final char Q = 'Q'; 
	public static final char M = '*';

	public static char[][] board1 = new char[][] {
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{Q, E, E, E, E, E, E, E}
	};

	public static char[][] moves1 = new char[][] {
		{M, E, E, E, E, E, E, M},
		{M, E, E, E, E, E, M, E},
		{M, E, E, E, E, M, E, E},
		{M, E, E, E, M, E, E, E},
		{M, E, E, M, E, E, E, E},
		{M, E, M, E, E, E, E, E},
		{M, M, E, E, E, E, E, E},
		{Q, M, M, M, M, M, M, M}
	};

	public static char[][] board2 = new char[][] {
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, Q, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E},
		{E, E, E, E, E, E, E, E}
	};

	public static char[][] moves2 = new char[][] {
		{E, E, E, E, M, M, M, E},
		{M, M, M, M, M, Q, M, M},
		{E, E, E, E, M, M, M, E},
		{E, E, E, M, E, M, E, M},
		{E, E, M, E, E, M, E, E},
		{E, M, E, E, E, M, E, E},
		{M, E, E, E, E, M, E, E},
		{E, E, E, E, E, M, E, E}
	};

	public static char[][] findMoves(char[][] board) {
		int x = 0, y = 0;
		for(int i = 0; i < board.length; i++) {
			for(int j = 0; j < board[0].length; j++) {
				if(board[i][j] == Q) {
					x = j;
					y = i;
				}
			}
		}
		for(int i = 0; i < board.length; i++) {
			for(int j = 0; j < board[0].length; j++) {
				if (board[i][j] == Q)
					board[i][j] = Q;
				else if((Math.toDegrees(Math.atan2(y - i, x - j))) % 45 == 0) {
					board[i][j] = M;
				} else {
					board[i][j] = E;
				}
			}
		}
		return board;
	}

	public static void showBoard(char[][] board, char[][] output, char[][] expected) {
		System.out.println("    original               output                expected");
		System.out.println("-----------------     -----------------     -----------------");
		for(int row = 0; row < 8; row++) {
			for(int col = 0; col < 8; col++)
				System.out.print("|" + board[row][col]);
			System.out.print("|     ");
			for(int col = 0; col < 8; col++)
				System.out.print("|" + output[row][col]);
			System.out.print("|     ");
			for(int col = 0; col < 8; col++)
				System.out.print("|" + expected[row][col]);
			System.out.println("|     ");
		}
		for(int row = 0; row < 8; row++) {
			for(int col = 0; col < 8; col++) {
				if(output[row][col] != expected[row][col]) {
					System.out.println("Computed moves does not match expected moves.");
					return;
				}
			}
		}
		System.out.println("Computed moves matches expected moves!");
	}

	public static void main(String[] args) {
		showBoard(board1, findMoves(board1), moves1);
		showBoard(board2, findMoves(board2), moves2);   
	}
}