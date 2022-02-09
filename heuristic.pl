:- consult(connect_four).

% Heuristic function
staticval(Pos, Val) :-
  % LowerBoard, UpperBoard, Row index, Column index,
  % Heuristic accumulator, Heuristic, Player
  heuristic([], Pos, 0, 0, 0, MaxVal, 1),
  heuristic([], Pos, 0, 0, 0, MinVal, -1),
  ((MaxVal =:= +1.0Inf, Val is +1.0Inf);
  (MinVal =:= +1.0Inf, Val is -1.0Inf);
  (Val is MaxVal - MinVal)).


% When the heuristic is infinite
heuristic(_, _, _, _, Val, Val, _) :-
  Val =:= +1.0Inf;
  Val =:= -1.0Inf.

% When the whole board has been examined, we completed the calculation of
% the heuristic
heuristic(_, _, I, _, Val, Val, _) :-
  end_of_board(I).

% When an entire row has been scanned, we continue the search in the upper row
heuristic(_, [Row|UpperBoard], I, J, ValAcc, Val, Player) :-
  end_of_row(J),
  NewI is I + 1,
  heuristic(Row, UpperBoard, NewI, 0, ValAcc, Val, Player).

heuristic(LowerRow, [Row|UpperBoard], I, J, ValAcc, Val, Player):-
  nth0(J, Row, Player), % If the disc is not of the right player, then it fails.
  OpponentPlayer is Player * -1,
  PreviousJ is J - 1,
  NewJ is J + 1,
  % Heuristic for the contiguous row
  ((J is 0, contiguous_row(Row, J, Player, 1, ValRow, true));
  (nth0(PreviousJ, Row, OpponentPlayer), contiguous_row(Row, J, Player, 1, ValRow, true));
  (nth0(PreviousJ, Row, 0), contiguous_row(Row, J, Player, 2, ValRow, false));
  ValRow is 0
  ),
  % Heuristic for the contiguous column
  % We are considering just the upper board, so the accumulator is already 2
  ((I is 0, contiguous_column(UpperBoard, J, Player, 2, ValColumn));
  (nth0(J, LowerRow, OpponentPlayer), contiguous_column(UpperBoard, J, Player, 2, ValColumn));
  (nth0(J, LowerRow, 0), contiguous_column(UpperBoard, J, Player, 4, ValColumn));
  ValColumn is 0),
  % Heuristic for the contiguous right diagonal
  % We are considering just the upper board, so the accumulator is already 2
  ((I is 0, contiguous_right_diagonal(UpperBoard, NewJ, Player, 2, ValRightDiagonal, true));
  (J is 0, contiguous_right_diagonal(UpperBoard, NewJ, Player, 2, ValRightDiagonal, true));
  (nth0(PreviousJ, LowerRow, OpponentPlayer), contiguous_right_diagonal(UpperBoard, NewJ, Player, 2, ValRightDiagonal, true));
  (nth0(PreviousJ, LowerRow, 0), contiguous_right_diagonal(UpperBoard, NewJ, Player, 4, ValRightDiagonal, false));
  ValRightDiagonal is 0),
  % Heuristic for the contiguous left diagonal
  % We are considering just the upper board, so the accumulator is already 2
  ((I is 0, contiguous_left_diagonal(UpperBoard, PreviousJ, Player, 2, ValLeftDiagonal, true));
  (end_of_row(NewJ), contiguous_left_diagonal(UpperBoard, PreviousJ, Player, 2, ValLeftDiagonal, true));
  (nth0(NewJ, LowerRow, OpponentPlayer), contiguous_left_diagonal(UpperBoard, PreviousJ, Player, 2, ValLeftDiagonal, true));
  (nth0(NewJ, LowerRow, 0), contiguous_left_diagonal(UpperBoard, PreviousJ, Player, 4, ValLeftDiagonal, false));
  ValLeftDiagonal is 0),
  % Updating accumulator and checking if winning position
  ((ValRow =:= +1.0Inf, NewValAcc is ValRow);
  (ValColumn =:= +1.0Inf, NewValAcc is ValColumn);
  (ValRightDiagonal =:= +1.0Inf, NewValAcc is ValRightDiagonal);
  (ValLeftDiagonal =:= +1.0Inf, NewValAcc is ValLeftDiagonal);
  (NewValAcc is ValAcc + ValRow + ValColumn + ValRightDiagonal + ValLeftDiagonal)),
  heuristic(LowerRow, [Row|UpperBoard], I, NewJ, NewValAcc, Val, Player).

% If the disc is not of the right player, then we check the next column
heuristic(LowerRow, UpperBoard, I, J, ValAcc, Val, Player) :-
  NewJ is J + 1,
  heuristic(LowerRow, UpperBoard, I, NewJ, ValAcc, Val, Player).


% Base case topp, we have four contiguous discs.
contiguous_row(_, _, _, ValRowAcc, ValRow, _) :-
  ValRowAcc is 16,
  ValRow is +1.0Inf.

% Otherwise, if we reach the end of the board (side) and we started with a blocked disc,
% the less than 4 discs are not expandable and the heuristic is 0
contiguous_row(_, J, _, _, 0, StartBlocked) :-
  end_of_row(J),
  StartBlocked.

% If at the beginning the disc was not blocked, then the line
% is still expandable and the heuristic is kept
contiguous_row(_, J, _, ValRow, ValRow, _) :-
  end_of_row(J).

% The same goes when the disc is not owned by the player.
% If there is an opponent's disc and StartBlocked is true, the heuristic becomes 0
contiguous_row(Row, J, Player, _, 0, StartBlocked) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer),
  StartBlocked.

% If the line is not blocked at beginning, it is still expandable on one side.
% Hence, the heuristic is kept
contiguous_row(Row, J, Player, ValRow, ValRow, _) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, it means that the line is still expandable on the right side.
% Therefore, we add the free side bonus
contiguous_row(Row, J, _, ValRowAcc, ValRow, _) :-
  nth0(J, Row, 0),
  ValRow is ValRowAcc * 2.

contiguous_row(Row, J, Player, ValRowAcc, ValRow, StartBlocked) :-
  nth0(J, Row, Player),
  NewValRowAcc is ValRowAcc * 2,
  NewJ is J + 1,
  contiguous_row(Row, NewJ, Player, NewValRowAcc, ValRow, StartBlocked).


% With the column there is no StartBlocked problem, because a disc always starts
% blocked in the vertical direction
% Base case topp, we have four contiguous discs.
contiguous_column(_, _, _, ValColumnAcc, ValColumn) :-
  ValColumnAcc is 16,
  ValColumn is +1.0Inf.

% Otherwise, if we reach the end of the board (up),
% the less than 4 discs are not expandable and the heuristic is 0
contiguous_column([], _, _, _, 0).

% The same goes when the disc is not owned by the player.
% If there is an opponent's disc the heuristic becomes 0
contiguous_column([Row|_], J, Player, _, 0) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, we accept the heuristic and we add the free side bonus
contiguous_column([Row|_], J, _, ValColumnAcc, ValColumn) :-
  nth0(J, Row, 0),
  ValColumn is ValColumnAcc * 2.

contiguous_column([Row|UpperBoard], J, Player, ValColumnAcc, ValColumn) :-
  nth0(J, Row, Player),
  NewValColumnAcc is ValColumnAcc * 2,
  contiguous_column(UpperBoard, J, Player, NewValColumnAcc, ValColumn).


% Base case topp, we have four contiguous discs.
contiguous_right_diagonal(_, _, _, ValDiagonalAcc, ValDiagonal, _) :-
  ValDiagonalAcc is 16,
  ValDiagonal is +1.0Inf.

% Otherwise, if we reach the end of the board (up or side) and we started with a blocked disc,
% the less than 4 discs are not expandable and the heuristic is 0
contiguous_right_diagonal(UpperBoard, J, _, _, 0, StartBlocked) :-
  (UpperBoard = []; end_of_row(J)),
  StartBlocked.

% If at the beginning the disc was not blocked, then the line
% is still expandable and the heuristic is returned
contiguous_right_diagonal(UpperBoard, J, _, ValDiagonal, ValDiagonal, _) :-
  (UpperBoard = []; end_of_row(J)).


% The same goes when the disc is not owned by the player.
% If there is an opponent's disc and we started with a blocked disc the heuristic becomes 0
contiguous_right_diagonal([Row|_], J, Player, _, 0, StartBlocked) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer),
  StartBlocked.

% If the line is not blocked at beginning, it is still expandable on one side.
% Hence, the heuristic is kept
contiguous_right_diagonal([Row|_], J, Player, ValDiagonal, ValDiagonal, _) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, it means that the line is still expandable on the upper-right side.
% Therefore, we add the free side bonus
contiguous_right_diagonal([Row|_], J, _, ValDiagonalAcc, ValDiagonal, _) :-
  nth0(J, Row, 0),
  ValDiagonal is ValDiagonalAcc * 2.

contiguous_right_diagonal([Row|UpperBoard], J, Player, ValDiagonalAcc, ValDiagonal, StartBlocked) :-
  nth0(J, Row, Player),
  NewValDiagonalAcc is ValDiagonalAcc * 2,
  NewJ is J + 1,
  contiguous_right_diagonal(UpperBoard, NewJ, Player, NewValDiagonalAcc, ValDiagonal, StartBlocked).


% Base case topp, we have four contiguous discs.
contiguous_left_diagonal(_, _, _, ValDiagonalAcc, ValDiagonal, _) :-
  ValDiagonalAcc is 16,
  ValDiagonal is +1.0Inf.

% Otherwise, if we reach the end of the board (up or side) and we started with a blocked disc,
% the less than 4 discs are not expandable and the heuristic is 0
contiguous_left_diagonal(UpperBoard, J, _, _, 0, StartBlocked) :-
  (UpperBoard = []; end_of_row(J)),
  StartBlocked.

% If at the beginning the disc was not blocked, then the line
% is still expandable and the heuristic is returned
contiguous_left_diagonal(UpperBoard, J, _, ValDiagonal, ValDiagonal, _) :-
  (UpperBoard = []; end_of_row(J)).

% The same goes when the disc is not owned by the player.
% If there is an opponent's disc and we started with a blocked disc the heuristic becomes 0
contiguous_left_diagonal([Row|_], J, Player, _, 0, StartBlocked) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer),
  StartBlocked.

% If the line is not blocked at beginning, it is still expandable on one side.
% Hence, the heuristic is kept
contiguous_left_diagonal([Row|_], J, Player, ValDiagonal, ValDiagonal, _) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, it means that the line is still expandable on the upper-left side.
% Therefore, we add the free side bonus
contiguous_left_diagonal([Row|_], J, _, ValDiagonalAcc, ValDiagonal, _) :-
  nth0(J, Row, 0),
  ValDiagonal is ValDiagonalAcc * 2.

contiguous_left_diagonal([Row|UpperBoard], J, Player, ValDiagonalAcc, ValDiagonal, StartBlocked) :-
  nth0(J, Row, Player),
  NewValDiagonalAcc is ValDiagonalAcc * 2,
  NewJ is J - 1,
  contiguous_left_diagonal(UpperBoard, NewJ, Player, NewValDiagonalAcc, ValDiagonal, StartBlocked).
