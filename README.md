# SimPLer

[![OCaml-CI Build Status](https://img.shields.io/endpoint?url=https://ocaml.ci.dev/badge/gustavodiasag/SimPLer/main&logo=ocaml)](https://ocaml.ci.dev/github/gustavodiasag/SimPLer)

Implementation of an interpreter for the SimPL and Core OCaml programming languages as the final exercise from the book [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/ocaml_programming.pdf). 

Although these toy languages are just basic calculators in some way (given that only expressions are supported), some ideas present in [lambda calculus theory](https://plato.stanford.edu/entries/lambda-calculus/) are provided by them, such as substitution and anonymous functions. Besides that, the languages are defined with syntactic and semantic rules very similar to those of OCaml.

Important excerpts from the book regarding the theoretical and mathematical aspects of the project are separately described in a [notes section](NOTES.md).

# Specifications

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
    | (e1, e2)
    | fst e 
    | snd e
    | if e1 then e2 else e3
    | let x = e1 in e2

bop ::= + | * | < | > | = | <= | >= 

x ::= <identifier>

i ::= <integer>

b ::= true | false

v ::= fun x -> e | i | b | (v1, v2)
```

## Lexing and Parsing

Neither the lexer nor the parser for the language are developed from scratch. Instead, the implementation relies on tools provided by the libraries [ocamllex](https://v2.ocaml.org/manual/lexyacc.html), responsible for the generation of lexical analyzers, and [Menhir](https://gallium.inria.fr/~fpottier/menhir/manual.pdf), responsible for the generation of parsers. 

The details for the lexer definition (i.e., identifiers and rules) are found in [lexer.mll](lib/lexer.mll), and the details for the grammar definition (i.e., symbols and production rules) are found in [parser.mly](lib/parser.mly).

## Evaluation

The process of simplifying the languages' [Abstract Syntax Tree](lib/ast.ml) down to a single value is defined through a mathematical relation whose style is known as **operational semantics**. More specifically, these semantics are divided in small step and big step semantics, where:

- **Small step** semantics represent execution in terms of individual small steps, or how a program takes one single step of execution.

- **Big step** semantics represent execution in terms of a big step from an expression directly to a value, abstracting away all the details of single steps.

Both styles are discussed by the book, but since big-step semantics are more similar to how an interpreter would actually be implemented, the languages' evaluation strategy is based only on this model.

## Substitution

The implementation of variables use the **substitution model** of evaluation, where the value of a variable is substituted for its name throughout the scope of that name, as soon as a binding of the variable is found.

For SimPL (which is composed of expressions), the notation `e'{e/x}` is used to determine the expression `e'` with `e` substituted for `x`. So anywhere `x` appears in `e'`, it should be replaced with `e`. For Core OCaml, the same logic is applied, but since it supports a value abstraction, the notation changes slightly to `e{v/x}`. This model is defined for each of the languages' constructs, but given that Core OCaml is a superset of SimPL, only its rules are specified:

### Constants

Variables cannot appear in them (e.g., `x` cannot syntactically occur in `42`), so substitution leaves constants unchanged.

```
i{v/x} = i

b{v/x} = b
```

### Operators and conditionals

All that substitution does is recurse inside the subexpressions.

```
(e1 + e2){v/x} = e1{v/x} + e2{v/x}

(if e1 then e2 else e3){v/x} = if e1{v/x} then e2{v/x} else e3{v/x}
```

### Variables

There are two possibilities, either the variable to be substituted is found or not, in which case the substitution must not happen

```
x{v/x} = v

y{v/x} = y
```

### Let expressions

Two cases are also possible, depending on the name of the bound variable. If a shadowed name has been reached, substitution must stop in order to prioritize the most recent binding, so it is only applied to the first expression. On the contrary, substitution carefully recurses inside both expressions, avoiding [capturing any variables](NOTES.md/#capture-avoiding-substitution-1139).

```
(let x = e1 in e2){v/x} = let x = e1{v/x} in e2

(let y = e1 in e2){v/x} = let y = e1{v/x} in e2{v/x}
    if y not in FV(v)
```

### Anonymous functions

Fundamentally the same as for "let" expressions.

```
(fun x -> e'){v/x} = (fun x -> e')

(fun y -> e'){v/x} = (fun y -> e'{v/x})
    if y not in FV(v)
```

### Tuples

```
(e1, e2){v/x} = (e1{v/x}, e2{v/x})

(fst e){v/x} = fst (e{v/x})

(snd e){v/x} = snd (e{v/x})
```

# License

The project is licensed under the [MIT License](LICENSE)