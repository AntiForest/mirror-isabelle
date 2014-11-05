/*  Title:      Pure/Thy/thy_header.scala
    Author:     Makarius

Static theory header information.
*/

package isabelle


import scala.annotation.tailrec
import scala.collection.mutable
import scala.util.parsing.input.{Reader, CharSequenceReader}
import scala.util.matching.Regex


object Thy_Header extends Parse.Parser
{
  val HEADER = "header"
  val CHAPTER = "chapter"
  val SECTION = "section"
  val SUBSECTION = "subsection"
  val SUBSUBSECTION = "subsubsection"

  val THEORY = "theory"
  val IMPORTS = "imports"
  val KEYWORDS = "keywords"
  val AND = "and"
  val BEGIN = "begin"

  private val header_keywords =
    Keyword.Keywords.empty +
      "%" + "(" + ")" + "," + "::" + "==" + AND + BEGIN + IMPORTS + KEYWORDS +
      (HEADER, Keyword.HEADING) +
      (CHAPTER, Keyword.HEADING) +
      (SECTION, Keyword.HEADING) +
      (SUBSECTION, Keyword.HEADING) +
      (SUBSUBSECTION, Keyword.HEADING) +
      (THEORY, Keyword.THY_BEGIN)


  /* theory file name */

  private val Base_Name = new Regex(""".*?([^/\\:]+)""")
  private val Thy_Name = new Regex(""".*?([^/\\:]+)\.thy""")

  def base_name(s: String): String =
    s match { case Base_Name(name) => name case _ => error("Malformed import: " + quote(s)) }

  def thy_name(s: String): Option[String] =
    s match { case Thy_Name(name) => Some(name) case _ => None }


  /* header */

  val header: Parser[Thy_Header] =
  {
    val file_name = atom("file name", _.is_name)

    val opt_files =
      $$$("(") ~! (rep1sep(name, $$$(",")) <~ $$$(")")) ^^ { case _ ~ x => x } |
      success(Nil)
    val keyword_spec =
      atom("outer syntax keyword specification", _.is_name) ~ opt_files ~ tags ^^
      { case x ~ y ~ z => ((x, y), z) }

    val keyword_decl =
      rep1(string) ~
      opt($$$("::") ~! keyword_spec ^^ { case _ ~ x => x }) ~
      opt($$$("==") ~! name ^^ { case _ ~ x => x }) ^^
      { case xs ~ y ~ z => xs.map((_, y, z)) }
    val keyword_decls =
      keyword_decl ~ rep($$$(AND) ~! keyword_decl ^^ { case _ ~ x => x }) ^^
      { case xs ~ yss => (xs :: yss).flatten }

    val file =
      $$$("(") ~! (file_name ~ $$$(")")) ^^ { case _ ~ (x ~ _) => (x, false) } |
      file_name ^^ (x => (x, true))

    val args =
      theory_name ~
      (opt($$$(IMPORTS) ~! (rep1(theory_xname))) ^^
        { case None => Nil case Some(_ ~ xs) => xs }) ~
      (opt($$$(KEYWORDS) ~! keyword_decls) ^^
        { case None => Nil case Some(_ ~ xs) => xs }) ~
      $$$(BEGIN) ^^
      { case x ~ ys ~ zs ~ _ => Thy_Header(x, ys, zs) }

    val heading =
      (command(HEADER) |
        command(CHAPTER) |
        command(SECTION) |
        command(SUBSECTION) |
        command(SUBSUBSECTION)) ~
      tags ~! document_source

    (rep(heading) ~ command(THEORY) ~ tags) ~! args ^^ { case _ ~ x => x }
  }


  /* read -- lazy scanning */

  def read(reader: Reader[Char]): Thy_Header =
  {
    val token = Token.Parsers.token(header_keywords)
    val toks = new mutable.ListBuffer[Token]

    @tailrec def scan_to_begin(in: Reader[Char])
    {
      token(in) match {
        case Token.Parsers.Success(tok, rest) =>
          toks += tok
          if (!tok.is_begin) scan_to_begin(rest)
        case _ =>
      }
    }
    scan_to_begin(reader)

    parse(commit(header), Token.reader(toks.toList)) match {
      case Success(result, _) => result
      case bad => error(bad.toString)
    }
  }

  def read(source: CharSequence): Thy_Header =
    read(new CharSequenceReader(source))


  /* keywords */

  type Keywords = List[(String, Option[Keyword.Spec], Option[String])]
}


sealed case class Thy_Header(
  name: String,
  imports: List[String],
  keywords: Thy_Header.Keywords)
{
  def map(f: String => String): Thy_Header =
    Thy_Header(f(name), imports.map(f), keywords)

  def decode_symbols: Thy_Header =
  {
    val f = Symbol.decode _
    Thy_Header(f(name), imports.map(f),
      keywords.map({ case (a, b, c) =>
        (f(a), b.map({ case ((x, y), z) => ((f(x), y.map(f)), z.map(f)) }), c.map(f)) }))
  }
}

