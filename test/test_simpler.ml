open OUnit2
open Simpler

let interpret_small = Simpler.Interpreter.interpret_small
let interpret_big = Simpler.Interpreter.interpret_big

open Ast

let test_expr name ~e ~s =
  name >:: (fun _ -> 
    assert_equal ~printer:show_expr e (interpret_small s);
    assert_equal ~printer:show_expr e (interpret_big s))
;;  

let test_value =
  [ test_expr "int"   ~e:(Int 22) ~s:"22" 
  ; test_expr "true"  ~e:(Bool true) ~s:"true"
  ]

let test_binop =
  [ test_expr "add"         ~e:(Int 22) ~s:"11 + 11"
  ; test_expr "add_prec"    ~e:(Int 22) ~s:"(10 + 1) + (5 + 6)"
  ; test_expr "add_assoc"   ~e:(Int 22) ~s:"10 + (1 + (5 + 6))"
  ; test_expr "mult"        ~e:(Int 22) ~s:"2 * 11"
  ; test_expr "mult_prec"   ~e:(Int 22) ~s:"2 + 2 * 10"
  ; test_expr "mult_prec2"  ~e:(Int 14) ~s:"2 * 2 + 10"
  ; test_expr "mult_assoc"  ~e:(Int 40) ~s:"2 * 2 * 10"
  ; test_expr "leq"         ~e:(Bool true) ~s:"1 <= 1"
  ]

let test_cond =
  [ test_expr "if"        ~e:(Int 22) ~s:"if true then 22 else 0"
  ; test_expr "if_binop"  ~e:(Int 22) ~s:
    "
      if 1 + 2 <= 3 + 4 then 22
      else 0
    "
  ; test_expr "if_let"    ~e:(Int 22) ~s:
    "
      if 1 + 2 <= 3 * 4
      then
        let x = 22 in
        x
      else 0
    "
  ]

let test_let =
  [ test_expr "let_id"  ~e:(Int 22) ~s:"let x = 22 in x"
  ; test_expr "lets"    ~e:(Int 22) ~s:
    "
      let x = 0 in
        let x = 22 in
        x
    "
  ; test_expr "let_if"  ~e:(Int 22) ~s:
    "
      let x = 1 + 2 <= 3 * 4 in
      if x then 22
      else 0
    "
  ]

let suite =
  "suite" >::: List.flatten [test_value; test_binop; test_cond; test_let]
;;

let _ = run_test_tt_main suite;;
