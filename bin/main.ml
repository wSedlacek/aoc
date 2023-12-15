let read_lines file =
  let contents = In_channel.with_open_bin file In_channel.input_all in
  String.split_on_char '\n' (String.trim contents)

let read_numbers_between line ?(stop_char = None) start_char =
  let start_index = String.index line start_char in
  let stop_index =
    match stop_char with
    | Some stop -> String.index_from line (start_index + 1) stop
    | None -> String.length line
  in
  let numbers_string =
    String.trim
      (String.sub line (start_index + 1) (stop_index - start_index - 1))
  in
  let number_strings = Str.split (Str.regexp " +") numbers_string in
  List.map int_of_string number_strings

module IntSet = Set.Make (struct
  type t = int

  let compare = compare
end)

let list_to_set lst =
  List.fold_left (fun set element -> IntSet.add element set) IntSet.empty lst

let find_common_elements sublist mainlist =
  let subset_set = list_to_set sublist in
  let mainlist_set = list_to_set mainlist in
  let common_set = IntSet.inter subset_set mainlist_set in
  IntSet.elements common_set

let get_line_score line =
  let my_numbers = read_numbers_between line ':' ~stop_char:(Some '|') in
  let winning_numbers = read_numbers_between line '|' in
  let my_winning_numbers = find_common_elements winning_numbers my_numbers in

  (* PART 2 *)
  List.length my_winning_numbers

(* PART 1  *)
(* match List.length my_winning_numbers with *)
(* | 0 -> 0 *)
(* | 1 -> 1 *)
(* | _ -> Int.pow 2 (List.length my_winning_numbers - 1) *)

let add_to_nth_index lst_ref n total =
  let rec aux i = function
    | [] -> []
    | x :: xs -> if i = 0 then (x + total) :: xs else x :: aux (i - 1) xs
  in
  let current_list = !lst_ref in
  let updated_list = aux n current_list in
  lst_ref := updated_list

(* Copies of scratchcards are scored like normal scratchcards and have the same *)
(* card number as the card they copied. So, if you win a copy of card 10 and it *)
(* has 5 matching numbers, it would then win a copy of the same cards that the *)
(* original card 10 won: cards 11, 12, 13, 14, and 15. This process repeats until *)
(* none of the copies cause you to win any more cards. (Cards will never make you *)
(* copy a card past the end of the table.) *)
let process_scores scores =
  let card_counts = ref (List.map (fun _ -> 1) scores) in

  for i = 0 to List.length scores - 1 do
    let card_count = List.nth !card_counts i in
    let score = List.nth scores i in
    for j = i + 1 to score + i do
      add_to_nth_index card_counts j card_count
    done
  done;

  List.fold_left (fun acc score -> acc + score) 0 !card_counts

let () =
  let file_name = "part2/question.txt" in
  let lines = read_lines file_name in
  let scores = List.map get_line_score lines in

  List.iter
    (fun score -> print_endline ("Score: " ^ string_of_int score))
    scores;

  (* PART 2 *)
  let total_score = process_scores scores in
  print_endline ("Total score: " ^ string_of_int total_score)

(* PART 1 *)
(* let total_score = List.fold_left (fun acc score -> acc + score) 0 scores in *)
(* print_endline ("Total score: " ^ string_of_int total_score) *)
