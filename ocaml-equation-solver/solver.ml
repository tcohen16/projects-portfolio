exception Fail

type op = PLUS | MIN | MULT | DIV | EQ 

type dir = L | R 

type tree = Flo of float | Node of op * tree * tree

type nd = float * dir * op * tree
 
let get_fun operation = match operation with
  | PLUS -> (+.)
  | MIN -> (-.)
  | MULT -> ( *. )
  | DIV -> (/.)

let str_of_op operation = match operation with
  | PLUS -> " + "
  | MIN -> " - "
  | MULT -> " * "
  | DIV -> " / "
  | EQ -> " = "

(* tests whether two operators are either both plus/minus or both multipy/divide. *)
let is_redundant (o1 : op) (o2 : op) : bool = match o1 with   
  | PLUS | MIN -> (match o2 with PLUS | MIN -> true | _ -> false)
  | MULT | DIV -> (match o2 with MULT | DIV -> true | _ -> false)
  | _ -> false 

(* returns a string of the arithmetic expression represented by the input tree *)
let string_of_tree tr : string = 
  let rec string_tr tr prevop sc = match tr with
    | Flo f -> sc (Float.to_string f)
    | Node (o, t1, t2) -> let str1 () = str_of_op o ^ string_tr t2 o (fun r-> r) in 
        if ((is_redundant o prevop) || (prevop = EQ)) 
        then string_tr t1 o (fun r -> sc (r ^ str1 ()))
        else if o = EQ then string_tr t1 o (fun r -> sc ("[" ^ r ^ str1 () ^ "]"))
        else string_tr t1 o (fun r -> sc ("(" ^ r ^ str1 () ^ ")"))
  in string_tr tr PLUS (fun r -> r)

(* tests for float equality *)
let equals (f1 : float) (f2 : float) = 
  let x = f1 -. f2 in (if x < 0. then 0.-.x else x) < 0.0001

(* generates the smallest nd list from the float list input *)
let rec ndlist_from_flist (flist : float list) (start : bool) : nd list =
  let rec helper acc flist start = match flist with
     | [] -> List.rev acc
     | f::[] -> List.rev ((f, L, EQ, Flo f) :: acc)
     | f::t -> helper ((if start then (f, R, EQ, Flo f) 
                       else (f, L, PLUS, Flo f)) :: acc) t false
  in
     helper [] flist start

(* for a given nd list, outputs the next nd list in according to an ordering of nd lists. 
   if there does not exist a next nd list, the Fail exception is raised *)
let rec increase_ndlist (nd_list: nd list): nd list = 
  let rec increase_tr nd_list sc = match nd_list with
  | ((f, R, EQ, tr) as n)::t -> increase_tr t (fun r -> sc (n::r))
  | (f, d, PLUS, tr)::t -> sc ((f, d, MIN, tr)::t)  
  | (f, d, MIN, tr)::t -> sc ((f, d, MULT, tr)::t) 
  | (f, d, MULT, tr)::t -> sc ((f, d, DIV, tr)::t)  
  | (f, L, DIV, tr)::t -> sc ((f, R, PLUS, tr)::t)  
  | (f, R, DIV, tr)::t -> increase_tr t (fun r -> sc ((f, L, PLUS, tr)::r)) 
  | [(_, L, EQ, tr)] -> raise Fail 
  in increase_tr nd_list (fun r -> r)

(* for a given nd list, returns the correct solutions that can be formed staring with that nd list. 
Each solution is in the form of an nd, where the tree contained in the nd has the information of what operators were used *)
let rec get_good_trees (ndlist : nd list) (ndstack : nd list) sc: nd list = match ndlist with
  | ((_, R, _, _) as n)::t ->  get_good_trees t (n::ndstack) sc
  | (f1, L, EQ, tr1)::t -> ( match ndstack with
    | (f2, R, EQ, tr2)::t2 -> if (equals f1 f2) then sc [(f2, R, EQ, Node (EQ, tr2, tr1))] else sc []
    | (f2, R, o2, tr2)::t2 -> 
      let (_, _, o3, _)::_ = t2 in if is_redundant o2 o3 then sc [] 
      else get_good_trees ((((get_fun o2) f2 f1), L, EQ, Node (o2, tr2, tr1))::t) t2 sc
    )
  | (f1, L, o1, tr1)::t -> (match ndstack with  
    | (f2, R, EQ, tr2)::t2 -> get_good_trees ((((get_fun o1) f2 f1), R, EQ, Node (o1, tr2, tr1))::t) t2 sc
    | (f2, R, o2, tr2)::t2 -> 
      let ndlistR = ((((get_fun o1) f2 f1), R, o2, Node (o1, tr2, tr1))::t) in 
      if is_redundant o1 o2 then get_good_trees ndlistR t2 sc
      else 
        let ndlistL = ((((get_fun o1) f2 f1), L, o2, Node (o1, tr2, tr1))::t) in 
        get_good_trees ndlistR t2 (fun r -> sc (r @ get_good_trees ndlistL t2 (fun r->r)))
  )

(* gets the solutions in string form for a given starting nd list *)
let get_results (ndlist : nd list) : string list = 
  let f = function (_, _, _, tr) -> string_of_tree tr in 
  let x = get_good_trees ndlist [] (fun r -> r) in 
  List.map f x 

(* cycles through all ndlists, and accumulates results*)
let rec generate_ndlists (current_nd_list) (results_list: 'a list) : 'a list = 
  try generate_ndlists (increase_ndlist current_nd_list) ((get_results current_nd_list) @ results_list)
  with Fail -> (get_results current_nd_list) @ results_list

(* outputs the list of solutions from a float list *)
let solve (flist : float list) : string list = 
  generate_ndlists (ndlist_from_flist flist true) [] 


(* let x = solve [1.;2.;3.;4.;5.;6.;7.];; *)
let x = solve [2.; 3.; 5.; 7.; 11.]
(* let y = solve [1. ; 2.] *)
(* let z = solve [1.; 2.; 4.; 7.; 14.; 12.; 3.] *)

let test1 = solve [5.; 3.; 2.];;
let test2 = solve [1.; 1.];;
let test3 = solve [1.; 2.];;
let test4 = solve [1.; 1.; 1.];;
let test5 = solve [4.; 1.; 3.; 2.];;


assert(test1 = ["[5. = 3. + 2.]"; "[5. - 3. = 2.]"]);;
assert(test2 = ["[1. = 1.]"]);;
assert(test3 = []);;
assert(test4 = ["[1. = 1. / 1.]";
"[1. = 1. * 1.]";
"[1. / 1. = 1.]";
"[1. * 1. = 1.]"]);;
assert(test5 = ["[4. + 1. = 3. + 2.]";
"[4. + 1. - 3. = 2.]"]);;

print_endline "Test + and -:";;
print_endline "solve [5.; 3.; 2.]";;
List.map print_endline test1;;
print_endline "------------------------------------------------------";;
print_endline "Test simple =:";;
print_endline "solve [1.; 1.]";;
List.map print_endline test2;;
print_endline "------------------------------------------------------";;
print_endline "Test unsolvable:";;
print_endline "solve [1.; 2.]";;
List.map print_endline test3;;
print_endline "------------------------------------------------------";;
print_endline "Test * and /:";;
print_endline "solve [1.; 1.; 1.]";;
List.map print_endline test4;;
print_endline "------------------------------------------------------";;
print_endline "Test = can be in the center and at the ends";;
print_endline "solve [4.; 1.; 3.; 2.]";;
List.map print_endline test5;;