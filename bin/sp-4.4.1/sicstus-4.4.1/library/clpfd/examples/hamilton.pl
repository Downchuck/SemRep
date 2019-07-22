:- module(hamilton,[hc/1]).

% ?- bench([hc(static)]).

:-use_module(library(trees)).
:-use_module(library(lists), [keyclumped/2]).
:-use_module(library(clpfd)).

hc(dynamic) :-
	graph(Nodes, Edges),
	length(Nodes, N),
	length(Path, N),
	keyclumped(Edges, Clumps),
	(   foreach(_-Ns,Clumps),
	    foreach(P,Path)
	do  list_to_fdset(Ns, Set),
	    P in_set Set
	),
	circuit(Path),
	labeling([ff,enum], Path),
	writeq(Path),
	nl.
hc(static) :-
	graph(Nodes, Edges),
	length(Nodes, N),
	length(Path, N),
	list_to_tree(Path, Tree),
	keyclumped(Edges, Clumps),
	(   foreach(_-Ns,Clumps),
	    foreach(P,Path)
	do  list_to_fdset(Ns, Set),
	    P in_set Set
	),
	circuit(Path),
	(   foreach(Node,Nodes),
	    foreach(V,Vars),
	    param(Tree)
	do  get_label(Node, Tree, V)
	),
	labeling([enum], Vars),
	writeq(Path),
	nl.

/***
vertex_order(Order) :-
	graph(_, Edges1),
	keyclumped(Edges1, VertNeibs),
	vertex_order(VertNeibs, Order, []).

vertex_order([]) --> !.
vertex_order(VertNeibs1) --> 
	{   foreach(V1-Ns1,VertNeibs1),
	    foreach(K-V1,DI1)
	do  length(Ns1, K)
	},
	{keysort(DI1, DI2)},
	{DI2 = [_-Vertex|_]},
	{filter(VertNeibs1, Vertex, VertNeibs2)},
	vertex_order(VertNeibs2),
	{   foreach(V2-Ns3,VertNeibs1),
	    fromto(VertNeibs2,S0,S,[]),
	    param(Vertex)
	do  (   V2=\=Vertex ->
		S0 = [V2-Ns2|S],
		delete(Ns3, Vertex, Ns2)
	    ;   S0 = S
	    )		
	},
	[Vertex].
***/

:- dynamic graph/2.
graph([60,57,54,44,34,52,31,47,42,43,48,41,55,58,59,37,40,38,56,36,33,45,51,39,50,53,35,32,30,27,24,14,17,1,12,4,13,11,25,7,29,28,22,18,10,8,26,6,3,15,21,9,20,23,5,2,46,49,19,16],
      [1-5,1-11,1-12,1-17,1-22,1-24,1-30,2-3,2-7,2-13,2-15,3-2,3-6,3-7,3-8,3-15,3-26,4-13,4-14,4-18,4-22,4-24,4-27,5-1,5-18,5-19,5-22,5-23,6-3,6-9,6-10,6-15,6-18,6-21,6-26,7-2,7-3,7-8,7-13,7-25,7-29,7-51,8-3,8-7,8-10,8-26,8-29,9-6,9-18,9-20,9-21,9-23,10-6,10-8,10-20,10-21,10-26,10-28,10-29,11-1,11-12,11-13,11-25,11-28,12-1,12-11,12-13,12-14,12-17,13-2,13-4,13-7,13-11,13-12,13-14,13-15,13-18,13-25,14-4,14-12,14-13,14-17,14-27,14-30,15-2,15-3,15-6,15-13,15-18,16-19,16-20,16-23,17-1,17-12,17-14,17-30,18-4,18-5,18-6,18-9,18-13,18-15,18-22,18-23,19-5,19-16,19-23,20-9,20-10,20-16,20-21,20-23,21-6,21-9,21-10,21-20,22-1,22-4,22-5,22-18,22-24,23-5,23-9,23-16,23-18,23-19,23-20,24-1,24-4,24-22,24-27,24-30,25-7,25-11,25-13,25-28,25-29,26-3,26-6,26-8,26-10,27-4,27-14,27-24,27-30,28-10,28-11,28-25,28-29,29-7,29-8,29-10,29-25,29-28,30-1,30-14,30-17,30-24,30-27,31-35,31-41,31-42,31-47,31-52,31-54,31-60,32-33,32-37,32-43,32-45,33-32,33-36,33-37,33-38,33-45,33-56,34-43,34-44,34-48,34-52,34-54,34-57,35-31,35-48,35-49,35-52,35-53,36-33,36-39,36-40,36-45,36-48,36-51,36-56,37-32,37-33,37-38,37-43,37-55,37-59,38-33,38-37,38-40,38-56,38-59,39-36,39-48,39-50,39-51,39-53,40-36,40-38,40-50,40-51,40-56,40-58,40-59,41-31,41-42,41-43,41-55,41-58,42-31,42-41,42-43,42-44,42-47,43-32,43-34,43-37,43-41,43-42,43-44,43-45,43-48,43-55,44-34,44-42,44-43,44-47,44-57,44-60,45-32,45-33,45-36,45-43,45-48,46-6,46-49,46-50,46-53,47-31,47-42,47-44,47-60,48-34,48-35,48-36,48-39,48-43,48-45,48-52,48-53,49-35,49-46,49-53,50-39,50-40,50-46,50-51,50-53,51-36,51-39,51-40,51-50,52-31,52-34,52-35,52-48,52-54,53-35,53-39,53-46,53-48,53-49,53-50,54-31,54-34,54-52,54-57,54-60,55-37,55-41,55-43,55-58,55-59,56-33,56-36,56-38,56-40,57-34,57-44,57-54,57-60,58-40,58-41,58-55,58-59,59-37,59-38,59-40,59-55,59-58,60-31,60-44,60-47,60-54,60-57]).
