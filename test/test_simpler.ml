open OUnit2
open Simpler

let interpret_small = Interpreter.interpret_small
let interpret_big = Interpreter.interpret_big

open Ast

let test_expr name ~e ~s =
  name >:: (fun _ -> 
    assert_equal ~printer:show_expr e (interpret_small s);
    assert_equal ~printer:show_expr e (interpret_big s))
;;  

let test_value =
  [ test_expr "int" ~e:(Int 22) ~s:"22" 
  ; test_expr "true" ~e:(Bool true) ~s:"true"
  ]

let test_add =
  [ test_expr "add" ~e:(Int 22) ~s:"11 + 11"
  ; test_expr "add_prec" ~e:(Int 22) ~s:"(10 + 1) + (5 + 6)"
  ; test_expr "add_assoc" ~e:(Int 22) ~s:"10 + (1 + (5 + 6))"
  ]

let test_mult =
  [ test_expr "mult" ~e:(Int 22) ~s:"2 * 11"
  ; test_expr "mult_prec" ~e:(Int 22) ~s:"2 + 2 * 10"
  ; test_expr "mult_prec2" ~e:(Int 14) ~s:"2 * 2 + 10"
  ; test_expr "mult_assoc" ~e:(Int 40) ~s:"2 * 2 * 10"
  ]

let test_lt =
  [ test_expr "lt_true" ~e:(Bool true) ~s:"50 < 100"
  ; test_expr "lt_false" ~e:(Bool false) ~s:"7 < 4"
  ; test_expr "lt_add" ~e:(Bool false) ~s:"if (3 + 2) < 1 then true else false"
  ]

let test_gt =
  [ test_expr "gt_true" ~e:(Bool true) ~s:"100 > 50"
  ; test_expr "gt_false" ~e:(Bool false) ~s:"4 > 7"
  ]

let test_eq =
  [ test_expr "eq_int" ~e:(Bool true) ~s:"8 = 8"
  ; test_expr "eq_bool" ~e:(Bool false) ~s: "false = true"
  ; test_expr "eq_cond" ~e:(Int 6) ~s:"if 1 = 2 then 3 else 6"
  ]

let test_leq =
  [ test_expr "leq_true" ~e:(Bool true) ~s:"1 <= 1" ]

let test_geq =
  [ test_expr "geq_true" ~e:(Bool true) ~s:"0 >= -1"]

let test_cond =
  [ test_expr "if" ~e:(Int 22) ~s:"if true then 22 else 0"
  ; test_expr "if_leq" ~e:(Int 22) ~s:"if 1 + 2 <= 3 + 4 then 22 else 0"
  ; test_expr "if_let" 
      ~e:(Int 22) 
      ~s:"if 1 + 2 <= 3 * 4 then let x = 22 in x else 0"
  ]

let test_let =
  [ test_expr "let_id" ~e:(Int 22) ~s:"let x = 22 in x"
  ; test_expr "lets" ~e:(Int 22) ~s:"let x = 0 in let x = 22 in x"
  ; test_expr "let_if"
      ~e:(Int 22)
      ~s:"let x = 1 + 2 <= 3 * 4 in if x then 22 else 0"
  ; test_expr "let_fun" ~e:(Fun ("x", Var "x")) ~s:"let x = (fun x -> x) in x"
  ]

let test_fun =
  [ test_expr "fun" ~e:(Fun ("x", Var "x")) ~s:"(fun x -> x)"
  ; test_expr "fun_add" 
      ~e:(Fun ("y", Binop (Add, Var "y", Int 10)))
      ~s:"(fun y -> y + 10)"
  ]

let test_app =
  [ test_expr "app" ~e:(Int 10) ~s:"(fun z -> z + 5) (5)"
  ; test_expr "app_fun" 
      ~e:(Fun ("y", Var "y")) 
      ~s:"(fun x -> x) (fun y -> y)"
  ]

let suite =
  "suite" >::: List.flatten
  [ test_value
  ; test_add
  ; test_mult
  ; test_lt
  ; test_gt
  ; test_eq
  ; test_leq
  ; test_geq
  ; test_cond
  ; test_let
  ; test_fun
  ; test_app
  ]
;;

let _ = run_test_tt_main suite;;
