# The sum of the first cubes is the square of the sum

**Theorem (Nicomachus).** For every natural number n,

  1³ + 2³ + ⋯ + n³ = (1 + 2 + ⋯ + n)².

**Proof.**

1. **The sum of the first numbers.** 2 · (1 + 2 + ⋯ + n) = n (n + 1). By induction: the case
   n = 0 is 0 = 0, and adding n + 1 to both sides takes n (n + 1) to (n + 1)(n + 2).
2. **The sum of the first cubes.** 4 · (1³ + 2³ + ⋯ + n³) = n² (n + 1)². By induction: the case
   n = 0 is 0 = 0, and adding 4 (n + 1)³ takes n² (n + 1)² to (n + 1)² (n + 2)², because
   n² + 4 (n + 1) = (n + 2)².
3. **Conclusion.** By step 1, 4 · (1 + 2 + ⋯ + n)² = n² (n + 1)². By step 2, this equals
   4 · (1³ + 2³ + ⋯ + n³). Divide by 4. ∎
