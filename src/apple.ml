open! Core

module Color = struct
  type t =
    | Red
    | Green
    | Blue
  [@@deriving sexp_of, enumerate, compare]
end

type t =
  { position : Position.t
  ; color : Color.t
  }
[@@deriving sexp_of]

let position t = t.position
let color t = t.color

let amount_to_grow t =
  match color t with Red -> 1 | Green -> 5 | Blue -> 10
;;

let value t = amount_to_grow t * 100

let get_apple_color score =
  if score < 1000
  then Color.Red
  else if score < 5000
  then Color.Green
  else Color.Blue
;;

(* Exercise 05:

   [create] takes in a board and a snake and creates a new apple with a
   position chosen randomly from all possible positions inside the board that
   are not currently occupied by the snake. If there is no position possible
   it should return [None]. (This will happen if the player wins!)

   We have used records before, but hard-coding the apple's position (i.e.,
   putting the specific value directly into the code) is the first time we'll
   make a new one. We can define a record like so:

   {[ { field_name1 = value1 ; field_name2 = value2 } ]}

   As it happens, we may not need to do this any more once we stop
   hard-coding it.

   We've already written the [create] logic; take a look at the function to
   make sure you understand what it's doing.

   Our implementation of [create] calls [possible_apple_positions], which
   you'll need to implement. It should return the positions on the board
   where an apple can be generated (in any order).

   One function you might find handy for this exercise is
   [Board.all_positions], which is defined in board.ml. [Board.all_positions]
   takes a board and returns a list of all positions on the board.

   Another function that may be useful is [Snake.all_positions], which is
   defined in snake.ml. This function takes a snake and returns all positions
   it currently occupies.

   Before you get started, check out LIST_FUNCTIONS.mkd for some useful new
   List functions. You probably won't need all of these functions, but they
   should give you a few options for how to write [possible_apple_positions].

   You may feel like your solution to this function is inefficient. That's
   perfectly fine, since the board is quite small. Talk to a TA if you'd like
   to learn other tools that might help make this function more efficient.

   When you're done writing [possible_apple_positions], make sure to check
   that tests pass by running   $ tests/exercise05/inline_tests_runner *)
let possible_apple_positions ~board ~snake =
  List.filter (Board.all_positions board) ~f:(fun pos ->
    not (List.exists (Snake.all_positions snake) ~f:(Position.equal pos)))
;;

let create ~board ~snake ~color =
  let possible_positions = possible_apple_positions ~board ~snake in
  match List.random_element possible_positions with
  | None -> None
  | Some position -> Some { position; color }
;;

(* module Exercises = struct let exercise05 = possible_apple_positions let
   create_with_position position = { position } end *)
