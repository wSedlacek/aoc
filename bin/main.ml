type search_direction = Forward | Backward

let number_words = [("one", 1); ("two", 2); ("three", 3); ("four", 4);
                    ("five", 5); ("six", 6); ("seven", 7); ("eight", 8);
                    ("nine", 9)]

let find_first_number str direction =
  let length = String.length str in
  let find_word i word =
    if String.length word + i > length then false
    else String.sub str i (String.length word) = word
  in

  let rec aux i =
    if (direction = Forward && i >= length) || (direction = Backward && i < 0) then
      None
    else match str.[i] with
      | '0'..'9' as digit ->
          Some (Char.code digit - Char.code '0')
      | _ ->
          match List.find_opt (fun (word, _) -> find_word i word) number_words with 
          | Some (_, num) -> Some num
          | None -> aux (if direction = Forward then i + 1 else i - 1)
  in
  aux (if direction = Forward then 0 else length - 1)


let rec solve_file channel sum =
  match input_line channel with
  | line ->
      let first_number = find_first_number line Forward in
      let second_number = find_first_number line Backward in
      let merged =
        match first_number, second_number with
        | Some first, Some second -> string_of_int first ^ string_of_int second
        | Some first, None -> string_of_int first ^ string_of_int first
        | None, Some second -> string_of_int second ^ string_of_int second
        | None, None -> ""
      in
      print_endline merged;
      let new_sum = sum + (if merged = "" then 0 else int_of_string merged) in
      solve_file channel new_sum
  | exception End_of_file -> sum


let file_name = "part1/question.txt"
let () =
  let ic = open_in file_name in
  let total_sum = solve_file ic 0 in
  print_endline ("Total sum: " ^ string_of_int total_sum)
