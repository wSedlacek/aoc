(*
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
...
Game 100: 
*)



let _get_game_id line =
  let line = String.split_on_char ':' line in
  let game_string = List.hd line in
  let game_id = String.sub game_string 5 (String.length game_string - 5) in
  int_of_string game_id


let find_max_color_number color input_str =
  let color_pattern = Printf.sprintf "\\([0-9]+ %s\\)" color in
  let color_regex = Str.regexp color_pattern in

  let rec aux max_num = function
    | s :: rest ->
      begin
        try
          let _ = Str.search_forward color_regex s 0 in
          let color_part = Str.matched_string s in
          let num = int_of_string (String.trim (Str.first_chars color_part (String.length color_part - String.length color))) in
          let new_max = max max_num num in
          aux new_max rest
        with
        | Not_found -> aux max_num rest
      end
    | [] -> max_num
  in
  Str.split (Str.regexp ";") input_str
  |> aux 0

(*
The Elf would first like to know which games would have been possible if the
bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?
*)


let rec solve_file channel sum =
  match input_line channel with
  | line ->
      let line = String.trim line in
      let max_red = find_max_color_number "red" line in
      let max_green = find_max_color_number "green" line in
      let max_blue = find_max_color_number "blue" line in
        
      (* PART 1 *)
      (* let red_constraint = 12 in  *)
      (* let green_constraint = 13 in *)
      (* let blue_constraint = 14 in *)
      (* let game_id = get_game_id line in *)
      (* let red_ok = max_red <= red_constraint in *)
      (* let green_ok = max_green <= green_constraint in *)
      (* let blue_ok = max_blue <= blue_constraint in *)
      (* let game_ok = red_ok && green_ok && blue_ok in *)
      (* let sum = if game_ok then sum + game_id else sum in *)

      (* PART 2 *)
      let product = max_red * max_green * max_blue in
      let sum = sum + product in

      solve_file channel sum
  | exception End_of_file -> sum


let file_name = "part1/question.txt"
let () =
  let ic = open_in file_name in
  let sum = solve_file ic 0 in
  print_endline (string_of_int sum);
