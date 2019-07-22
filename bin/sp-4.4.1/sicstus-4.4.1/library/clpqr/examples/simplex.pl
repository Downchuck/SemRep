%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  clp(q,r)                                         version 1.3.2 %
%                                                                 %
%  (c) Copyright 1992,1993,1994,1995                              %
%  Austrian Research Institute for Artificial Intelligence (OFAI) %
%  Schottengasse 3                                                %
%  A-1010 Vienna, Austria                                         %
%                                                                 %
%  File:   simplex.pl                                             %
%  Author: Christian Holzbaur           christian@ai.univie.ac.at %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% b152 p.32	40/160/17200
example( 1, [X1,X2], Z) :-
  {
    X1=<50,
    X2=<200,
    X1+0.2*X2=<72,
    150*X1+25*X2=<10000,
    Z = 250*X1+45*X2
  },
  maximize(Z).

% p.33	       1/0/1.5/7
example( 2,[X1,X2,X3], Z) :-
  {
    X1=<2,
    X1+X2+2*X3=<4,
    3*X2+4*X3=<6,
    X1>=0,
    X2>=0,
    X3>=0,
    Z = X1+2*X2+4*X3
  },
  maximize(Z).

% p.38		38/170/18850
example( 3, [X1,X2], Z) :-
  {
    X1=<50,
    X2=<200,
    X1+0.2*X2=<72,
    150*X1+25*X2=<10000,
    10*X1+X2>=550,
    Z = 250*X1+55*X2
  },
  maximize(Z).

% 7/2/310
example( 4, [X,Y], Z) :-
  {
    2*X+Y =< 16,
    X+2*Y =< 11,
    X+3*Y =< 15,
    Z = 30*X+50*Y
  },
  maximize(Z).

% b30313 p.315	 0/0/2.5/5
example( 5, [X,Y,Z], Min) :-
  {
    X+3*Y+2*Z >= 5,
    2*X+2*Y+Z >= 2,
    4*X-2*Y+3*Z >= -1,
    X >= 0,
    Y >= 0,
    Z >= 0,
    Min = 6*X+5*Y+2*Z
  },
  minimize(Min).

% -7
example( 6, [X1,X2,X3], Min) :-
 {
  X1=<2,
  X1+X2+2*X3=<4,
  3*X2+4*X3=<6,
  X1>=0,
  X2>=0,
  X3>=0,
  Min = -X1-2*X2-4*X3
 },
 minimize( Min).

% -70
example( 7, [X1,X2,X3,X4,X5,X6,X7], Min) :-
 {
  X1 +	   X3 - X4 +   X5 + 2*X6 +   X7 =< 6,
       X2     + X4 - 2*X5 +   X6 - 2*X7 =< 4,
	   X3 - X4	  + 2*X6 +   X7 =< 1,

  0 =< X1, X1 =<  6,
  0 =< X2, X2 =<  6,
  0 =< X3,
  0 =< X4, X4 =<  4,
  0 =< X5, X5 =<  2,
  0 =< X6, X6 =< 10,
  0 =< X7,
  Min = -3*X1 + 4*X2 + 2*X3 - 2*X4 - 14*X5 + 11*X6 - 5*X7
 },
 minimize( Min).

% -39/2
example( 8, [X1,X2,X3,X4,X5,X6,X7], Min) :-
 {
  X1 +	   X3 - X4 +   X5 + 2*X6 +   X7 =< 6,
       X2     + X4 - 2*X5 +   X6 - 2*X7 =< 4,
	   X3 - X4	  + 2*X6 +   X7 =< 1,

  0 =< X1, X1 =<  6,
  0 =< X2, X2 =<  6,
  0 =< X3,
  0 =< X4, X4 =<  4,
  0 =< X5, X5 =<  2,
  0 =< X6, X6 =< 10,
  0 =< X7,
  Min = 3*X1 - 4*X2 - 2*X3 + 2*X4 + 14*X5 - 11*X6 + 5*X7
 },
 minimize( Min).

%
% min = 11429082625/9792 = 1167185.7255923203
%
example( 9, Vs, Obj) :-

 Vs = [ Anm1,Anm2,Anm3,Anm4,Anm5,Anm6,
	   Stm1,Stm2,Stm3,Stm4,Stm5,Stm6,
	   UE1,UE2,UE3,UE4,UE5,UE6
      ],

 allpos( Vs),
 {
   +1*Stm1  = 60,
   +0.9*Stm1 +1*Anm1 -1*Stm2  = 0,
   +0.9*Stm2 +1*Anm2 -1*Stm3  = 0,
   +0.9*Stm3 +1*Anm3 -1*Stm4  = 0,
   +0.9*Stm4 +1*Anm4 -1*Stm5  = 0,
   +0.9*Stm5 +1*Anm5 -1*Stm6  = 0,
   +150*Stm1 -100*Anm1 +1*UE1 >= 8000,
   +150*Stm2 -100*Anm2 +1*UE2 >= 9000,
   +150*Stm3 -100*Anm3 +1*UE3 >= 8000,
   +150*Stm4 -100*Anm4 +1*UE4 >= 10000,
   +150*Stm5 -100*Anm5 +1*UE5 >= 9000,
   +150*Stm6 -100*Anm6 +1*UE6 >= 12000,
   -20*Stm1 +1*UE1 =< 0,
   -20*Stm2 +1*UE2 =< 0,
   -20*Stm3 +1*UE3 =< 0,
   -20*Stm4 +1*UE4 =< 0,
   -20*Stm5 +1*UE5 =< 0,
   -20*Stm6 +1*UE6 =< 0,
     Anm1 =< 18,
     57 =< Stm2,
     Stm2 =< 75,
     Anm2 =< 18,
     57 =< Stm3,
     Stm3 =< 75,
     Anm3 =< 18,
     57 =< Stm4,
     Stm4 =< 75,
     Anm4 =< 18,
     57 =< Stm5,
     Stm5 =< 75,
     Anm5 =< 18,
     57 =< Stm6,
     Stm6 =< 75,
     Anm6 =< 18,

     Obj =  +2700*Stm1 +1500*Anm1 +30*UE1
	    +2700*Stm2 +1500*Anm2 +30*UE2
	    +2700*Stm3 +1500*Anm3 +30*UE3
	    +2700*Stm4 +1500*Anm4 +30*UE4
	    +2700*Stm5 +1500*Anm5 +30*UE5
	    +2700*Stm6 +1500*Anm6 +30*UE6
  },
  minimize( Obj).


% b20011, p144
%
example( utility, Vs, Min) :-

  Vs = [ X11, X12, X13, X14, X15,
	 X21, X22, X23, X24, X25,
	 Y11, Y12, Y13, Y14,
	 Y21, Y22, Y23, Y24, Y25,
	 Z11, Z12, Z13, Z14,
	 Z21, Z22, Z23, Z24, Z25],
  {
    X11 + X12 + X13 + X14 + X15 = 1000,
    X21 + X22 + X23 + X24 + X25 = 1000,

    3*X11 + 2*X21 - Y11 - Y14 - Z11 - Z14  =< 0,
   -3*X12 - 2*X22 + Y11 - Y12 + Z11 - Z12 = 0,
   -3*X13 - 2*X23 - Y13 + Y14 - Z13 + Z14 = 0,
   -3*X14 - 2*X24 + Y12 + Z12 = 0,
   -3*X15 - 2*X25 + Y13 + Z13 = 0,

    4*X11 + 5*X21 - Y21 - Z21 =< 0,
   -4*X12 - 5*X22 + Y22 + Z22 = 0,
   -4*X13 - 5*X23 + Y24 - Y25 + Z24 - Z25 = 0,
   -4*X14 - 5*X24 + Y21 - Y22 - Y23 + Y25
		  + Z21 - Z22 - Z23 + Z25 = 0,
   -4*X15 - 5*X25 + Y23 - Y24 + Z23 - Z24 = 0,

    7*X11 + 9*X21 >= 0,
    7*X12 + 9*X22 =< 3000,
    7*X13 + 9*X23 =< 200,
    7*X14 + 9*X24 =< 10000,
    7*X15 + 9*X25 =< 7000,

    Z11 =< 1000,
    Z12 =< 500,
    Z13 =< 2000,
    Z14 =< 100,
    Z21 =< 5000,
    Z22 =< 250,
    Z23 =< 600,
    Z24 =< 7000,
    Z25 =< 4000,

    X11 >= 0, X12 >= 0, X13 >= 0, X14 >= 0, X15 >= 0,
    X21 >= 0, X22 >= 0, X23 >= 0, X24 >= 0, X25 >= 0,

    Y11 >= 0, Y12 >= 0, Y13 >= 0, Y14 >= 0,
    Y21 >= 0, Y22 >= 0, Y23 >= 0, Y24 >= 0, Y25 >= 0,

    Z11 >= 0, Z12 >= 0, Z13 >= 0, Z14 >= 0,
    Z21 >= 0, Z22 >= 0, Z23 >= 0, Z24 >= 0, Z25 >= 0,

    M = 99999,
    Min = M*X11 + M*X21 + 3*Y11 + 7*Y12 + 9*Y13 + Y14 + 4*Y21 + 7*Y22 + 3*Y23 +
			  8*Y24 + 5*Y25
  },
  minimize(Min).

example( electricity, Vs, Min) :-

  Vs = [ X11, X12, X13, X14, X15,
	 X21, X22, X23, X24, X25,
	 Y11, Y12, Y13, Y14,
	 Z11, Z12, Z13, Z14],
  {
    X11 + X12 + X13 + X14 + X15 = 1000,
    X21 + X22 + X23 + X24 + X25 = 1000,

    3*X11 + 2*X21 - Y11 - Y14 - Z11 - Z14 =< 0,
   -3*X12 - 2*X22 + Y11 - Y12 + Z11 - Z12 = 0,
   -3*X13 - 2*X23 - Y13 + Y14 - Z13 + Z14 = 0,
   -3*X14 - 2*X24 + Y12 + Z12 = 0,
   -3*X15 - 2*X25 + Y13 + Z13 = 0,

    7*X11 + 9*X21 >= 0,
    7*X12 + 9*X22 =< 3000,
    7*X13 + 9*X23 =< 200,
    7*X14 + 9*X24 =< 10000,
    7*X15 + 9*X25 =< 7000,

    Z11 =< 1000,
    Z12 =< 500,
    Z13 =< 2000,
    Z14 =< 100,

    X11 >= 0, X12 >= 0, X13 >= 0, X14 >= 0, X15 >= 0,
    X21 >= 0, X22 >= 0, X23 >= 0, X24 >= 0, X25 >= 0,
    Y11 >= 0, Y12 >= 0, Y13 >= 0, Y14 >= 0,
    Z11 >= 0, Z12 >= 0, Z13 >= 0, Z14 >= 0,

    M = 99999,
    Min = M*X11 + M*X21 + 3*Y11 + 7*Y12 + 9*Y13 + Y14
  },
  minimize(Min).

example( water, Vs, Min) :-

  Vs = [ X11, X12, X13, X14, X15,
	 X21, X22, X23, X24, X25,
	 Y21, Y22, Y23, Y24, Y25,
	 Z21, Z22, Z23, Z24, Z25],
  {
    X11 + X12 + X13 + X14 + X15 = 1000,
    X21 + X22 + X23 + X24 + X25 = 1000,

    4*X11 + 5*X21 - Y21 - Z21 =< 0,
   -4*X12 - 5*X22 + Y22 + Z22 = 0,
   -4*X13 - 5*X23 + Y24 - Y25 + Z24 - Z25 = 0,
   -4*X14 - 5*X24 + Y21 - Y22 - Y23 + Y25
		  + Z21 - Z22 - Z23 + Z25 = 0,
   -4*X15 - 5*X25 + Y23 - Y24 + Z23 - Z24 = 0,

    7*X11 + 9*X21 >= 0,
    7*X12 + 9*X22 =< 3000,
    7*X13 + 9*X23 =< 200,
    7*X14 + 9*X24 =< 10000,
    7*X15 + 9*X25 =< 7000,

    Z21 =< 5000,
    Z22 =< 250,
    Z23 =< 600,
    Z24 =< 7000,
    Z25 =< 4000,

    X11 >= 0, X12 >= 0, X13 >= 0, X14 >= 0, X15 >= 0,
    X21 >= 0, X22 >= 0, X23 >= 0, X24 >= 0, X25 >= 0,

    Y21 >= 0, Y22 >= 0, Y23 >= 0, Y24 >= 0, Y25 >= 0,

    Z21 >= 0, Z22 >= 0, Z23 >= 0, Z24 >= 0, Z25 >= 0,

    M = 99999,
    Min = M*X11 + M*X21 + 4*Y21 + 7*Y22 + 3*Y23 +  8*Y24 + 5*Y25
  },
  minimize(Min).

allpos( []).
allpos( [V|Vs]) :-
  { V >= 0 },
  allpos( Vs).

% --------------------------------------------------------------------------

test(0) :- { A=<2,B=<3,C=<4,A+B+C=10 }. 	% must fail

test(5) :-
 {
  2*X1 + 4*X2 + 3*X3 - 4*W1 - 10*W2 =  0,
  2*X1 +   X2 +   X3		    =  4,
  5*X1 + 3*X2 + 2*X3		    = 10,
		       2*W1 +  5*W2 =< 2,
			 W1 +  3*W2 =< 4,
			 W1 +  2*W2 =< 3,
    X1 >= 0,
    X2 >= 0,
    X3 >= 0
 }.


