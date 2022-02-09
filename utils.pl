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
