# lean-proof-demo

Claude Code proves theorems in Lean 4 with Mathlib. Lean runs in an Agentformers sandbox. Your machine
needs no Lean, no Mathlib and no 11 GB of build files.

```text
 your machine                               Agentformers
 ┌──────────────────────────────┐   HTTPS   ┌──────────────────────────────────────────┐
 │ Claude Code                  │ ────────▶ │ engine  /v1/sandboxes                     │
 │   edits Problems/*.lean      │           │   pool `lean` on a ComputeLink node       │
 │   runs bin/lean-sandbox      │ ◀──────── │   image env-lean: Lean 4.35.0, Mathlib,   │
 │     check / verify           │  result   │   lean-check (kernel replay, axiom check) │
 └──────────────────────────────┘           └──────────────────────────────────────────┘
```

The idea comes from [kontti](https://github.com/l-oksanen/kontti), which runs Claude Code and Lean
in an Apptainer container on a shared host. Here Claude Code stays on your machine, and only the
checks go to the sandbox. The sandbox has no network.

## The problems

| Level | File | Theorem | What a proof needs |
|---|---|---|---|
| 1 | `Problems/OddSum.lean` | 1 + 3 + ⋯ + (2n − 1) = n² | Induction and `ring` |
| 2 | `Problems/Sqrt2.lean` | p² ≠ 2q² for q ≠ 0 | A bridge to `irrational_sqrt_two` through ℝ, or descent |
| 3 | `Problems/Imo1959P1.lean` | gcd(21n + 4, 14n + 3) = 1 (IMO 1959, Problem 1) | 3(14n + 3) − 2(21n + 4) = 1, and divisibility |

Each file states its theorem with `sorry`. The line `-- expect: NAME` names the theorem that the
check must find.

## What you need

- Claude Code, Python 3.10 or later, and git.
- An Agentformers API key with `sandboxes:read` and `sandboxes:write`, in a tenant that can use
  the pool `lean`. Create one in the console under **API keys**.

## Run the demo

```sh
git clone https://github.com/ekelhala/lean-proof-demo && cd lean-proof-demo
export AGENTFORMERS_API_KEY_FILE=~/.config/agentformers/key   # a file that holds the key
bin/lean-sandbox check Problems/OddSum.lean                   # the goal at the sorry
claude
```

In Claude Code:

```text
/prove Problems/Imo1959P1.lean
```

Claude Code says how it plans to prove the theorem, writes a proof, and checks it. It reads each
error and tries again until the check passes. Then it runs `verify`. `.claude/settings.json`
allows the `bin/lean-sandbox` commands, so the loop does not stop for a permission prompt.
Claude Code reads that file only in a trusted folder: accept the trust dialog at the first start.
A headless run (`claude -p`) in a new clone has no dialog, so name the commands yourself:

```sh
claude -p "/prove Problems/OddSum.lean" --permission-mode acceptEdits \
  --allowedTools "Bash(bin/lean-sandbox check:*)" "Bash(bin/lean-sandbox verify:*)" \
  "Bash(bin/lean-sandbox exec:*)" "Bash(bin/lean-sandbox stop)"
```

To start again: `git checkout Problems/` and `bin/lean-sandbox stop`.

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
3. It creates a workstation of the type `lean` in Agentformers Workstations. That is one
   sandbox of the pool `lean`, and it starts one agent for each step, at most three. Each agent
   gets its step's text and formalizes that argument with `lean-check`. Workstations pushes each
   agent's work to `ws/<agent-id>`. Claude Code relays what the agents report as they work.
4. Claude Code fetches every agent's branch and runs `verify` on each lemma itself. It trusts no
   agent's own check. Then it assembles the proof, verifies the whole theorem, destroys the
   workstation and shows each informal step next to its Lean lemma.

A run of `thirty-divides` took about 5 minutes. The three agents took 45 to 54 s each.

`/delegate Problems/<File>.lean` does steps 2 to 4 for a theorem that is already stated in Lean.

It needs:

- The MCP server `workstations` in Claude Code: `claude mcp add --transport http --scope user
  workstations <url> --header "Authorization: Bearer <key>"`, with a key from the Workstations
  **Access** page.
- The Workstations GitHub App, with access to this repository. The agents clone it and push to
  it.
- A trusted folder, so `.claude/settings.json` lets the run go on without permission prompts.

To reset after a demo, delete the run's branches: `formalize/…` and the agents' `ws/agent_…`.

## `bin/lean-sandbox`

| Command | What it does |
|---|---|
| `check FILE…` | Uploads the files to `/work/proj` of this working tree's sandbox, and runs `lean-check` on each. It creates the sandbox at the first call and keeps it for 30 minutes after the last call, so the Lean server stays warm |
| `verify FILE…` | Creates a new sandbox. It checks each file, and compares each theorem's type with the version of the last commit. It prints `VERIFIED` only for a proof of the committed statement. It destroys the sandbox at the end |
| `exec 'CMD'` | Runs a command in the sandbox, in `/work/proj` |
| `status`, `stop` | Shows the kept sandbox, or destroys it |

The exit code is `0` when every file passes, `1` when a file fails and `2` for an error of the
call. `AGENTFORMERS_API_URL` (default `https://engine.next.agentformers.fi`) and
`LEAN_SANDBOX_POOL` (default `lean`) change the target.

Times on the pool `lean` (bwrap, 3500 MiB, 1 CPU): the first check of a sandbox loads Mathlib
in 14 to 30 s. Later checks take 0.3 to 1 s. `exact?` takes 35 to 70 s. A `verify` takes about
15 s, because its new sandbox loads Mathlib again.

## What a pass means

`lean-check` passes a file when Lean elaborates it with no error, the kernel accepts every new
declaration again, and the declarations use no axiom but `propext`, `Classical.choice` and
`Quot.sound`. `verify` adds the check that the statement is the committed one.

This is a check for an honest prover. The file's own meta-code runs in the sandbox that checks
it, so a hostile file can defeat the check. `CLAUDE.md` forbids such code. A verdict that a third
party must trust needs a re-check of the bare file by a program that the file cannot touch.

## Build locally (optional)

The project pins the same Lean and Mathlib as the sandbox image, with the image's
`lake-manifest.json`. With [elan](https://github.com/leanprover/elan) installed:

```sh
lake exe cache get   # Mathlib's prebuilt .olean files, about 5 GB
lake build
```
