% Name     : Michael Maxwell
% Student #: 10106277

% ------------------- Question 3 -------------------

% lastEle(X, L): finds the last element of a list
lastEle(X, [X]).
lastEle(X, [_|T]) :- lastEle(X, T).

% gradeMap(L, R): maps a list of grades to their corresponding grade letters
gradeMap([], []).
gradeMap([G|T], [a|R]) :- G >= 80, G =< 100, gradeMap(T, R).
gradeMap([G|T], [b|R]) :- G >= 70, G < 80, gradeMap(T, R).
gradeMap([G|T], [c|R]) :- G >= 60, G < 70, gradeMap(T, R).
gradeMap([G|T], [d|R]) :- G >= 50, G < 60, gradeMap(T, R).
gradeMap([G|T], [f|R]) :- G >= 0, G < 50, gradeMap(T, R).

% split(List, Pivot, L1, L2): splits 2 lists using a pivot value
split([], _, [], []).
split([H|List], Pivot, [H|L1], L2) :- H =< Pivot, split(List, Pivot, L1, L2).
split([H|List], Pivot, L1, [H|L2]) :- H > Pivot, split(List, Pivot, L1, L2).

% myNextto(X, Y, L): succeeds when elements X, Y exists together in a list
myNextto(X, Y, [X, Y|_]).
myNextto(X, Y, [_|T]) :- myNextto(X, Y, T).

% ------------------- Question 4 -------------------

% myAppend(L1, L2, L3): appends two lists
myAppend([], [], []).
myAppend([], [H2|T2], [H2|T3]) :- myAppend([], T2, T3).
myAppend([H1|T1], L2, [H1|T3]) :- myAppend(T1, L2, T3).

% myFirst(X, L): true if X is the first item in L, using myAppend
myFirst(X, L) :- myAppend([X], _, L).

% myLast(X, L): true if X is the last item in L, using append
myLast(X, L) :- append(_, [X], L).

% myNextto2(X, Y, L): succeeds when elements X, Y exists together in a list, using append
myNextto2(X, Y, [X2,Y2|_]) :- append([X], [Y], [X2,Y2]).
myNextto2(X, Y, [_|T]) :- myNextto2(X, Y, T).

% myReverse(L1, L2): succeeds when reversing L1 equals L2, using append
myReverse([], []).
myReverse([H|T], L) :- myReverse(T, RT), append(RT, [H], L).

% ------------------- Question 5 -------------------

% list(L): succeeds if given a list, without using is_list
list([]).
list([_|_]).

% treeFlat(T, L): succeeds if the T contains the same elements as the list, without using flatten
treeFlat(T, L) :- treeFlat(T, L, []).
treeFlat([], R, R) :- !.
treeFlat([H|T], R, C) :- !, treeFlat(H, R, C1), treeFlat(T, C1, C).
treeFlat(T, [T|C], C).

% treeSum(T, S): succeeds if the sum of all elements in T equals S
treeSum([], 0).
treeSum(L, S) :- treeFlat(L, [Val|T]), treeSum(T, Total), S is Val + Total.

% treeMerge(T1, T2, R): succeeds when R is the result of merging the trees T1 and T2
% base cases
treeMerge([], [], []). % 2 empty lists
treeMerge(Val, [], []) :- not(list(Val)). % leaf
treeMerge([], Val, []) :- not(list(Val)).
treeMerge([Subtree], [], [Subtree]). % subtree with empty list
treeMerge([], [Subtree], [Subtree]).

% merges first subtree or leafs of the input trees into the result tree
treeMerge([H1|T1], [H2|T2], [HR|TR]) :- treeMerge(H1, H2, HR), treeMerge(T1, T2, TR).
treeMerge([H1|T1], [H2|T2], [HR|TR]) :- not(list(H1)), not(list(H2)), HR is H1 * H2, treeMerge(T1, T2, TR).
treeMerge(Val, [H2|T2], [HR|TR]) :- not(list(Val)), not(list(H2)), HR is Val * H2, treeMerge(Val, T2, TR).
treeMerge([H1|T1], Val, [HR|TR]) :- not(list(Val)), not(list(H1)), HR is Val * H1, treeMerge(T1, Val, TR).
treeMerge(Val, [H2|T2], [HR|TR]) :- not(list(Val)), treeMerge(Val, H2, HR), treeMerge(Val, T2, TR).
treeMerge([H1|T1], Val, [HR|TR]) :- not(list(Val)), treeMerge(H1, Val, HR), treeMerge(T1, Val, TR).

% Testing
:- begin_tests(lists).
:- use_module(library(lists)).

% ------------------- Question 3 -------------------

test(lastEle) :-
  lastEle(0, [0]),
  lastEle(today, [how, are, you, today]),
  lastEle(5, [1, 2, 3, 4, 5]),
  lastEle([9, 7], [[1, 9], [9, 7]]),
  not(lastEle(_, [])).

test(gradeMap) :-
  gradeMap([], []),
  gradeMap([66], [c]),
  gradeMap([0, 16, 49, 55, 63, 78, 92], [f, f, f, d, c, b, a]),
  gradeMap([0, 49, 50, 59, 60, 69, 70, 79, 80, 100], [f, f, d, d, c, c, b, b, a, a]),
  gradeMap([10, 55, 65, 75, 85], [f, d, c, b, a]).

test(split) :-
  split([], 5, [], []),
  split([1, 9], 5, [1], [9]),
  split([99, 50, 51, 49, 1], 50, [50, 49, 1], [99, 51]),
  split([4, 7, 1, 8, 2, 9, 3], 5, [4, 1, 2, 3], [7, 8, 9]).

test(myNextto) :-
  myNextto(a, b, [c, a, b, d]),
  myNextto(b, d, [c, a, b, d]),
  myNextto(c, a, [c, a, b, d]),
  myNextto(1, 2, [1, 2]),
  myNextto([a], [b], [5, [a], [b], 7]).

% ------------------- Question 4 -------------------

test(myAppend) :-
  myAppend([], [], []),
  myAppend([a, b], [], [a, b]),
  myAppend([], [c, d], [c, d]),
  myAppend([a, b], [c, d], [a, b, c, d]),
  myAppend([9, 8, 7], [1, 2, 3], [9, 8, 7, 1, 2, 3]).

test(myFirst) :-
  myFirst(0, [0]),
  myFirst(how, [how, are, you, today]),
  myFirst(1, [1, 2, 3, 4, 5]),
  myFirst([1, 9], [[1, 9], [9, 7]]),
  not(myFirst(_, [])).

test(myLast) :-
  myLast(0, [0]),
  myLast(today, [how, are, you, today]),
  myLast(5, [1, 2, 3, 4, 5]),
  myLast([9, 7], [[1, 9], [9, 7]]).

test(myNextto2) :-
  myNextto2(a, b, [c, a, b, d]),
  myNextto2(b, d, [c, a, b, d]),
  myNextto2(c, a, [c, a, b, d]),
  myNextto2(1, 2, [1, 2]),
  myNextto2([a], [b], [5, [a], [b], 7]).

test(myReverse) :-
  myReverse([], []),
  myReverse([X], [X]),
  myReverse([a, b], [b, a]),
  myReverse([60, [50, 45], 14], [14, [50, 45], 60]),
  myReverse([1, 2, 3], [3, 2, 1]).

% ------------------- Question 5 -------------------

test(list) :-
  list([]),
  list([_]),
  list([a, b, c]),
  list([1, 2, 3]).

test(treeFlat) :-
  treeFlat([1, [2, 3], [[4, [5]], 6]], [1, 2, 3, 4, 5, 6]).

test(treeSum) :-
  treeSum([], 0),
  treeSum([[[[[[[2]]]]]]], 2),
  treeSum([[1], [2], [3]], 6),
  treeSum([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 55),
  treeSum([[1, [2, 3]], 4, [5, 6, [7]]], 28),
  treeSum([[5, [3, 8]], 11, [4, 1, [0]]], 32).

test(treeMerge) :-
  treeMerge([], [], []),
  treeMerge(5, [], []),
  treeMerge([], 5, []),
  treeMerge([1], [], [1]),
  treeMerge([], [2], [2]),
  treeMerge([2, [2, 3], [4, 5, [5, 6, 7]]], [[5, [4, 3], [2, 1]], 6, [7, 8]], [[10, [8, 6], [4, 2]], [12, 18], [28, 40, [5, 6, 7]]]).

:- end_tests(lists).
