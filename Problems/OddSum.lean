import Mathlib

/-!
# Level 1: the sum of the first odd numbers

1 + 3 + 5 + ⋯ + (2n − 1) = n². Induction on `n` with `Finset.sum_range_succ` proves it.
-/

-- expect: sum_first_odds
theorem sum_first_odds (n : ℕ) : ∑ i ∈ Finset.range n, (2 * i + 1) = n ^ 2 := by
  sorry
