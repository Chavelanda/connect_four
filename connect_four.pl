even(N) :- mod(N,2) =:= 0.

odd(N) :- mod(N,2) =:= 1.

matrix(Matrix, I, J, Value) :-
  nth0(I, Matrix, Row),
  nth0(J, Row, Value).

% Replace with value Val in list at position J
replace([_|T], J, J, Val, [Val|T]).

replace([H|T], I, J, Val, [H|OtherT]) :-
  NewI is I + 1,
  replace(T, NewI, J, Val, OtherT).

max_to_move([PosH|[]], S) :-
  sum_list(PosH, S1),
  SFinal is S + S1,
  even(SFinal).

max_to_move([PosH|PosT], S) :-
  sum_list(PosH, S1),
  S2 is S + S1,
  max_to_move(PosT, S2).

max_to_move(Pos) :-
  max_to_move(Pos, 0).

moves(Pos, PosList) :-
  max_to_move(Pos), !,
  moves([], Pos, 0, 0, PosList, 1).

moves(Pos, PosList) :-
  \+ max_to_move(Pos), !,
  moves([], Pos, 0, 0, PosList, -1).

% Stop when all the rows have been examined
moves(_, _, 3, _, [], _).

% If a row has been completely examined, then examine next row.
moves(LowerBoard, [BoardI|UpperBoard], I, 3, PosList, Player) :-
  append(LowerBoard, [BoardI], NewLowerBoard),
  NewI is I + 1,
  moves(NewLowerBoard, UpperBoard, NewI, 0, PosList, Player).

% If there is no disc in the first row, then it is possible to play it
% The parameters are: Lower part the board, Upper part of the board, Row, Column,
% Possible new positions list
moves([], [BoardI|UpperBoard], 0, J, [PosListH|PosListT], Player) :-
  nth0(J, BoardI, 0), !,
  replace(BoardI, 0, J, Player, PosListHI),
  append([], [PosListHI|UpperBoard], PosListH),
  NewJ is J + 1,
  moves([], [BoardI|UpperBoard], 0, NewJ, PosListT, Player).

moves([], Board, 0, J, PosList, Player) :-
  NewJ is J + 1,
  moves([], Board, 0, NewJ, PosList, Player).

% If it is not the first row, then to put a disc there should be a disc in the
% lower row
moves(LowerBoard, [BoardI|UpperBoard], I, J, [PosListH|PosListT], Player) :-
  nth0(J, BoardI, 0),
  ICheck is I - 1,
  matrix(LowerBoard, ICheck, J, Val),
  Val =\= 0, !,
  replace(BoardI, 0, J, Player, PosListHI),
  append(LowerBoard, [PosListHI|UpperBoard], PosListH),
  NewJ is J + 1,
  moves(LowerBoard, [BoardI|UpperBoard], I, NewJ, PosListT, Player).

moves(LowerBoard, UpperBoard, I, J, PosList, Player) :-
  NewJ is J + 1,
  moves(LowerBoard, UpperBoard, I, NewJ, PosList, Player).
