%male(Name)
male(john).
male(bob).
male(mike).
male(luke).
male(anakin).
male(jesus).

%female(Name)
female(mary).
female(rachel).
female(monika).
female(jennifer).
female(heather).
female(pamela).

%father(Father,Child)
father(john,mike).
father(john,heather).
father(john,jennifer).
father(anakin,luke).

%mother(Mother,Child)
mother(pamela,mike).
mother(pamela,heather).
mother(pamela,jennifer).
mother(rachel,bob).
mother(rachel,monika).
mother(mary,jesus).

%married(X,Y)
married(john,pamela).
married(mike,monika).

parent(X,Y):- father(X,Y); mother(X,Y).
different(X,Y):- X \= Y.
is_mother(X):- mother(X,_).
is_father(X):- father(X,_).
aunt(X,Y):- sister(X,P), parent(P,Y).
uncle(X,Y):- brother(X,P), parent(P,Y).
sister(X,Y):- female(X), parent(P,X), parent(P,Y), different(X,Y).
brother(X,Y):- male(X), parent(P,X), parent(P,Y), different(X,Y).
grandfather(X,Y):- father(X,P), parent(P,Y).
grandmother(X,Y):- mother(X,P), parent(P,Y).
ancestor(X,Y):- parent(X,Y).
  ancestor(X,Y):- parent(X,Z), ancestor(Z,Y).
