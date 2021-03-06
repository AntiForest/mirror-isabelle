(*  Title:      Pure/System/isabelle_system.ML
    Author:     Makarius

Isabelle system support.
*)

signature ISABELLE_SYSTEM =
sig
  val bash_process: string -> Process_Result.T
  val bash_output: string -> string * int
  val bash: string -> int
  val bash_functions: unit -> string list
  val check_bash_function: Proof.context -> string * Position.T -> string
  val make_directory: Path.T -> Path.T
  val copy_dir: Path.T -> Path.T -> unit
  val copy_file: Path.T -> Path.T -> unit
  val copy_file_base: Path.T * Path.T -> Path.T -> unit
  val create_tmp_path: string -> string -> Path.T
  val with_tmp_file: string -> string -> (Path.T -> 'a) -> 'a
  val rm_tree: Path.T -> unit
  val with_tmp_dir: string -> (Path.T -> 'a) -> 'a
  val download: string -> Path.T -> unit
end;

structure Isabelle_System: ISABELLE_SYSTEM =
struct

(* bash *)

fun bash_process script =
  Scala.function_thread "bash_process"
    ("export ISABELLE_TMP=" ^ Bash.string (getenv "ISABELLE_TMP") ^ "\n" ^ script)
  |> split_strings0
  |> (fn [] => raise Exn.Interrupt
      | [err] => error err
      | a :: b :: c :: d :: lines =>
          let
            val rc = Value.parse_int a;
            val (elapsed, cpu) = apply2 (Time.fromMilliseconds o Value.parse_int) (b, c);
            val (out_lines, err_lines) = chop (Value.parse_int d) lines;
          in
            Process_Result.make
             {rc = rc,
              out_lines = out_lines,
              err_lines = err_lines,
              timing = {elapsed = elapsed, cpu = cpu, gc = Time.zeroTime}}
         end
      | _ => raise Fail "Malformed Isabelle/Scala result");

val bash = bash_process #> Process_Result.print #> Process_Result.rc;

fun bash_output s =
  let
    val res = bash_process s;
    val _ = warning (Process_Result.err res);
  in (Process_Result.out res, Process_Result.rc res) end;


(* bash functions *)

fun bash_functions () =
  bash_process "declare -Fx"
  |> Process_Result.check
  |> Process_Result.out_lines
  |> map_filter (space_explode " " #> try List.last);

fun check_bash_function ctxt arg =
  Completion.check_entity Markup.bash_functionN
    (bash_functions () |> map (rpair Position.none)) ctxt arg;


(* directory and file operations *)

val absolute_path = Path.implode o File.absolute_path;
fun scala_function0 name = ignore o Scala.function name o cat_strings0;
fun scala_function name = scala_function0 name o map absolute_path;

fun make_directory path = (scala_function "make_directory" [path]; path);

fun copy_dir src dst = scala_function "copy_dir" [src, dst];

fun copy_file src dst = scala_function "copy_file" [src, dst];

fun copy_file_base (base_dir, src) target_dir =
  scala_function0 "copy_file_base"
    [absolute_path base_dir, Path.implode src, absolute_path target_dir];


(* tmp files *)

fun create_tmp_path name ext =
  let
    val path = File.tmp_path (Path.basic (name ^ serial_string ()) |> Path.ext ext);
    val _ = File.exists path andalso
      raise Fail ("Temporary file already exists: " ^ Path.print path);
  in path end;

fun with_tmp_file name ext f =
  let val path = create_tmp_path name ext
  in Exn.release (Exn.capture f path before ignore (try File.rm path)) end;


(* tmp dirs *)

fun rm_tree path = scala_function "rm_tree" [path];

fun with_tmp_dir name f =
  let val path = create_tmp_path name ""
  in Exn.release (Exn.capture f (make_directory path) before ignore (try rm_tree path)) end;


(* download file *)

fun download url file =
  ignore (Scala.function_thread "download" (cat_strings0 [url, absolute_path file]));

end;
