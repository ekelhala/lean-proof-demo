# lean-proof-demo

Claude Code formalizes proofs in Lean 4 with Mathlib. It plans the proof and checks every step
with the local Lean. It hands the parts of a proof to agents in Agentformers Workstations,
which prove them in parallel.

```text
 your machine                                      Agentformers Workstations
 ┌──────────────────────────────────────┐   MCP    ┌──────────────────────────────────────┐
 │ Claude Code                          │ ───────▶ │ workstation `lean`: Lean + Mathlib   │
 │   states the theorem, plans lemmas   │          │   agent 1: lemma A ─┐                │
 │   checks with bin/check (local Lean) │          │   agent 2: lemma B ─┼─ lean-check    │
 │   verifies each agent's branch       │ ◀─────── │   agent 3: lemma C ─┘                │
 └──────────────────────────────────────┘  GitHub  └──────────────────────────────────────┘
                                         ws/<agent-id> branches
```

The idea comes from [kontti](https://github.com/l-oksanen/kontti), which runs Claude Code and Lean
in an Apptainer container on a shared host.

## Setup

1. Install [elan](https://github.com/leanprover/elan), the Lean toolchain manager.
2. In the repository, fetch Mathlib's prebuilt files (about 5 GB in `.lake`):

   ```sh
   lake exe cache get
   bin/check Problems/OddSum.lean    # FAILED: sum_first_odds uses sorry
   ```

   The first `lake` call also installs the toolchain of `lean-toolchain` (Lean 4.35.0). The
   project pins Mathlib v4.35.0 with the same `lake-manifest.json` as the Workstations image.
3. For the Workstations demo only:
   - add the MCP server `workstations` to Claude Code: `claude mcp add --transport http --scope
     user workstations <url> --header "Authorization: Bearer <key>"`, with a key from the
     Workstations **Access** page;
   - give the Workstations GitHub App access to this repository. The agents clone it and push to
     it.
4. Start `claude` in the repository once and accept the trust dialog. Claude Code reads
   `.claude/settings.json`, which allows `bin/check`, the Workstations tools and the git commands
   of the demo, only in a trusted folder.

## Formalize a proof with Workstations agents

The main demo. `Proofs/` holds proofs written in ordinary mathematics:

| File | Theorem | Steps for agents |
|---|---|---|
| `Proofs/thirty-divides.md` | 30 ∣ n⁵ − n for every integer n | 2, 3 and 5 divide it |
| `Proofs/nicomachus.md` | 1³ + ⋯ + n³ = (1 + ⋯ + n)² | the sum of the numbers, the sum of the cubes |

Start Claude Code in the repository and point it at a proof:

```text
Formalize Proofs/thirty-divides.md
```

(or `/formalize Proofs/thirty-divides.md`). Then watch:

1. Claude Code writes the theorem in Lean, checks that it parses, and asks you to confirm that the
   statement means what the text says. No check can decide that. Only a reader can.
2. It commits the statement to a branch `formalize/…`. It writes one Lean lemma file for each
   step of the proof, with `sorry`, and checks that the conclusion follows from the lemmas.
3. It creates a workstation of the type `lean` and starts one agent for each step, at most
   three. Each agent gets its step's text and formalizes that argument with `lean-check` in the
   workstation. Workstations pushes each agent's work to `ws/<agent-id>`. Claude Code relays
   what the agents report as they work.
4. Claude Code fetches every agent's branch and runs `bin/check --verify` on each lemma itself. It
   trusts no agent's own check. Then it assembles the proof, verifies the whole theorem, destroys
   the workstation and shows each informal step next to its Lean lemma.

A run of `thirty-divides` took about 5 minutes. The three agents took 55 to 85 s each.

`/delegate Problems/<File>.lean` does steps 2 to 4 for a theorem that is already stated in Lean.

To reset after a demo, delete the run's branches: `formalize/…` and the agents' `ws/agent_…`.

## Prove a problem alone

`Problems/` holds three problems stated in Lean with `sorry`, for Claude Code alone:

| Level | File | Theorem | What a proof needs |
|---|---|---|---|
| 1 | `Problems/OddSum.lean` | 1 + 3 + ⋯ + (2n − 1) = n² | Induction and `ring` |
| 2 | `Problems/Sqrt2.lean` | p² ≠ 2q² for q ≠ 0 | A bridge to `irrational_sqrt_two` through ℝ, or descent |
| 3 | `Problems/Imo1959P1.lean` | gcd(21n + 4, 14n + 3) = 1 (IMO 1959, Problem 1) | 3(14n + 3) − 2(21n + 4) = 1, and divisibility |

```text
/prove Problems/Imo1959P1.lean
```

To start again: `git checkout Problems/`.

## `bin/check`

```sh
bin/check Problems/OddSum.lean            # errors, sorry and axioms
bin/check --verify Problems/OddSum.lean   # also: the statement is the committed one
```

It runs `lake env lean` on a copy of each file, with `#print axioms` and `#check` added for each
`-- expect: NAME` line. A file passes (`ok`) when:

- Lean reports no error,
- the file declares each expected name,
- those declarations use no axiom but `propext`, `Classical.choice` and `Quot.sound`. A `sorry`
  shows as the axiom `sorryAx`.

`--verify` also compares each expected declaration's type with the version of the file in the
last commit, and prints `VERIFIED` only for a proof of the committed statement. The exit code is
`0` when every file passes, `1` when a file fails and `2` for an error of the call.

## What a pass means

This is a check for an honest prover. The file's own commands run in the Lean process that checks
it, so a hostile file can defeat the check. `CLAUDE.md` forbids such code. A verdict that a third
party must trust needs a re-check of the bare file by a program that the file cannot touch, such
as a kernel replay of the compiled `.olean`.
