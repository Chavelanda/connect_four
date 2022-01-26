% alpha beta relation. GoodPos is a possible next position that satisfies the alpha beta values.
% first finds the possible moves from Pos, finds a good enough position if Pos is not a leaf
% otherwise it takes the value of the leaf node
alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, MaxDepth) :-
  moves(Pos, PosList), !,
  Depth < MaxDepth,
  boundedbest(PosList, Alpha, Beta, GoodPos, Val, Depth, MaxDepth).

alphabeta(Pos, Alpha, Beta, GoodPos, Val, _, _) :-
  staticval(Pos, Val).

% finds a good enough position GoodPos in the list Poslist so that the backed-up
% value Val of GoodPos is a good enough approximation with respect to Alpha and Beta
boundedbest([Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth, MaxDepth) :-
  NewDepth is Depth + 1,
  alphabeta(Pos, Alpha, Beta, _, Val, NewDepth, MaxDepth),
  goodenough(Poslist, Alpha, Beta, Pos, Val, GoodPos, GoodVal).

% no other candidates
goodenough([], _, _, Pos, Val, Pos, Val) :- !.

% maximum reached
goodenough(_, Alpha, Beta, Pos, Val, Pos, Val) :-
  min_to_move(Pos), Val > Beta, !.

% minimum reached
goodenough(_, Alpha, Beta, Pos, Val, Pos, Val) :-
  max_to_move(Pos), Val < Alpha, !.

goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal) :-
  newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),
  boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1),
  betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

newbounds(Alpha, Beta, Pos, Val, Val, Beta) :-
  min_to_move(Pos), Val > Alpha, !.

newbounds(Alpha, Beta, Pos, Val, Alpha, Val) :-
  max_to_move(Pos), Val < Beta, !.

newbounds(Alpha, Beta, _, _, Alpha, Beta).

betterof(Pos, Val, Pos1, Val1, Pos, Val) :-
  min_to_move(Pos), Val > Val1, !.

betterof(Pos, Val, Pos1, Val1, Pos, Val) :-
  max_to_move(Pos), Val < Val1, !.

betterof(_, _, Pos1, Val1, Pos1, Val1).
