% Name     : Michael Maxwell
% Student #: 10106277

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
different(X,Y) :- X \= Y.

parent(Parent,Child) :- father(Parent,Child).
parent(Parent,Child) :- mother(Parent,Child).

is_mother(Mother) :- mother(Mother,_).

is_father(Father) :- father(Father,_).

sister(Sister,Sibling) :- female(Sister), parent(Parent,Sister), parent(Parent,Sibling), different(Sister,Sibling).

brother(Brother,Sibling) :- male(Brother), parent(Parent,Brother), parent(Parent,Sibling), different(Brother,Sibling).

aunt(Aunt,Nibling) :- sister(Aunt,Parent), parent(Parent,Nibling).
aunt(Aunt,Nibling) :- married(Uncle,Aunt), uncle(Uncle,Nibling).

uncle(Uncle,Nibling) :- brother(Uncle,Parent), parent(Parent,Nibling).
uncle(Uncle,Nibling) :- married(Uncle,Aunt), aunt(Aunt,Nibling).

grandfather(Grandfather,Grandchild) :- father(Grandfather,Parent), parent(Parent,Grandchild).

grandmother(Grandmother,Grandchild) :- mother(Grandmother,Parent), parent(Parent,Grandchild).

ancestor(Ancestor,Descendant) :- parent(Ancestor,Descendant).
ancestor(Ancestor,Descendant) :- parent(Ancestor,Z), ancestor(Z,Descendant).

% Family Tree
/*
maxwellM --- maxwellF                                                    smithM --- smithF
          |                                                                      |
-----------------------------------------------------             ------------------------------
|                   |                               |             |                |           |
jim --- darlene     rob --- sandraM                 john --- pamela       dave --- sandraB     glen
     |                    |                               |                     |
---------          -----------------         ---------------------            ---------
|       |          |        |      |         |         |         |            |       |
chris   andrew     taylor   abby   shawn     heather   mike      jennifer     sarah   alex
*/

% Testing
:- begin_tests(family).
:- use_module(library(family)).

test(different) :-
  different(mike, jennifer),
  different(1, 2),
  not(different(1, 1)).

test(parent) :-
  parent(maxwellM, jim),
  parent(maxwellM, john),
  parent(maxwellM, rob),
  parent(maxwellF, jim),
  parent(maxwellF, john),
  parent(maxwellF, rob),

  parent(smithM, sandraB),
  parent(smithM, pamela),
  parent(smithM, glen),
  parent(smithF, sandraB),
  parent(smithF, pamela),
  parent(smithF, glen),

  parent(jim,chris),
  parent(jim,andrew),
  parent(darlene,chris),
  parent(darlene,andrew),

  parent(john,heather),
  parent(john,mike),
  parent(john,jennifer),
  parent(pamela,heather),
  parent(pamela,mike),
  parent(pamela,jennifer),

  parent(rob,taylor),
  parent(rob,abby),
  parent(rob,shawn),
  parent(sandraM,taylor),
  parent(sandraM,abby),
  parent(sandraM,shawn),

  parent(dave,sarah),
  parent(dave,alex),
  parent(sandraB,sarah),
  parent(sandraB,alex),

% Non-Parent Tests
  not(parent(chris,_)),
  not(parent(andrew,_)),
  not(parent(heather,_)),
  not(parent(mike,_)),
  not(parent(jennifer,_)),
  not(parent(taylor,_)),
  not(parent(abby,_)),
  not(parent(shawn,_)),
  not(parent(sarah,_)),
  not(parent(alex,_)),
  not(parent(glen,_)).

test(is_mother) :-
  is_mother(maxwellF),
  is_mother(smithF),
  is_mother(darlene),
  is_mother(pamela),
  is_mother(sandraM),
  is_mother(sandraB),

% Non-Mother Tests
  not(is_mother(john)),
  not(is_mother(mike)),
  not(is_mother(dave)),
  not(is_mother(heather)),
  not(is_mother(taylor)),
  not(is_mother(jennifer)).

test(is_father) :-
  is_father(maxwellM),
  is_father(smithM),
  is_father(jim),
  is_father(john),
  is_father(rob),
  is_father(dave),

% Non-Father Tests
  not(is_father(mike)),
  not(is_father(glen)),
  not(is_father(alex)),
  not(is_father(shawn)),
  not(is_father(pamela)),
  not(is_father(chris)).

test(sister) :-
  sister(sandraB,pamela),
  sister(sandraB,glen),
  sister(pamela,sandraB),
  sister(pamela,glen),
  sister(heather,mike),
  sister(heather,jennifer),
  sister(jennifer,heather),
  sister(jennifer,mike),
  sister(taylor,abby),
  sister(taylor,shawn),
  sister(abby,taylor),
  sister(abby,shawn),
  sister(sarah,alex),

% Non-Sister Tests
  not(sister(mike,jennifer)),
  not(sister(mike,heather)),
  not(sister(pamela,john)),
  not(sister(chris,andrew)),
  not(sister(shawn,taylor)),
  not(sister(maxwellF,smithM)).

test(brother) :-
  brother(jim,john),
  brother(jim,rob),
  brother(john,jim),
  brother(john,rob),
  brother(glen,sandraB),
  brother(glen,pamela),
  brother(chris,andrew),
  brother(andrew,chris),
  brother(mike,heather),
  brother(mike,jennifer),
  brother(shawn,taylor),
  brother(shawn,abby),
  brother(alex,sarah),

% Non-Brother Tests
  not(brother(heather,mike)),
  not(brother(john,dave)),
  not(brother(dave,glen)),
  not(brother(chris,shawn)),
  not(brother(dave,pamela)),
  not(brother(john,pamela)).

test(aunt) :-
  aunt(darlene,heather),
  aunt(darlene,mike),
  aunt(darlene,jennifer),
  aunt(darlene,taylor),
  aunt(darlene,abby),
  aunt(darlene,shawn),

  aunt(sandraM,chris),
  aunt(sandraM,andrew),
  aunt(sandraM,heather),
  aunt(sandraM,mike),
  aunt(sandraM,jennifer),

  aunt(pamela,chris),
  aunt(pamela,andrew),
  aunt(pamela,taylor),
  aunt(pamela,abby),
  aunt(pamela,shawn),
  aunt(pamela,sarah),
  aunt(pamela,alex),

  aunt(sandraB,heather),
  aunt(sandraB,mike),
  aunt(sandraB,jennifer),

% Non-Aunt Tests
  not(aunt(mike,taylor)),
  not(aunt(glen,jennifer)),
  not(aunt(jim,mike)).
  % not(aunt(pamela,glen)),
  % not(aunt(sandraB,andrew)),
  % not(aunt(sandraM,alex)).

test(uncle) :-
  uncle(jim,heather),
  uncle(jim,mike),
  uncle(jim,jennifer),
  uncle(jim,taylor),
  uncle(jim,abby),
  uncle(jim,shawn),

  uncle(john,chris),
  uncle(john,andrew),
  uncle(john,taylor),
  uncle(john,abby),
  uncle(john,shawn),
  uncle(john,sarah),
  uncle(john,alex),

  uncle(rob,chris),
  uncle(rob,andrew),
  uncle(rob,heather),
  uncle(rob,mike),
  uncle(rob,jennifer),

  uncle(dave,heather),
  uncle(dave,mike),
  uncle(dave,jennifer),

  uncle(glen,heather),
  uncle(glen,mike),
  uncle(glen,jennifer),
  uncle(glen,sarah),
  uncle(glen,alex),

% Non-Uncle Tests
  not(uncle(mike,shawn)),
  not(uncle(glen,chris)),
  not(uncle(sandraB,heather)),
  not(uncle(chris,alex)).
  % not(uncle(maxwellM,mike)),
  % not(uncle(john,glen)).

test(grandfather) :-
  grandfather(maxwellM,chris),
  grandfather(maxwellM,andrew),
  grandfather(maxwellM,heather),
  grandfather(maxwellM,mike),
  grandfather(maxwellM,jennifer),
  grandfather(maxwellM,taylor),
  grandfather(maxwellM,abby),
  grandfather(maxwellM,shawn),

  grandfather(smithM,heather),
  grandfather(smithM,mike),
  grandfather(smithM,jennifer),
  grandfather(smithM,sarah),
  grandfather(smithM,alex),

% Non-Grandfather Tests
  not(grandfather(smithM,andrew)),
  not(grandfather(smithF,alex)),
  not(grandfather(mike,john)),
  not(grandfather(jim,chris)).

test(grandmother) :-
  grandmother(maxwellF,chris),
  grandmother(maxwellF,andrew),
  grandmother(maxwellF,heather),
  grandmother(maxwellF,mike),
  grandmother(maxwellF,jennifer),
  grandmother(maxwellF,taylor),
  grandmother(maxwellF,abby),
  grandmother(maxwellF,shawn),

  grandmother(smithF,heather),
  grandmother(smithF,mike),
  grandmother(smithF,jennifer),
  grandmother(smithF,sarah),
  grandmother(smithF,alex),

% Non-grandmother Tests
  not(grandmother(smithF,andrew)),
  not(grandmother(maxwellF,alex)),
  not(grandmother(pamela,mike)),
  not(grandmother(darlene,chris)).

test(ancestor) :-

% parents
  ancestor(maxwellM, jim),
  ancestor(maxwellM, john),
  ancestor(maxwellM, rob),
  ancestor(maxwellF, jim),
  ancestor(maxwellF, john),
  ancestor(maxwellF, rob),

  ancestor(smithM, sandraB),
  ancestor(smithM, pamela),
  ancestor(smithM, glen),
  ancestor(smithF, sandraB),
  ancestor(smithF, pamela),
  ancestor(smithF, glen),

  ancestor(jim,chris),
  ancestor(jim,andrew),
  ancestor(darlene,chris),
  ancestor(darlene,andrew),

  ancestor(john,heather),
  ancestor(john,mike),
  ancestor(john,jennifer),
  ancestor(pamela,heather),
  ancestor(pamela,mike),
  ancestor(pamela,jennifer),

  ancestor(rob,taylor),
  ancestor(rob,abby),
  ancestor(rob,shawn),
  ancestor(sandraM,taylor),
  ancestor(sandraM,abby),
  ancestor(sandraM,shawn),

  ancestor(dave,sarah),
  ancestor(dave,alex),
  ancestor(sandraB,sarah),
  ancestor(sandraB,alex),

% grandfathers
  ancestor(maxwellM,chris),
  ancestor(maxwellM,andrew),
  ancestor(maxwellM,heather),
  ancestor(maxwellM,mike),
  ancestor(maxwellM,jennifer),
  ancestor(maxwellM,taylor),
  ancestor(maxwellM,abby),
  ancestor(maxwellM,shawn),

  ancestor(smithM,heather),
  ancestor(smithM,mike),
  ancestor(smithM,jennifer),
  ancestor(smithM,sarah),
  ancestor(smithM,alex),

% grandmothers
  ancestor(maxwellF,chris),
  ancestor(maxwellF,andrew),
  ancestor(maxwellF,heather),
  ancestor(maxwellF,mike),
  ancestor(maxwellF,jennifer),
  ancestor(maxwellF,taylor),
  ancestor(maxwellF,abby),
  ancestor(maxwellF,shawn),

  ancestor(smithF,heather),
  ancestor(smithF,mike),
  ancestor(smithF,jennifer),
  ancestor(smithF,sarah),
  ancestor(smithF,alex),

% Non-Ancestor Tests
  not(ancestor(mike,sarah)),
  not(ancestor(chris,andrew)),
  not(ancestor(chris,jim)),
  not(ancestor(jennifer,maxwellM)),
  not(ancestor(maxwellM,alex)),
  not(ancestor(pamela,maxwellF)).

:- end_tests(family).
