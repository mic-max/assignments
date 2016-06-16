/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public abstract class AbstractCard {

	protected static String[] SUITS = new String[] {
		"Spades", "Hearts", "Clubs", "Diamonds"
	};
	protected static String[] RANKS = new String[] {
		"Joker", "Ace", "Two", "Three", "Four", "Five", "Six", 
		"Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"
	};

	protected String suit;
	protected int rank;

	public AbstractCard(String suit, int rank){
		this.suit = suit;
		this.rank = rank;
	}

	public String getSuit() { return suit; }
	public int getRank() { return rank; }
}