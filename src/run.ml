open! Core

(* This is the core logic that actually runs the game. We have implemented
   all of this for you, but feel free to read this file as a reference. *)
let every seconds ~f ~stop =
  let open Async in
  let rec loop () =
    if !stop
    then return ()
    else
      Clock.after (Time_float.Span.of_sec seconds)
      >>= fun () ->
      f ();
      loop ()
  in
  don't_wait_for (loop ())
;;

let is_digit n = match n with '0' .. '9' -> true | _ -> false

(*I broke the stop so I can always get keyboard input*)
let handle_keys (game : Game.t) =
  every ~stop:(ref false) 0.001 ~f:(fun () ->
    match Snake_graphics.read_key () with
    | None -> ()
    | Some 'r' -> Game.restart game
    | Some 'p' -> Game.pause game
    | Some 'l' -> Game.flip_mode game
    | Some k when is_digit k -> Game.change_color game k
    | Some key ->
      Game.handle_key game key;
      Snake_graphics.render game)
;;

let handle_steps (game : Game.t) =
  every ~stop:(ref false) 0.1 ~f:(fun () ->
    Game.step game;
    Snake_graphics.render game)
;;

let run () =
  let game = Snake_graphics.init_exn () in
  Snake_graphics.render game;
  handle_keys game;
  handle_steps game
;;
(* these are running in paralell !!*)
