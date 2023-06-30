open! Core

module Colors = struct
  let black = Graphics.rgb 000 000 000
  let white = Graphics.rgb 255 255 255
  let head_color = Graphics.rgb 100 100 125
  let red = Graphics.rgb 255 000 000
  let orange = Graphics.rgb 255 165 000
  let yellow = Graphics.rgb 255 255 000
  let green = Graphics.rgb 000 255 000
  let blue = Graphics.rgb 000 000 255
  let cyan = Graphics.rgb 000 255 255
  let grey = Graphics.rgb 100 100 100
  let game_in_progress = Graphics.rgb 100 100 200
  let game_lost = Graphics.rgb 200 100 100
  let game_won = Graphics.rgb 100 200 100

  let apple_color apple =
    match Apple.color apple with Red -> red | Green -> green | Blue -> blue
  ;;

  let primary_snake_color snake =
    match Game.primary_color snake with
    | Red -> red
    | Orange -> orange
    | Green -> green
    | Blue -> blue
    | Cyan -> cyan
  ;;

  let secondary_snake_color snake =
    match Game.secondary_color snake with
    | Red -> red
    | Orange -> orange
    | Green -> green
    | Blue -> blue
    | Cyan -> cyan
  ;;
end

(* These constants are optimized for running on a low-resolution screen. Feel
   free to increase the scaling factor to tweak! *)
module Constants = struct
  let scaling_factor = 1.
  let play_area_height = 600. *. scaling_factor |> Float.iround_down_exn
  let header_height = 75. *. scaling_factor |> Float.iround_down_exn
  let play_area_width = 675. *. scaling_factor |> Float.iround_down_exn
  let block_size = 27. *. scaling_factor |> Float.iround_down_exn
end

let only_one : bool ref = ref false

let init_exn () =
  let open Constants in
  (* Should raise if called twice *)
  if !only_one
  then failwith "Can only call init_exn once"
  else only_one := true;
  Graphics.open_graph
    (Printf.sprintf
       " %dx%d"
       (play_area_height + header_height)
       play_area_width);
  let height = play_area_height / block_size in
  let width = play_area_width / block_size in
  Game.create ~height ~width ~initial_snake_length:3
;;

let draw_block { Position.row; col } ~color =
  let open Constants in
  let col = col * block_size in
  let row = row * block_size in
  Graphics.set_color color;
  Graphics.fill_rect (col + 1) (row + 1) (block_size - 1) (block_size - 1)
;;

let draw_header ~game_state dark_mode score high_score =
  let open Constants in
  let header_color =
    match (game_state : Game_state.t) with
    | In_progress -> Colors.game_in_progress
    | Game_over _ -> Colors.game_lost
    | Paused -> Colors.grey
    | Win -> Colors.game_won
  in
  Graphics.set_color header_color;
  Graphics.fill_rect 0 play_area_height play_area_width header_height;
  if header_color = Colors.game_lost
  then ()
  else (
    Graphics.set_color (if dark_mode then Colors.white else Colors.black);
    Graphics.moveto (play_area_width - 150) (play_area_height + 35);
    Graphics.draw_string (Printf.sprintf "Score: %d" score);
    Graphics.moveto (play_area_width - 150) (play_area_height + 20);
    Graphics.draw_string (Printf.sprintf "High score: %d" high_score);
    Graphics.set_font "-*-*-*-*-*-*-25-*-*-*-*-*-*-*";
    Graphics.moveto ((play_area_width / 2) - 300) (play_area_height + 25);
    Graphics.draw_string (Printf.sprintf "SNAKE LETS GOOOOOOOOOOOO");
    Graphics.set_font "-*-*-*-*-*-*-15-*-*-*-*-*-*-*")
;;

let draw_play_area dark_mode =
  let open Constants in
  Graphics.set_color (if dark_mode then Colors.black else Colors.white);
  Graphics.fill_rect 0 0 play_area_width play_area_height
;;

let draw_apple apple =
  let apple_position = Apple.position apple in
  draw_block apple_position ~color:(Colors.apple_color apple)
;;

let draw_snake snake_head snake_tail dark_mode primary_color secondary_color =
  List.iteri snake_tail ~f:(fun n position ->
    if n % 2 = 1
    then draw_block ~color:primary_color position
    else draw_block ~color:secondary_color position);
  (* Snake head is a different color *)
  draw_block ~color:Colors.head_color snake_head
;;

let draw_menu ~game_state dark_mode score high_score =
  let open Constants in
  Graphics.set_color (if dark_mode then Colors.white else Colors.black);
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 200);
  Graphics.draw_string (Printf.sprintf "game is paused");
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 100);
  Graphics.draw_string (Printf.sprintf "current score: %d" score);
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 80);
  Graphics.draw_string (Printf.sprintf "high score: %d" high_score);
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 30);
  Graphics.draw_string (Printf.sprintf "Press [R] to restart");
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 15);
  Graphics.draw_string (Printf.sprintf "Press [P] to pause");
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 0);
  Graphics.draw_string (Printf.sprintf "Press [L] to toggle dark mode");
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) - 15);
  Graphics.draw_string
    (Printf.sprintf "Press [1-5] to change primary snake color");
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) - 30);
  Graphics.draw_string
    (Printf.sprintf "Press [6-0] to change secondary snake color")
;;

let draw_game_over ~game_state dark_mode score high_score =
  let open Constants in
  Graphics.set_color (if dark_mode then Colors.white else Colors.black);
  Graphics.set_font "-*-*-*-*-*-*-25-*-*-*-*-*-*-*";
  Graphics.moveto ((play_area_width / 2) - 75) (play_area_height + 25);
  Graphics.draw_string (Printf.sprintf "GAME OVER");
  Graphics.moveto ((play_area_width / 2) - 5) 150;
  Graphics.draw_string (Printf.sprintf ":(");
  Graphics.set_font "-*-*-*-*-*-*-15-*-*-*-*-*-*-*";
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 200);
  Graphics.draw_string
    (Printf.sprintf " %s" (Game_state.to_string game_state));
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 100);
  Graphics.draw_string (Printf.sprintf "current score: %d" score);
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 80);
  Graphics.draw_string (Printf.sprintf "high score: %d" high_score);
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 30);
  Graphics.draw_string (Printf.sprintf "Press [R] to restart");
  Graphics.moveto ((play_area_width / 2) - 100) ((play_area_height / 2) + 15)
;;

let render game =
  (* We want double-buffering. See
     https://caml.inria.fr/pub/docs/manual-ocaml/libref/Graphics.html for
     more info!

     So, we set [display_mode] to false, draw to the background buffer, set
     [display_mode] to true and then synchronize. This guarantees that there
     won't be flickering! *)
  Graphics.display_mode false;
  let snake = Game.snake game in
  let apple = Game.apple game in
  let dark_mode = Game.mode game in
  let game_state = Game.game_state game in
  draw_header ~game_state dark_mode (Game.score game) (Game.high_score game);
  draw_play_area dark_mode;
  (match game_state with
   | Paused ->
     draw_menu ~game_state dark_mode (Game.score game) (Game.high_score game)
   | Game_over _ ->
     draw_game_over
       ~game_state
       dark_mode
       (Game.score game)
       (Game.high_score game)
   | _ ->
     draw_apple apple;
     draw_snake
       (Snake.head snake)
       (Snake.tail snake)
       dark_mode
       (Colors.primary_snake_color game)
       (Colors.secondary_snake_color game));
  Graphics.display_mode true;
  Graphics.synchronize ()
;;

let read_key () =
  if Graphics.key_pressed () then Some (Graphics.read_key ()) else None
;;
