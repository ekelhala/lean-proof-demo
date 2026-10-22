import Mathlib

/-!
# Level 2: the square root of 2 is irrational

No fraction p / q squares to 2: p² = 2q² has no solution with q ≠ 0. The statement is about
natural numbers, so Mathlib's `irrational_sqrt_two` (about the real number √2) does not close it
directly. A proof can bridge the two with casts to ℝ, or argue by infinite descent on q, or
compare the powers of 2 on both sides.
-/

-- expect: no_rational_sqrt_two
theorem no_rational_sqrt_two (p q : ℕ) (hq : q ≠ 0) : p ^ 2 ≠ 2 * q ^ 2 := by
  sorry
