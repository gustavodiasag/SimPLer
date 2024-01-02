{

open Parser

}

(* Identifiers *)
let white = [' ' '\t' '\n' ';']+
let digit = ['0'-'9']
let int = '-'? digit+
let letter = ['a'-'z' 'A'-'Z']
let id = letter+

(* Rules *)
rule read =
  parse
    (* Whitespace *)
    | white { read lexbuf }
    (* Single-character *)
    | "," { COMMA }
    | "<" { LT }
    | ">" { GT }
    | "*" { TIMES }
    | "+" { PLUS }
    | "(" { LPAREN }
    | ")" { RPAREN }
    | "=" { EQ }
    (* Keywords *)
    | "let" { LET }
    | "true" { TRUE }
    | "false" { FALSE }
    | "in" { IN }
    | "if" { IF }
    | "then" { THEN }
    | "else" { ELSE }
    | "fun" { FUN }
    | "->" { ARROW }
    | "fst" { FST }
    | "snd" { SND }
    (* Literals *)
    | id { ID (Lexing.lexeme lexbuf ) }
    | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
    (* Eof *)
    | eof { EOF }