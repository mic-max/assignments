/**
*	@author Michael Maxwell
*	@since 2016/03/02
*	@custom.citations I did not use any reference material in developing this assignment.
*/

public class TicTacToePlayer {

	private final String name;
	private final boolean isX;

	public TicTacToePlayer(String name, char p) {
		this.name = name;
		this.isX = p == 'x';
	}

	public String getName() {
		return name;
	}

	public boolean isX() {
		return isX;
	}

	public char getXO() {
		if(name.equals("reset"))
			return '\0';
		return isX ? 'x' : 'o';
	}

	private static int getSpots(TicTacToeGame game) {
		return (int) Math.pow(game.getDimension(), 2);
	}

	private static boolean isWinningRow(TicTacToeGame game, int pos) {
		char symbol = game.getAtPosition(pos);

		for(int i = 1; i < game.getDimension(); i++) {
			if(symbol == '\0' || symbol != game.getAtPosition(pos + i))
				return false;
		}
		return true;
	}

	private static boolean isWinningColumn(TicTacToeGame game, int pos) {
		char symbol = game.getAtPosition(pos);

		for(int i = 1; i < game.getDimension(); i++) {
			if(symbol == '\0' || symbol != game.getAtPosition(pos + i * game.getDimension()))
				return false;
		}
		return true;
	}

	private static boolean isWinningDiagonal(TicTacToeGame game, int pos, int dir) {
		char symbol = game.getAtPosition(pos);

		for(int i = 1; i < game.getDimension(); i++) {
			if(symbol == '\0' || symbol != game.getAtPosition(pos + i * (game.getDimension() + dir)))
				return false;
		}
		return true;
	}

	private static char findWinningChar(TicTacToeGame game) {
		for(int i = 0; i < game.getDimension(); i++) {

			if(isWinningRow(game, i * game.getDimension()))
				return game.getAtPosition(i * game.getDimension());
			if(isWinningColumn(game, i))
				return game.getAtPosition(i);
		}

		if(isWinningDiagonal(game, 0, 1))
			return game.getAtPosition(0);

		if(isWinningDiagonal(game, game.getDimension() - 1, -1))
			return game.getAtPosition(game.getDimension() - 1);

		if(!openSpaces(game))
			return 't';

		return '\0';
	}

	public static boolean gameOver(TicTacToeGame game) {
		return findWinningChar(game) != '\0';
	}

	public static TicTacToePlayer winner(TicTacToeGame game, TicTacToePlayer p1, TicTacToePlayer p2) {
		char win = findWinningChar(game);
		if(win == p1.getXO())
			return p1;
		else if(win == p2.getXO())
			return p2;
		return null;
	}

	private static boolean openSpaces(TicTacToeGame game) {
		for(int i = 0; i < getSpots(game); i++) {
			if(game.getAtPosition(i) == '\0')
				return true;
		}
		return false;
	}

	public int findMove(TicTacToeGame game) {
		for(int i = 0; i < getSpots(game); i++) {
			if(game.getAtPosition(i) == '\0')
				return i;
		}
		return -1;
	}

	public int[] findAllMoves(TicTacToeGame game) {
		int move = 0;
		int[] temp = new int[getSpots(game)];

		for(int i = 0; i < temp.length; i++) {
			if(game.getAtPosition(i) == '\0')
				temp[move++] = i;
		}

		int[] moves = new int[move];

		for(move = 0; move < moves.length; move++)
			moves[move] = temp[move];

		return moves;
	}

	public int findWinningMove(TicTacToeGame game) {
		TicTacToePlayer reset = new TicTacToePlayer("reset", '\0');
		TicTacToePlayer other = new TicTacToePlayer("other", isX ? 'o' : 'x');
		int[] moves = findAllMoves(game);

		for(int i = 0; i < moves.length; i++) {
			play(game, moves[i]);
			TicTacToePlayer winner = winner(game, this, other);
			reset.play(game, moves[i]);
			if(winner != null && winner.isX() == isX)
				return moves[i];
		}
		return -1;
	}

	public int findBlockingMove(TicTacToeGame game) {
		TicTacToePlayer otherP = new TicTacToePlayer("other", isX ? 'o' : 'x');
		int winPos = otherP.findWinningMove(game);
		return winPos;
	}

	public void play(TicTacToeGame game, int pos) {
		game.play(pos, this);
	}
}