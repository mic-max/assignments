% Database of Facts

% male(Name)
male(mike).
male(jim).
male(john).
male(rob).
male(glen).
male(dave).
male(chris).
male(andrew).
male(alex).
male(shawn).
male(maxwellM).
male(smithM).

% female(Name)
female(pamela).
female(jennifer).
female(heather).
female(darlene).
female(sandraM).
female(sandraB).
female(sarah).
female(taylor).
female(abby).
female(maxwellF).
female(smithF).

% father(Father,Child)
father(john,mike).
father(john,heather).
father(john,jennifer).
father(jim,chris).
father(jim,andrew).
father(rob,shawn).
father(rob,abby).
father(rob,taylor).
father(dave,alex).
father(dave,sarah).
father(maxwellM,jim).
father(maxwellM,rob).
father(maxwellM,john).
father(smithM,pamela).
father(smithM,sandraB).
father(smithM,glen).

% mother(Mother,Child)
mother(pamela,mike).
mother(pamela,heather).
mother(pamela,jennifer).
mother(darlene,chris).
mother(darlene,andrew).
mother(sandraM,shawn).
mother(sandraM,abby).
mother(sandraM,taylor).
mother(sandraB,alex).
mother(sandraB,sarah).
mother(maxwellF,jim).
mother(maxwellF,john).
mother(maxwellF,rob).
mother(smithF,pamela).
mother(smithF,sandraB).
mother(smithF,glen).

% married(Husband,Wife)
married(john,pamela).
married(jim,darlene).
married(rob,sandraM).
married(dave,sandraB).
married(maxwellM,maxwellF).
married(smithM,smithF).

% Relationships
different(X,Y):- X \= Y.

parent(Parent,Child):- father(Parent,Child).
parent(Parent,Child):- mother(Parent,Child).

is_mother(Mother):- mother(Mother,_).

is_father(Father):- father(Father,_).

sister(Sister,Sibling):- female(Sister), parent(Parent,Sister), parent(Parent,Sibling), different(Sister,Sibling).

brother(Brother,Sibling):- male(Brother), parent(Parent,Brother), parent(Parent,Sibling), different(Brother,Sibling).

aunt(Aunt,Nibling):- sister(Aunt,Parent), parent(Parent,Nibling).
aunt(Aunt,Nibling):- married(Uncle,Aunt), uncle(Uncle,Nibling).

uncle(Uncle,Nibling):- brother(Uncle,Parent), parent(Parent,Nibling).
uncle(Uncle,Nibling):- married(Uncle,Aunt), aunt(Aunt,Nibling).

grandfather(Grandfather,Grandchild):- father(Grandfather,Parent), parent(Parent,Grandchild).

grandmother(Grandmother,Grandchild):- mother(Grandmother,Parent), parent(Parent,Grandchild).

ancestor(Ancestor,Descendant):- parent(Ancestor,Descendant).
ancestor(Ancestor,Descendant):- parent(Ancestor,Z), ancestor(Z,Descendant).

% Testing
