open! Core

module Color : sig
  type t =
    | Red
    | Orange
    | Green
    | Blue
    | Cyan
  [@@deriving sexp_of]
end

(** A [t] represents the entire game state, including the current snake,
    apple, and game state. *)
type t [@@deriving sexp_of]

(** Used for pretty-printing game contents for tests. *)
val to_string : t -> string

(** [create] creates a new game with specified parameters. *)
val create : height:int -> width:int -> initial_snake_length:int -> t

(** [snake] returns the snake that is currently in the game. *)
val snake : t -> Snake.t

(** [handle_key] is called whenever the user presses a key. It takes that key
    and updates the game accordingly. *)
val handle_key : t -> char -> unit

(** [apple] returns the apple that is currently in the game. *)
val apple : t -> Apple.t

(** [mode] returns if the game is in dark mode. *)
val mode : t -> bool

(** [game_state] returns the state of the current game. *)
val game_state : t -> Game_state.t

(** [step] is called in a loop, and the game is re-rendered after each call. *)
val step : t -> unit

(** [score] returns the game's current score *)
val score : t -> int

(** [pause] pauses the game*)
val pause : t -> unit

(** [restart] restarts the game*)
val restart : t -> unit

(** [score] returns the game's highest score *)
val high_score : t -> int

(** [flip_mode] changes the game mode from light to dark or vice versa*)
val flip_mode : t -> unit

(** [change_color] changes primary or secondary color of the snake **)
val change_color : t -> char -> unit

(** [primary_color] returns the primary color of the snake. *)
val primary_color : t -> Color.t

(** [secondary_color] returns the secondary color of the snake. *)
val secondary_color : t -> Color.t

(** Functions in [Exercises] modules shouldn't be used. They are only exposed
    so they can be tested *)
module Exercises : sig
  val exercise02b : t -> char -> unit
  val exercise03b : t -> Snake.t -> Game_state.t
  val exercise04b : t -> Snake.t -> Snake.t * Game_state.t
  val exercise06b : t -> unit
  val set_snake : t -> Snake.t -> unit
  val set_apple : t -> Apple.t -> unit
end
