---
description: Prove a Lean problem of this repository in the Agentformers sandbox
argument-hint: Problems/<File>.lean
---

Prove the theorem in $ARGUMENTS. Follow CLAUDE.md: change only the proof, check every attempt with
`bin/lean-sandbox check $ARGUMENTS`, and finish with `bin/lean-sandbox verify $ARGUMENTS`.

Before the first edit, say in two or three sentences how you plan to prove it. After each failed
check, say in one sentence what the error means and what you change. When `verify` prints
`VERIFIED`, show the final proof and stop the sandbox.
