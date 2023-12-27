open OUnit2
open Simpler

let interpret_small = Simpler.Interpreter.interpret_small
let interpret_big = Simpler.Interpreter.interpret_big

let test_int_expr name expr ~s =
  let open Ast in
  name >:: (fun _ -> 
    assert_equal (Int expr) (interpret_small s);
    assert_equal (Int expr) (interpret_big s))
;;  

let test_bool_expr name expr ~s =
  let open Ast in
  name >:: (fun _ -> 
    assert_equal (Bool expr) (interpret_small s);
    assert_equal (Bool expr) (interpret_big s))
;;

let test_value =
[ test_int_expr "int" 22 ~s:"22" 
; test_bool_expr "true" true ~s:"true"
]

let test_binop =
[ test_int_expr "add" 22 ~s:"11 + 11"
; test_int_expr "add_prec" 22 ~s:"(10 + 1) + (5 + 6)"
; test_int_expr "add_assoc" 22 ~s:"10 + (1 + (5 + 6))"
; test_int_expr "mult" 22 ~s:"2 * 11"
; test_int_expr "mult_prec" 22 ~s:"2 + 2 * 10"
; test_int_expr "mult_prec2" 14 ~s:"2 * 2 + 10"
; test_int_expr "mult_assoc" 40 ~s:"2 * 2 * 10"
; test_bool_expr "leq" true ~s:"1 <= 1"
]

let test_cond =
[ test_int_expr "if" 22 ~s:"if true then 22 else 0"
; test_int_expr "if_binop" 22 ~s:
  "
    if 1 + 2 <= 3 + 4 then 22
    else 0
  "
; test_int_expr "if_let" 22 ~s:
  "
    if 1 + 2 <= 3 * 4
    then
      let x = 22 in
      x
    else 0
  "
]

let test_let =
[ test_int_expr "let_id" 22 ~s:"let x = 22 in x"
; test_int_expr "lets" 22 ~s:
  "
    let x = 0 in
      let x = 22 in
      x
  "
; test_int_expr "let_if" 22 ~s:
  "
    let x = 1 + 2 <= 3 * 4 in
    if x then 22
    else 0
  "
]

let suite =
  "suite" >::: List.flatten 
  [test_value; test_binop; test_cond; test_let]
;;

let _ = run_test_tt_main suite
