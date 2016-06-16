/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

import java.util.Arrays;

public class TestCards {

	public static void main(String[] args) {
		Card[] hand = new Card[56];
		// generate a full deck of cards
		int count = 0;
		for(int suit = 0; suit < AbstractCard.SUITS.length; suit++) {
			for(int rank = 2; rank <= 15; rank++) {
				hand[count++] = new Card(AbstractCard.SUITS[suit], rank);
			}
		}
		System.out.println(Arrays.toString(hand));
		// shuffe the deck
		for(int i = 0; i < hand.length; i++) {
			int k = (int) (Math.random() * (hand.length - i));
			// swap card i with card i + k
			Card tmp = hand[i];
			hand[i] = hand[i + k];
			hand[i + k] = tmp;
		}
		System.out.println(Arrays.toString(hand));
		// Sort the deck using the Arrays.sort method.
		// Calling the sort method like this only works because the Card
		// class implements Comparable (it expects to find a compareTo method)
		Arrays.sort(hand);
		System.out.println(Arrays.toString(hand));

		Card c1 = new Card("Hearts", "Queen");
		Card c2 = new Card("Spades", "Joker");
		Card c3 = new Card("Spades", "Ace");
		System.out.println(c1);
		System.out.println(c2);
		System.out.println(c3);
		System.out.println(c1.compareTo(c2) < 0);
		System.out.println(c1.compareTo(c2) > 0);
	}
}