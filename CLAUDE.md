# Lean proofs in an Agentformers sandbox

This repository holds Lean 4 problems that import Mathlib. You prove them. Lean does not run on
this machine: `bin/lean-sandbox` sends each file to a sandbox of the Agentformers pool `lean`,
whose image holds Lean 4.35.0, a prebuilt Mathlib and `lean-check`.

## Rules

1. Change only the proof. Keep each theorem's name and statement, the `-- expect:` line and the
   `import Mathlib` header exactly as committed. `verify` compares the statement with the
   committed one.
2. You may add helper lemmas above the theorem.
3. Never use `sorry`, `admit`, a new `axiom`, `native_decide`, `#eval`, `run_cmd`, `set_option`
   that silences warnings, or other meta-code. `lean-check` refuses the first four. The rest can
   fool the check, and this demo is about an honest proof.
4. On your own machine, never run `lean`, `lake` or `elan`. Use `bin/lean-sandbox`. In a
   workstation, see "Inside a workstation" below.
5. Never print the API key or the contents of `AGENTFORMERS_API_KEY_FILE`.

## Workflow

1. `bin/lean-sandbox check Problems/<File>.lean`. The output gives each error and the goal at
   each `sorry`. The first check of a session loads Mathlib: 15 to 30 s. Later checks take about
   1 s.
2. Edit the proof, check again, and repeat. Read the goal before you choose a tactic.
3. To search Mathlib, put `exact?` or `apply?` in the proof and check: the output names a
   lemma. A search takes 35 to 70 s, so use it when you are stuck, not on every step. Use
   `bin/lean-sandbox exec 'grep -rn "theorem name" /opt/lean/.lake/packages/mathlib/Mathlib'`
   to read a lemma's source.
4. When `check` prints `ok`, run `bin/lean-sandbox verify Problems/<File>.lean`. It checks the
   file in a new sandbox and compares the statement with the committed one. The proof is done
   only when it prints `VERIFIED`.
5. Report the final proof and the `verify` output. Then run `bin/lean-sandbox stop`.

## Delegating to Workstations

`/delegate Problems/<File>.lean` plans a proof here and gives its lemmas to agents in a
Workstations workstation of the type `lean`. The steps are in `.claude/commands/delegate.md`. It
needs the MCP server `workstations`, and the Workstations GitHub App must have access to this
repository.

- One workstation is one sandbox of the pool `lean`. All agents in it share its Mathlib.
- At most three `lean` agents run at once. Give each agent one lemma in its own file, so their
  branches never conflict.
- Each agent's work arrives on the branch `ws/<agent-id>`. Workstations trusts the agent's own
  `lean-check`. Run `bin/lean-sandbox verify` on every lemma before you use it.
- Destroy the workstation when the work is done, also after a failure.

## Inside a workstation

You are inside a workstation when `command -v lean-check` finds the command. Then:

1. Run `lean-check --expect <name> <file>` directly. Do not use `bin/lean-sandbox`: it has no
   API key there, and it would start a second sandbox.
2. Read `/opt/lean/SKILL.md` before the first check.
3. Change only the file that your task names, and only the proof in it. The rules above apply.
4. Other agents can use the same Lean server. A check can wait for theirs, so give each check
   `--timeout 300`.
5. Commit the file when `lean-check` prints `ok`, and put the proof in your result.

## Errors of the call

- `set AGENTFORMERS_API_KEY or AGENTFORMERS_API_KEY_FILE`: ask the user for the key. Do not
  search for it.
- `HTTP 429 sandbox_quota_exceeded`: every place of the pool is in use. `verify` needs one
  place more than `check`. Run `bin/lean-sandbox stop`, then `verify` again.
- `lean-check: lake is not on PATH`: the node runs an old version. Tell the user.
- A check that runs past 300 s fails with a timeout. Split the proof into lemmas.
