# 30 divides n⁵ − n

**Theorem.** For every integer n, the number n⁵ − n is divisible by 30.

**Proof.** Since 30 = 2 · 3 · 5 and the numbers 2, 3 and 5 are pairwise coprime, it is enough
to show that each of them divides n⁵ − n.

First factor the expression:

  n⁵ − n = n (n⁴ − 1) = (n − 1) · n · (n + 1) · (n² + 1).

1. **Divisibility by 2.** Of the two consecutive integers n − 1 and n, one is even. So 2 divides
   the product, and therefore n⁵ − n.
2. **Divisibility by 3.** Of the three consecutive integers n − 1, n and n + 1, one is a multiple
   of 3. So 3 divides n⁵ − n.
3. **Divisibility by 5.** Consider the remainder of n modulo 5.
   - If n ≡ 0, then 5 divides the factor n.
   - If n ≡ 1, then 5 divides n − 1. If n ≡ 4, then 5 divides n + 1.
   - If n ≡ 2 or n ≡ 3, then n² ≡ 4, so 5 divides n² + 1.

   In every case 5 divides one of the factors, so 5 divides n⁵ − n.
4. **Conclusion.** 2 and 3 are coprime, so 6 divides n⁵ − n. Then 6 and 5 are coprime, so
   30 divides n⁵ − n. ∎
