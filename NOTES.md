# Notes

## Capture-Avoiding Substitution (11.3.9)

The implementation of substitution for SimPL is very straightforward, but its definition can get more complicated when looking at it through the lens of a stricter functional perspective. Consider a tiny language that consists of:

```
e ::= x 
    | e1 e2
    | fun x -> e

v ::= fun x -> e
```

This syntax is also known as the **lambda calculus**. There are only three kinds of expressions in it: variables, function application and anonymous functions. The only values are anonymous functions and the language isn't even typed.

Taking this language to analysis, what should be the substitution model for a function? In SimPL, substitution continues until a bound variable of the same name is found. In the lambda calculus, that idea would be stated as follows:

```
(fun x -> e'){e/x} = fun x -> e'
(fun y -> e'){e/x} = fun y -> e'{e/x}
```

This definition, however, turns out to be incorrect, because it violates the **Principle of Name Irrelevance**. Using this model, suppose the substitution processes below:

```
(fun z -> x){z/x}
=   fun z -> x{z/x}
=   fun z -> z

(fun y -> x){z/x}
=   fun y -> x{z/x}
=   fun y -> z
```

In the first case, the anonymous function did not represent an identity function, but it became the identity function after the substitution, whereas the second case does not turn to the identity function. So this definition of substitution inside anonymous functions is incorrect because it **captures** variables. **A variable name being substituted inside an anonymous function can be accidentaly captured by the function's argument name**.

The answer to how to define substitution so that it evaluates correctly, without capturing variables, is called **capture-avoiding substitution** and its definition is:

```
(fun x -> e'){e/x} = fun x -> e'
(fun y -> e'){e/x} = fun y -> e'{e/x} if y is not in FV(e)
```

Where FV(e) means the **free variables** of `e`, i.e., the variables that are not bound in it. 