%set_prolog_flag(answer_write_options,[max_depth(0)]).
/*
   _____                           _                      _ _           _            
  / ____|                         | |                    | (_)         | |           
 | |  __  ___ _ __   ___ _ __ __ _| |  _ __  _ __ ___  __| |_  ___ __ _| |_ ___  ___ 
 | | |_ |/ _ \ '_ \ / _ \ '__/ _` | | | '_ \| '__/ _ \/ _` | |/ __/ _` | __/ _ \/ __|
 | |__| |  __/ | | |  __/ | | (_| | | | |_) | | |  __/ (_| | | (_| (_| | ||  __/\__ \
  \_____|\___|_| |_|\___|_|  \__,_|_| | .__/|_|  \___|\__,_|_|\___\__,_|\__\___||___/
                                      | |                                            
                                      |_|                                            
*/

% union(+L1, +L2, -L) :- L is the union of sets L1 and L2 represented by an ordered list.
union_set([], L, L) :- !.
union_set(L, [], L) :- !.
union_set([X|Xs], Y, [X|Zs]) :- union_set(Xs, Y, [X|Zs]), !. % X is already included
union_set(X, [Y|Ys], [Y|Zs]) :- union_set(X, Ys, [Y|Zs]), !. % Y is already included
union_set([X|Xs], [Y|Ys], [X|Zs]) :- X < Y, union_set(Xs, [Y|Ys], Zs).
union_set([X|Xs], [Y|Ys], [Y|Zs]) :- Y < X, union_set([X|Xs], Ys, Zs).

% list_difference(L1, L2, L) :- L contains those members L1 which are not members of L2
list_difference([], _, []).
list_difference([X|Xs], L2, Zs) :- member(X, L2), list_difference(Xs, L2, Zs), !.
list_difference([X|Xs], L2, [X|Zs]) :- list_difference(Xs, L2, Zs).

% nonempty_intersect(+List1, +List2) :- List1 and List2 share at least one element
nonempty_intersect([X|_], Y) :- member(X, Y), !.
nonempty_intersect([_|Xs], Y) :- nonempty_intersect(Xs, Y).

% lam_search(+TF, +States, -Closure) :- Closure is the lambda closure of States under the transition function TF
lam_search(TF, States, Closure) :- lam_search(TF, States, [], Closure).
lam_search(_, [], Visited, Visited).
lam_search(TF, [X|Xs], Visited, Res) :- member([X, '\\', States], TF), list_difference(States, Visited, NewStates), append(Xs, NewStates, Quewe), lam_search(TF, Quewe, [X|Visited], Res), !.
lam_search(TF, [X|Xs], Visited, Res) :- lam_search(TF, Xs, [X|Visited], Res).

% union_transition(+TF, +Input, +State, +Transitions, -R) :- R contains the union of sets Transitions and the set of reachable states from State with Input under the transition function TF
union_transition(TF, Input, State, Transitions, R) :- member([State, Input, Next], TF), union_set(Next, Transitions, R), !.
union_transition(_, _, _, Transitions, Transitions).

% nfa_step(+TF, +I, +C, -N) :- the transition funtion TF projects the current states C to next states N with the input I
nfa_step(TF, I, C, N) :- lam_search(TF, C, Close), foldl(union_transition(TF,I), Close, [], Reachable), lam_search(TF, Reachable, N).

% nfa_parse(NFA, Input) :- satisfiable iff the NFA accepts the string Input
nfa_parse(nfa(Start, TF, Fin), "") :- lam_search(TF, Start, LClose), nonempty_intersect(LClose, Fin), !.
nfa_parse(nfa(Start, TF, Fin), Input) :- atom_chars(Input, Chars), foldl(nfa_step(TF), Chars, Start, Res), nonempty_intersect(Res, Fin), !.

% dfa_transition_to_nfa(+DFA_Fun, -NFA_Fun) :- NFA_fun is the equivalend transition rule ro DFA_Fun
dfa_transition_to_nfa([State, Sym, Value],[State, Sym, [Value]]).

% dfa_to_nfa(+DFA, -NFA) :- NFA is the equivalent automaton to DFA
dfa_to_nfa(dfa(Start, DeTF, Fin), nfa([Start], NdTF, Fin)) :- maplist(dfa_transition_to_nfa, DeTF, NdTF).

% dfa_parse(DFA, Input) :- satisfiable iff the DFA accepts the string Input
dfa_parse(DFA, Input) :- dfa_to_nfa(DFA, NFA), nfa_parse(NFA, Input).





/*
  _____  ______        _          _____            ______            
 |  __ \|  ____/\     | |        |  __ \          |  ____|           
 | |  | | |__ /  \    | |_ ___   | |__) |___  __ _| |__  __  ___ __  
 | |  | |  __/ /\ \   | __/ _ \  |  _  // _ \/ _` |  __| \ \/ / '_ \ 
 | |__| | | / ____ \  | || (_) | | | \ \  __/ (_| | |____ >  <| |_) |
 |_____/|_|/_/    \_\  \__\___/  |_|  \_\___|\__, |______/_/\_\ .__/ 
                                              __/ |           | |    
                                             |___/            |_|
*/

% list_to_dif(+L, -DL) :- DL is the equivalent difference list to L
list_to_dif([],S-S).
list_to_dif([X|Xs],[X|S]-T) :- list_to_dif(Xs,S-T).

dif_to_list(Xs-[], Xs).

% concat_dif(+L1, +L2, -L) :- L is the concatenation of difference lists L1 and L2
concat_dif(A-B, B-C, A-C).

% join_with(+Sep, +L, -R) :- R is the result of inserting Sep between all characters of L
join_with(_, [X], [X]) :- !.
join_with(Sep, [X|Xs], [X,Sep|Res]) :- join_with(Sep, Xs, Res).

% join_lists_with(+Sep, +L1, +L2, -Res) :- L is the concatenaton of L1 and L2 separated by Sep
join_lists_with(Sep, L1, L2, Res) :- concat_dif(L1, [Sep|X]-X, LTemp), concat_dif(LTemp, L2, Res).

% maplist1(+Predicate, +List, -ResultList) :- similar to maplist but drops elements that cant be called
maplist1(_, [], []).
maplist1(Pred, [X|Xs], [R|Res]) :- call(Pred, X, R), maplist1(Pred, Xs, Res), !.
maplist1(Pred, [_|Xs], Res) :- maplist1(Pred, Xs, Res).

% r(+TF, +I, +J, +K, -Expr) :- the expression R_{i, j}^k from the construction of RegExp
r(TF, I, I, 0, Expr) :- !, bagof(Char, member([I, Char, I], TF), Bag), join_with('+', ['\\'|Bag], Joined), list_to_dif(Joined, Expr).
r(TF, I, J, 0, Expr) :- !, bagof(Char, member([I, Char, J], TF), Bag), join_with('+', Bag, Joined), list_to_dif(Joined, Expr).
r(TF, I, J, K, Expr) :- K_minus is K - 1, 
    r(TF, I, J, K_minus, E1),
    r(TF, I, K, K_minus, E2),
    r(TF, K, K, K_minus, E3),
    r(TF, K, J, K_minus, E4),
    join_lists_with('+(', E1, E2, L1),
    join_lists_with(').(', L1, E3, L2),
    join_lists_with(')*.(', L2, E4, L3),
    concat_dif(L3, [')'|D]-D, Expr),
    !.
r(TF, I, J, K, Expr) :- K_minus is K - 1, 
    r(TF, I, J, K_minus, Expr), !. % the second part of the formula is empty
r(TF, I, J, K, Expr) :- K_minus is K - 1, 
    r(TF, I, K, K_minus, E2),
    r(TF, K, K, K_minus, E3),
    r(TF, K, J, K_minus, E4),
    concat_dif(['('|Tmp0]-Tmp0, E2, L0),
    join_lists_with(').(', L0, E3, L1),
    join_lists_with(')*.(', L1, E4, L2),
    concat_dif(L2, [')'|Tmp1]-Tmp1, Expr). % the first part of the formula is empty

% helper predicate for foldl; simply changes the order of arguments
generate_r(TF, Start, Max, Index, Res) :- r(TF, Start, Index, Max, Res).

% dfa_to_regexp(+DFA, -Expr) :- Expr is the corresponding regexp to the DFA
dfa_to_regexp(dfa(Start, TF, Fin), Expr) :- findall(State, member([_, _, State], [[_, _, Start]|TF]), Reachable),
    max_list(Reachable, MaxIndex),
    maplist1(generate_r(TF, Start, MaxIndex), Fin, [Ex1|Exs]),
    foldl(join_lists_with('+'), Exs, Ex1, LstD),
    dif_to_list(LstD, Lst),
    atomic_list_concat(Lst, Expr), !.
dfa_to_regexp(_, "#").

/*
  _____            ______              _          _   _ ______      
 |  __ \          |  ____|            | |        | \ | |  ____/\    
 | |__) |___  __ _| |__  __  ___ __   | |_ ___   |  \| | |__ /  \   
 |  _  // _ \/ _` |  __| \ \/ / '_ \  | __/ _ \  | . ` |  __/ /\ \  
 | | \ \  __/ (_| | |____ >  <| |_) | | || (_) | | |\  | | / ____ \ 
 |_|  \_\___|\__, |______/_/\_\ .__/   \__\___/  |_| \_|_|/_/    \_\
              __/ |           | |                                   
             |___/            |_|                                   
*/
% lamda: '\\' (escaped backslash)
% empty expresion: '#'

% TODO
% remove_outter_brackets(+DLst, -Res) :- Res is the expression DList after removing all pairs of bracket around the inner expression; both represented by a dif list.
remove_outter_brackets(['('|Xs]-A, Res-B) :- remove_last_bracket(Xs-A, 0, Tmp), remove_outter_brackets(Tmp, Res-B), !.
remove_outter_brackets(X, X).

% remove_last_bracket(+Lst, +OpenBrackets, -Result) :- difference Lst ends with ')' and Result is the Lst without the ')', if the ')' does not correspond to another open bracket.
remove_last_bracket([')'|A]-A, 0, A-A) :- var(A), !.
remove_last_bracket(['('|Xs]-A, OB, ['('|Res]-B) :-  var(A), var(B), NOB is OB + 1, remove_last_bracket(Xs-A, NOB, Res-B), !.
remove_last_bracket([')'|Xs]-A, OB, [')'|Res]-B) :- var(A), var(B), !, OB > 0, NOB is OB - 1, remove_last_bracket(Xs-A, NOB, Res-B), !.
remove_last_bracket([X|Xs]-A, OB, [X|Res]-B) :- var(A), var(B), remove_last_bracket(Xs-A, OB, Res-B).

% combine_to_term(+Operator, +LeftTree, +RightTree, -CompondTerm) :- combines the LeftTree and RightTree into the corresponding CompondTerm based on the Operator
combine_to_term('+', Left, Right, alt(Left, Right)).
combine_to_term('.', Left, Right, concat(Left, Right)).

% build_expr_tree1(+DLst, -Res) :- builds a corresponding expression tree to the regexp DList represented as a difference list
build_expr_tree1(DLst, Res) :- remove_outter_brackets(DLst, Tmp), build_expr_tree1('+', A-A, Tmp, 0, Res), !.
build_expr_tree1(DLst, Res) :- remove_outter_brackets(DLst, Tmp), build_expr_tree1('.', A-A, Tmp, 0, Res), !.
build_expr_tree1(DLst, Res) :- remove_outter_brackets(DLst, Tmp), build_expr_tree1('*', A-A, Tmp, 0, Res), !.

% build_expr_tree1(+CurrentLowestPriorityOperator, +LeftSideExpression, +RightSideExpression, +CurrentlyOpenBrackets, -Tree)
build_expr_tree1('*', Left, ['*'|R]-R, 0, iter(Tree)) :- var(R), build_expr_tree1(Left, Tree), !.
build_expr_tree1(LowestSymbol, Left, [LowestSymbol|Right]-R, 0, Tree) :- var(R), build_expr_tree1(Left, LeftTree), build_expr_tree1(Right-R, RightTree), combine_to_term(LowestSymbol, LeftTree, RightTree, Tree), !.
build_expr_tree1(_, L-L, ['\\'|R]-R, 0, lam) :- var(R), var(L), !.
build_expr_tree1(_, L-L, ['#'|R]-R, 0, empt) :- var(R), var(L), !.
build_expr_tree1(_, L-L, [Sym|R]-R, 0, sym(Sym)) :- var(R), var(L), !.
build_expr_tree1(LS, Left, ['('|Right]-R, OpenBrackets, Res) :- 
    var(R), !,
    concat_dif(Left, ['('|A]-A, NewLeft), 
    NewOpenBrackets is OpenBrackets + 1, 
    build_expr_tree1(LS, NewLeft, Right-R, NewOpenBrackets, Res), !.
build_expr_tree1(LS, Left, [')'|Right]-R, OpenBrackets, Res) :- 
    var(R), !, 
    concat_dif(Left, [')'|A]-A, NewLeft), 
    NewOpenBrackets is OpenBrackets - 1, 
    build_expr_tree1(LS, NewLeft, Right-R, NewOpenBrackets, Res), !.
build_expr_tree1(LS, Left, [Char|Right]-R, OpenBrackets, Res) :- var(R), concat_dif(Left, [Char|A]-A, NewLeft), var(A), build_expr_tree1(LS, NewLeft, Right-R, OpenBrackets, Res).


% build_expr_tree(+Expr, -Tree) :- Expr is the regular expression represented by a string, Tree is the corresponding expression tree
exp_to_tree(Exp, Res) :- atom_chars(Exp, Lst), list_to_dif(Lst, Dif), build_expr_tree1(Dif, Res).

% tree_eval(+Tree, -NFA) :- builds the corresponging NFA for the regexp Tree
tree_eval(Tree, Res) :- tree_eval(Tree, 0, _, Res).

% tree_eval(+Tree, +NumberOfStates, -NewNumberOfStates, -Res)
tree_eval(lam, NumberOfStates, NewNumberOfStates, nfa([A], [[A, '\\', [B]]], [B])) :- 
    A is NumberOfStates + 1,
    B is NumberOfStates + 2,
    NewNumberOfStates is B.
tree_eval(empt, NumberOfStates, NewNumberOfStates, nfa([A], [], [B])) :- 
    A is NumberOfStates + 1,
    B is NumberOfStates + 2,
    NewNumberOfStates is B.
tree_eval(sym(X), NumberOfStates, NewNumberOfStates, nfa([A], [[A, X, [B]]], [B])) :- 
    A is NumberOfStates + 1,
    B is NumberOfStates + 2,
    NewNumberOfStates is B.
tree_eval(alt(X, Y), NumberOfStates, NewNumberOfStates, nfa([A], TF, [B])) :- 
    tree_eval(X, NumberOfStates, NOS1, nfa([RS], RTF, [RF])),
    tree_eval(Y, NOS1, NOS2, nfa([SS], STF, [SF])),
    A is NOS2 + 1,
    B is NOS2 + 2,
    NewNumberOfStates is B,
    append([[A, '\\', [RS, SS]], [RF, '\\', [B]], [SF, '\\', [B]]], RTF, TmpTF),
    append(TmpTF, STF, TF).
tree_eval(concat(X, Y), NumberOfStates, NOS2, nfa([RS], TF, [SF])) :- 
    tree_eval(X, NumberOfStates, NOS1, nfa([RS], RTF, [RF])),
    tree_eval(Y, NOS1, NOS2, nfa([SS], STF, [SF])),
    append([[RF, '\\', [SS]]], RTF, TmpTF),
    append(TmpTF, STF, TF).
tree_eval(iter(X), NumberOfStates, NewNumberOfStates, nfa([A], TF, [B])) :- 
    tree_eval(X, NumberOfStates, NOS1, nfa([RS], RTF, [RF])),
    A is NOS1 + 1,
    B is NOS1 + 2,
    NewNumberOfStates is B,
    append([[A, '\\', [RS, B]], [RF, '\\', [RS, B]]], RTF, TF).

% regexp_to_nfa(+RegularExpression, -NFA) :- NFA is the corresponding lam-NFA to the RegularExpression
regexp_to_nfa(RE, NFA) :- exp_to_tree(RE, Tree), tree_eval(Tree, NFA).




/*
  _______        _       
 |__   __|      | |      
    | | ___  ___| |_ ___ 
    | |/ _ \/ __| __/ __|
    | |  __/\__ \ |_\__ \
    |_|\___||___/\__|___/
                         
*/

% simple lam-NFA for accepting numbers of the four base
% YES "3.", ".2", "-2.3"
% NO ".", "1", "5"
base_4_nfa(nfa([1], [
    [1, '\\', [2]],
    [1, '+', [2]],
    [1, '-', [2]],
    [2, '0', [2,5]],
    [2, '1', [2,5]],
    [2, '2', [2,5]],
    [2, '3', [2,5]],
    [2, '.', [3]],
    [3, '0', [4]],
    [3, '1', [4]],
    [3, '2', [4]],
    [3, '3', [4]],
    [4, '0', [4]],
    [4, '1', [4]],
    [4, '2', [4]],
    [4, '3', [4]],
    [4, '\\', [6]],
    [5, '.', [4]]
], [6])).
start_base_four_test :-
    base_4_nfa(NFA),
    write("This is a simple test of parsing fractions of base four with a lam-NFA.\n"),
    write("Testing for \"3.\".\n"),
    nfa_parse(NFA, "3."), 
    write("Accepted.\n"),
    write("Testing for \".2\".\n"),
    nfa_parse(NFA, ".2"), 
    write("Accepted.\n"),
    write("Testing for \"-2.3\".\n"),
    nfa_parse(NFA, "-2.3"),
    write("Accepted.\n"),
    write("Testing for \"-2.3.\".\n"),
    not(nfa_parse(NFA, "-2.3.")),
    write("Rejected.\n"),
    write("Testing for \".5\".\n"),
    not(nfa_parse(NFA, ".5")),
    write("Rejected.\n"),
    write("Test OK.\n").


start_exp_tree_test :-
    write("This test demonstrates the conversion from RegExp expression tree, with regards to the operators priority\n"),
    write("Converting \"\\.a+b*\"\n"),
    exp_to_tree("\\.a+b*", T1),
    write("Result:\n"),
    write(T1),
    write("\n\nConverting \"\\.(a+b)*\"\n"),
    exp_to_tree("\\.(a+b)*", T2),
    write("Result:\n"),
    write(T2),
    write("\n\nConverting \"a.b+c.d\"\n"),
    exp_to_tree("a.b+c.d", T3),
    write("Result:\n"),
    write(T3),
    write("\n\nTest done.\n").


% dfa accepting words {a,b}^n that have a number of a's that is divisible by three.
% YES "", "aaa", "bababbabb"
% NO "aaabc", "aa", "abababa"
a_div_3_dfa(dfa(1, [
    [1, a, 2],
    [1, b, 1],
    [2, a, 3],
    [2, b, 2],
    [3, a, 1],
    [3, b, 3]
], [1]) ).

start_fa_to_rege_to_fa_test :-
    a_div_3_dfa(DFA),
    write("This test tries DFA parsing, then converts the DFA to RegExp and then back to NFA and tests it.\n"),
    write("The DFA acceptswords {a,b}^n that have a number of occurances of \"a\" that is divisible by three\n"),
    write("Testing for \"\".\n"),
    dfa_parse(DFA, ""), 
    write("Accepted.\n"),
    write("Testing for \"babaabababbbabbb\".\n"),
    dfa_parse(DFA, "babaabababbbabbb"), 
    write("Accepted.\n"),
    write("Testing for \"baba\".\n"),
    not(dfa_parse(DFA, "baba")), 
    write("Rejected.\n"),
    write("Part 1 OK.\n\n"),

    write("Converting the DFA to RegExp.\n"),
    dfa_to_regexp(DFA, RE),
    write("Result:\n"),
    write(RE),
    write("\nPart 2 OK.\n\n"),

    write("Converting the RegExp to NFA.\n"),
    regexp_to_nfa(RE, NFA),
    write("Result:\n"),
    write(NFA),
    write("\nPart 3 OK.\n\n"),

    write("Testing the NFA.\n"),
    write("Testing for \"\".\n"),
    nfa_parse(NFA, ""), 
    write("Accepted.\n"),
    write("Testing for \"babaabababbbabbb\".\n"),
    nfa_parse(NFA, "babaabababbbabbb"), 
    write("Accepted.\n"),
    write("Testing for \"baba\".\n"),
    not(nfa_parse(NFA, "baba")), 
    write("Rejected.\n"),
    write("Part 4 OK.\n\n"),

    write("Test OK.\n").

start_re_to_nfa_demo_test :-
    write("This test demonstrates the conversion from RegExp to NFA on a short expression\n"),
    write("Converting \"\\+a.c*\"\n"),
    regexp_to_nfa("\\+a.c*", N),
    write("Result:\n"),
    write(N),
    write("\nTest done.\n").

test(start_base_four_test).
test(start_exp_tree_test).
test(start_fa_to_rege_to_fa_test).
test(start_re_to_nfa_demo_test).

start_all_tests :- write("Starting all tests. Press \";\" to move to the next test or \".\" to exit.\n").
start_all_tests :- start_base_four_test, write("\n\n"). 
start_all_tests :- start_exp_tree_test, write("\n\n").
start_all_tests :- start_fa_to_rege_to_fa_test, write("\n\n").
start_all_tests :- start_re_to_nfa_demo_test, write("\n\n").