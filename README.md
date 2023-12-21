# SimPLer

Implementation of an interpreter for the SimPL and Core OCaml programming languages as the final exercise from the book [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/ocaml_programming.pdf). Although these toy languages are just basic calculators in some way (given that only expressions are supported), a whole lot of syntactic and semantic rules present in the [Lambda Calculus](https://plato.stanford.edu/entries/church-turing/) are provided by them, such as substitution, partial application and pattern matching.

## Syntax

The syntax rules in the standard BNF notation for SimPL and Core Ocaml are presented below:

### SimPL

```
e ::= x 
    | i 
    | b 
    | e binop e'
    | if e then e' else e''
    | let x = e in e'

binop ::= + | * | <=

x ::= <identifier>

i ::= <integer>

b ::= true | false
```

### Core OCaml

```
e ::= x 
    | e1 e2 
    | fun x -> e
    | i 
    | b 
    | e1 bop e2
    | (e1, e2) | fst e | snd e
    | Left e | Right e
    | match e with Left x1 -> e1 | Right x2 -> e2
    | if e1 then e2 else e3
    | let x = e1 in e2

bop ::= + | * | < | =

x ::= <identifier>

i ::= <integer>

b ::= true | false

v ::= fun x -> e | i | b | (v1, v2) | Left v | Right v
```

# License

The project is licensed under the [MIT License](LICENSE)