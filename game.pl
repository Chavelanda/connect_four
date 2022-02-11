% Game

:- consult(alphabeta).
:- consult(connect_four).
:- consult(utils).

% Entry point
game() :-
  game([[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0]], 1, 0).

% Base case
% Always draws the board
% If the game is over say who won
% If not, let's make a move!
game(Pos, Player, 0) :-
  draw_board(Pos, 0),
  write('  0123456\n\n'),
  OpponentPlayer is Player * -1,
  end_of_game([], Pos, 0, 0, 0, OpponentPlayer, GameEnded),
  ((GameEnded is 1, game(Pos, 0, 1));
  (GameEnded is 0, game(Pos, Player, 1))).

% The game is over
game(Pos, 0, 1) :-
  staticval(Pos, Val),
  ((Val is 0, write('The game ended with a draw :|'));
  (Val is 1.0Inf, write('You woooooon, sbamm!'));
  (Val is -1.0Inf, write('Auch, you lose :('))).

% Human plays
game(Pos, 1, 1) :-
  write('Write the column in which you want to put your disc
  (index starts at 0)'),
  read(Column),
  check_valid_move(Pos, Column),
  generate_pos(Pos, Column, NewPos),
  game(NewPos, -1, 0).

% CPU plays
game(Pos, -1, 1) :-
  write('Alex, the world\'s best player, has done its move\n'),
  min_to_move(Pos),
  alphabeta(Pos, -1.0Inf, 1.0Inf, NewPos, _, 0, 4),
  game(NewPos, 1, 0).




% Function to draw the Connect Four board
draw_board([Row|[]], _) :-
  write('5|'),
  draw_row(Row),
  write('|\n').

draw_board([Row|UpperBoard], I) :-
  NewI is I + 1,
  draw_board(UpperBoard, NewI),
  write(I),
  write('|'),
  draw_row(Row),
  write('|\n').




% Function to draw a Connect Four row
draw_row([]).

draw_row([Disc|Row]) :-
  ((Disc is 1, write('X'));
  (Disc is 0, write('_'));
  (Disc is -1, write('O'))),
  draw_row(Row).




% Functions that checks if the input of the human player is valid
check_valid_move(Pos, Column) :-
  integer(Column),
  Column >= 0,
  Column < 7,
  matrix(Pos, 5, Column, Disc),
  Disc is 0.

check_valid_move(Pos, _) :-
  write('\n!Warning! Your column is not a valid option. Please try
  with another one.\n'),
  game(Pos, 1, 1).




% Function that relates a position and a column in which the new
% disc must be inserted to the new position
generate_pos(Pos, Column, NewPos) :-
  generate_pos([], Pos, 0, Column, NewPos).

% Base case
% The first free slot in the right column has been reached
% and the new position is found.
generate_pos(LowerBoard, [Row|UpperBoard], _, Column, NewPos) :-
  nth0(Column, Row, 0),
  replace(Row, 0, Column, 1, NewRow),
  append(LowerBoard, [NewRow|UpperBoard], NewPos).

generate_pos(LowerBoard, [Row|UpperBoard], I, Column, NewPos) :-
  \+ nth0(Column, Row, 0),
  append(LowerBoard, [Row], NewLowerBoard),
  NewI is I + 1,
  generate_pos(NewLowerBoard, UpperBoard, NewI, Column, NewPos).
