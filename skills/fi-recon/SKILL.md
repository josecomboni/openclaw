---
name: fi-recon
description: Read-only Fork Integration reconnaissance for OpenClaw. Use to compute fork/upstream divergence, classify fork commits, audit overlap, choose cherry-pick vs concept-reimplementation strategy, and produce machine-readable FI assessment JSON before any mutation.
---

# FI Recon

Use `fi-recon` before every Fork Integration run. This skill is read-only: do not create branches, modify worktrees, write `.fi/*`, or push.

## Inputs

- repo root
- upstream remote, default `upstream`
- fork remote, default `origin`
- target branch, default `main`
- optional run id, format `YYYY.MMDD.NN`

## Canonical sequence

1. Confirm `fi-orchestrate` already fetched remotes under lock.
2. Load `.fi/learnings.jsonl` for prior successful learnings.
3. Run `scripts/compute-divergence.sh`.
4. Run `scripts/classify-fork-commits.sh`.
5. Run targeted upstream audits with `scripts/audit-upstream-state.sh`.
6. Choose strategy using `references/conflict-strategies.md`.
7. Return assessment JSON to the orchestrator.

## Parallelization

Fan out only read-only work:

- upstream changelog grouping
- fork commit classification
- overlap/deleted-file audit
- targeted upstream-state audits

Do not fetch, mutate refs, create worktrees, write `.fi/*`, or change local config.

## Output

Return JSON with:

- `run_id`
- `merge_base`, `upstream_head`, `fork_head`, `main_head`
- `divergence`
- `strategy`
- `risk_level`
- per-commit `recommended_action`
- baseline failure summary when requested

## Hard stops

Report `risk_level: "catastrophic"` when:

- predicted conflict ratio is >= 0.5
- five or more fork-touched files were deleted upstream
- baseline validation cannot be captured
- repo state is dirty before recon starts
