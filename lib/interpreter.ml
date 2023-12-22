open Ast

let parse s =
  let lexbuf = Lexing.from_string s in
  Parser.prog Lexer.read lexbuf
;;

(** [is_value e] is whether [e] is a value. *)
let is_value (e : expr) : bool =
  match e with
  | Int _ | Bool _ -> true
  | _ -> false
;;

(** [sub e v x] is [e{v/x}]. *)
let rec sub e v x =
  match e with
  | Var y -> if x = y then v else e
  | Bool _ | Int _ -> e
  | Binop (bop, e1, e2) -> Binop (bop, sub e1 v x, sub e2 v x)
  | Let (y, e1, e2) ->
    begin
      let e1' = sub e1 v x in
      if x = y then Let (y, e1', e2)
      else Let (y, e1', sub e2 v x)
    end
  | If (e1, e2, e3) ->
      If (sub e1 v x, sub e2 v x, sub e3 v x) 
;;

(** [step] is the single-step relation, that is, a single step of
    evaluation. *)
let rec step (e : expr) : expr =
  match e with
  | Int _ | Bool _ -> failwith "Does not step"
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) when is_value e1 && is_value e2 ->
      step_bop bop e1 e2
  | Binop (bop e1, e2) when is_value e1 -> Binop (bop, e1, step e2)
  | Binop (bop, e1, e2) -> Binop (bop, step e1, e2)
  | Let (x, e1, e2) when is_value e1 -> sub e2 e1 x
  | Let (x, e1, e2) -> Let (x, step e1, e2)
  | If (Bool true, e2, _) -> e2
  | If (Bool false, _, e3) -> e3
  | If (e1, e2, e3) -> If (step e1, e2, e3)
  | If (Int _, _, _) -> failwith "Guard of 'if' must have type bool"

(** [step_bop bop v1 v2] implements the primitive operation [v1 bop v2].
    Requires: [v1] and [v2] are both values. *)
and step_bop bop e1 e2 =
  match bop, e1, e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ failwith "Operator and operand type mismatch"
;;

(** [eval_small e] is the multistep relation. That is, keep applying [step] until a
    value is produced. *)
let rec eval_small (e : expr) : expr =
  if is_value e then e
  else e |> step |> eval_small
;;

(** [eval_big e] is the big step relation. *)
let rec eval_big (e : expr) : expr =
  match e with
  | Int _ | Bool _ -> e
  | Var _ -> failwith "Unbound variable"
  | Binop (bop, e1, e2) -> eval_bop bop e1 e2
  | Let (x, e1, e2) -> sub e2 (eval_big e1) x |> eval_big
  | If (e1, e2, e3) eval_if e1 e2 e3

(** [eval_bop bop e1 e2] is the [e] such that [e1 bop e2 = e]. *)
and eval_bop bop e1 e2 =
  match bop, eval_big e1, eval_big e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Mult, Int a, Int b -> Int (a * b)
  | Leq, Bool a, Bool b -> Bool (a <= b)
  | _ failwith "Operator and operand type mismatch"

(** [eval_if e1 e2 e3] is the [e] such that [if e1 then e2 else e3 = e]. *)
and eval_if e1 e2 e3 =
  match eval_big e1 with
  | Bool true -> eval_big e2
  | Bool false -> eval_big e3
  | _ -> failwith "Guard of 'if' must have type bool"
;;