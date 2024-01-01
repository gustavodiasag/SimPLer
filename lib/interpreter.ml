open Ast

module VarSet = Set.Make(String)
open VarSet

let parse s =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast
;;

(** [is_value e] is whether [e] is a value. *)
let rec is_value : expr -> bool = function
    Int _ | Bool _ | Fun _ -> true
  | Pair (e1, e2) -> is_value e1 && is_value e2
  | _ -> false
;;

(** [fv e] is a set-like list of the free variables of [e]. *)
let rec fv (e : expr) : VarSet.t =
  match e with
  | Bool _ | Int _ -> empty
  | Var x -> singleton x
  | Binop (_, e1, e2) -> union (fv e1) (fv e2)
  | Let (x, e1, e2) -> union (fv e1) (diff (fv e2) (singleton x))
  | If (e1, e2, e3) -> union (union (fv e1) (fv e2)) (fv e3)
  | Fun (x, e) -> diff (fv e) (singleton x)
  | App (e1, e2) | Pair (e1, e2) -> union (fv e1) (fv e2)
  | Fst e | Snd e -> (fv e)
;;

(** [sub e v x] is [e] with [v] substituted for [x], that is, [e{v/x}]. *)
let rec sub e v x =
  match e with
  | Var y -> if x = y then v else e
  | Bool _ | Int _ -> e
  | Binop (bop, e1, e2) -> Binop (bop, sub e1 v x, sub e2 v x)
  | Let (y, e1, e2) -> begin
      let e1' = sub e1 v x in
      if x = y then Let (y, e1', e2) else Let (y, e1', sub e2 v x)
    end
  | If (e1, e2, e3) -> If (sub e1 v x, sub e2 v x, sub e3 v x)
  | Fun (y, e') as f -> begin
      if x = y then e
      else if not (mem y (fv v)) then Fun (y, sub e' v x)
      else f
    end
  | App (e1, e2) -> App (sub e1 v x, sub e2 v x)
  | Pair (e1, e2) -> Pair (sub e1 v x, sub e2 v x)
  | Fst e -> Fst (sub e v x)
  | Snd e -> Snd (sub e v x)
;;

(** [eval_big e] is the big step relation. *)
let rec eval_big (e : expr) : expr =
  match e with
  | Int _ | Bool _ | Fun _ -> e
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) -> eval_bop bop e1 e2
  | Let (x, e1, e2) -> sub e2 (eval_big e1) x |> eval_big
  | If (e1, e2, e3) -> eval_if e1 e2 e3
  | App (e1, e2) -> eval_app e1 e2
  | Pair (e1, e2) -> eval_pair e1 e2
  | Fst _ | Snd _ as p -> eval_pairop p

(** [eval_bop bop e1 e2] is the [e] such that [e1 bop e2 = e]. *)
and eval_bop bop e1 e2 =
  match bop, eval_big e1, eval_big e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Lt, Int a, Int b -> Bool (a < b)
  | Gt, Int a, Int b -> Bool (a > b)
  | Eq, Int a, Int b -> Bool (a = b)
  | Eq, Bool a, Bool b -> Bool (a = b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | Geq, Int a, Int b -> Bool (a >= b)
  | _ -> failwith "Operator and operand type mismatch"

(** [eval_if e1 e2 e3] is the [e] such that [if e1 then e2 else e3 = e]. *)
and eval_if e1 e2 e3 =
  match eval_big e1 with
  | Bool true -> eval_big e2
  | Bool false -> eval_big e3
  | _ -> failwith "Guard of 'if' must have type bool"

and eval_app e1 e2 =
  match eval_big e1 with
  | Fun (x, e) ->
    let e2' = eval_big e2 in
    sub e e2' x |> eval_big
  | _ -> failwith "Cannot apply non-function"

and eval_pair e1 e2 =
  if is_value e1 && is_value e2 then Pair (e1, e2)
  else
    let e1' = eval_big e1 in
    Pair (e1', eval_big e2)

and eval_pairop = function
  | Fst (Pair (e1, e2)) ->
      eval_pair e1 e2 |> fst |> Option.get
  | Snd (Pair (e1, e2)) ->
      eval_pair e1 e2 |> snd |> Option.get
  | _ -> failwith "Invalid pair operation"

and fst = function
    Pair (e1, _) -> Some e1
  | _ -> None

and snd = function
    Pair (_, e2) -> Some e2
  | _ -> None
;;

let interpret s =
  s |> parse |> eval_big
;;