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

% If the disc is not of the right player, then we check the next column
heuristic(LowerRow, [Row|UpperBoard], I, J, ValAcc, Val, Player) :-
  \+ nth0(J, Row, Player),
  NewJ is J + 1,
  heuristic(LowerRow, [Row|UpperBoard], I, NewJ, ValAcc, Val, Player).

heuristic(LowerRow, [Row|UpperBoard], I, J, ValAcc, Val, Player) :-
  OpponentPlayer is Player * -1,
  PreviousJ is J - 1,
  NewJ is J + 1,

  heuristic_row(Row, J, PreviousJ, Player, OpponentPlayer, ValRow),
  heuristic_column([Row|UpperBoard], LowerRow, I, J, Player, OpponentPlayer, ValColumn),
  heuristic_diagonal([Row|UpperBoard], LowerRow, I, J, PreviousJ, 1, Player, OpponentPlayer, ValRightDiagonal),
  heuristic_diagonal([Row|UpperBoard], LowerRow, I, J, NewJ, -1, Player, OpponentPlayer, ValLeftDiagonal),

  % Updating accumulator and checking if winning position
  ((ValRow =:= +1.0Inf, NewValAcc is ValRow);
  (ValColumn =:= +1.0Inf, NewValAcc is ValColumn);
  (ValRightDiagonal =:= +1.0Inf, NewValAcc is ValRightDiagonal);
  (ValLeftDiagonal =:= +1.0Inf, NewValAcc is ValLeftDiagonal);
  (NewValAcc is ValAcc + ValRow + ValColumn + ValRightDiagonal + ValLeftDiagonal)),

  heuristic(LowerRow, [Row|UpperBoard], I, NewJ, NewValAcc, Val, Player).




% Heuristic for the contiguous row
heuristic_row(Row, J, PreviousJ, Player, OpponentPlayer, ValRow) :-
  ((J is 0, StartBlocked is 1, contiguous_row(Row, J, Player, 0, DiscsInLine, EndBlocked));
  (nth0(PreviousJ, Row, OpponentPlayer), StartBlocked is 1, contiguous_row(Row, J, Player, 0, DiscsInLine, EndBlocked));
  (nth0(PreviousJ, Row, 0), StartBlocked is 0, contiguous_row(Row, J, Player, 0, DiscsInLine, EndBlocked));
  (nth0(PreviousJ, Row, Player), DiscsInLine is 0, StartBlocked is 1, EndBlocked is 1)),

  Blocked is StartBlocked + EndBlocked,

  ((DiscsInLine >= 4, ValRow is +1.0Inf);
  (Blocked is 2, ValRow is 0);
%  (Blocked is 1, ValRow is 2**(DiscsInLine + 1));
%  (Blocked is 0, ValRow is 2**(DiscsInLine + 2))).
  (Blocked is 1, ValRow is 2**(DiscsInLine));
  (Blocked is 0, ValRow is 2**(DiscsInLine))).




% Heuristic for the contiguous column
heuristic_column(UpperBoard, LowerRow, I, J, Player, OpponentPlayer, ValColumn) :-
  ((I is 0, contiguous_column(UpperBoard, J, Player, 0, DiscsInLine, EndBlocked));
  (nth0(J, LowerRow, OpponentPlayer), contiguous_column(UpperBoard, J, Player, 0, DiscsInLine, EndBlocked));
  (nth0(J, LowerRow, 0), contiguous_column(UpperBoard, J, Player, 0, DiscsInLine, EndBlocked));
  (DiscsInLine is 0, EndBlocked is 1)),

  ((DiscsInLine >= 4, ValColumn is +1.0Inf);
  (EndBlocked is 1, ValColumn is 0);
%  (EndBlocked is 0, ValColumn is 2**(DiscsInLine + 1))).
  (EndBlocked is 0, ValColumn is 2**(DiscsInLine))).




% Heuristic for the contiguous left diagonal
heuristic_diagonal(UpperBoard, LowerRow, I, J, CheckJ, Direction, Player, OpponentPlayer, ValDiagonal) :-
  ((I is 0, StartBlocked is 1, contiguous_diagonal(UpperBoard, J, Player, 0, DiscsInLine, EndBlocked, Direction));
  (end_of_row(CheckJ), StartBlocked is 1, contiguous_diagonal(UpperBoard, J, Player, 0, DiscsInLine, EndBlocked, Direction));
  (nth0(CheckJ, LowerRow, OpponentPlayer), StartBlocked is 1, contiguous_diagonal(UpperBoard, J, Player, 0, DiscsInLine, EndBlocked, Direction));
  (nth0(CheckJ, LowerRow, 0), StartBlocked is 0, contiguous_diagonal(UpperBoard, J, Player, 0, DiscsInLine, EndBlocked, Direction));
  (DiscsInLine is 0, StartBlocked is 1, EndBlocked is 1)),

  Blocked is StartBlocked + EndBlocked,

  ((DiscsInLine >= 4, ValDiagonal is +1.0Inf);
  (Blocked is 2, ValDiagonal is 0);
%  (Blocked is 1, ValDiagonal is 2**(DiscsInLine + 1));
%  (Blocked is 0, ValDiagonal is 2**(DiscsInLine + 2))).
  (Blocked is 1, ValDiagonal is 2**(DiscsInLine));
  (Blocked is 0, ValDiagonal is 2**(DiscsInLine))).



heuristic_list([], []).

heuristic_list([HP|TP], [HH|TH]) :-
  staticval(HP, HH),
  heuristic_list(TP, TH).
