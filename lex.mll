{}

let white = [ ' ' '\t' '\r' ]
let letter = ( ['a' - 'z' 'A' - 'Z'] 
		 | "é" | "è" | "È" | "ê" | "Ê" | "ë" | "Ë" 
		 | "à" | "À" | "â" | "Â" | "ä" | "Ä" 
		 | "ô" | "Ô" | "ö" | "Ö" | "œ" | "Œ" 
		 | "î" | "Î" | "ï" | "Ï" 
		 | "ç" | "Ç" 
		 | "-" ) 

let punctuation = [ '?' '!' ':' '\'' ] 

rule continue inDialog inParagraph inv = parse

  | white * '\n' ( white | '\n' ) * '\n' 
      { if inDialog then inv # end_dialog else
	  if inParagraph then inv # end_paragraph ;
	continue false false inv lexbuf } 

  | white * ( punctuation as c ) 
      { if not inParagraph then inv # start_paragraph ; 
	inv # non_letter c ; 
	continue inDialog true inv lexbuf }

  | white * "<<" white * 
      { if inParagraph then (
	  inv # start_quote ; 
	  continue inDialog inParagraph inv lexbuf
	) else (
	  inv # start_dialog ;
	  continue true true inv lexbuf
        ) }

  | white * "---" white * 
      { if inDialog then inv # next_tirade 
	else inv # emdash ;
	continue inDialog inParagraph inv lexbuf }

  | "<em>" { inv # start_emphasis ; continue inDialog inParagraph inv lexbuf }
  | "</em>" { inv # end_emphasis ; continue inDialog inParagraph inv lexbuf }

  | "<b>" { inv # start_strong ; continue inDialog inParagraph inv lexbuf }
  | "</b>" { inv # end_strong ; continue inDialog inParagraph inv lexbuf }
	
  | "<small>" { inv # start_small ; continue inDialog inParagraph inv lexbuf }
  | "</small>" { inv # end_small ; continue inDialog inParagraph inv lexbuf }
		
  | "<br/>" { inv # line_break ; continue inDialog inParagraph inv lexbuf }

  | ('\n' | white) * ">>" white * 
      { if inDialog then ( 
          inv # end_dialog ; 
          continue false false inv lexbuf
        ) else (
	  inv # end_quote ;
	  continue inDialog inParagraph inv lexbuf
        ) }

  | white * ('\n' | white +) 
      { if inParagraph then inv # non_letter ' ' ;
	continue inDialog inParagraph inv lexbuf }

  | letter + as str
      { if not inParagraph then inv # start_paragraph ;
	inv # word str ;
	continue inDialog true inv lexbuf }

  | _ as c 
      { if not inParagraph then inv # start_paragraph ; 
	inv # non_letter c ;
	continue inDialog true inv lexbuf }

  | eof 
      { if inParagraph then inv # end_paragraph }

{
  let clean lexbuf = 
    let inv = new ToHtml.toHtml in 
    continue false false inv lexbuf ;
    inv # contents

  let words count listref lexbuf = 
    let inv = new ToWords.toWords count listref in 
    continue false false inv lexbuf 

  let latex (inv:ToLatex.toLatex) lexbuf = 
    continue false false inv lexbuf 
}
