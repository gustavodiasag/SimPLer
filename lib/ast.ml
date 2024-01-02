type binop =
  | Add
  | Mult
  | Lt
  | Gt
  | Eq
  | Geq
  | Leq
[@@deriving show, eq]

type expr =
  | Var of string
  | Int of int
  | Bool of bool
  | Binop of binop * expr * expr
  | Let of string * expr * expr
  | If of expr * expr * expr
  | Fun of string * expr
  | App of expr * expr
  | Pair of expr * expr
  | Fst of expr
  | Snd of expr
[@@deriving show, eq]
