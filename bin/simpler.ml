open Core
open Simpler

let interp path =
  path
  |> In_channel.read_all
  |> Interpreter.interpret
  |> Ast.show_expr
  |> print_endline
;;

let command =
  Command.basic
    ~summary:"Simple CLI for interpreting SimPL or Core OCaml code"
    (let%map_open.Command filename =
      anon (maybe_with_default "examples/pair.simpl" ("filename" %: string))
    in
    fun () -> interp filename)
;;

let () = 
  Command_unix.run command
;;