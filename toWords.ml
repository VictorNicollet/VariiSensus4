let clean word = 
  String.lowercase word 

class toWords words listref = object
  val words = words
  val list = listref
  method start_emphasis = () 
  method end_emphasis = () 
  method start_small = () 
  method end_small = () 
  method start_strong = ()
  method end_strong = ()
  method line_break = ()
  method end_paragraph = () 
  method start_paragraph = ()
  method non_letter (_:char) = () 
  method start_quote = ()
  method start_dialog = ()
  method next_tirade = ()
  method emdash = ()
  method end_dialog = () 
  method end_quote = ()
  method contents = ()
  method word word = 
    let word = clean word in 
    let count = try Hashtbl.find words word with Not_found -> 0 in
    Hashtbl.remove words word ;
    Hashtbl.add words word (count + 1) ;
    list := word :: !list 
end

