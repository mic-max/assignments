// ---------------------------------------------------------------------------
// Student Name:     Michael Maxwell
// Student Number:   101006277
// References:       I did not use any reference material in developing this assignment.
// ---------------------------------------------------------------------------

#include "A4Types.h"
#include <iostream>

// constructors
Money::Money(){
    numDollars = numQuarters = numDimes = numNickels = numPennies = 0;
}

Money::Money(unsigned int dollars, unsigned int cents) : Money() {
    numDollars = dollars;
    numPennies = cents;
}

Money::Money(unsigned int dd, unsigned int q, unsigned int d, unsigned int n, unsigned int p){
    numDollars  = dd;
    numQuarters = q;
    numDimes    = d;
    numNickels  = n;
    numPennies  = p;
}

// getters
unsigned int Money::getDollars() { return numDollars; }
unsigned int Money::getQuarters(){ return numQuarters;}
unsigned int Money::getDimes()   { return numDimes;   }
unsigned int Money::getNickels() { return numNickels; }
unsigned int Money::getPennies() { return numPennies; }

unsigned int Money::getCents() {
    return numQuarters * 25 + numDimes * 10 + numNickels * 5 + numPennies;
}

unsigned int Money::numberOfCoins() {
    return numQuarters + numDimes + numNickels + numPennies;
}

// setters
void Money::addDollars(unsigned int d)  { numDollars  += d; }
void Money::addQuarters(unsigned int q) { numQuarters += q; }
void Money::addDimes(unsigned int d)    { numDimes    += d; }
void Money::addNickels(unsigned int n)  { numNickels  += n; }
void Money::addPennies(unsigned int p)  { numPennies  += p; }
void Money::addCents(unsigned int c)    { addPennies(c);    }

void Money::addMoney(Money m) {
    numDollars += m.numDollars;
    numPennies += m.getCents();
}

// other methods
// "... 2 dimes plus a nickel make a quarter to help you do this."
// Why would that help if you had $0.30, then you'd get 3 dimes
// instead of a quarter and a nickel which is less coins, jw
void Money::leastCoins() {
    numDollars += getCents() / 100;
    numPennies  = getCents() % 100;
    numQuarters = numDimes = numNickels = 0;
    while(numPennies >= 5) {
        if(numPennies >= 25) {
            numQuarters++;
            numPennies -= 25;
        } else if(numPennies >= 10) {
            numDimes++;
            numPennies -= 10;
        } else {
            numNickels++;
            numPennies -= 5;
        }
    }
}

Money* makeChange(Money& cost,  Money& paid) {
    if(cost.getDollars() * 100 + cost.getCents() <= paid.getDollars() * 100 + paid.getCents()) {
        Money* change = new Money(0,(paid.getDollars() - cost.getDollars()) * 100 + paid.getCents() - cost.getCents());
        change->leastCoins();
        return change;
    }
    return NULL;
}

Money* makeChangeNpPennies(Money& cost, Money& paid) {
    unsigned int xPennys = cost.getCents() % 5;
    if(xPennys < 3)
        cost.addCents(-xPennys);
    else
        cost.addCents(5 - xPennys);
    return makeChange(cost, paid);
}
