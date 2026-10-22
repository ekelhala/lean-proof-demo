---
description: Plan a Lean proof, and delegate its lemmas to agents in a Workstations workstation
argument-hint: Problems/<File>.lean
---

Prove the theorem in $ARGUMENTS by planning it here and delegating the parts to Workstations
agents. Follow CLAUDE.md, section "Delegating to Workstations". Tell the user what you do at
each step, in one or two sentences, because this is a live demo.

1. **Plan.** Read $ARGUMENTS. Split the proof into two or three lemmas that agents can prove
   independently, and say the plan to the user. Workstations runs at most three `lean` agents at
   once.
2. **Skeleton.** For each lemma, write `Lemmas/<Problem>/<LemmaName>.lean`: the header
   `import Mathlib`, a doc comment with the idea, `-- expect: <lemma_name>`, and the statement
   with `:= by sorry`. In $ARGUMENTS, put the same lemma statements above the theorem (with
   `sorry`), and prove the theorem from them. Run `bin/lean-sandbox check` on all the files. Go
   on only when the only errors are the ones about `sorryAx`. Then run `bin/lean-sandbox stop`:
   the pool `lean` has few places, and the workstation and its agents need them.
3. **Branch.** `git switch -c delegate/<problem>-<yyyymmdd-hhmm>`, commit the skeleton, and
   `git push -u origin HEAD`. The agents start from this branch.
4. **Workstation.** Call `list_workstation_types` and check that `lean` is available. Call
   `create_workstation` with `workstation_type: "lean"`, `lifetime_s: 3600` and a label.
   Wait with `get_workstation` until its state is `ready`.
5. **Agents.** For each lemma, call `create_agent` with the workstation, `repository` (the
   `owner/name` of `git remote get-url origin`), `base_branch` (the new branch), and this task:

   > Prove the lemma `<lemma_name>` in `Lemmas/<Problem>/<LemmaName>.lean`. Change only the proof
   > in that file: keep the header, the doc comment, the `-- expect:` line and the statement.
   > Follow CLAUDE.md, section "Inside a workstation". Check with
   > `lean-check --expect <lemma_name> Lemmas/<Problem>/<LemmaName>.lean` until it prints `ok`,
   > then commit the file. Put the final proof in your result summary.

   Pass `extra_instructions`: "Read CLAUDE.md, section 'Inside a workstation', and
   /opt/lean/SKILL.md before the first check."
6. **Wait.** Call `read_inbox` with `wait_s: 50` in a loop, and pass each `next_cursor` on.
   Tell the user each `progress`, `question` and `result` item in one line. Answer a `question`
   with `send_message`. When an agent ends, call `get_agent` for its branch.
7. **Check their work.** For each agent whose `repository.delivery_state` is `pushed`, also when
   its state is `failed`, because `verify` decides:
   `git fetch origin ws/<agent-id>` and `git checkout FETCH_HEAD -- Lemmas/<Problem>/<LemmaName>.lean`.
   Then run `bin/lean-sandbox verify` on all the lemma files in one call. If it answers `HTTP 429`
   or `pool_offline`, wait until every agent has ended, destroy the workstation, and try again. An agent's own
   `lean-check` is not enough. If an agent failed or a lemma is not `VERIFIED`, send the agent
   the error with `send_message`, or prove the lemma here.
8. **Assemble.** Replace each `sorry` lemma in $ARGUMENTS with the verified proof. Run
   `bin/lean-sandbox check`, then `bin/lean-sandbox verify $ARGUMENTS`. The proof is done only
   when it prints `VERIFIED`.
9. **Clean up.** Call `destroy_workstation`. Commit the lemmas and the proof, and push the
   branch. Run `bin/lean-sandbox stop`.
10. **Report.** Show the plan, which agent proved which lemma and how long it took, the final
    proof, and the `verify` output.
