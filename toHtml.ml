let hyphenate word = 
  word

class toHtml = object
  val buffer = Buffer.create 1024 
  method start_emphasis = 
    Buffer.add_string buffer "<em>"
  method end_emphasis = 
    Buffer.add_string buffer "</em>"
  method start_small = 
    Buffer.add_string buffer "<small>"
  method end_small = 
    Buffer.add_string buffer "</small>"
  method start_strong = 
    Buffer.add_string buffer "<strong>"
  method end_strong = 
    Buffer.add_string buffer "</strong>"
  method line_break = 
    Buffer.add_string buffer "<br/>"
  method end_paragraph = 
    Buffer.add_string buffer "</p>" 
  method start_paragraph = 
    Buffer.add_string buffer "<p class=t>"
  method non_letter c = 
    let () = match c with 
      | '?' | '!' | ':' -> Buffer.add_string buffer "&nbsp;"
      | _ -> () 
    in
    match c with
    | '\'' -> Buffer.add_string buffer "&rsquo;" 
    | _ -> Buffer.add_char buffer c
  method start_quote = 
    Buffer.add_string buffer " &laquo;&nbsp;"
  method start_dialog = 
    Buffer.add_string buffer "<p class=ds>&laquo;&nbsp;"
  method next_tirade = 
    Buffer.add_string buffer "</p><p class=d>&mdash;&nbsp;"
  method emdash = 
    Buffer.add_string buffer "&mdash;"
  method end_dialog = 
    Buffer.add_string buffer "&nbsp;&raquo;</p>"
  method end_quote = 
    Buffer.add_string buffer "&nbsp;&raquo; "
  method contents = 
    Buffer.contents buffer
  method word word = 
    Buffer.add_string buffer (hyphenate word) 
end

