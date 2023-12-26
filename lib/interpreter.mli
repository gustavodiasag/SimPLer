val parse : string -> Ast.expr
(** [parse s] parses [s] into an AST. *)

val interpret_small : string -> Ast.expr
(** [interpret_small s] interprets [s] by parsing, type-checking, and
    evaluating it with the small-step model. *)
    
val interpret_big : string -> Ast.expr
(** [interpret_big s] interprets [s] by parsing, type-checking, and evaluating
    it with the big-step model. *)