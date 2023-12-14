let read_lines file =
  let contents = In_channel.with_open_bin file In_channel.input_all in
  String.split_on_char '\n' contents

;;

let is_digit = function '0' .. '9' -> true | _ -> false
let _is_symbol = function '0'.. '9' -> false | '.' -> false | _ -> true
let is_gear = function '*' -> true | _ -> false

;;

let extract_values rows predicate =
  let extract_values_from_row row row_index =
    let rec extract_value chars col_index current_value acc =
      match chars with
      | [] -> 
          (match current_value with
          | Some (value, cols) -> (value, row_index, List.rev cols) :: acc
          | None -> acc)
      | hd :: tl ->
          if predicate hd then
            let new_value, cols = 
              match current_value with
              | Some (value, cols) -> (value ^ (Char.escaped hd), col_index :: cols)
              | None -> (Char.escaped hd, [col_index])
            in
            extract_value tl (col_index + 1) (Some (new_value, cols)) acc
          else
            (match current_value with
            | Some (value, cols) -> extract_value tl (col_index + 1) None ((value, row_index, List.rev cols) :: acc)
            | None -> extract_value tl (col_index + 1) None acc)
    in
    let chars = String.to_seq row |> List.of_seq in
    extract_value chars 0 None [] in
  
  let rec extract_values_from_rows rows row_index acc =
    match rows with
    | [] -> acc
    | hd :: tl ->
        let values_in_row = extract_values_from_row hd row_index in
        extract_values_from_rows tl (row_index + 1) (values_in_row @ acc)
  in

  extract_values_from_rows rows 0 []

;;

let is_adjacent (row1, cols1) (row2, cols2) =
  let dx = abs (row1 - row2) in
  let dy = List.fold_left min max_int (List.map (fun col1 ->
    List.fold_left min max_int (List.map (fun col2 ->
      abs (col1 - col2)
    ) cols2)
  ) cols1) in
  dx <= 1 && dy <= 1

let _extract_adjacent_numbers symbols numbers =
  let adjacent_numbers = ref [] in

  let rec extract_adjacent_numbers_for_symbol symbol_positions =
    match symbol_positions with
    | [] -> ()
    | (_, row, cols) :: rest ->
        let nearby_numbers = List.filter (fun (_, num_row, num_cols) ->
          is_adjacent (row, cols) (num_row, num_cols)
        ) numbers in
        adjacent_numbers := nearby_numbers @ !adjacent_numbers;
        extract_adjacent_numbers_for_symbol rest
  in

  extract_adjacent_numbers_for_symbol symbols;
  !adjacent_numbers

;;

let find_adjacent_numbers symbols numbers =
  let find_adjacent_numbers_for_symbol (_, row, cols) =
    List.filter (fun (_, num_row, num_cols) ->
      is_adjacent (row, cols) (num_row, num_cols)
    ) numbers
  in

  List.map (fun symbol_position ->
    let symbol_numbers = find_adjacent_numbers_for_symbol symbol_position in
    symbol_numbers
  ) symbols

;;

let file_name = "part2/question.txt"
let () =
  let lines = read_lines file_name in
  let numbers = extract_values lines is_digit in

  (* PART 2 *)
  let gears = extract_values lines is_gear in
  let adjacent_numbers = find_adjacent_numbers gears numbers in
  let gear_ratios = List.filter (fun numbers ->
    List.length numbers = 2
  ) adjacent_numbers in

  List.iter (fun numbers ->
    List.iter (fun (value, _, _) -> print_string (value ^ " ")) numbers;
    print_endline ""
  ) gear_ratios;

  let values = List.map (fun numbers ->
    List.map (fun (value, _, _) ->  int_of_string value) numbers
  ) gear_ratios in

  let multiples = List.map (fun numbers ->
    List.fold_left (fun acc num -> acc * num) 1 numbers
  ) values in

  let sum = List.fold_left (+) 0 multiples in
  print_endline ("Total sum: " ^ (string_of_int sum));


  (* PART 1 *)
  (* let symbols = extract_values lines is_gear in *)
  (* let adjacent_numbers = _extract_adjacent_numbers symbols numbers in *)
  (**)
  (* let sorted_numbers = List.sort (fun (_, row1, _) (_, row2, _) -> compare row1 row2) adjacent_numbers in *)
  (* List.iter (fun (value, row, cols) -> *)
  (*   Printf.printf("Value: %s, Row: %d, Cols: [%s]\n") value row (String.concat ", " (List.map string_of_int cols)) *)
  (* ) sorted_numbers; *)
  (**)
  (* let sum = List.fold_left (fun acc (value, _, _) -> acc + int_of_string value) 0 adjacent_numbers in *)
  (* print_endline ("Total sum: " ^ (string_of_int sum)) *)
