type binop =
  | Add
  | Mult
  | Leq

type expr =
  | Var of string
  | Int of int
  | Bool of bool
  | Binop of binop * expr * expr
  | Let of string * expr * expr
  | If of expr * expr * expr