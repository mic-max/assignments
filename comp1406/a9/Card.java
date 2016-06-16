/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public class Card extends AbstractCard implements Comparable<Card> {

	public Card(String suit, int rank) {
		super(suit, rank);
		if(2 > rank || rank > 14)
			this.rank = 0;
	}

	public Card(String suit, String rank) {
		super(suit, 0);
		for(int i = 2; i < AbstractCard.RANKS.length; i++) {
			if(rank.equals(AbstractCard.RANKS[i]))
				this.rank = i;
		}
		if(rank.equals("Ace"))
			this.rank = 14;
	}

	private int suitValue() {
		for(int i = 0; i < AbstractCard.SUITS.length; i++) {
			if(AbstractCard.SUITS[i].equals(suit))
				return AbstractCard.SUITS.length - i;
		}
		return 0;
	}

	public int compareTo(Card other) {
		int comp = suitValue() - other.suitValue();
		if(comp == 0 || rank == 0 || other.rank == 0)
			return rank - other.rank;
		return comp;
	}

	public String toString() {
		String s = "";
		if(2 <= rank  && rank <= 13)
			s += AbstractCard.RANKS[rank];
		else if(rank == 14)
			s += AbstractCard.RANKS[1];
		else
			s += AbstractCard.RANKS[0];
		return s + " of " + suit;
	}
}