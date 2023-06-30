open! Core

type t =
  | In_progress
  | Game_over of string
  | Paused
  | Win
[@@deriving sexp_of, compare]

let to_string t =
  match t with
  | In_progress -> ""
  | Game_over x -> x
  | Paused -> ""
  | Win -> "WIN!"
;;
