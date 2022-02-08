% Connect 4

% [[0,0,1],[0,0,0],[0,0,0]]
% [0,0,1] � la riga pi� in basso

endOfRow(J) :-
  J is 7.
endOfRow(J) :-
  J is -1.

endOfBoard(I) :-
  I is 6.

even(N) :- mod(N,2) =:= 0.
odd(N) :- mod(N,2) =:= 1.

% Restituisce il valore in (I, J)
matrix(Matrix, I, J, Value) :-
  % Prima otteniamo la row (ci pensa nth0), poi ottiamo il valore, con la seconda chiamataa a nth0
  nth0(I, Matrix, Row), % True when Row is the I�th element of Matrix. Counting starts at 0.
  nth0(J, Row, Value).  % True when Value is the J�th element of Matrix. Counting starts at 0.

% Cambia un valore in una lista (utilizzato da Moves per aggiungere
% nuova mossa a vecchia matrice) Replace with value Val in list at
% position J
replace([_|T], J, J, Val, [Val|T]).

% [H|T] lista
% I counter della lista, dove siamo ora?
% J index dove dobbiamo sostituire
% Val valore da mettere
% [H|OtherT] lista modificata
replace([H|T], I, J, Val, [H|OtherT]) :-
  NewI is I + 1,
  replace(T, NewI, J, Val, OtherT).


% min_to_move non � implementato perch� � il contrario not(max_to_move)
max_to_move([PosH|[]], S) :-
  sum_list(PosH, S1),
  SFinal is S + S1,
  even(SFinal). % Ti ritorna (quando rimane solo una lista) se � pari o dispari

% [PosH|PosT] sfoglia le liste
% S � la somma attuale
max_to_move([PosH|PosT], S) :-
  % sum_list si prende una lista e ti da la somma S1
  sum_list(PosH, S1),
  S2 is S + S1,
  max_to_move(PosT, S2).

% Gli entra una matrice, la posizione attuale: vuole contare se la somma
% dei valori della matrice � pari o dispari
max_to_move(Pos) :-
  max_to_move(Pos, 0).

min_to_move(Pos) :-
  \+ max_to_move(Pos).


% questi due vanno messi in fondo
% Caso In cui tocca a max giocare
% pos � input
% posList � output
% 1 viene utilizzato solo per il replace
moves(Pos, PosList) :-
  max_to_move(Pos), !,
  moves([], Pos, 0, 0, PosList, 1).

% \+ � un not
% caso in cui tocca a min giocare
moves(Pos, PosList) :-
  min_to_move(Pos), !,
  moves([], Pos, 0, 0, PosList, -1).


% Stop when all the rows have been examined
% Base case
% Qui abbiamo finito le colonne dell'ultima riga
% Infatti abbiamo solo un 3, out of bound delle righe.
% Se questo predicato fa match � perch� il numero di row � uguale a 3
%
% Ritorna anche una lista vuota la quale consente di terminare PosList:
% � l'ultima parte da aggiungere a quella variabile
moves(_, _, 3, _, [], _).

% If a row has been completely examined, then examine next row.
% Base case
% Quando la colonna arriva a 3 vuol dire che out of bound (non ci sono
% pi� colonne)
% Quindi cosa fa? Avanza di riga.
moves(LowerBoard, [BoardI|UpperBoard], I, 3, PosList, Player) :-
  append(LowerBoard, [BoardI], NewLowerBoard), % Lower Board � la matrice delle righe gi� esaminate
  NewI is I + 1,
  moves(NewLowerBoard, UpperBoard, NewI, 0, PosList, Player).

% If there is no disc in the first row, then it is possible to play it
% The parameters are: Lower part the board, Upper part of the board, Row, Column,
% Possible new positions list
%
% Particular general case: vale solo per la prima riga. Qui possiamo
% mettere la pedina dove ci pare a livello base.
% Primo passo che facciamo, dopo l'entry point, � questo.
% [] righe gi� esaminate
% BoardI � la riga attuale, quella analizzata ora
% UpperBoard quelle sopra, da analizzare dopo
% 0 indice riga attuale
% J indice della colonna
% [PosListH|PosListT] � l'output (� una lista di matrici -> posListH �
% una matrice)
moves([], [BoardI|UpperBoard], 0, J, [PosListH|PosListT], Player) :-
  nth0(J, BoardI, 0), % Controlliamo che in questa riga e colonna il valore � zero: possiamo giocare la pedina li se � vero
                      % Se � diverso da 0 non possiamo giocare qui e passiamo al moves successivo: che manda avanti la colonna
  !,
  replace(BoardI, 0, J, Player, PosListHI), % Mettiamo -1/1 su posizione (riga, colonna)
  % Append � una funzione built-in: aggiunge la nuova matrice modificata (con la nuova mossa alla lista di matrici)
  append([], [PosListHI|UpperBoard], PosListH),
  NewJ is J + 1, % manda avanti la colonna
  moves([], [BoardI|UpperBoard], 0, NewJ, PosListT, Player).

% attualmente non facciamo un check sull'input, ma partendo da una
% posizione valida arriveremo sempre a posizioni valide

% Ci cade se il valore (riga, colonna) � diverso da 0, quindi non
% possiamo giocarci. (VALE SOLO PER LA PRIMA RIGA). Mandiamo solo avanti
% la colonna.
moves([], Board, 0, J, PosList, Player) :-
  NewJ is J + 1, % Manda avanti la colonna
  moves([], Board, 0, NewJ, PosList, Player). % Richiama moves sopra con la prossima colonna

% If it is not the first row, then to put a disc there should be a disc in the
% lower row
moves(LowerBoard, [BoardI|UpperBoard], I, J, [PosListH|PosListT], Player) :-
  nth0(J, BoardI, 0), % Controlliamo come prima, se il valore � uguale 0
  % Controlliamo anche che il valore sotto alla posizione corrente sia diverso da 0
  ICheck is I - 1,
  matrix(LowerBoard, ICheck, J, Val), % Prendi valore (riga, colonna) -> Val � output
  Val =\= 0, % La posizione sotto deve essere occupata
  !,
  replace(BoardI, 0, J, Player, PosListHI),
  append(LowerBoard, [PosListHI|UpperBoard], PosListH),
  NewJ is J + 1,
  moves(LowerBoard, [BoardI|UpperBoard], I, NewJ, PosListT, Player).

% Caso in cui il valore non � zero oppure il valore sotto non � diverso
% da 0
moves(LowerBoard, UpperBoard, I, J, PosList, Player) :-
  NewJ is J + 1,
  moves(LowerBoard, UpperBoard, I, NewJ, PosList, Player).


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
  endOfBoard(I).

% When an entire row has been scanned, we continue the search in the upper row
heuristic(_, [Row|UpperBoard], I, J, ValAcc, Val, Player) :-
  endOfRow(J),
  NewI is I + 1,
  heuristic(Row, UpperBoard, NewI, 0, ValAcc, Val, Player).

heuristic(LowerRow, [Row|UpperBoard], I, J, ValAcc, Val, Player):-
  nth0(J, Row, Player), % If the disc is not of the right player, then it fails.
  OpponentPlayer is Player * -1,
  PreviousJ is J - 1,
  NewJ is J + 1,
  % Heuristic for the contiguous row
  ((J is 0, contiguousRow(Row, J, Player, 1, ValRow, true));
  (nth0(PreviousJ, Row, OpponentPlayer), contiguousRow(Row, J, Player, 1, ValRow, true));
  (nth0(PreviousJ, Row, 0), contiguousRow(Row, J, Player, 2, ValRow, false));
  ValRow is 0
  ),
  % Heuristic for the contiguous column
  % We are considering just the upper board, so the accumulator is already 2
  ((I is 0, contiguousColumn(UpperBoard, J, Player, 2, ValColumn));
  (nth0(J, LowerRow, OpponentPlayer), contiguousColumn(UpperBoard, J, Player, 2, ValColumn));
  (nth0(J, LowerRow, 0), contiguousColumn(UpperBoard, J, Player, 4, ValColumn));
  ValColumn is 0),
  % Heuristic for the contiguous right diagonal
  % We are considering just the upper board, so the accumulator is already 2
  ((I is 0, contiguousRightDiagonal(UpperBoard, NewJ, Player, 2, ValRightDiagonal, true));
  (J is 0, contiguousRightDiagonal(UpperBoard, NewJ, Player, 2, ValRightDiagonal, true));
  (nth0(PreviousJ, LowerRow, OpponentPlayer), contiguousRightDiagonal(UpperBoard, NewJ, Player, 2, ValRightDiagonal, true));
  (nth0(PreviousJ, LowerRow, 0), contiguousRightDiagonal(UpperBoard, NewJ, Player, 4, ValRightDiagonal, false));
  ValRightDiagonal is 0),
  % Heuristic for the contiguous left diagonal
  % We are considering just the upper board, so the accumulator is already 2
  ((I is 0, contiguousLeftDiagonal(UpperBoard, PreviousJ, Player, 2, ValLeftDiagonal, true));
  (endOfRow(NewJ), contiguousLeftDiagonal(UpperBoard, PreviousJ, Player, 2, ValLeftDiagonal, true));
  (nth0(NewJ, LowerRow, OpponentPlayer), contiguousLeftDiagonal(UpperBoard, PreviousJ, Player, 2, ValLeftDiagonal, true));
  (nth0(NewJ, LowerRow, 0), contiguousLeftDiagonal(UpperBoard, PreviousJ, Player, 4, ValLeftDiagonal, false));
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
contiguousRow(_, _, _, ValRowAcc, ValRow, _) :-
  ValRowAcc is 16,
  ValRow is +1.0Inf.

% Otherwise, if we reach the end of the board (up) and we started with a blocked disc,
% the less than 4 discs are not expandable and the heuristic is 0
contiguousRow(_, J, _, _, 0, StartBlocked) :-
  endOfRow(J),
  StartBlocked.

% If at the beginning the disc was not blocked, then the line
% is still expandable and the heuristic is kept
contiguousRow(_, J, _, ValRow, ValRow, _) :-
  endOfRow(J).

% The same goes when the disc is not owned by the player.
% If there is an opponent's disc and StartBlocked is true, the heuristic becomes 0
contiguousRow(Row, J, Player, _, 0, StartBlocked) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer),
  StartBlocked.

% If the line is not blocked at beginning, it is still expandable on one side.
% Hence, the heuristic is kept
contiguousRow(Row, J, Player, ValRow, ValRow, _) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, it means that the line is still expandable on the right side.
% Therefore, we add the free side bonus
contiguousRow(Row, J, _, ValRowAcc, ValRow, _) :-
  nth0(J, Row, 0),
  ValRow is ValRowAcc * 2.

contiguousRow(Row, J, Player, ValRowAcc, ValRow, StartBlocked) :-
  nth0(J, Row, Player),
  NewValRowAcc is ValRowAcc * 2,
  NewJ is J + 1,
  contiguousRow(Row, NewJ, Player, NewValRowAcc, ValRow, StartBlocked).


% With the column there is no StartBlocked problem, because a disc always starts
% blocked in the vertical direction
% Base case topp, we have four contiguous discs.
contiguousColumn(_, _, _, ValColumnAcc, ValColumn) :-
  ValColumnAcc is 16,
  ValColumn is +1.0Inf.

% Otherwise, if we reach the end of the board (up),
% the less than 4 discs are not expandable and the heuristic is 0
contiguousColumn([], _, _, _, 0).

% The same goes when the disc is not owned by the player.
% If there is an opponent's disc the heuristic becomes 0
contiguousColumn([Row|_], J, Player, _, 0) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, we accept the heuristic and we add the free side bonus
contiguousColumn([Row|_], J, _, ValColumnAcc, ValColumn) :-
  nth0(J, Row, 0),
  ValColumn is ValColumnAcc * 2.

contiguousColumn([Row|UpperBoard], J, Player, ValColumnAcc, ValColumn) :-
  nth0(J, Row, Player),
  NewValColumnAcc is ValColumnAcc * 2,
  contiguousColumn(UpperBoard, J, Player, NewValColumnAcc, ValColumn).


% Base case topp, we have four contiguous discs.
contiguousRightDiagonal(_, _, _, ValDiagonalAcc, ValDiagonal, _) :-
  ValDiagonalAcc is 16,
  ValDiagonal is +1.0Inf.

% Otherwise, if we reach the end of the board (up or side) and we started with a blocked disc,
% the less than 4 discs are not expandable and the heuristic is 0
contiguousRightDiagonal(UpperBoard, J, _, _, 0, StartBlocked) :-
  (UpperBoard = []; endOfRow(J)),
  StartBlocked.

% If at the beginning the disc was not blocked, then the line
% is still expandable and the heuristic is returned
contiguousRightDiagonal(UpperBoard, J, _, ValDiagonal, ValDiagonal, _) :-
  (UpperBoard = []; endOfRow(J)).


% The same goes when the disc is not owned by the player.
% If there is an opponent's disc and we started with a blocked disc the heuristic becomes 0
contiguousRightDiagonal([Row|_], J, Player, _, 0, StartBlocked) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer),
  StartBlocked.

% If the line is not blocked at beginning, it is still expandable on one side.
% Hence, the heuristic is kept
contiguousRightDiagonal([Row|_], J, Player, ValDiagonal, ValDiagonal, _) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, it means that the line is still expandable on the upper-right side.
% Therefore, we add the free side bonus
contiguousRightDiagonal([Row|_], J, _, ValDiagonalAcc, ValDiagonal, _) :-
  nth0(J, Row, 0),
  ValDiagonal is ValDiagonalAcc * 2.

contiguousRightDiagonal([Row|UpperBoard], J, Player, ValDiagonalAcc, ValDiagonal, StartBlocked) :-
  nth0(J, Row, Player),
  NewValDiagonalAcc is ValDiagonalAcc * 2,
  NewJ is J + 1,
  contiguousRightDiagonal(UpperBoard, NewJ, Player, NewValDiagonalAcc, ValDiagonal, StartBlocked).


% Base case topp, we have four contiguous discs.
contiguousLeftDiagonal(_, _, _, ValDiagonalAcc, ValDiagonal, _) :-
  ValDiagonalAcc is 16,
  ValDiagonal is +1.0Inf.

% Otherwise, if we reach the end of the board (up or side) and we started with a blocked disc,
% the less than 4 discs are not expandable and the heuristic is 0
contiguousLeftDiagonal(UpperBoard, J, _, _, 0, StartBlocked) :-
  (UpperBoard = []; endOfRow(J)),
  StartBlocked.

% If at the beginning the disc was not blocked, then the line
% is still expandable and the heuristic is returned
contiguousLeftDiagonal(UpperBoard, J, _, ValDiagonal, ValDiagonal, _) :-
  (UpperBoard = []; endOfRow(J)).

% The same goes when the disc is not owned by the player.
% If there is an opponent's disc and we started with a blocked disc the heuristic becomes 0
contiguousLeftDiagonal([Row|_], J, Player, _, 0, StartBlocked) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer),
  StartBlocked.

% If the line is not blocked at beginning, it is still expandable on one side.
% Hence, the heuristic is kept
contiguousLeftDiagonal([Row|_], J, Player, ValDiagonal, ValDiagonal, _) :-
  OpponentPlayer is Player * -1,
  nth0(J, Row, OpponentPlayer).

% Otherwise, it means that the line is still expandable on the upper-left side.
% Therefore, we add the free side bonus
contiguousLeftDiagonal([Row|_], J, _, ValDiagonalAcc, ValDiagonal, _) :-
  nth0(J, Row, 0),
  ValDiagonal is ValDiagonalAcc * 2.

contiguousLeftDiagonal([Row|UpperBoard], J, Player, ValDiagonalAcc, ValDiagonal, StartBlocked) :-
  nth0(J, Row, Player),
  NewValDiagonalAcc is ValDiagonalAcc * 2,
  NewJ is J - 1,
  contiguousLeftDiagonal(UpperBoard, NewJ, Player, NewValDiagonalAcc, ValDiagonal, StartBlocked).
