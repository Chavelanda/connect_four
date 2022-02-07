% Alpha beta relation.
:- consult(connect_four).

% GoodPos is a possible next position that satisfies the alpha beta
% values. First finds the possible moves from Pos, finds a good enough
% position if Pos is not a leaf otherwise it takes the value of the leaf
% node
% GoodPos � la migliore mossa, quella da fare
% Pos: input
% Depth: input
% MaxDepth: input
% Tutte le altre sono output
alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, MaxDepth) :-
  Depth < MaxDepth,
  moves(Pos, PosList),
  !,
  (boundedbest(PosList, Alpha, Beta, GoodPos, Val, Depth, MaxDepth);staticval(Pos, Val)).

alphabeta(Pos, _, _, _, Val, _, _) :-
  staticval(Pos, Val).
  % Staticval � l'euristica
  % Pos � input
  % Val � output

staticval(Pos, 0).

% ------------------------------------------------------------------------

% Finds a good enough position (known as GoodPos) in the list Poslist so
% that the backed-up value Val of GoodPos is a good enough approximation
% with respect to Alpha and Beta
boundedbest([Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth, MaxDepth) :-
  NewDepth is Depth + 1,
  alphabeta(Pos, Alpha, Beta, _, Val, NewDepth, MaxDepth),
  goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal).

% ------------------------------------------------------------------------

% no other candidates
goodenough([], _, _, Pos, Val, Pos, Val) :- !.

% maximum reached
goodenough(_, _, Beta, Pos, Val, Pos, Val) :-
  min_to_move(Pos), Val > Beta, !.

% minimum reached
goodenough(_, Alpha, _, Pos, Val, Pos, Val) :-
  max_to_move(Pos), Val < Alpha, !.

goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal) :-
  newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),
  boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1),
  betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

% ------------------------------------------------------------------------

newbounds(Alpha, Beta, Pos, Val, Val, Beta) :-
  min_to_move(Pos), Val > Alpha, !.   % min_to_move(Pos) is true if and only
                                      % if the "minimizing" player is to make
                                      % a move in position Pos

newbounds(Alpha, Beta, Pos, Val, Alpha, Val) :-
  max_to_move(Pos), Val < Beta, !.    % max_to_move(Pos) is true if and only
                                      % if the "maximizing" player is to make
                                      % a move in position Pos

newbounds(Alpha, Beta, _, _, Alpha, Beta).

% ------------------------------------------------------------------------

betterof(Pos, Val, Pos1, Val1, Pos, Val) :-
  min_to_move(Pos), Val > Val1, !.

betterof(Pos, Val, Pos1, Val1, Pos, Val) :-
  max_to_move(Pos), Val < Val1, !.

betterof(_, _, Pos1, Val1, Pos1, Val1).

% ------------------------------------------------------------------------
