---
name: fi-apply
description: Mutating Fork Integration application skill for OpenClaw. Use after fi-recon to create an isolated FI worktree, apply fork changes by cherry-pick or concept reimplementation, validate the exact candidate tree, and return result/proposed-learnings JSON without writing .fi artifacts.
---

# FI Apply

Use `fi-apply` only after `fi-recon` has produced an assessment. This skill owns the FI worktree for one run and must not write `.fi/*`.

## Inputs

- recon assessment JSON
- run id in `YYYY.MMDD.NN` format
- upstream head
- fork commit list
- strategy: `cherry-pick`, `cherry-pick-with-fallback`, or `concept-reimpl`

## Canonical sequence

1. Create isolated worktree with `scripts/create-fi-worktree.sh`.
2. Apply according to recon strategy.
3. On any retry or halt, use the rollback contract in `references/rollback-contract.md`.
4. Validate with `scripts/validate-worktree.sh`.
5. Collect proposed learnings with `scripts/collect-learnings.sh`.
6. Return JSON to `fi-orchestrate`.

## Ownership rules

- Mutate only `../openclaw-fi/<run-id>`.
- Do not write `.fi/learnings.jsonl`, `.fi/fi-history.*`, or reports.
- Do not merge or push.
- Do not downgrade strategy. Ladder: `cherry-pick -> cherry-pick-with-fallback -> concept-reimpl -> halt`.

## Validation

Default to sequential validation in the FI worktree. Parallel validation is only allowed with isolated caches and a clean-tree check after each lane.
