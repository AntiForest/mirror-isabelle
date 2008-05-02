(* $Id$ *)

theory "syntax"
imports CPure
begin

chapter {* Syntax primitives *}

text {*
  The rather generic framework of Isabelle/Isar syntax emerges from
  three main syntactic categories: \emph{commands} of the top-level
  Isar engine (covering theory and proof elements), \emph{methods} for
  general goal refinements (analogous to traditional ``tactics''), and
  \emph{attributes} for operations on facts (within a certain
  context).  Subsequently we give a reference of basic syntactic
  entities underlying Isabelle/Isar syntax in a bottom-up manner.
  Concrete theory and proof language elements will be introduced later
  on.

  \medskip In order to get started with writing well-formed
  Isabelle/Isar documents, the most important aspect to be noted is
  the difference of \emph{inner} versus \emph{outer} syntax.  Inner
  syntax is that of Isabelle types and terms of the logic, while outer
  syntax is that of Isabelle/Isar theory sources (specifications and
  proofs).  As a general rule, inner syntax entities may occur only as
  \emph{atomic entities} within outer syntax.  For example, the string
  @{verbatim "\"x + y\""} and identifier @{verbatim z} are legal term
  specifications within a theory, while @{verbatim "x + y"} without
  quotes is not.

  Printed theory documents usually omit quotes to gain readability
  (this is a matter of {\LaTeX} macro setup, say via @{verbatim
  "\\isabellestyle"}, see also \cite{isabelle-sys}).  Experienced
  users of Isabelle/Isar may easily reconstruct the lost technical
  information, while mere readers need not care about quotes at all.

  \medskip Isabelle/Isar input may contain any number of input
  termination characters ``@{verbatim ";"}'' (semicolon) to separate
  commands explicitly.  This is particularly useful in interactive
  shell sessions to make clear where the current command is intended
  to end.  Otherwise, the interpreter loop will continue to issue a
  secondary prompt ``@{verbatim "#"}'' until an end-of-command is
  clearly recognized from the input syntax, e.g.\ encounter of the
  next command keyword.

  More advanced interfaces such as Proof~General \cite{proofgeneral}
  do not require explicit semicolons, the amount of input text is
  determined automatically by inspecting the present content of the
  Emacs text buffer.  In the printed presentation of Isabelle/Isar
  documents semicolons are omitted altogether for readability.

  \begin{warn}
    Proof~General requires certain syntax classification tables in
    order to achieve properly synchronized interaction with the
    Isabelle/Isar process.  These tables need to be consistent with
    the Isabelle version and particular logic image to be used in a
    running session (common object-logics may well change the outer
    syntax).  The standard setup should work correctly with any of the
    ``official'' logic images derived from Isabelle/HOL (including
    HOLCF etc.).  Users of alternative logics may need to tell
    Proof~General explicitly, e.g.\ by giving an option @{verbatim "-k ZF"}
    (in conjunction with @{verbatim "-l ZF"}, to specify the default
    logic image).  Note that option @{verbatim "-L"} does both
    of this at the same time.
  \end{warn}
*}


section {* Lexical matters \label{sec:lex-syntax} *}

text {*
  The Isabelle/Isar outer syntax provides token classes as presented
  below; most of these coincide with the inner lexical syntax as
  presented in \cite{isabelle-ref}.

  \begin{matharray}{rcl}
    @{syntax_def ident} & = & letter\,quasiletter^* \\
    @{syntax_def longident} & = & ident (\verb,.,ident)^+ \\
    @{syntax_def symident} & = & sym^+ ~|~ \verb,\,\verb,<,ident\verb,>, \\
    @{syntax_def nat} & = & digit^+ \\
    @{syntax_def var} & = & ident ~|~ \verb,?,ident ~|~ \verb,?,ident\verb,.,nat \\
    @{syntax_def typefree} & = & \verb,',ident \\
    @{syntax_def typevar} & = & typefree ~|~ \verb,?,typefree ~|~ \verb,?,typefree\verb,.,nat \\
    @{syntax_def string} & = & \verb,", ~\dots~ \verb,", \\
    @{syntax_def altstring} & = & \backquote ~\dots~ \backquote \\
    @{syntax_def verbatim} & = & \verb,{*, ~\dots~ \verb,*,\verb,}, \\[1ex]

    letter & = & latin ~|~ \verb,\,\verb,<,latin\verb,>, ~|~ \verb,\,\verb,<,latin\,latin\verb,>, ~|~ greek ~|~ \\
           &   & \verb,\<^isub>, ~|~ \verb,\<^isup>, \\
    quasiletter & = & letter ~|~ digit ~|~ \verb,_, ~|~ \verb,', \\
    latin & = & \verb,a, ~|~ \dots ~|~ \verb,z, ~|~ \verb,A, ~|~ \dots ~|~ \verb,Z, \\
    digit & = & \verb,0, ~|~ \dots ~|~ \verb,9, \\
    sym & = & \verb,!, ~|~ \verb,#, ~|~ \verb,$, ~|~ \verb,%, ~|~ \verb,&, ~|~
     \verb,*, ~|~ \verb,+, ~|~ \verb,-, ~|~ \verb,/, ~|~ \\
    & & \verb,<, ~|~ \verb,=, ~|~ \verb,>, ~|~ \verb,?, ~|~ \texttt{\at} ~|~
    \verb,^, ~|~ \verb,_, ~|~ \verb,|, ~|~ \verb,~, \\
    greek & = & \verb,\<alpha>, ~|~ \verb,\<beta>, ~|~ \verb,\<gamma>, ~|~ \verb,\<delta>, ~| \\
          &   & \verb,\<epsilon>, ~|~ \verb,\<zeta>, ~|~ \verb,\<eta>, ~|~ \verb,\<theta>, ~| \\
          &   & \verb,\<iota>, ~|~ \verb,\<kappa>, ~|~ \verb,\<mu>, ~|~ \verb,\<nu>, ~| \\
          &   & \verb,\<xi>, ~|~ \verb,\<pi>, ~|~ \verb,\<rho>, ~|~ \verb,\<sigma>, ~|~ \verb,\<tau>, ~| \\
          &   & \verb,\<upsilon>, ~|~ \verb,\<phi>, ~|~ \verb,\<chi>, ~|~ \verb,\<psi>, ~| \\
          &   & \verb,\<omega>, ~|~ \verb,\<Gamma>, ~|~ \verb,\<Delta>, ~|~ \verb,\<Theta>, ~| \\
          &   & \verb,\<Lambda>, ~|~ \verb,\<Xi>, ~|~ \verb,\<Pi>, ~|~ \verb,\<Sigma>, ~| \\
          &   & \verb,\<Upsilon>, ~|~ \verb,\<Phi>, ~|~ \verb,\<Psi>, ~|~ \verb,\<Omega>, \\
  \end{matharray}

  The syntax of @{syntax string} admits any characters, including
  newlines; ``@{verbatim "\""}'' (double-quote) and ``@{verbatim
  "\\"}'' (backslash) need to be escaped by a backslash; arbitrary
  character codes may be specified as ``@{verbatim "\\"}@{text ddd}'',
  with three decimal digits.  Alternative strings according to
  @{syntax altstring} are analogous, using single back-quotes instead.
  The body of @{syntax verbatim} may consist of any text not
  containing ``@{verbatim "*"}@{verbatim "}"}''; this allows
  convenient inclusion of quotes without further escapes.  The greek
  letters do \emph{not} include @{verbatim "\<lambda>"}, which is already used
  differently in the meta-logic.

  Common mathematical symbols such as @{text \<forall>} are represented in
  Isabelle as @{verbatim \<forall>}.  There are infinitely many Isabelle
  symbols like this, although proper presentation is left to front-end
  tools such as {\LaTeX} or Proof~General with the X-Symbol package.
  A list of standard Isabelle symbols that work well with these tools
  is given in \cite[appendix~A]{isabelle-sys}.
  
  Source comments take the form @{verbatim "(*"}~@{text
  "\<dots>"}~@{verbatim "*)"} and may be nested, although user-interface
  tools might prevent this.  Note that this form indicates source
  comments only, which are stripped after lexical analysis of the
  input.  The Isar document syntax also provides formal comments that
  are considered as part of the text (see \secref{sec:comments}).
*}


section {* Common syntax entities *}

text {*
  We now introduce several basic syntactic entities, such as names,
  terms, and theorem specifications, which are factored out of the
  actual Isar language elements to be described later.
*}


subsection {* Names *}

text {*
  Entity \railqtok{name} usually refers to any name of types,
  constants, theorems etc.\ that are to be \emph{declared} or
  \emph{defined} (so qualified identifiers are excluded here).  Quoted
  strings provide an escape for non-identifier names or those ruled
  out by outer syntax keywords (e.g.\ quoted @{verbatim "\"let\""}).
  Already existing objects are usually referenced by
  \railqtok{nameref}.

  \indexoutertoken{name}\indexoutertoken{parname}\indexoutertoken{nameref}
  \indexoutertoken{int}
  \begin{rail}
    name: ident | symident | string | nat
    ;
    parname: '(' name ')'
    ;
    nameref: name | longident
    ;
    int: nat | '-' nat
    ;
  \end{rail}
*}


subsection {* Comments \label{sec:comments} *}

text {*
  Large chunks of plain \railqtok{text} are usually given
  \railtok{verbatim}, i.e.\ enclosed in @{verbatim "{"}@{verbatim
  "*"}~@{text "\<dots>"}~@{verbatim "*"}@{verbatim "}"}.  For convenience,
  any of the smaller text units conforming to \railqtok{nameref} are
  admitted as well.  A marginal \railnonterm{comment} is of the form
  @{verbatim "--"} \railqtok{text}.  Any number of these may occur
  within Isabelle/Isar commands.

  \indexoutertoken{text}\indexouternonterm{comment}
  \begin{rail}
    text: verbatim | nameref
    ;
    comment: '--' text
    ;
  \end{rail}
*}


subsection {* Type classes, sorts and arities *}

text {*
  Classes are specified by plain names.  Sorts have a very simple
  inner syntax, which is either a single class name @{text c} or a
  list @{text "{c\<^sub>1, \<dots>, c\<^sub>n}"} referring to the
  intersection of these classes.  The syntax of type arities is given
  directly at the outer level.

  \railalias{subseteq}{\isasymsubseteq}
  \railterm{subseteq}

  \indexouternonterm{sort}\indexouternonterm{arity}
  \indexouternonterm{classdecl}
  \begin{rail}
    classdecl: name (('<' | subseteq) (nameref + ','))?
    ;
    sort: nameref
    ;
    arity: ('(' (sort + ',') ')')? sort
    ;
  \end{rail}
*}


subsection {* Types and terms \label{sec:types-terms} *}

text {*
  The actual inner Isabelle syntax, that of types and terms of the
  logic, is far too sophisticated in order to be modelled explicitly
  at the outer theory level.  Basically, any such entity has to be
  quoted to turn it into a single token (the parsing and type-checking
  is performed internally later).  For convenience, a slightly more
  liberal convention is adopted: quotes may be omitted for any type or
  term that is already atomic at the outer level.  For example, one
  may just write @{verbatim x} instead of quoted @{verbatim "\"x\""}.
  Note that symbolic identifiers (e.g.\ @{verbatim "++"} or @{text
  "\<forall>"} are available as well, provided these have not been superseded
  by commands or other keywords already (such as @{verbatim "="} or
  @{verbatim "+"}).

  \indexoutertoken{type}\indexoutertoken{term}\indexoutertoken{prop}
  \begin{rail}
    type: nameref | typefree | typevar
    ;
    term: nameref | var
    ;
    prop: term
    ;
  \end{rail}

  Positional instantiations are indicated by giving a sequence of
  terms, or the placeholder ``@{text _}'' (underscore), which means to
  skip a position.

  \indexoutertoken{inst}\indexoutertoken{insts}
  \begin{rail}
    inst: underscore | term
    ;
    insts: (inst *)
    ;
  \end{rail}

  Type declarations and definitions usually refer to
  \railnonterm{typespec} on the left-hand side.  This models basic
  type constructor application at the outer syntax level.  Note that
  only plain postfix notation is available here, but no infixes.

  \indexouternonterm{typespec}
  \begin{rail}
    typespec: (() | typefree | '(' ( typefree + ',' ) ')') name
    ;
  \end{rail}
*}


subsection {* Mixfix annotations *}

text {*
  Mixfix annotations specify concrete \emph{inner} syntax of Isabelle
  types and terms.  Some commands such as @{command "types"} (see
  \secref{sec:types-pure}) admit infixes only, while @{command
  "consts"} (see \secref{sec:consts}) and @{command "syntax"} (see
  \secref{sec:syn-trans}) support the full range of general mixfixes
  and binders.

  \indexouternonterm{infix}\indexouternonterm{mixfix}\indexouternonterm{structmixfix}
  \begin{rail}
    infix: '(' ('infix' | 'infixl' | 'infixr') string? nat ')'
    ;
    mixfix: infix | '(' string prios? nat? ')' | '(' 'binder' string prios? nat ')'
    ;
    structmixfix: mixfix | '(' 'structure' ')'
    ;

    prios: '[' (nat + ',') ']'
    ;
  \end{rail}

  Here the \railtok{string} specifications refer to the actual mixfix
  template (see also \cite{isabelle-ref}), which may include literal
  text, spacing, blocks, and arguments (denoted by ``@{text _}''); the
  special symbol ``@{verbatim "\<index>"}'' (printed as ``@{text "\<index>"}'')
  represents an index argument that specifies an implicit structure
  reference (see also \secref{sec:locale}).  Infix and binder
  declarations provide common abbreviations for particular mixfix
  declarations.  So in practice, mixfix templates mostly degenerate to
  literal text for concrete syntax, such as ``@{verbatim "++"}'' for
  an infix symbol, or ``@{verbatim "++"}@{text "\<index>"}'' for an infix of
  an implicit structure.
*}


subsection {* Proof methods \label{sec:syn-meth} *}

text {*
  Proof methods are either basic ones, or expressions composed of
  methods via ``@{verbatim ","}'' (sequential composition),
  ``@{verbatim "|"}'' (alternative choices), ``@{verbatim "?"}'' 
  (try), ``@{verbatim "+"}'' (repeat at least once), ``@{verbatim
  "["}@{text n}@{verbatim "]"}'' (restriction to first @{text n}
  sub-goals, with default @{text "n = 1"}).  In practice, proof
  methods are usually just a comma separated list of
  \railqtok{nameref}~\railnonterm{args} specifications.  Note that
  parentheses may be dropped for single method specifications (with no
  arguments).

  \indexouternonterm{method}
  \begin{rail}
    method: (nameref | '(' methods ')') (() | '?' | '+' | '[' nat? ']')
    ;
    methods: (nameref args | method) + (',' | '|')
    ;
  \end{rail}

  Proper Isar proof methods do \emph{not} admit arbitrary goal
  addressing, but refer either to the first sub-goal or all sub-goals
  uniformly.  The goal restriction operator ``@{text "[n]"}''
  evaluates a method expression within a sandbox consisting of the
  first @{text n} sub-goals (which need to exist).  For example, the
  method ``@{text "simp_all[3]"}'' simplifies the first three
  sub-goals, while ``@{text "(rule foo, simp_all)[]"}'' simplifies all
  new goals that emerge from applying rule @{text "foo"} to the
  originally first one.

  Improper methods, notably tactic emulations, offer a separate
  low-level goal addressing scheme as explicit argument to the
  individual tactic being involved.  Here ``@{text "[!]"}'' refers to
  all goals, and ``@{text "[n-]"}'' to all goals starting from @{text
  "n"}.

  \indexouternonterm{goalspec}
  \begin{rail}
    goalspec: '[' (nat '-' nat | nat '-' | nat | '!' ) ']'
    ;
  \end{rail}
*}


subsection {* Attributes and theorems \label{sec:syn-att} *}

text {*
  Attributes (and proof methods, see \secref{sec:syn-meth}) have their
  own ``semi-inner'' syntax, in the sense that input conforming to
  \railnonterm{args} below is parsed by the attribute a second time.
  The attribute argument specifications may be any sequence of atomic
  entities (identifiers, strings etc.), or properly bracketed argument
  lists.  Below \railqtok{atom} refers to any atomic entity, including
  any \railtok{keyword} conforming to \railtok{symident}.

  \indexoutertoken{atom}\indexouternonterm{args}\indexouternonterm{attributes}
  \begin{rail}
    atom: nameref | typefree | typevar | var | nat | keyword
    ;
    arg: atom | '(' args ')' | '[' args ']'
    ;
    args: arg *
    ;
    attributes: '[' (nameref args * ',') ']'
    ;
  \end{rail}

  Theorem specifications come in several flavors:
  \railnonterm{axmdecl} and \railnonterm{thmdecl} usually refer to
  axioms, assumptions or results of goal statements, while
  \railnonterm{thmdef} collects lists of existing theorems.  Existing
  theorems are given by \railnonterm{thmref} and
  \railnonterm{thmrefs}, the former requires an actual singleton
  result.

  There are three forms of theorem references:
  \begin{enumerate}
  
  \item named facts @{text "a"},

  \item selections from named facts @{text "a(i)"} or @{text "a(j - k)"},

  \item literal fact propositions using @{syntax_ref altstring} syntax
  @{verbatim "`"}@{text "\<phi>"}@{verbatim "`"} (see also method
  @{method_ref fact} in \secref{sec:pure-meth-att}).

  \end{enumerate}

  Any kind of theorem specification may include lists of attributes
  both on the left and right hand sides; attributes are applied to any
  immediately preceding fact.  If names are omitted, the theorems are
  not stored within the theorem database of the theory or proof
  context, but any given attributes are applied nonetheless.

  An extra pair of brackets around attributes (like ``@{text
  "[[simproc a]]"}'') abbreviates a theorem reference involving an
  internal dummy fact, which will be ignored later on.  So only the
  effect of the attribute on the background context will persist.
  This form of in-place declarations is particularly useful with
  commands like @{command "declare"} and @{command "using"}.

  \indexouternonterm{axmdecl}\indexouternonterm{thmdecl}
  \indexouternonterm{thmdef}\indexouternonterm{thmref}
  \indexouternonterm{thmrefs}\indexouternonterm{selection}
  \begin{rail}
    axmdecl: name attributes? ':'
    ;
    thmdecl: thmbind ':'
    ;
    thmdef: thmbind '='
    ;
    thmref: (nameref selection? | altstring) attributes? | '[' attributes ']'
    ;
    thmrefs: thmref +
    ;

    thmbind: name attributes | name | attributes
    ;
    selection: '(' ((nat | nat '-' nat?) + ',') ')'
    ;
  \end{rail}
*}


subsection {* Term patterns and declarations \label{sec:term-decls} *}

text {*
  Wherever explicit propositions (or term fragments) occur in a proof
  text, casual binding of schematic term variables may be given
  specified via patterns of the form ``@{text "(\<IS> p\<^sub>1 \<dots>
  p\<^sub>n)"}''.  This works both for \railqtok{term} and \railqtok{prop}.

  \indexouternonterm{termpat}\indexouternonterm{proppat}
  \begin{rail}
    termpat: '(' ('is' term +) ')'
    ;
    proppat: '(' ('is' prop +) ')'
    ;
  \end{rail}

  \medskip Declarations of local variables @{text "x :: \<tau>"} and
  logical propositions @{text "a : \<phi>"} represent different views on
  the same principle of introducing a local scope.  In practice, one
  may usually omit the typing of \railnonterm{vars} (due to
  type-inference), and the naming of propositions (due to implicit
  references of current facts).  In any case, Isar proof elements
  usually admit to introduce multiple such items simultaneously.

  \indexouternonterm{vars}\indexouternonterm{props}
  \begin{rail}
    vars: (name+) ('::' type)?
    ;
    props: thmdecl? (prop proppat? +)
    ;
  \end{rail}

  The treatment of multiple declarations corresponds to the
  complementary focus of \railnonterm{vars} versus
  \railnonterm{props}.  In ``@{text "x\<^sub>1 \<dots> x\<^sub>n :: \<tau>"}''
  the typing refers to all variables, while in @{text "a: \<phi>\<^sub>1 \<dots>
  \<phi>\<^sub>n"} the naming refers to all propositions collectively.
  Isar language elements that refer to \railnonterm{vars} or
  \railnonterm{props} typically admit separate typings or namings via
  another level of iteration, with explicit @{keyword_ref "and"}
  separators; e.g.\ see @{command "fix"} and @{command "assume"} in
  \secref{sec:proof-context}.
*}


subsection {* Antiquotations \label{sec:antiq} *}

text {*
  \begin{matharray}{rcl}
    @{antiquotation_def "theory"} & : & \isarantiq \\
    @{antiquotation_def "thm"} & : & \isarantiq \\
    @{antiquotation_def "prop"} & : & \isarantiq \\
    @{antiquotation_def "term"} & : & \isarantiq \\
    @{antiquotation_def const} & : & \isarantiq \\
    @{antiquotation_def abbrev} & : & \isarantiq \\
    @{antiquotation_def typeof} & : & \isarantiq \\
    @{antiquotation_def typ} & : & \isarantiq \\
    @{antiquotation_def thm_style} & : & \isarantiq \\
    @{antiquotation_def term_style} & : & \isarantiq \\
    @{antiquotation_def "text"} & : & \isarantiq \\
    @{antiquotation_def goals} & : & \isarantiq \\
    @{antiquotation_def subgoals} & : & \isarantiq \\
    @{antiquotation_def prf} & : & \isarantiq \\
    @{antiquotation_def full_prf} & : & \isarantiq \\
    @{antiquotation_def ML} & : & \isarantiq \\
    @{antiquotation_def ML_type} & : & \isarantiq \\
    @{antiquotation_def ML_struct} & : & \isarantiq \\
  \end{matharray}

  The text body of formal comments (see also \secref{sec:comments})
  may contain antiquotations of logical entities, such as theorems,
  terms and types, which are to be presented in the final output
  produced by the Isabelle document preparation system (see also
  \secref{sec:document-prep}).

  Thus embedding of ``@{text "@{term [show_types] \"f x = a + x\"}"}''
  within a text block would cause
  \isa{{\isacharparenleft}f{\isasymColon}{\isacharprime}a\ {\isasymRightarrow}\ {\isacharprime}a{\isacharparenright}\ {\isacharparenleft}x{\isasymColon}{\isacharprime}a{\isacharparenright}\ {\isacharequal}\ {\isacharparenleft}a{\isasymColon}{\isacharprime}a{\isacharparenright}\ {\isacharplus}\ x} to appear in the final {\LaTeX} document.  Also note that theorem
  antiquotations may involve attributes as well.  For example,
  @{text "@{thm sym [no_vars]}"} would print the theorem's
  statement where all schematic variables have been replaced by fixed
  ones, which are easier to read.

  \begin{rail}
    atsign lbrace antiquotation rbrace
    ;

    antiquotation:
      'theory' options name |
      'thm' options thmrefs |
      'prop' options prop |
      'term' options term |
      'const' options term |
      'abbrev' options term |
      'typeof' options term |
      'typ' options type |
      'thm\_style' options name thmref |
      'term\_style' options name term |
      'text' options name |
      'goals' options |
      'subgoals' options |
      'prf' options thmrefs |
      'full\_prf' options thmrefs |
      'ML' options name |
      'ML\_type' options name |
      'ML\_struct' options name
    ;
    options: '[' (option * ',') ']'
    ;
    option: name | name '=' name
    ;
  \end{rail}

  Note that the syntax of antiquotations may \emph{not} include source
  comments @{verbatim "(*"}~@{text "\<dots>"}~@{verbatim "*)"} or verbatim
  text @{verbatim "{"}@{verbatim "*"}~@{text "\<dots>"}~@{verbatim
  "*"}@{verbatim "}"}.

  \begin{descr}
  
  \item [@{text "@{theory A}"}] prints the name @{text "A"}, which is
  guaranteed to refer to a valid ancestor theory in the current
  context.

  \item [@{text "@{thm a\<^sub>1 \<dots> a\<^sub>n}"}] prints theorems
  @{text "a\<^sub>1 \<dots> a\<^sub>n"}.  Note that attribute specifications
  may be included as well (see also \secref{sec:syn-att}); the
  @{attribute_ref no_vars} rule (see \secref{sec:misc-meth-att}) would
  be particularly useful to suppress printing of schematic variables.

  \item [@{text "@{prop \<phi>}"}] prints a well-typed proposition @{text
  "\<phi>"}.

  \item [@{text "@{term t}"}] prints a well-typed term @{text "t"}.

  \item [@{text "@{const c}"}] prints a logical or syntactic constant
  @{text "c"}.
  
  \item [@{text "@{abbrev c x\<^sub>1 \<dots> x\<^sub>n}"}] prints a constant
  abbreviation @{text "c x\<^sub>1 \<dots> x\<^sub>n \<equiv> rhs"} as defined in
  the current context.

  \item [@{text "@{typeof t}"}] prints the type of a well-typed term
  @{text "t"}.

  \item [@{text "@{typ \<tau>}"}] prints a well-formed type @{text "\<tau>"}.
  
  \item [@{text "@{thm_style s a}"}] prints theorem @{text a},
  previously applying a style @{text s} to it (see below).
  
  \item [@{text "@{term_style s t}"}] prints a well-typed term @{text
  t} after applying a style @{text s} to it (see below).

  \item [@{text "@{text s}"}] prints uninterpreted source text @{text
  s}.  This is particularly useful to print portions of text according
  to the Isabelle {\LaTeX} output style, without demanding
  well-formedness (e.g.\ small pieces of terms that should not be
  parsed or type-checked yet).

  \item [@{text "@{goals}"}] prints the current \emph{dynamic} goal
  state.  This is mainly for support of tactic-emulation scripts
  within Isar --- presentation of goal states does not conform to
  actual human-readable proof documents.

  Please do not include goal states into document output unless you
  really know what you are doing!
  
  \item [@{text "@{subgoals}"}] is similar to @{text "@{goals}"}, but
  does not print the main goal.
  
  \item [@{text "@{prf a\<^sub>1 \<dots> a\<^sub>n}"}] prints the (compact)
  proof terms corresponding to the theorems @{text "a\<^sub>1 \<dots>
  a\<^sub>n"}. Note that this requires proof terms to be switched on
  for the current object logic (see the ``Proof terms'' section of the
  Isabelle reference manual for information on how to do this).
  
  \item [@{text "@{full_prf a\<^sub>1 \<dots> a\<^sub>n}"}] is like @{text
  "@{prf a\<^sub>1 \<dots> a\<^sub>n}"}, but displays the full proof terms,
  i.e.\ also displays information omitted in the compact proof term,
  which is denoted by ``@{text _}'' placeholders there.
  
  \item [@{text "@{ML s}"}, @{text "@{ML_type s}"}, and @{text
  "@{ML_struct s}"}] check text @{text s} as ML value, type, and
  structure, respectively.  The source is displayed verbatim.

  \end{descr}

  \medskip The following standard styles for use with @{text
  thm_style} and @{text term_style} are available:

  \begin{descr}
  
  \item [@{text lhs}] extracts the first argument of any application
  form with at least two arguments -- typically meta-level or
  object-level equality, or any other binary relation.
  
  \item [@{text rhs}] is like @{text lhs}, but extracts the second
  argument.
  
  \item [@{text "concl"}] extracts the conclusion @{text C} from a rule
  in Horn-clause normal form @{text "A\<^sub>1 \<Longrightarrow> \<dots> A\<^sub>n \<Longrightarrow> C"}.
  
  \item [@{text "prem1"}, \dots, @{text "prem9"}] extract premise
  number @{text "1, \<dots>, 9"}, respectively, from from a rule in
  Horn-clause normal form @{text "A\<^sub>1 \<Longrightarrow> \<dots> A\<^sub>n \<Longrightarrow> C"}

  \end{descr}

  \medskip
  The following options are available to tune the output.  Note that most of
  these coincide with ML flags of the same names (see also \cite{isabelle-ref}).

  \begin{descr}

  \item[@{text "show_types = bool"} and @{text "show_sorts = bool"}]
  control printing of explicit type and sort constraints.

  \item[@{text "show_structs = bool"}] controls printing of implicit
  structures.

  \item[@{text "long_names = bool"}] forces names of types and
  constants etc.\ to be printed in their fully qualified internal
  form.

  \item[@{text "short_names = bool"}] forces names of types and
  constants etc.\ to be printed unqualified.  Note that internalizing
  the output again in the current context may well yield a different
  result.

  \item[@{text "unique_names = bool"}] determines whether the printed
  version of qualified names should be made sufficiently long to avoid
  overlap with names declared further back.  Set to @{text false} for
  more concise output.

  \item[@{text "eta_contract = bool"}] prints terms in @{text
  \<eta>}-contracted form.

  \item[@{text "display = bool"}] indicates if the text is to be
  output as multi-line ``display material'', rather than a small piece
  of text without line breaks (which is the default).

  \item[@{text "break = bool"}] controls line breaks in non-display
  material.

  \item[@{text "quotes = bool"}] indicates if the output should be
  enclosed in double quotes.

  \item[@{text "mode = name"}] adds @{text name} to the print mode to
  be used for presentation (see also \cite{isabelle-ref}).  Note that
  the standard setup for {\LaTeX} output is already present by
  default, including the modes @{text latex} and @{text xsymbols}.

  \item[@{text "margin = nat"} and @{text "indent = nat"}] change the
  margin or indentation for pretty printing of display material.

  \item[@{text "source = bool"}] prints the source text of the
  antiquotation arguments, rather than the actual value.  Note that
  this does not affect well-formedness checks of @{antiquotation
  "thm"}, @{antiquotation "term"}, etc. (only the @{antiquotation
  "text"} antiquotation admits arbitrary output).

  \item[@{text "goals_limit = nat"}] determines the maximum number of
  goals to be printed.

  \item[@{text "locale = name"}] specifies an alternative locale
  context used for evaluating and printing the subsequent argument.

  \end{descr}

  For boolean flags, ``@{text "name = true"}'' may be abbreviated as
  ``@{text name}''.  All of the above flags are disabled by default,
  unless changed from ML.

  \medskip Note that antiquotations do not only spare the author from
  tedious typing of logical entities, but also achieve some degree of
  consistency-checking of informal explanations with formal
  developments: well-formedness of terms and types with respect to the
  current theory or proof context is ensured here.
*}


subsection {* Tagged commands \label{sec:tags} *}

text {*
  Each Isabelle/Isar command may be decorated by presentation tags:

  \indexouternonterm{tags}
  \begin{rail}
    tags: ( tag * )
    ;
    tag: '\%' (ident | string)
  \end{rail}

  The tags @{text "theory"}, @{text "proof"}, @{text "ML"} are already
  pre-declared for certain classes of commands:

 \medskip

  \begin{tabular}{ll}
    @{text "theory"} & theory begin/end \\
    @{text "proof"} & all proof commands \\
    @{text "ML"} & all commands involving ML code \\
  \end{tabular}

  \medskip The Isabelle document preparation system (see also
  \cite{isabelle-sys}) allows tagged command regions to be presented
  specifically, e.g.\ to fold proof texts, or drop parts of the text
  completely.

  For example ``@{command "by"}~@{text "%invisible auto"}'' would
  cause that piece of proof to be treated as @{text invisible} instead
  of @{text "proof"} (the default), which may be either show or hidden
  depending on the document setup.  In contrast, ``@{command
  "by"}~@{text "%visible auto"}'' would force this text to be shown
  invariably.

  Explicit tag specifications within a proof apply to all subsequent
  commands of the same level of nesting.  For example, ``@{command
  "proof"}~@{text "%visible \<dots>"}~@{command "qed"}'' would force the
  whole sub-proof to be typeset as @{text visible} (unless some of its
  parts are tagged differently).
*}

end
