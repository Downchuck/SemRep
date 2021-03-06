% Terminological Reasoning (similar to KL-ONE or feature trees)
% Ph. Hanschke, DFKI Kaiserslautern, and Th. Fruehwirth
% 920120-920217-920413-920608ff-931210, LMU 980312

:- use_module( library(chr)).

% handler klone.


% SYNTAX

% Basic operators
:- op(1200,xfx,isa).	% concept definition
:- op(950,xfx,'::').	% A-Box membership and role-filler assertion
:- op(940,xfy,or).	% disjunction
:- op(930,xfy,and).	% conjunction
:- op(700,xfx,is).	% used in restricitions 
:- op(690,fy, nota). % complement 		
:- op(650,fx, some).	% exists-in restriction
:- op(650,fx, every). % value restriction
% Operators for extensions
:- op(100,fx, feature). % functional role / attribute
:- op(100,fx, distinct). % concept distinct from any other concept
:- op(100,fx, at_most_one). % local functional role
:- op(100,yfx,of).	% role chain  (note associativity)

:- dynamic (feature)/1, (distinct)/1, (isa)/2.  % to allow scattered clauses


% TYPES

role_assertion((I,J)::R):- individual(I),individual(J), role(R).
membership_assertion(I::T):- individual(I), concept_term(T).

concept_definition((C isa T)):- concept(C), concept_term(T).

concept_term(S):- concept(S).
concept_term(S or T):- concept_term(S), concept_term(T).
concept_term(S and T):- concept_term(S), concept_term(T).
concept_term(nota S):- concept_term(S).
concept_term(some R is S):- role(R), concept_term(S).
concept_term(every R is S):- role(R), concept_term(S).
concept_term(at_most_one R):- role(R).	% extension

individual(I):- var(I) ; atomic(I).

role(R):- atom(R).
role(R1 of R2):- role(R1), role(R2).	% extension

concept(C):- atom(C).




% CONSISTENCY CHECK
% A-box as constraint goals, T-box asserted (concept definitions by isa-rules)

:- chr_constraint (::)/2, labeling/0.

% disjunction (is delayed as choice)
labeling, (I::S or T) # Ph <=>
	(I::S ; I::T),
	labeling
    pragma passive(Ph).

% primitive clash
  I::nota Q, I::Q <=> fail.		

% duplicates
  I::C \ I::C <=> true.

% top
  I::top <=> true.

% complement nota/1

% nota-top
  I::nota top <=> fail.

% nota-or
  I::nota (S or T) <=> I::(nota S and nota T).

% nota-and
  I::nota (S and T) <=> I::(nota S or nota T).

% nota-nota
  I::nota nota S <=> I::S.

% nota-every 
  I::nota every R is S <=> I::some R is nota S.

% nota-some 
  I::nota some R is S <=> I::every R is nota S.

% conjunction
  I::S and T <=> I::S, I::T.

% exists-in restriction
  I::some R is S <=> role(R) | (I,J)::R, J::S.	% generate witness

% value restriction
  I::every R is S, (I,J)::R ==> J::S.

% Extensions ------------------------------------------------------------------

% value restriction merge and consistency test
  I::every R is S1, I::every R is S2 <=> I::every R is S1 and S2, J::S1 and S2.

% distinct/disjoint concept
  I::C1 \ I::C2 <=> concept(C1),concept(C2),distinct C1 | C1=C2.

% features/attributes/functional role
  (I,J1)::F \ (I,J2)::F <=> feature F | J1=J2. 

% role chains
  (I,J)::C1 of C2 <=> (I,K)::C2, (K,J)::C1.	% also covers "some" case
  I::every R1 of R is S, (I,J)::R ==> J::every R1 is S.
  I::at_most_one R1 of R, (I,J)::R ==> J::at_most_one R1.

% simple number restriction / local functional role using role chains
:- chr_constraint (at_most_one)/3.
  I::at_most_one R, (I,J)::R ==> at_most_one(I,J,R).
  at_most_one(I,J,R) \ at_most_one(I,J1,R) <=> J1=J.

  I::nota at_most_one R <=> (I,J1)::R, (I,J2)::R, (J1,J2)::different.

% concrete domain predicates
  (X,X)::different <=> fail.
  (X,Y)::identical <=> X=Y.

  X::greater(Y) <=>  ground(X) | X>Y.
  (X,Y)::greater <=> ground(X), ground(Y) | X>Y.
  X::smaller(Y) <=>  ground(X) | X<Y.
  (X,Y)::smaller <=> ground(X), ground(Y) | X<Y.

% binary concrete domain predicates using role chains
  I::some (R1 and R2) is S <=> (I,J1)::R1, (I,J2)::R2, (J1,J2)::S.
:- chr_constraint (every)/3.
  I::every (R1 and R2) is S <=> every((I,I),(R1,R2),S).
  every((I1,I2),(identical,identical),S) <=> (I1,I2)::S.
  every((I1,I2),(identical,R),S), (I2,J2)::R ==> 
	(I1,J2)::S.
  every((I1,I2),(identical,R2 of R),S), (I2,J2)::R ==> 
	every((I1,J2),(identical,R2),S).
  every((I1,I2),(R,R2),S), (I1,J1)::R ==> 
	every((J1,I2),(identical,R2),S).
  every((I1,I2),(R1 of R,R2),S), (I1,J1)::R ==> 
	every((J1,I2),(R1,R2),S).


% unfolding using concept definition
%    if you use recursion in concepts, replace rules below by propagation rules
  I::C <=> (C isa T) | I::T.
  I::nota C <=> (C isa T) | I::nota T.




% EXAMPLES ===================================================================


% Family ---------------------------------------------------------------------

female isa nota male.
woman isa human and female.
man isa human and male.
parent isa human and some child is human.
father isa parent and man.
mother isa parent and woman.
grandfather isa father and some child is parent.
grandmother isa mother and some child is parent.
fatherofsons isa father and every child is male.

feature age. 
person isa (man or woman) and every age is number.

distinct number.
X::number <=> nonvar(X) | number(X).

feature partner.
married_person isa person and every partner is married_person. % recursion !


% Configuration ---------------------------------------------------------------

distinct interface.
distinct configuration.

simple_device isa device and 
	some connector is interface.

feature component_1.
feature component_2.

simple_config isa configuration and
	some component_1 is simple_device and	
	some component_2 is simple_device.

very_simple_device isa simple_device and 
	at_most_one connector.

  feature price.
  feature voltage.
  feature frequency.

  electrical_device isa very_simple_device and
      	some voltage is greater(0) and some price is greater(1).

  low_cost_device isa electrical_device and 
	every price is smaller(200).  

  high_voltage_device isa electrical_device and 
	every voltage is greater(15).

  electrical_config isa simple_configuration and
      	every component_1 is electrical_device and
      	every component_2 is electrical_device and
      	every (voltage of component_1 and voltage of component_2) 
		is greater.

  bus_device isa simple_device and bus and 
	some frequency is greater(0).  
  cpu_device isa simple_device and cpu and 
	some frequency is greater(0).  

  bus_config isa configuration and
      	some main_device is bus_device and
      	every component is cpu_device and
      	every (frequency of main_device and frequency of sub_device)
		is greater.


  catalog(dev1) :- dev1::electrical_device,
      	(dev1,10)::voltage, (dev1,100)::price.
  catalog(dev2) :- dev2::electrical_device,
      	(dev2,20)::voltage, (dev2,1000)::price.

  possible_config(C) :- 
      	catalog(D1), (C,D1)::component_1,
      	catalog(D2), (C,D2)::component_2.

/*
% Example Queries

  :- possible_config(C).

  :- possible_config(C), C::electrical_config.

  :- possible_config(C), C::electrical_config,
      	(C,D1)::component_1, D1::low_cost_device,
      	(C,D2)::component_2, D2::high_voltage_device.
*/


% Prolog terms ---------------------------------------------------------
% see also handler term.chr

feature functor.
feature arity.
feature arg(N).

term isa top and some arity is number and some arity is greater(-1)
	     and some functor is top.

(X,_)::arg(N) ==> N>=1.
%(X,A)::arity ==> A>=0.
(X,A)::arity,(X,_)::arg(N) ==> A>=N,A>=1.

% (X,0)::arity <-> (X,X)::functor
(X,0)::arity ==> (X,X)::functor.
(X,X)::functor ==> (X,0)::arity.


% end of kl-one.pl ========================================================
