val parse : string -> Ast.expr
(** [parse s] parses [s] into an AST. *)

val interpret : string -> Ast.expr
(** [interpret_big s] interprets [s] by parsing, type-checking, and evaluating
    it with the big-step model. *)
