%{

open Ast

let rec make_apply e = function
  | [] -> failwith "Precondition violated"
  | [e'] -> App (e, e')
  | h :: ((_ :: _) as t) -> make_apply (App (e, h)) t
;;

%}

%token <int> INT
%token <string> ID
%token TRUE
%token FALSE
%token COMMA
%token LT
%token GT
%token TIMES
%token PLUS
%token LPAREN
%token RPAREN
%token LET
%token EQ
%token IN
%token IF
%token THEN
%token ELSE
%token FUN
%token ARROW
%token FST
%token SND
%token EOF

%nonassoc IN
%nonassoc ELSE
%left LT
%left EQ
%left PLUS
%left TIMES

%start <Ast.expr> prog

%%

prog:
  | e = expr; EOF { e }
  ;

expr:
  | e = simpl_expr { e }
  | e = simpl_expr; es = simpl_expr+ { make_apply e es }
  | i = INT { Int i }
  | TRUE { Bool true }
  | FALSE { Bool false }
  | e1 = expr; LT; e2 = expr { Binop (Lt, e1, e2) }
  | e1 = expr; GT; e2 = expr { Binop (Gt, e1, e2) }
  | e1 = expr; EQ; e2 = expr { Binop (Eq, e1, e2) }
  | e1 = expr; LT; EQ; e2 = expr { Binop (Leq, e1, e2) }
  | e1 = expr; GT; EQ; e2 = expr { Binop (Geq, e1, e2) }
  | e1 = expr; TIMES; e2 = expr { Binop (Mult, e1, e2) }
  | e1 = expr; PLUS; e2 = expr { Binop (Add, e1, e2) }
  | LET; x = ID; EQ; e1 = expr; IN; e2 = expr { Let (x, e1, e2) }
  | IF; e1 = expr; THEN; e2 = expr; ELSE; e3 = expr { If (e1, e2, e3) }
  | FUN; x = ID; ARROW; e = expr { Fun (x, e) }
  | LPAREN; e1 = expr; COMMA; e2 = expr; RPAREN { Pair (e1, e2) }
  | FST; e = expr { Fst e }
  | SND; e = expr { Snd e }
  ;

simpl_expr:
  | x = ID { Var x }
  | LPAREN; e = expr; RPAREN { e }
  ;