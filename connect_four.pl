% Connect 4

% [[0,0,1],[0,0,0],[0,0,0]]
% [0,0,1] � la riga pi� in basso

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
