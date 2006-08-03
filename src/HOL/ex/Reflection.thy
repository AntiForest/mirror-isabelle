(*
    ID:         $Id$
    Author:     Amine Chaieb, TU Muenchen
*)

header {* Generic reflection and reification *}

theory Reflection
imports Main
uses "reflection.ML"
begin

method_setup reify = {*
  fn src =>
    Method.syntax (Attrib.thms --
      Scan.option (Scan.lift (Args.$$$ "(") |-- Args.term --| Scan.lift (Args.$$$ ")"))) src #>
  (fn (ctxt, (eqs,to)) => Method.SIMPLE_METHOD' HEADGOAL (Reflection.genreify_tac ctxt eqs to))
*} "partial automatic reification"

method_setup reflection = {*
  fn src =>
    Method.syntax (Attrib.thms --
      Scan.option (Scan.lift (Args.$$$ "(") |-- Args.term --| Scan.lift (Args.$$$ ")"))) src #>
  (fn (ctxt, (ths,to)) => Method.SIMPLE_METHOD' HEADGOAL (Reflection.reflection_tac ctxt ths to))
*} "reflection method"

end
