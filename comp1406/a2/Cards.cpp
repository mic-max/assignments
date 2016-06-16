/*
    Student Name:     Michael Maxwell
    Student Number:   101006277
    References:       Hinek,      J. (2016). COMP 1406 Live Demo Vampiric Numbers. http://carleton.ca/culearn
                      Stroustrup, B. (2013). The C++ Programming Language.
*/

#include <sstream>
#include "Cards.h"

int findSuit(cardType card) {
    const char suitOrder[] = {'s', 'd', 'c', 'h'};
    for(int i = 0; i < sizeof(suitOrder); i++) {
        if(card.suit == suitOrder[i])
            return i;
    }
    return -1;
}

void swap(cardType &a, cardType &b) {
    cardType t = a;
    a = b;
    b = t;
}

void sortSuit(handType &hand) {
    for(int i = 1; i < hand.numCards; i++) {
		for(int j = 0; j < hand.numCards - i; j++) {
			if(findSuit(hand.cards[j]) < findSuit(hand.cards[j + 1]))
                  swap(hand.cards[j], hand.cards[j + 1]);
		}
	}
}

void sortRank(handType &hand) {
    for(int i = 1; i < hand.numCards; i++) {
		for(int j = 0; j < hand.numCards - i; j++) {
			if(hand.cards[j].rank < hand.cards[j + 1].rank)
                  swap(hand.cards[j], hand.cards[j + 1]);
		}
	}
}

int compare(cardType firstCard, cardType seconCard) {
    if(firstCard.rank < seconCard.rank)
        return -1;
    else if(firstCard.rank > seconCard.rank)
        return 1;
    else if(findSuit(firstCard) < findSuit(seconCard))
        return -1;
    else if(findSuit(firstCard) > findSuit(seconCard))
        return 1;
    return 0;
}

int compareRank(cardType c1, cardType c2) {
    if(c1.rank < c2.rank)
        return -1;
    else if(c1.rank > c2.rank)
        return 1;
    return 0;
}

int compare(handType firstHand, handType secondHand) {
    sortRank(firstHand);
    sortRank(secondHand);

    int i = 0;

    while(compareRank(firstHand.cards[i], secondHand.cards[i]) == 0) {
        i++;
        if(firstHand.numCards == i && firstHand.numCards < secondHand.numCards)
            return -1;
        else if (secondHand.numCards == i && secondHand.numCards < firstHand.numCards)
            return 1;
        else if (firstHand.numCards == secondHand.numCards == i)
            break;
    }
    return compareRank(firstHand.cards[i], secondHand.cards[i]);
}

std::string displayHand(handType hand) {
    sortSuit(hand);
    std::stringstream s;
    for(int i = 0; i < hand.numCards; i++) {
        switch(hand.cards[i].rank) {
            case 11:
                s << "Jack";
                break;
            case 12:
                s << "Queen";
                break;
            case 13:
                s << "King";
                break;
            case 14:
                s << "Ace";
                break;
            default:
                s << hand.cards[i].rank;
                break;
        }
        s << " of ";
        switch(hand.cards[i].suit) {
            case 'c':
                s << "Clubs";
                break;
            case 'd':
                s << "Diamonds";
                break;
            case 'h':
                s << "Hearts";
                break;
            case 's':
                s << "Spades";
                break;
        }
        s << '\n';
    }
    return s.str();
}
