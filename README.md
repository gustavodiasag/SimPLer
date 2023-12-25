# SimPLer

Implementation of an interpreter for the SimPL and Core OCaml programming languages as the final exercise from the book [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/ocaml_programming.pdf). 

Although these toy languages are just basic calculators in some way (given that only expressions are supported), a whole lot of ideas present in [lambda calculus theory](https://plato.stanford.edu/entries/lambda-calculus/) are provided by them, such as partial substitution and partial application. Besides that, the languages are defined with syntactic and semantic rules very similar to those of OCaml, with features such as tuples, pattern matching and lack of mutability/side effects.

Important excerpts from the book regarding the theoretical and mathematical aspects of the project are separately described in a [notes section](NOTES.md).

# Specifications

## Lexing and Parsing

Neither the lexer nor the parser for the language are developed from scratch. Instead, the implementation relies on tools provided by the libraries [ocamllex](https://v2.ocaml.org/manual/lexyacc.html), responsible for the generation of lexical analyzers, and [Menhir](https://gallium.inria.fr/~fpottier/menhir/manual.pdf), responsible for the generation of parsers. 

The details for the lexer definition (i.e., identifiers and rules) are found in [lexer.mll](lib/lexer.mll), and the details for the grammar definition (i.e., symbols and production rules) are found in [parser.mly](lib/parser.mly).

## Evaluation

The process of simplifying the languages' [Abstract Syntax Tree](lib/ast.ml) down to a single value is defined through a mathematical relation whose style is known as **operational semantics**. More specifically, these semantics are divided in small step and big step semantics, where:

- **Small step** semantics represent execution in terms of individual small steps, or how a program takes one single step of execution.

- **Big step** semantics represent execution in terms of a big step from an expression directly to a value, abstracting away all the details of single steps.

Both styles are provided by the interpreter for the purpose of choosing the one best suited for certain circumstances. The small-step semantics tend to be easier to work when it comes to modeling complicated language features, and the big-step semantics tend to be more similar to how an interpreter would actually be implemented.

## Substitution

The implementation of variables consider the **substitution model** of evaluation, where the value of a variable is substituted for its name throughout the scope of that name, as soon as a binding of the variable is found.

A notation `e'{e/x}` is used to determine the expression `e'` with `e` substituted for `x`. So anywhere `x` appears in `e'`, it should be replaced with `e`, and this model is defined for each of the languages' constructs:

### Constants

Variables cannot appear in them (e.g., `x` cannot syntactically occur in `42`), so substitution leaves constants unchanged.

```
i{e/x} = i
b{e/x} = b
```

### Operators and conditionals

All that substitution does is recurse inside the subexpressions.

```
(e1 bop e2){e/x} = e1{e/x} bop e2{e/x}
(if e1 then e2 else e3){e/x} = if e1{e/x} then e2{e/x} else e3{e/x}
```

### Variables

There are two possibilities, either the variable to be substituted is found or not, in which case the substitution must not happen

```
x{e/x} = e
y{e/x} = y
```

### Let expressions

Two cases are also possible, depending on the name of the bound variable. If a shadowed name has been reached, substitution must stop in order to prioritize the most recent binding, so it is only applied to the first expression.

```
(let x = e1 in e2){e/x} = let x = e1{e/x} in e2
(let y = e1 in e2){e/x} = let y = e1{e/x} in e2{e/x} 
```

# Syntax

The syntax rules in the standard BNF notation for SimPL and Core Ocaml are presented below:

## SimPL

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

## Core OCaml

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