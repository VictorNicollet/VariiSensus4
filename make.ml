let generate_graphs () = 

  let count = Hashtbl.create 1000 in
  let words = ref [] in
  let offsets = Array.make (List.length All.all + 1) 0 in   
  let titles  = Array.of_list (List.map snd All.all) in
  let i = ref 1 in

  List.iter (fun (path,_) -> 
    let chan = open_in ("chapters/" ^ path) in 
    let lexbuf = Lexing.from_channel chan in 
    Lex.words count words lexbuf ;
    offsets.(!i) <- List.length !words ;
    incr i 
  ) All.all ;
 
  let words = Array.of_list (List.rev !words) in

  (* Prints out some stats to a given file *)
  let print scale file stat = 
    
    print_endline file ; 

    let chapter = ref 1 in
    let high = Array.fold_left max stat.(0) stat in
    let low  = Array.fold_left min stat.(0) stat in
    let delta = high -. low in
    let sum = ref 0.0 in
    let chan = open_out file in

    output_string chan "<!DOCTYPE html><html><head><link rel=stylesheet href=\"http://nicollet.net/book/style.css\"/></head><body><div id=graphnav>" ;

    List.iter 
      (fun name -> output_string chan 
	("<a href='/book/" ^ String.lowercase name ^"'>" ^ name ^ "</a>"))
      [ "Frequency" ;
	"Simmera" ;
	"Giselle" ;
	"Ildaric" ;
	"Nathan" ; 
	"Staniel" ;
	"Athanor" ;
	"Altarane" ; 
	"Arkadir" ;
	"Archange" ;
	"Ygao" ] ;

    output_string chan "</div><div id=page><div id=text><div id=graph>" ;

    for i = 0 to Array.length stat - 1 do 

      (* Display the current chapter box *)
      if i = offsets.(!chapter - 1) then 
	( output_string chan "<div class=chapter><h2>" ;
	  output_string chan titles.(!chapter - 1) ;
	  output_string chan "</h2><div>" ) ;
      if i = offsets.(!chapter) - 1 then
	( output_string chan "</div></div>" ; 
	  incr chapter ) ;

      sum := !sum +. stat.(i) ; 

      if i mod scale = 0 then begin 
	
	let value = !sum /. float_of_int scale in 
	let value = 100. *. (value -. low) /. delta in
	let line  = Printf.sprintf "<div style='width:%.2f%%'></div>" value in

	output_string chan line ;
	sum := 0.0 

      end 

    done ;

    output_string chan "</div></div></div></body></html>" ;
    close_out chan 
  in

  (* Apply an involution to an array *)
  let involution matrix array = 
    let mid = Array.length matrix / 2 in
    let n   = Array.length array in 
    Array.init (Array.length array) (fun i -> 
      let sum = ref 0. and weight = ref 0. in
      Array.iteri (fun j w -> 
	let k = i + j - mid in
	if k >= 0 && k < n then begin
	  weight := w +. !weight ;
	  sum := w *. array.(k) +. !sum
	end
      ) matrix ;
      if !weight > 0. then !sum /. !weight else 0. 
    ) 
  in

  (* Gaussian coefficients for involution *)
  let gauss_factor = 300 in
  let gauss = Array.init (2 * gauss_factor + 1) (fun i ->
    let m = gauss_factor in
    let z = 3. *. float_of_int (i - m) /. float_of_int gauss_factor in
    exp (z *. z *. -0.5) 
  ) in

  (* Inverse word frequency *)
  let () = 
    print 20 "www/frequency.htm"
      (involution gauss 
	 (Array.map 
	    (fun w -> 1. /. float_of_int (Hashtbl.find count w))
	    words))
  in

  let find word = 
    print 20 ("www/" ^ word ^ ".htm")
      (involution gauss 
	 (Array.map 
	    (fun w -> if w = word then 1. else 0.)
	    words))
  in
  
  List.iter find [
    "simmera" ; 
    "giselle" ; 
    "ildaric" ;
    "athanor" ;
    "staniel" ;
    "nathan" ; 
    "ygao" ; 
    "altarane" ;
    "arkadir" ;
    "archange"
  ]

let generate_words () = 

  let count_for name counter =

    let count = Hashtbl.create 1000 in

    counter count ; 

    let list = List.sort (fun (_,a) (_,b) -> compare b a)
      (Hashtbl.fold (fun k v acc -> (k,v) :: acc) count []) in

    let total = List.fold_left (fun acc (_,a) -> acc + a) 0 list in

    Printf.printf "==== %s - %d words - spread factor %f ====\n" name total 
      (float_of_int (List.length list) /. float_of_int total) ;

    List.iter (fun (word, count) ->
      Printf.printf "%3d (%2d%%) %s\n" count (count * 100 / total) word) list ;

    print_newline () ;

  in

  count_for "All" (fun count -> 

    List.iter (fun (path,_) -> 
      let chan = open_in ("chapters/" ^ path) in 
      let lexbuf = Lexing.from_channel chan in 
      Lex.words count (ref []) lexbuf ;
    ) All.all ;

  ) ;

  List.iter (fun (path,name) ->
    count_for name (fun count -> 
      let chan = open_in ("chapters/" ^ path) in 
      let lexbuf = Lexing.from_channel chan in 
      Lex.words count (ref []) lexbuf 
    )
  ) All.all 

let body path = 
  let chan = open_in path in 
  let lexbuf = Lexing.from_channel chan in 
  Lex.clean lexbuf 

let index path last = 
 "<!DOCTYPE html>
<html>
<head>
  <meta http-equiv=\"Content-Type\" value=\"text/html; charset=UTF-8\"/>
  <meta property=\"og:title\" content=\"Varii Sensus\"/>
  <meta property=\"og:type\" content=\"book\"/>
  <meta property=\"og:url\" content=\"http://nicollet.net/book/\"/>
  <meta property=\"og:image\" content=\"http://nicollet.net/book/cliff-thumb.png\"/>
  <meta property=\"og:site_name\" content=\"Varii Sensus\"/>
  <meta property=\"fb:admins\" content=\"517629600\"/>
  <link href='http://fonts.googleapis.com/css?family=Francois+One' rel='stylesheet' type='text/css'>
  <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>  
  <link rel=stylesheet href=\"http://nicollet.net/book/style.css\"/>
  <title>Varii Sensus</title>
</head>
<body>
  
    <center style=\"margin-top: 150px\">
      <h1 style=\"font-size:2.5em\">Varii Sensus</h1>
      <div class=\"navig\" style=\"float:none;text-align:center\">
	<a href=\"http://nicollet.net/book/"^path^"\">"^path^". "^last^"</a>
      </div>
    </center>
  
  <div id=foot><small>Varii Sensus &copy; 2013 Victor Nicollet.</small></div>
  <script type=\"text/javascript\">
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-34610151-1']);
    _gaq.push(['_trackPageview']);
    (function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = 'http://www.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
  </script>
</body>
</html>"


let wrap title page path prev next = 

  let arch = 
    if prev <> None || next <> None 
    then "<a id=archives href=archives>Archives</a>"      
    else ""
  in

  let opengraph = 
    match path with 
      | Some path when prev <> None || next <> None ->
	"
  <meta property=\"og:title\" content=\"Chapitre " ^ path ^ " - " ^ title ^"\"/>
  <meta property=\"og:type\" content=\"book\"/>
  <meta property=\"og:url\" content=\"http://nicollet.net/book/"^path^"\"/>
  <meta property=\"og:image\" content=\"http://nicollet.net/book/cliff-thumb.png\"/>
  <meta property=\"og:site_name\" content=\"Varii Sensus\"/>
  <meta property=\"fb:admins\" content=\"517629600\"/>"	
      | _ -> ""
  in

  let next = match next with 
    | None -> ""
    | Some (path,title) -> "<a class=next href=" ^ path ^ ">" ^ path ^ ". " ^ title ^ "&emsp;▶</a>"
  in 

  let prev = match prev with 
    | None -> ""
    | Some (path,title) -> "<a class=prev href=" ^ path ^ ">◀&emsp;" ^ path ^ ". " ^ title ^ "</a>"
  in

  let num = match path with 
    | Some path -> "<span>" ^ path ^ ". </span>"
    | None -> ""
  in

  "<!DOCTYPE html>
<html>
<head>
  <meta http-equiv=\"Content-Type\" value=\"text/html; charset=UTF-8\"/>" ^ opengraph ^ "
  <link href='http://fonts.googleapis.com/css?family=Francois+One' rel='stylesheet' type='text/css'>
  <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>  
  <link rel=stylesheet href=\"style.css\"/>
  <title>" ^ title ^ " &ndash; Varii Sensus</title>
</head>
<body>
  <div id=head>
    <h1><a href=\"http://nicollet.net/book\">Varii Sensus</a></h1>
    <div id=author><p>écrit par <a href=\"http://nicollet.net\">Victor Nicollet</a></p></div>
    <p>Varii Sensus est un roman de fiction, dont un nouveau chapitre est mis en ligne chaque semaine.</p>
  </div>
  <div id=page>
    <div id=top>
      <div class=navig>
        " ^ prev ^ " 
        " ^ next ^ "
        " ^ arch ^ " 
      </div>
      <h2>" ^ num ^ title ^ "</h2>
    </div>
    " ^ page ^ "
    <div id=bot>
      <div class=navig>
        " ^ prev ^ " 
        " ^ next ^ "
        " ^ arch ^ " 
      </div>
      <a id=\"RSS\" href=\"http://nicollet.net/book/rss.xml\">RSS</a>
    </div>    
  </div>
  <div id=foot>Varii Sensus &copy; 2013 Victor Nicollet<br/><small>Avec des photos par <a href=\"http://www.flickr.com/photos/quelgar/83763441/in/photostream/\">Lachlan O'Dea</a> et <a href=\"http://wallbase.cc/wallpaper/409811\">Wallbase</a>.</div>
  <script type=\"text/javascript\">
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-34610151-1']);
    _gaq.push(['_trackPageview']);
    (function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = 'http://www.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
  </script>
</body>
</html>"
  
let html prev (path,title) next = 

  let body = body ("chapters/" ^ path) in 
  let page = 
    "<div id=text>" ^ body ^ "</div>"
  in

  wrap title page (Some path) prev next
  
let generate prev (path,title) next = 
  let html = html prev (path,title) next in
  let path = "www/" ^ path ^ ".htm" in
  print_endline path ;
  let chan = open_out path in
  output_string chan html ;
  close_out chan 

let generate_all () = 
  let rec aux prev = function 
    | a :: (b :: _ as t) -> generate prev a (Some b) ; aux (Some a) t
    | [x] -> generate prev x None ;
    | [] -> assert false
  in aux None All.all

let generate_archives () = 
  let list = String.concat "</li><li>" (List.map (fun (path,title) -> 
    "<a href=" ^ path ^ "><span>" ^ path ^ ". </span> " ^ title ^ "</a>"
  ) All.all) in
  let html = wrap "Archives" ("<ul id=archive><li>" ^ list ^ "</li></ul>") None None None in
  let path = "www/archives.htm" in
  print_endline path ;
  let chan = open_out path in
  output_string chan html ;
  close_out chan 

let generate_rss () = 

  let date time = 
    let tm = Unix.gmtime time in 
    Unix.(Printf.sprintf "%s, %02d %s %d %02d:%02d:%02d +0000"
	    [| "Sun" ; "Mon" ; "Tue" ; "Wed" ; "Thu" ; "Fri" ; "Sat" |].(tm.tm_wday)
	    tm.tm_mday 
	    [| "Jan" ; "Feb" ; "Mar" ; "Apr" ; "May" ; "Jun" ; "Jul" ; "Aug" ; "Sep" ; "Oct" ; "Nov" ; "Dec" |].(tm.tm_mon)
	    (1900 + tm.tm_year)
	    tm.tm_hour tm.tm_min tm.tm_sec)
  in

  let items = String.concat "</item><item>" (List.map (fun (path,title) ->
    "<title>" ^ path ^ ".&#160;" ^ title ^ "</title><link>http://nicollet.net/book/" ^ path ^ "</link>"
  ) (List.rev All.all)) in

  let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<rss version=\"2.0\">
<channel>
  <title>Varii Sensus</title>
  <description>Varii Sensus est un roman de fiction, dont un nouveau chapitre est mis en ligne chaque lundi.</description>
  <link>http://nicollet.net/book</link>
  <pubDate>" ^ date (Unix.gettimeofday ()) ^ "</pubDate>
  <item>" ^ items ^ "</item>
</channel>" in
  let path = "www/rss.xml" in
  print_endline path ;
  let chan = open_out path in
  output_string chan xml ;
  close_out chan 

let generate_index () = 
  let rec aux = function
    | [path,title] -> index path title
    | _ :: t -> aux t
    | [] -> ""
  in
  let html = aux All.all in
  print_endline "www/index.htm" ;
  let chan = open_out "www/index.htm" in
  output_string chan html ;
  close_out chan 
	
let page404 () = 
  generate None ("404","Page Non Trouvée") None 

let generate_latex what = 
  let inv = new ToLatex.toLatex what in
  List.iter (fun (path, name) -> 
    inv # start_chapter name ;
    let chan = open_in ("chapters/" ^ path) in 
    let lexbuf = Lexing.from_channel chan in 
    Lex.latex inv lexbuf ;
    close_in chan 
  ) All.all ;
(*
  inv # start_lexicon ;
  let chan = open_in "lexicon" in
  let lexbuf = Lexing.from_channel chan in
  Lex.latex inv lexbuf ;
  close_in chan;
*)
  print_endline "out/book.tex" ;
  let chan = open_out "out/book.tex" in
  output_string chan (inv # contents) ;
  close_out chan 

let generate_epub () = 

  (* OPF file (includes manifest) *) 
  let chan = open_out "epub/content.opf" in
  output_string chan ToEpub.opf_head ;
  List.iter (fun (path,_) -> output_string chan
    (Printf.sprintf "<item id=\"%s\" href=\"%s.htm\" media-type=\"application/xhtml+xml\"/>"
       path path)) All.all ;
  output_string chan ToEpub.opf_mid ; 
  List.iter (fun (path,_) -> output_string chan
    (Printf.sprintf "<itemref idref=\"%s\"/>" path)) All.all ;
  output_string chan ToEpub.opf_foot ; 
  close_out chan ;

  (* NCX file (table of contents) *)

  let chan = open_out "epub/toc.ncx" in
  output_string chan ToEpub.ncx_head ;
  let i = ref 1 in
  List.iter (fun x -> output_string chan (ToEpub.ncx_item (!i) x) ; incr i) All.all;
  output_string chan (ToEpub.ncx_foot !i) ;
  close_out chan ;

  (* Generate actual chapters *) 

  List.iter (fun (path, name) -> 
    let inv = new ToEpub.toEpub in
    inv # start_chapter name ;
    let chan = open_in ("chapters/" ^ path) in 
    let lexbuf = Lexing.from_channel chan in 
    Lex.latex inv lexbuf ;
    close_in chan ;
    print_endline ("epub/"^path^".htm") ;
    let chan = open_out ("epub/"^path^".htm") in
    output_string chan (inv # contents) ;
    close_out chan     
  ) All.all ;

  let inv = new ToEpub.toEpub in
  inv # start_lexicon ;
  let chan = open_in "lexicon" in
  let lexbuf = Lexing.from_channel chan in 
  Lex.latex inv lexbuf ;
  close_in chan ;
  print_endline ("epub/lexicon.htm") ;
  let chan = open_out ("epub/lexicon.htm") in
  output_string chan (inv # contents) ;
  close_out chan     


let () = 
  if Array.length Sys.argv = 1 then begin 
    generate_all () ;
    generate_archives () ;
    generate_rss () ;
    generate_index () ;
    page404 () ; 
  end else if Sys.argv.(1) = "--latex" then begin 
    generate_latex ToLatex.Final ;
  end else if Sys.argv.(1) = "--latex-draft" then begin 
    generate_latex ToLatex.Draft ;
  end else if Sys.argv.(1) = "--latex-pdf" then begin 
    generate_latex ToLatex.Pdf ;
  end else if Sys.argv.(1) = "--ePub" then begin 
    generate_epub () ;
  end else if Sys.argv.(1) = "--words" then begin
    generate_words () 
  end else if Sys.argv.(1) = "--graph" then begin 
    generate_graphs () 
  end
