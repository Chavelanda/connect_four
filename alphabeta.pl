% Alpha beta

:- consult(connect_four).
:- consult(heuristic).

% GoodPos is a possible next position that satisfies the alpha beta
% values. First finds the possible moves from Pos, finds a good enough
% position if Pos is not a leaf otherwise it takes the value of the leaf node.
% alphabeta is executed up to a certain depth. If max depth is reached,
% then the position is evaluated using the heuristic.
alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, MaxDepth) :-
  Depth < MaxDepth,
  moves(Pos, PosList),
  NewDepth is Depth + 1,
  !,
  (boundedbest(PosList, Alpha, Beta, GoodPos, Val, NewDepth, MaxDepth); staticval(Pos, Val)).

% Max depth has been reached
alphabeta(Pos, _, _, _, Val, _, _) :-
  staticval(Pos, Val).




% Finds a good enough position (known as GoodPos) in the list Poslist so
% that the backed-up value Val of GoodPos is a good enough approximation
% with respect to Alpha and Beta
boundedbest([Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth, MaxDepth) :-
  alphabeta(Pos, Alpha, Beta, _, Val, Depth, MaxDepth),
  goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, MaxDepth).




% no other candidates
goodenough([], _, _, Pos, Val, Pos, Val, _, _) :- !.

goodenough(_, Alpha, Beta, Pos, Val, Pos, Val, _, _) :-
  min_to_move(Pos), Val > Beta, !; % maximum reached
  max_to_move(Pos), Val < Alpha, !. % minimum reached

goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, MaxDepth) :-
  newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),
  boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1, Depth, MaxDepth),
  betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).



% min_to_move(Pos) is true if and only if the "minimizing" player
% must move in position Pos
newbounds(Alpha, Beta, Pos, Val, Val, Beta) :-
  min_to_move(Pos), Val > Alpha, !.

% max_to_move(Pos) is true if and only if the "maximizing" player
% must move in position Pos
newbounds(Alpha, Beta, Pos, Val, Alpha, Val) :-
  max_to_move(Pos), Val < Beta, !.

newbounds(Alpha, Beta, _, _, Alpha, Beta).




betterof(Pos, Val, _, Val1, Pos, Val) :-
  min_to_move(Pos), Val > Val1, !.

betterof(Pos, Val, _, Val1, Pos, Val) :-
  max_to_move(Pos), Val < Val1, !.

betterof(_, _, Pos1, Val1, Pos1, Val1).
