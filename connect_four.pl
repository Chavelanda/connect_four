% Connect 4

:- consult(utils).

% [[0,0,1],[0,0,0],[0,0,0]] This is an example of a mini board
% [0,0,1] This is the lowest row of the mini board


end_of_row(J) :-
  J is 7.

end_of_row(J) :-
  J is -1.


end_of_board(I) :-
  I is 6.


% Base case
% Summation ended, max is to move if the sum is even
max_to_move([PosH|[]], S) :-
  sum_list(PosH, S1),
  SFinal is S + S1,
  even(SFinal).

% Sum up all the rows of the board
% S is the sum accumulator
max_to_move([PosH|PosT], S) :-
  sum_list(PosH, S1),
  S2 is S + S1,
  max_to_move(PosT, S2).

% Checks if max has to move in Pos.
% Max is to move if the sum of all the discs is even
max_to_move(Pos) :-
  max_to_move(Pos, 0).

% Min moves when max does not move
min_to_move(Pos) :-
  \+ max_to_move(Pos).


% If the game is over, no move is allowed
% The game is over if the opponent has won in the previous turn
moves(Pos, []) :-
  (max_to_move(Pos), end_of_game([], Pos, 0, 0, DiscsInLine, -1));
  (min_to_move(Pos), end_of_game([], Pos, 0, 0, DiscsInLine, 1).

% Relates a position (Pos) to all the reachable positions (PosList) by executing valid moves
% Max must move
moves(Pos, PosList) :-
  max_to_move(Pos), !,
  moves([], Pos, 0, 0, PosList, 1).

% Min must move
moves(Pos, PosList) :-
  min_to_move(Pos), !,
  moves([], Pos, 0, 0, PosList, -1).


% Base case
% Stop when all the rows have been examined
% There no more reachable positions
moves(_, _, I, _, [], _) :-
  end_of_board(I).

% Base case
% If a row has been completely examined, then examine next row.
moves(LowerBoard, [Row|UpperBoard], I, J, PosList, Player) :-
  end_of_row(J),
  append(LowerBoard, [Row], NewLowerBoard),
  NewI is I + 1,
  moves(NewLowerBoard, UpperBoard, NewI, 0, PosList, Player).

% If the examined position is empty (no disc => 0) and we are in the first row, or if the
% examined position is empty and the lower position is not empty, then we can
% play a disc in the examined position.
% The parameters are: Lower part the board, [Row examined|Upper part of the board],
% Row index, Column index, Possible new positions list, Player
moves(LowerBoard, [Row|UpperBoard], I, J, [PosListH|PosListT], Player) :-
  ((I is 0, nth0(J, Row, 0));
  (nth0(J, Row, 0), ICheck is I - 1, matrix(LowerBoard, ICheck, J, LowerVal), LowerVal =\= 0)),
  replace(Row, 0, J, Player, PosListHRow),
  append(LowerBoard, [PosListHRow|UpperBoard], PosListH),
  NewJ is J + 1,
  moves(LowerBoard, [Row|UpperBoard], I, NewJ, PosListT, Player).

% If the examined position is not playable, we go to the next one
moves(LowerBoard, UpperBoard, I, J, PosList, Player) :-
  NewJ is J + 1,
  moves(LowerBoard, UpperBoard, I, NewJ, PosList, Player).


% Base case
% If four discs of the right player are found in a line, then the game is over
end_of_game(_, _, _, _, 4, 1).
end_of_game(_, _, _, _, -4, -1).

% Base case
% The whole board has been examined and the game is not over
end_of_game(_, _, I, _, _, _) :-
  end_of_board(I),
  false.

% When an entire row has been scanned, we continue the search in the upper row
end_of_game(_, [Row|UpperBoard], I, J, DiscsInLine, Player) :-
  end_of_row(J),
  NewI is I + 1,
  end_of_game(Row, UpperBoard, NewI, 0, DiscsInLine, Player).

end_of_game(LowerRow, [Row|UpperBoard], I, J, DiscsInLine, Player) :-
  nth0(J, Row, Player), % If the disc is not of the right player, then it fails.
  OpponentPlayer is Player * -1,
  PreviousJ is J - 1,
  NewJ is J + 1,
