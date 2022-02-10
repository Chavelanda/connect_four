:- consult(alphabeta).
:- consult(connect_four).
:- consult(utils).

% Entry point
game() :-
  game([[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0]], 1, 0).

% Base case
% Always draws the board
% If the game is over say who won
% Do we know if the game is over?
game(Pos, Player, 0) :-
  draw_board(Pos, 0),
  write(' 0123456'),
  write('\n'),
  end_of_game([], Pos, 0, 0, 0, Player, GameEnded),
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
  write('Write the column in which you want to put your disc (index starts at 0)'),
  read(Column),
  check_valid_move(Pos, Column),
  generate_pos(Pos, Column, NewPos),
  game(NewPos, -1, 0).

% CPU plays
game(Pos, -1, 1) :-
  write('ALex, the world\'s best player, has done its move\n'),
  min_to_move(Pos),
  alphabeta(Pos, -1.0Inf, 1.0Inf, NewPos, _, 0, 4),
  game(NewPos, 1, 0).



draw_board([Row|[]], _) :-
  write('5'),
  draw_row(Row).

draw_board([Row|UpperBoard], I) :-
  NewI is I + 1,
  draw_board(UpperBoard, NewI),
  write(I),
  draw_row(Row).



draw_row([]) :-
  write('\n').

draw_row([Disc|Row]) :-
  ((Disc is 1, write('X'));
  (Disc is 0, write('-'));
  (Disc is -1, write('O'))),
  draw_row(Row).




check_valid_move(Pos, Column) :-
  Column >= 0,
  Column < 7,
  matrix(Pos, 5, Column, Disc),
  Disc is 0.

check_valid_move(Pos, _) :-
  write('!Warning! Your column is not a valid option. Please try with another one.'),
  game(Pos, 1, 1).




generate_pos(Pos, Column, NewPos) :-
  generate_pos([], Pos, 0, Column, NewPos).

generate_pos(LowerBoard, [Row|UpperBoard], _, Column, NewPos) :-
  nth0(Column, Row, 0),
  replace(Row, 0, Column, 1, NewRow),
  append(LowerBoard, [NewRow|UpperBoard], NewPos).

generate_pos(LowerBoard, [Row|UpperBoard], I, Column, NewPos) :-
  \+ nth0(Column, Row, 0),
  append(LowerBoard, [Row], NewLowerBoard),
  NewI is I + 1,
  generate_pos(NewLowerBoard, UpperBoard, NewI, Column, NewPos).
