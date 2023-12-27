open Ast

module VarSet = Set.Make (String)
open VarSet

let parse s =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast
;;

(** [is_value e] is whether [e] is a value. *)
let is_value (e : expr) : bool =
  match e with
  | Int _ | Bool _ | Fun _ -> true
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
  | App (e1, e2) -> union (fv e1) (fv e2)
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
;;

(** [step] is the single-step relation, that is, a single step of
    evaluation. *)
let rec step (e : expr) : expr =
  match e with
  | Int _ | Bool _ | Fun _ -> failwith "Does not step"
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) when is_value e1 && is_value e2 -> step_bop bop e1 e2
  | Binop (bop, e1, e2) when is_value e1 -> Binop (bop, e1, step e2)
  | Binop (bop, e1, e2) -> Binop (bop, step e1, e2)
  | Let (x, e1, e2) when is_value e1 -> sub e2 e1 x
  | Let (x, e1, e2) -> Let (x, step e1, e2)
  | If (Bool true, e2, _) -> e2
  | If (Bool false, _, e3) -> e3
  | If (Int _, _, _) -> failwith "Guard of 'if' must have type bool"
  | If (e1, e2, e3) -> If (step e1, e2, e3)
  | App (Fun (x, e1), e2) when is_value e2 -> sub e1 e2 x
  | App ((Fun _ as f), e2) -> App (f, step e2)
  | App (e1, e2) -> App (step e1, e2)

(** [step_bop bop v1 v2] implements the primitive operation [v1 bop v2].
    Requires: [v1] and [v2] are both values. *)
and step_bop bop e1 e2 =
  match bop, e1, e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Lt, Int a, Int b -> Bool (a < b)
  | Gt, Int a, Int b -> Bool (a > b)
  | Eq, Int a, Int b -> Bool (a = b)
  | Eq, Bool a, Bool b -> Bool (a = b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | Geq, Int a, Int b -> Bool (a >= b)
  | _ -> failwith "Operator and operand type mismatch"
;;

(** [eval_small e] is the multistep relation. That is, keep applying [step] until a
    value is produced. *)
let rec eval_small (e : expr) : expr =
  match e with
  | Int _ | Bool _ | Fun _ -> e
  | _ -> e |> step |> eval_small
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
;;

let interpret_small s =
  let e = parse s in
  eval_small e
;;

let interpret_big s =
  let e = parse s in
  eval_big e
;;
