(*  Title:      Pure/Thy/document_source.ML
    Author:     Makarius

Document source for presentation.
*)

signature DOCUMENT_SOURCE =
sig
  val is_white: Token.T -> bool
  val is_black: Token.T -> bool
  val is_white_comment: Token.T -> bool
  val is_black_comment: Token.T -> bool
  val is_improper: Token.T -> bool
  val improper: Token.T list parser
  val improper_end: Token.T list parser
  val blank_end: Token.T list parser
  val get_tags: Proof.context -> string list
  val update_tags: string -> Proof.context -> Proof.context
  val tags: string list parser
  val annotation: unit parser
end;

structure Document_Source: DOCUMENT_SOURCE =
struct

(* white space and comments *)

(*NB: arranging white space around command spans is a black art*)

val is_white = Token.is_space orf Token.is_informal_comment;
val is_black = not o is_white;

val is_white_comment = Token.is_informal_comment;
val is_black_comment = Token.is_formal_comment;


val space_proper =
  Scan.one Token.is_blank -- Scan.many is_white_comment -- Scan.one is_black;

val is_improper = not o (is_black orf Token.is_begin_ignore orf Token.is_end_ignore);
val improper = Scan.many is_improper;
val improper_end = Scan.repeat (Scan.unless space_proper (Scan.one is_improper));
val blank_end = Scan.repeat (Scan.unless space_proper (Scan.one Token.is_blank));


(* syntactic tags (old-style) *)

structure Tags = Proof_Data
(
  type T = string list;
  fun init _ = [];
);

val get_tags = Tags.get;
val update_tags = Tags.map o update (op =);

val tag_name = Parse.group (fn () => "document tag name") (Parse.short_ident || Parse.string);

val tag = (improper -- Parse.$$$ "%" -- improper) |-- Parse.!!! (tag_name --| blank_end);
val tags = Scan.repeat tag;


(* semantic markers (operation on presentation context) *)

val marker = improper |-- Parse.document_marker --| blank_end;

val annotation = Scan.repeat (tag >> K () || marker >> K ()) >> K ();

end;