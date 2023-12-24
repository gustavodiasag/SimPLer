open OUnit2
open Simpler
open Interpreter

(** [make_i n i s] makes an OUnit test named [n] that expects
    [s] to evalute to [Int i]. *)
let make_i n i s =
  [n >:: (fun _ -> assert_equal (Ast.Int i) (interpret_small s));
   n >:: (fun _ -> assert_equal (Ast.Int i) (interpret_big s))]

(** [make_b n b s] makes an OUnit test named [n] that expects
    [s] to evalute to [Bool b]. *)
let make_b n b s =
  [n >:: (fun _ -> assert_equal (Ast.Bool b) (interpret_small s));
   n >:: (fun _ -> assert_equal (Ast.Bool b) (interpret_big s))]

let tests = [
  make_i "int" 22 "22";
  make_i "add" 22 "11 + 11";
  make_i "adds" 22 "(10 + 1) + (5 + 6)";
  make_i "let" 22 "let x = 22 in x";
  make_i "lets" 22 "let x = 0 in let x = 22 in x";
  make_i "mul1" 22 "2 * 11";
  make_i "mul2" 22 "2 + 2 * 10";
  make_i "mul3" 14 "2 * 2 + 10";
  make_i "mul4" 40 "2 * 2 * 10";
  make_i "if1" 22 "if true then 22 else 0";
  make_b "true" true "true";
  make_b "leq" true "1 <= 1";
  make_i "if2" 22 "if 1 + 2 <= 3 + 4 then 22 else 0";
  make_i "if3" 22 "if 1 + 2 <= 3 * 4 then let x = 22 in x else 0";
  make_i "letif" 22 "let x = 1 + 2 <= 3 * 4 in if x then 22 else 0";
]

let _ = run_test_tt_main ("suite" >::: List.flatten tests)
