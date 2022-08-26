# Finite automaton to regular expression to finite wutomaton in prolog

## Introduction

### Disclaimer
This project was created as a final project for the non-procedural programming class at Charles University, Prague. The code was not written by a professional programmer. We are not responsible for any bugs in the program and their consequences. We decided to publish the project for educational purposes only.

### Copyright
You may use and edit the code or any of its parts for non-commercial uses. You must, however, state that this is not your own code, i.e., using this code alone to obtain a credit at your university is not allowed.

### Specification
This project written in [Prolog language](https://en.wikipedia.org/wiki/Prolog) demonstrates the conversion from [FSM](https://en.wikipedia.org/wiki/Finite-state_machine) to [regular expression](https://en.wikipedia.org/wiki/Regular_expression) and vice versa.

This is a CLI application with two main predicates:
1. `dfa_to_regexp(+DFA: DFA, -RegularExpression: string)`
2. `regexp_to_nfa(+Expression: string, -NFA: NFA)`

Additionally, two predicates for parsing string by FSM are available: `dfa_parse(+DFA, +String)` and `nfa_parse(+NFA, +String)`.

## User manual

### Prerequirements

This projects requires Prolog installed on your computer. [SWI-Prolog](https://www.swi-prolog.org/) was used for developing the project. This user manual will use SWI-Prolog specific names, such as the `swipl` command.

### Notation
#### Regexp
There are 7 specific symbols for regular expressions:
1. `+` for alternation,
2. `.` for concatenation,
3. `*` for iteration,
4. `(` for open bracket,
5. `)` for close bracket,
6. `\` for $\lambda$ or $\varepsilon$ (similar to [Haskell](https://www.haskell.org/) syntax),
7. `#` for $\emptyset$.

Every other symbol will be considered a regular symbol. Symbols can only be one character long.

Every operation has to be explicitely stated, e.g. the expression $ab+c$ would be denoted by `a.b+c`.

The priority of the operators is as follows (highest to lowest): iteration, concatenation, alternation.

__Note:__ In some contexts you may need to escape the `\`, resulting in double backslash `\\`.

#### DFA
[Deterministic finite automaton](https://en.wikipedia.org/wiki/Deterministic_finite_automaton) is represented by a compunnd term:

```prolog
dfa(StartState, TransitionFunction, FinishStates)
```

Where:
* `StartState` is a name of a state, typically a number,
* `TransitionFunction` is a list of transition rules:
    * transition rule is a triple `[Current, Input, Next]`, which denotes that the automaton transitions from the state `Current` to `Next` if it reads the `Input`.
* `FinishStates` is a list of names of states which are finishing.

For example, the following compound term would represent the automaton below.
```prolog
dfa(1, [
    [1, a, 2],
    [1, b, 1],
    [2, a, 3],
    [2, b, 2],
    [3, a, 1],
    [3, b, 3]
], [1])
```

<p style="text-align: center">
<svg width="300" height="220" version="1.1" style="background-color: white; border-radius: 12px" xmlns="http://www.w3.org/2000/svg">
	<ellipse stroke="black" stroke-width="1" fill="none" cx="73.5" cy="109.5" rx="30" ry="30"/>
	<text x="68.5" y="115.5" font-family="Times New Roman" font-size="20">1</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="73.5" cy="109.5" rx="24" ry="24"/>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="197.5" cy="40.5" rx="30" ry="30"/>
	<text x="192.5" y="46.5" font-family="Times New Roman" font-size="20">2</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="197.5" cy="174.5" rx="30" ry="30"/>
	<text x="192.5" y="180.5" font-family="Times New Roman" font-size="20">3</text>
	<polygon stroke="black" stroke-width="1" points="17.5,109.5 43.5,109.5"/>
	<polygon fill="black" stroke-width="1" points="43.5,109.5 35.5,104.5 35.5,114.5"/>
	<path stroke="black" stroke-width="1" fill="none" d="M 60.275,82.703 A 22.5,22.5 0 1 1 86.725,82.703"/>
	<text x="68.5" y="33.5" font-family="Times New Roman" font-size="20">b</text>
	<polygon fill="black" stroke-width="1" points="86.725,82.703 95.473,79.17 87.382,73.292"/>
	<path stroke="black" stroke-width="1" fill="none" d="M 221.691,22.956 A 22.5,22.5 0 1 1 226.14,49.029"/>
	<text x="271.5" y="32.5" font-family="Times New Roman" font-size="20">b</text>
	<polygon fill="black" stroke-width="1" points="226.14,49.029 231.094,57.058 235.527,48.094"/>
	<path stroke="black" stroke-width="1" fill="none" d="M 220.57,155.506 A 22.5,22.5 0 1 1 226.609,181.258"/>
	<text x="270.5" y="160.5" font-family="Times New Roman" font-size="20">b</text>
	<polygon fill="black" stroke-width="1" points="226.609,181.258 232.046,188.968 235.921,179.749"/>
	<polygon stroke="black" stroke-width="1" points="99.715,94.913 171.285,55.087"/>
	<polygon fill="black" stroke-width="1" points="171.285,55.087 161.863,54.608 166.726,63.346"/>
	<text x="121.5" y="65.5" font-family="Times New Roman" font-size="20">a</text>
	<polygon stroke="black" stroke-width="1" points="197.5,70.5 197.5,144.5"/>
	<polygon fill="black" stroke-width="1" points="197.5,144.5 202.5,136.5 192.5,136.5"/>
	<text x="202.5" y="113.5" font-family="Times New Roman" font-size="20">a</text>
	<polygon stroke="black" stroke-width="1" points="100.071,123.428 170.929,160.572"/>
	<polygon fill="black" stroke-width="1" points="170.929,160.572 166.165,152.429 161.522,161.286"/>
	<text x="121.5" y="163.5" font-family="Times New Roman" font-size="20">a</text>
</svg>
</p>

#### NFA
[Nondeterministic finite automaton](https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton) is represented similarly to above:

```prolog
nfa(StartStates, TransitionFunction, FinishStates)
```

Where:
* `StartStates` is a __sorted list__ of names of the starting states,
* `TransitionFunction` is a list of transition rules:
    * transition rule is a triple `[Current, Input, NextStates]`, which denotes that the automaton transitions from the state `Current` to the __list__ of states `NextStates`, which are __sorted__ lexicographically, if it reads the `Input`.
* `FinishStates` is a list of names of states which are finishing.

For example, the following compound term would represent the automaton below.
```prolog
nfa([1, 3], [
    [1, a, [1,2]],
    [1, '\\', [3]],
    [3, a, [2]]
], [2])
```

<p style="text-align: center">
<svg width="250" height="250" version="1.1" style="background-color: white; border-radius: 12px" xmlns="http://www.w3.org/2000/svg">
	<ellipse stroke="black" stroke-width="1" fill="none" cx="79.5" cy="77.5" rx="30" ry="30"/>
	<text x="74.5" y="83.5" font-family="Times New Roman" font-size="20">1</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="79.5" cy="188.5" rx="30" ry="30"/>
	<text x="74.5" y="194.5" font-family="Times New Roman" font-size="20">3</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="186.5" cy="131.5" rx="30" ry="30"/>
	<text x="181.5" y="137.5" font-family="Times New Roman" font-size="20">2</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="186.5" cy="131.5" rx="24" ry="24"/>
	<polygon stroke="black" stroke-width="1" points="28.5,77.5 49.5,77.5"/>
	<polygon fill="black" stroke-width="1" points="49.5,77.5 41.5,72.5 41.5,82.5"/>
	<polygon stroke="black" stroke-width="1" points="28.5,188.5 49.5,188.5"/>
	<polygon fill="black" stroke-width="1" points="49.5,188.5 41.5,183.5 41.5,193.5"/>
	<polygon stroke="black" stroke-width="1" points="106.283,91.016 159.717,117.984"/>
	<polygon fill="black" stroke-width="1" points="159.717,117.984 154.828,109.915 150.323,118.843"/>
	<text x="137.5" y="95.5" font-family="Times New Roman" font-size="20">a</text>
	<path stroke="black" stroke-width="1" fill="none" d="M 92.421,50.555 A 22.5,22.5 0 1 1 108.747,71.366"/>
	<text x="138.5" y="27.5" font-family="Times New Roman" font-size="20">a</text>
	<polygon fill="black" stroke-width="1" points="108.747,71.366 116.926,76.068 116.557,66.075"/>
	<polygon stroke="black" stroke-width="1" points="79.5,107.5 79.5,158.5"/>
	<polygon fill="black" stroke-width="1" points="79.5,158.5 84.5,150.5 74.5,150.5"/>
	<text x="64.5" y="139.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="105.977,174.395 160.023,145.605"/>
	<polygon fill="black" stroke-width="1" points="160.023,145.605 150.611,144.953 155.313,153.779"/>
	<text x="137.5" y="181.5" font-family="Times New Roman" font-size="20">a</text>
</svg>
</p>

### Use
#### Starting the program
To start the file, make sure that `swipl` is a valid environment variable in zour environment. Then, open a terminal/cmd and tzpe the following:
```
swipl [path_to_FSM-RegExp.pl]
```

#### Using the predicates
* For DFA to RE write the following

    ```
    dfa_to_regexp({your DFA}, R).
    ```

    Example:
    ```
    ?- dfa_to_regexp(dfa(1, [[1, 'a', 2]], [2]), RE).
    RE = a.
    ```
* For RE to NFA write the following

    ```
    regexp_to_nfa({your RegExp}, NFA).
    ```

    Example:
    ```
    ?- regexp_to_nfa("a", NFA).
    NFA = nfa([1], [[1, a, [2]]], [2]).
    ```
* For NFA/DFA parsing write the following

    ```
    nfa_parse({your NFA}, {your word}).
    dfa_parse({your DFA}, {your word}).
    ```

    The result is `true` if the word is accepted and `false` otherwise.

    Example:
    ```
    ?- nfa_parse(nfa([1], [[1, a, [2]]], [2]), "a").
    true.
    ```

## Tests
To start all tests, run the following:
```
?- start_all_tests.
```
Then press `;` to start the next test.

### Base four test
```
?- start_base_four_test.
```

This is a test of parsing fraction in 4-base system. The test is run on the following NFA:

<p style="text-align: center">
<svg width="530" height="330" version="1.1" style="background-color: white; border-radius: 12px" xmlns="http://www.w3.org/2000/svg">
    <ellipse stroke="black" stroke-width="1" fill="none" cx="100.5" cy="106.5" rx="30" ry="30"/>
	<text x="95.5" y="112.5" font-family="Times New Roman" font-size="20">1</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="229.5" cy="106.5" rx="30" ry="30"/>
	<text x="224.5" y="112.5" font-family="Times New Roman" font-size="20">2</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="368.5" cy="106.5" rx="30" ry="30"/>
	<text x="363.5" y="112.5" font-family="Times New Roman" font-size="20">5</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="229.5" cy="217.5" rx="30" ry="30"/>
	<text x="224.5" y="223.5" font-family="Times New Roman" font-size="20">3</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="368.5" cy="217.5" rx="30" ry="30"/>
	<text x="363.5" y="223.5" font-family="Times New Roman" font-size="20">4</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="469.5" cy="217.5" rx="30" ry="30"/>
	<text x="464.5" y="223.5" font-family="Times New Roman" font-size="20">6</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="469.5" cy="217.5" rx="24" ry="24"/>
	<polygon stroke="black" stroke-width="1" points="22.5,106.5 70.5,106.5"/>
	<polygon fill="black" stroke-width="1" points="70.5,106.5 62.5,101.5 62.5,111.5"/>
	<polygon stroke="black" stroke-width="1" points="130.5,106.5 199.5,106.5"/>
	<polygon fill="black" stroke-width="1" points="199.5,106.5 191.5,101.5 191.5,111.5"/>
	<text x="141.5" y="127.5" font-family="Times New Roman" font-size="20">&#955;, +, -</text>
	<polygon stroke="black" stroke-width="1" points="259.5,106.5 338.5,106.5"/>
	<polygon fill="black" stroke-width="1" points="338.5,106.5 330.5,101.5 330.5,111.5"/>
	<text x="264.5" y="127.5" font-family="Times New Roman" font-size="20">0, 1, 2, 3</text>
	<path stroke="black" stroke-width="1" fill="none" d="M 216.275,79.703 A 22.5,22.5 0 1 1 242.725,79.703"/>
	<text x="194.5" y="30.5" font-family="Times New Roman" font-size="20">0, 1, 2, 3</text>
	<polygon fill="black" stroke-width="1" points="242.725,79.703 251.473,76.17 243.382,70.292"/>
	<polygon stroke="black" stroke-width="1" points="229.5,136.5 229.5,187.5"/>
	<polygon fill="black" stroke-width="1" points="229.5,187.5 234.5,179.5 224.5,179.5"/>
	<text x="219.5" y="168.5" font-family="Times New Roman" font-size="20">.</text>
	<polygon stroke="black" stroke-width="1" points="259.5,217.5 338.5,217.5"/>
	<polygon fill="black" stroke-width="1" points="338.5,217.5 330.5,212.5 330.5,222.5"/>
	<text x="264.5" y="238.5" font-family="Times New Roman" font-size="20">0, 1, 2, 3</text>
	<path stroke="black" stroke-width="1" fill="none" d="M 381.725,244.297 A 22.5,22.5 0 1 1 355.275,244.297"/>
	<text x="333.5" y="306.5" font-family="Times New Roman" font-size="20">0, 1, 2, 3</text>
	<polygon fill="black" stroke-width="1" points="355.275,244.297 346.527,247.83 354.618,253.708"/>
	<polygon stroke="black" stroke-width="1" points="398.5,217.5 439.5,217.5"/>
	<polygon fill="black" stroke-width="1" points="439.5,217.5 431.5,212.5 431.5,222.5"/>
	<text x="414.5" y="238.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="368.5,136.5 368.5,187.5"/>
	<polygon fill="black" stroke-width="1" points="368.5,187.5 373.5,179.5 363.5,179.5"/>
	<text x="358.5" y="168.5" font-family="Times New Roman" font-size="20">.</text>
</svg>
</p>

### Expression tree test
```
?- start_exp_tree_test.
```

This is a test of parsing string into an expression tree with regard to the priority of the operators. The anatomy of the tree is similar to the [Binary expression tree](https://en.wikipedia.org/wiki/Binary_expression_tree). The notation of each node is: `node(LeftSubtree, RightSubtree)` or, in unary operators, `node(Subtree)` or just `node` for nullary operators. The possible nodes are:
* `alt(L, R)` for $+$
* `concat(L, R)` for $.$
* `iter(T)` for $*$
* `sym(X)` for a symbol
* `lam` for $\lambda$
* `empt` for $\emptyset$

The value `alt(concat(lam,sym(a)),iter(sym(b)))` corresponds to the following tree:

<p style="text-align: center">
<svg width="250" height="300" version="1.1" style="background-color: white; border-radius: 12px" xmlns="http://www.w3.org/2000/svg">
    <ellipse stroke="black" stroke-width="1" fill="none" cx="136.5" cy="38.5" rx="30" ry="30"/>
	<text x="130.5" y="44.5" font-family="Times New Roman" font-size="20">+</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="86.5" cy="151.5" rx="30" ry="30"/>
	<text x="84.5" y="157.5" font-family="Times New Roman" font-size="20">.</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="188.5" cy="151.5" rx="30" ry="30"/>
	<text x="183.5" y="157.5" font-family="Times New Roman" font-size="20">*</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="188.5" cy="255.5" rx="30" ry="30"/>
	<text x="175.5" y="261.5" font-family="Times New Roman" font-size="20">"b"</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="53.5" cy="255.5" rx="30" ry="30"/>
	<text x="48.5" y="261.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="123.5" cy="255.5" rx="30" ry="30"/>
	<text x="110.5" y="261.5" font-family="Times New Roman" font-size="20">"a"</text>
	<polygon stroke="black" stroke-width="1" points="124.361,65.934 98.639,124.066"/>
	<polygon fill="black" stroke-width="1" points="98.639,124.066 106.449,118.773 97.304,114.727"/>
	<polygon stroke="black" stroke-width="1" points="149.041,65.753 175.959,124.247"/>
	<polygon fill="black" stroke-width="1" points="175.959,124.247 177.157,114.889 168.072,119.07"/>
	<polygon stroke="black" stroke-width="1" points="188.5,181.5 188.5,225.5"/>
	<polygon fill="black" stroke-width="1" points="188.5,225.5 193.5,217.5 183.5,217.5"/>
	<polygon stroke="black" stroke-width="1" points="77.427,180.095 62.573,226.905"/>
	<polygon fill="black" stroke-width="1" points="62.573,226.905 69.759,220.792 60.227,217.767"/>
	<polygon stroke="black" stroke-width="1" points="96.556,179.765 113.444,227.235"/>
	<polygon fill="black" stroke-width="1" points="113.444,227.235 115.474,218.022 106.052,221.374"/>
</svg>
</p>

### DFA to RegExp to NFA test

```
?- start_fa_to_rege_to_fa_test.
```

This tests demonstrates and tests both ways of conversion bewtween FA and RE. The original DFA is as follows.

<p style="text-align: center">
<svg width="300" height="270" version="1.1" style="background-color: white; border-radius: 12px" xmlns="http://www.w3.org/2000/svg">
	<ellipse stroke="black" stroke-width="1" fill="none" cx="92.5" cy="109.5" rx="30" ry="30"/>
	<text x="87.5" y="115.5" font-family="Times New Roman" font-size="20">1</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="92.5" cy="109.5" rx="24" ry="24"/>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="238.5" cy="109.5" rx="30" ry="30"/>
	<text x="233.5" y="115.5" font-family="Times New Roman" font-size="20">2</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="162.5" cy="209.5" rx="30" ry="30"/>
	<text x="157.5" y="215.5" font-family="Times New Roman" font-size="20">3</text>
	<polygon stroke="black" stroke-width="1" points="30.5,109.5 62.5,109.5"/>
	<polygon fill="black" stroke-width="1" points="62.5,109.5 54.5,104.5 54.5,114.5"/>
	<polygon stroke="black" stroke-width="1" points="122.5,109.5 208.5,109.5"/>
	<polygon fill="black" stroke-width="1" points="208.5,109.5 200.5,104.5 200.5,114.5"/>
	<text x="161.5" y="100.5" font-family="Times New Roman" font-size="20">a</text>
	<path stroke="black" stroke-width="1" fill="none" d="M 79.275,82.703 A 22.5,22.5 0 1 1 105.725,82.703"/>
	<text x="87.5" y="33.5" font-family="Times New Roman" font-size="20">b</text>
	<polygon fill="black" stroke-width="1" points="105.725,82.703 114.473,79.17 106.382,73.292"/>
	<path stroke="black" stroke-width="1" fill="none" d="M 225.275,82.703 A 22.5,22.5 0 1 1 251.725,82.703"/>
	<text x="233.5" y="33.5" font-family="Times New Roman" font-size="20">b</text>
	<polygon fill="black" stroke-width="1" points="251.725,82.703 260.473,79.17 252.382,73.292"/>
	<polygon stroke="black" stroke-width="1" points="220.348,133.385 180.652,185.615"/>
	<polygon fill="black" stroke-width="1" points="180.652,185.615 189.474,182.271 181.512,176.22"/>
	<text x="206.5" y="179.5" font-family="Times New Roman" font-size="20">a</text>
	<polygon stroke="black" stroke-width="1" points="145.296,184.923 109.704,134.077"/>
	<polygon fill="black" stroke-width="1" points="109.704,134.077 110.195,143.498 118.388,137.764"/>
	<text x="112.5" y="179.5" font-family="Times New Roman" font-size="20">a</text>
	<path stroke="black" stroke-width="1" fill="none" d="M 190.869,200.11 A 22.5,22.5 0 1 1 187.21,226.306"/>
	<text x="236.5" y="226.5" font-family="Times New Roman" font-size="20">b</text>
	<polygon fill="black" stroke-width="1" points="187.21,226.306 189.499,235.458 196.439,228.259"/>
</svg>
</p>

### RegExp to NFA demo test

```
?- start_re_to_nfa_demo_test.
```

Due to the conversion algorithm generating quite complicated results, it is hard to manually check the correctness of the result. This test is therefore run on a very simple expression and the expected result is illustrated below:

<p style="text-align: center">
<svg width="500" height="300" version="1.1" style="background-color: white; border-radius: 12px" xmlns="http://www.w3.org/2000/svg">
	<ellipse stroke="black" stroke-width="1" fill="none" cx="72.5" cy="56.5" rx="30" ry="30"/>
	<text x="67.5" y="62.5" font-family="Times New Roman" font-size="20">9</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="186.5" cy="56.5" rx="30" ry="30"/>
	<text x="181.5" y="62.5" font-family="Times New Roman" font-size="20">1</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="72.5" cy="153.5" rx="30" ry="30"/>
	<text x="67.5" y="159.5" font-family="Times New Roman" font-size="20">3</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="418.5" cy="56.5" rx="30" ry="30"/>
	<text x="408.5" y="62.5" font-family="Times New Roman" font-size="20">10</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="418.5" cy="56.5" rx="24" ry="24"/>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="418.5" cy="153.5" rx="30" ry="30"/>
	<text x="413.5" y="159.5" font-family="Times New Roman" font-size="20">8</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="294.5" cy="56.5" rx="30" ry="30"/>
	<text x="289.5" y="62.5" font-family="Times New Roman" font-size="20">2</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="168.5" cy="153.5" rx="30" ry="30"/>
	<text x="163.5" y="159.5" font-family="Times New Roman" font-size="20">4</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="257.5" cy="153.5" rx="30" ry="30"/>
	<text x="252.5" y="159.5" font-family="Times New Roman" font-size="20">7</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="257.5" cy="243.5" rx="30" ry="30"/>
	<text x="252.5" y="249.5" font-family="Times New Roman" font-size="20">5</text>
	<ellipse stroke="black" stroke-width="1" fill="none" cx="418.5" cy="243.5" rx="30" ry="30"/>
	<text x="413.5" y="249.5" font-family="Times New Roman" font-size="20">6</text>
	<polygon stroke="black" stroke-width="1" points="18.5,56.5 42.5,56.5"/>
	<polygon fill="black" stroke-width="1" points="42.5,56.5 34.5,51.5 34.5,61.5"/>
	<polygon stroke="black" stroke-width="1" points="102.5,56.5 156.5,56.5"/>
	<polygon fill="black" stroke-width="1" points="156.5,56.5 148.5,51.5 148.5,61.5"/>
	<text x="124.5" y="77.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="72.5,86.5 72.5,123.5"/>
	<polygon fill="black" stroke-width="1" points="72.5,123.5 77.5,115.5 67.5,115.5"/>
	<text x="57.5" y="111.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="418.5,123.5 418.5,86.5"/>
	<polygon fill="black" stroke-width="1" points="418.5,86.5 413.5,94.5 423.5,94.5"/>
	<text x="423.5" y="111.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="216.5,56.5 264.5,56.5"/>
	<polygon fill="black" stroke-width="1" points="264.5,56.5 256.5,51.5 256.5,61.5"/>
	<text x="235.5" y="77.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="198.5,153.5 227.5,153.5"/>
	<polygon fill="black" stroke-width="1" points="227.5,153.5 219.5,148.5 219.5,158.5"/>
	<text x="208.5" y="174.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="102.5,153.5 138.5,153.5"/>
	<polygon fill="black" stroke-width="1" points="138.5,153.5 130.5,148.5 130.5,158.5"/>
	<text x="116.5" y="174.5" font-family="Times New Roman" font-size="20">a</text>
	<polygon stroke="black" stroke-width="1" points="257.5,183.5 257.5,213.5"/>
	<polygon fill="black" stroke-width="1" points="257.5,213.5 262.5,205.5 252.5,205.5"/>
	<text x="242.5" y="204.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="287.5,153.5 388.5,153.5"/>
	<polygon fill="black" stroke-width="1" points="388.5,153.5 380.5,148.5 380.5,158.5"/>
	<text x="333.5" y="174.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<path stroke="black" stroke-width="1" fill="none" d="M 286.028,234.298 A 216.275,216.275 0 0 1 389.972,234.298"/>
	<polygon fill="black" stroke-width="1" points="286.028,234.298 294.996,237.229 292.593,227.522"/>
	<text x="333.5" y="218.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<polygon stroke="black" stroke-width="1" points="418.5,213.5 418.5,183.5"/>
	<polygon fill="black" stroke-width="1" points="418.5,183.5 413.5,191.5 423.5,191.5"/>
	<text x="423.5" y="204.5" font-family="Times New Roman" font-size="20">&#955;</text>
	<path stroke="black" stroke-width="1" fill="none" d="M 389.07,249.271 A 342.168,342.168 0 0 1 286.93,249.271"/>
	<polygon fill="black" stroke-width="1" points="389.07,249.271 380.414,245.522 381.906,255.41"/>
	<text x="333.5" y="274.5" font-family="Times New Roman" font-size="20">c</text>
	<polygon stroke="black" stroke-width="1" points="324.5,56.5 388.5,56.5"/>
	<polygon fill="black" stroke-width="1" points="388.5,56.5 380.5,51.5 380.5,61.5"/>
	<text x="351.5" y="77.5" font-family="Times New Roman" font-size="20">&#955;</text>
</svg>
</p>

## Data structures
### Difference lists
In many cases, predicates repeatedly concatenate two lists. By default, this operation runs in [$O(n)$](https://en.wikipedia.org/wiki/Big_O_notation)  time, where $n$ is the length of the first list. To avoid this, some predicates, such as `r/5` or `build_expr_tree1/5` use the [difference list](https://en.wikibooks.org/wiki/Prolog/Difference_Lists) data structure, which allows concatenation in $O(1)$  time.

Conversion to a difference list from a regular list is effective $O(n)$ and therefore used as a prefered option.

### Sets
Primarily in searching for all the current states in NFA parsing, a data structure that allows two operations - union and iteration is required. For this, a simple ordered list was chosen to implement the operations. The union works similarly to merging in [merge  sort](https://en.wikipedia.org/wiki/Merge_sort). The time complexity is therefore $O(n+m)$ for union (where $n$ and $m$ are the lenghts of the merged sets) and $O(n)$  for iteration through the set (where $n$ is the length of the set).

The time complexity is asymptotically optimal for both operations and therefore no other implementations were considered.

## Algorithms

# WIP