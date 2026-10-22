import Mathlib

/-!
# Level 4: n⁵ − n is divisible by 30

For every integer n, 30 divides n⁵ − n. The statement splits into parts that can be proved
independently: 30 = 2 · 3 · 5, and the three factors are pairwise coprime. This is the problem
for `/delegate`, which gives each part to its own agent in a Workstations workstation.
-/

-- expect: thirty_dvd_pow_five_sub
theorem thirty_dvd_pow_five_sub (n : ℤ) : 30 ∣ n ^ 5 - n := by
  sorry
