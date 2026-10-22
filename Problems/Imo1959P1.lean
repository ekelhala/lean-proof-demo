import Mathlib

/-!
# Level 3: IMO 1959, Problem 1

Prove that the fraction (21n + 4) / (14n + 3) is irreducible for every natural number n.
The International Mathematical Olympiad set this problem in its first year.
-/

-- expect: imo1959_p1
theorem imo1959_p1 (n : ℕ) : Nat.gcd (21 * n + 4) (14 * n + 3) = 1 := by
  sorry
