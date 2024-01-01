open OUnit2
open Simpler
open Ast

let interpret = Interpreter.interpret

let test_expr name ~e ~s =
  name >:: (fun _ -> assert_equal ~printer:show_expr e (interpret s))
;;

let test_int_expr name ~e ~s =
  name >:: (fun _ ->
    assert_equal ~printer:show_expr (Int e) (interpret s))
;;

let test_bool_expr name ~e ~s =
  name >:: (fun _ ->
    assert_equal ~printer:show_expr (Bool e) (interpret s))
;;

let test_value =
  [ test_int_expr "int" ~e:22 ~s:"22" 
  ; test_bool_expr "true" ~e:true ~s:"true"
  ]

let test_add =
  [ test_int_expr "add" ~e:22 ~s:"11 + 11"
  ; test_int_expr "add_prec" ~e:22 ~s:"(10 + 1) + (5 + 6)"
  ; test_int_expr "add_assoc" ~e:22 ~s:"10 + (1 + (5 + 6))"
  ]

let test_mult =
  [ test_int_expr "mult" ~e:22 ~s:"2 * 11"
  ; test_int_expr "mult_prec" ~e:22 ~s:"2 + 2 * 10"
  ; test_int_expr "mult_prec2" ~e:14 ~s:"2 * 2 + 10"
  ; test_int_expr "mult_assoc" ~e:40 ~s:"2 * 2 * 10"
  ]

let test_lt =
  [ test_bool_expr "lt_true" ~e:true ~s:"50 < 100"
  ; test_bool_expr "lt_false" ~e:false ~s:"7 < 4"
  ; test_bool_expr "lt_add" ~e:false ~s:"if (3 + 2) < 1 then true else false"
  ]

let test_gt =
  [ test_bool_expr "gt_true" ~e:true ~s:"100 > 50"
  ; test_bool_expr "gt_false" ~e:false ~s:"4 > 7"
  ]

let test_eq =
  [ test_bool_expr "eq_int" ~e:true ~s:"8 = 8"
  ; test_bool_expr "eq_bool" ~e:false ~s: "false = true"
  ; test_int_expr "eq_cond" ~e:6 ~s:"if 1 = 2 then 3 else 6"
  ]

let test_leq =
  [ test_bool_expr "leq_true" ~e:true ~s:"1 <= 1" ]

let test_geq =
  [ test_bool_expr "geq_true" ~e:true ~s:"0 >= -1"]

let test_cond =
  [ test_int_expr "if" ~e:22 ~s:"if true then 22 else 0"
  ; test_int_expr "if_leq" ~e:22 ~s:"if 1 + 2 <= 3 + 4 then 22 else 0"
  ; test_int_expr "if_let" 
      ~e:22 
      ~s:"if 1 + 2 <= 3 * 4 then let x = 22 in x else 0"
  ]

let test_let =
  [ test_int_expr "let_id" ~e:22 ~s:"let x = 22 in x"
  ; test_int_expr "lets" ~e:22 ~s:"let x = 0 in let x = 22 in x"
  ; test_int_expr "let_if"
      ~e:22
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

let test_pair =
  [ test_expr "pair" ~e:(Pair (Int 1, Int 2)) ~s:"(1, 2)"
  ; test_expr "triplet"
      ~e:(Pair (Int 4, Pair (Int 5, Int 6)))
      ~s:"(2 * 2, (1 + 4, 3 + 3))"
  ]

let test_pairop =
  [ test_int_expr "fst" ~e:1 ~s:"fst (1 + 0, 3)"
  ; test_int_expr "snd" ~e:5 ~s:"snd (3, let x = 3 in 5)"
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
  ; test_pair
  ; test_pairop
  ]
;;

let _ =
  run_test_tt_main suite
;;
