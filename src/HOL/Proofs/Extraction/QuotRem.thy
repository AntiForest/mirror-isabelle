(*  Title:      HOL/Proofs/Extraction/QuotRem.thy
    Author:     Stefan Berghofer, TU Muenchen
*)

section \<open>Quotient and remainder\<close>

theory QuotRem
imports Util "HOL-Library.Realizers"
begin

text \<open>Derivation of quotient and remainder using program extraction.\<close>

theorem division: "\<exists>r q. a = Suc b * q + r \<and> r \<le> b"
proof (induct a)
  case 0
  have "0 = Suc b * 0 + 0 \<and> 0 \<le> b" by simp
  then show ?case by iprover
next
  case (Suc a)
  then obtain r q where I: "a = Suc b * q + r" and "r \<le> b" by iprover
  from nat_eq_dec show ?case
  proof
    assume "r = b"
    with I have "Suc a = Suc b * (Suc q) + 0 \<and> 0 \<le> b" by simp
    then show ?case by iprover
  next
    assume "r \<noteq> b"
    with \<open>r \<le> b\<close> have "r < b" by (simp add: order_less_le)
    with I have "Suc a = Suc b * q + (Suc r) \<and> (Suc r) \<le> b" by simp
    then show ?case by iprover
  qed
qed

extract division

text \<open>
  The program extracted from the above proof looks as follows
  @{thm [display] division_def [no_vars]}
  The corresponding correctness theorem is
  @{thm [display] division_correctness [no_vars]}
\<close>

lemma "division 9 2 = (0, 3)" by eval

end
