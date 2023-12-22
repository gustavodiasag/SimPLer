let parse s =
  let lexbuf = Lexing.from_string s in
  Parser.prog Lexer.read lexbuf
;;