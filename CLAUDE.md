# Lean proofs with Mathlib

This repository holds Lean 4 problems and informal proofs. You prove and formalize them with the
local Lean: `bin/check` runs `lake env lean` on a file and reports its errors, its `sorry`s and
its axioms. The project pins Lean 4.35.0 and Mathlib v4.35.0. Agents in Agentformers Workstations
can prove parts of a proof for you (see "Delegating to Workstations").

## Rules

1. Change only the proof. Keep each theorem's name and statement, the `-- expect:` line and the
   `import Mathlib` header exactly as committed. `bin/check --verify` compares the statement
   with the committed one.
2. You may add helper lemmas above the theorem.
3. Never use `sorry`, `admit`, a new `axiom`, `native_decide`, `#eval`, `run_cmd`, `set_option`
   that silences warnings, or other meta-code. `bin/check` refuses the first four through their
   axioms. The rest can fool the check, and this demo is about an honest proof.
4. Never run `lake update`, and never change `lakefile.toml`, `lake-manifest.json` or
   `lean-toolchain`. They pin the same Mathlib as the Workstations agents use.

## Workflow

1. `bin/check Problems/<File>.lean`. It prints each Lean message with its line, then `ok` or
   `FAILED` with the reasons. Each run loads Mathlib, which takes a few seconds.
2. To see the goal at a step, replace that `sorry` with `done`: Lean then reports the unsolved
   goal. Edit the proof, check again, and repeat.
3. To search Mathlib, put `exact?` or `apply?` in the proof and check: the output names a
   lemma. A search takes about a minute, so use it when you are stuck. Lemma sources are in
   `.lake/packages/mathlib/Mathlib`.
4. When `bin/check` prints `ok`, run `bin/check --verify Problems/<File>.lean`. The proof is
   done only when it prints `VERIFIED`.
5. Report the final proof and the `--verify` output.

If `bin/check` says that `lake` is not installed, or Lean cannot find Mathlib's files, tell the
user the setup in README.md. Do not install anything yourself.

## Formalize an informal proof

`Proofs/` holds proofs in ordinary mathematics. When the user asks you to formalize one, or runs
`/formalize Proofs/<file>.md`:

1. **State.** Read the proof. Write the theorem in Lean in a new file `Problems/<Name>.lean`:
   the header `import Mathlib`, a doc comment that quotes the theorem, `-- expect: <name>`, and
   the statement with `:= by sorry`. Choose types that match the text: ℤ for "every integer", ℕ
   for "every natural number". Run `bin/check`: the only reason must be that it uses sorry.
2. **Confirm.** Show the user the Lean statement, and say in one sentence how it matches the
   text. Ask the user to confirm it before you go on, unless the user said to go on without
   asking. No check can tell whether a statement means what the text means. Only a reader can.
3. **Branch.** `git switch -c formalize/<name>-<yyyymmdd-hhmm>`, and commit the statement alone.
   `--verify` compares every later version with the committed statement.
4. **Delegate.** Follow `.claude/commands/delegate.md` from step 2, on this branch. The lemmas
   are the steps of the informal proof, at most three, and the conclusion stays with you. Quote
   each step's text in its agent's task, so the agent formalizes that argument.
5. **Report.** Put the informal step and its Lean lemma side by side, then the final `--verify`
   output.

## Delegating to Workstations

`/delegate Problems/<File>.lean` plans a proof here and gives its lemmas to agents in a
Workstations workstation of the type `lean`. The steps are in `.claude/commands/delegate.md`. It
needs the MCP server `workstations`, and the Workstations GitHub App must have access to this
repository.

- One workstation is one sandbox with Lean and Mathlib. All agents in it share it.
- At most three `lean` agents run at once. Give each agent one lemma in its own file, so their
  branches never conflict.
- Each agent's work arrives on the branch `ws/<agent-id>`. Workstations trusts the agent's own
  check. Run `bin/check --verify` on every lemma here before you use it.
- Destroy the workstation when the work is done, also after a failure.

## Inside a workstation

You are a Workstations agent when `command -v lean-check` finds the command. Then:

1. Check with `lean-check --timeout 300 --expect <name> <file>`. Do not run `bin/check` or
   `lake` in the repository: the workstation has no network, and Lake would try to fetch
   Mathlib. `lean-check` uses the workstation's own Mathlib, the same version as this project.
2. Read `/opt/lean/SKILL.md` before the first check.
3. Change only the file that your task names, and only the proof in it. The rules above apply.
4. Other agents can use the same Lean server, so a check can wait for theirs.
5. Commit the file when `lean-check` prints `ok`, and put the proof in your result.
