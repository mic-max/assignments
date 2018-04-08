% lastEle(X, L): finds the last element of a list
lastEle([], []):- !.
lastEle(X, [X|[]]):- !.
lastEle(X, [_|T]):- lastEle(X, T).

% gradeMap(L, R): maps a list of grades to their corresponding grade letters
gradeMap([], []).
gradeMap([G|T], [a|R]):- G > 79, gradeMap(T, R).
gradeMap([G|T], [b|R]):- G > 69, G < 80, gradeMap(T, R).
gradeMap([G|T], [c|R]):- G > 59, G < 70, gradeMap(T, R).
gradeMap([G|T], [d|R]):- G > 49, G < 60, gradeMap(T, R).
gradeMap([G|T], [f|R]):- G < 50, gradeMap(T, R).

% split(List, Pivot, L1, L2): splits 2 lists using a pivot value
split([], _, [], []).
split([H|List], Pivot, [H|L1], L2):- H =< Pivot, split(List, Pivot, L1, L2).
split([H|List], Pivot, L1, [H,L2]):- H > Pivot, split(List, Pivot, L1, L2).

% myNextto(X, Y, L): succeeds when elements X, Y exists together in a list
myNextto(X, Y, [X, Y|_]).
myNextto(X, Y, [_|T]):- myNextto(X, Y, T).

% myAppend(L1, L2, L3): appends two lists
myAppend([], L2, L2).


% /* Testing

lastEle(X, [how, are, you, today]). % X = today

gradeMap([0, 16, 49, 55, 63, 78, 92], R). % R = [f, f, f, d, c, b, a]

split([4, 7, 1, 8, 2, 9, 3], 5, L1, L2).
% L1 = [4, 1, 2, 3]
% L2 = [7, 8, 9]

myNextto(a, b, [c, a, b, d]). % True
myNextto(a, b, [c, a, d, b]). % False

myAppend([a, b], [c, d], L).
% L = [a, b, c, d]


% */
