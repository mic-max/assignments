/**
*	@author Michael Maxwell
*	@since 2016/03/02
*	@custom.citations I did not use any reference material in developing this assignment.
*/

import java.util.Scanner;

public class TicTacToeApp {

	public static void main(String[] args) {

		Scanner keyboard = new Scanner(System.in);
		String input = "";
		TicTacToeGame game = new TicTacToeGame();
		int pos, play, win, lose, tie;
		play = win = lose = tie = 0;

		System.out.print("Enter Name & X or O: ");
		TicTacToePlayer p1 = new TicTacToePlayer(keyboard.next(), keyboard.next().toLowerCase().charAt(0));
		TicTacToePlayer p2 = new TicTacToePlayer("Computer", p1.isX() ? 'o' : 'x');
		

		outer: while(input != "quit") {
			TicTacToePlayer cur = p1.isX() ? p2 : p1;
			while(!TicTacToePlayer.gameOver(game)) {
				cur = cur == p1 ? p2 : p1;
				System.out.println(game.show());
				if(cur == p1) {
					System.out.print(cur.getName() + "'s Move: ");
					input = keyboard.next();
					if(input.equals("quit"))
						break outer;
					pos = Integer.parseInt(input);
				} else {
					pos = cur.findWinningMove(game);
					if(pos < 0)
						pos = cur.findBlockingMove(game);
					if(pos < 0)
						pos = cur.findMove(game);
					System.out.println(cur.getName() + " played at " + pos + ".");
				}
				cur.play(game, pos);
			}
			System.out.println(game.show());
			TicTacToePlayer winningPlayer = TicTacToePlayer.winner(game, p1, p2);
			play++;
			if(winningPlayer == p1) {
				win++;
				System.out.println("You won!");
			} else if (winningPlayer == p2) {
				lose++;
				System.out.println("You Lost!");
			} else {
				tie++;
				System.out.println("Tie Game.");
			}
			game = new TicTacToeGame();
		}

		System.out.println(play + " plays\n" + win + " wins\n" + lose + " losses\n" + tie + " ties");
	}
}