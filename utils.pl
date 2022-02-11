% Utils

even(N) :- mod(N,2) =:= 0.
odd(N) :- mod(N,2) =:= 1.




% Defines a matrix, can be used for matrix indexing
matrix(Matrix, I, J, Value) :-
  nth0(I, Matrix, Row),
  nth0(J, Row, Value).




% Base case
% The right index has been reached, the value is changed
replace([_|T], J, J, Val, [Val|T]).

% Replace with value Val in list at position J
replace([H|T], I, J, Val, [H|OtherT]) :-
  NewI is I + 1,
  replace(T, NewI, J, Val, OtherT).
