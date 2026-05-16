---
name: fi-orchestrate
description: Continuous Fork Integration orchestrator for OpenClaw. Use to run periodic or manual FI safely with locking, drift detection, fi-recon, fi-apply, baseline-aware validation, PR-first merge, .fi history, and learnings persistence.
---

# FI Orchestrate

Use `fi-orchestrate` as the only top-level entrypoint for continuous Fork Integration. It owns locking, run identity, `.fi/*` writes, report generation, and PR/merge gating.

## Canonical lifecycle

1. **ACQUIRE_LOCK** with `scripts/fi-lock.sh`.
2. **CHECK_DRIFT** with `scripts/fi-check-drift.sh`.
3. **RECON** using `fi-recon`.
4. **APPLY** using `fi-apply` in an exclusive FI worktree.
5. **REPORT_IN_FI_WORKTREE** with `scripts/fi-report-gen.sh`.
6. **FINAL_VALIDATE** on the exact commit that will be PR/merged.
7. **PR_OR_SAFE_MERGE**: default PR-only.
8. **FINALIZE_HISTORY_AND_LEARNINGS** with `scripts/fi-finalize-history.sh`.
9. Release lock.

## Safety rules

- Hold `.fi/fi.lock` before allocating run IDs, writing `.fi/*`, creating FI worktrees, or merging.
- Use branch/worktree format `fi/YYYY.MMDD.NN`.
- Do not force-push unless an explicit one-run emergency override is present.
- Do not mark upstream as integrated until the final state is `merged`.
- Promote learnings only from validated/merged runs.
- Quarantine learnings from failed runs.

## Trigger handling

Cron, webhook, and manual triggers all enter this same orchestrator. If the lock is held, coalesce duplicate upstream heads and queue at most one pending run.

## Merge model

Default to PR creation. Direct merge requires:

- config explicitly enables it,
- `origin/main` still matches the expected head after re-fetch,
- fast-forward-only push succeeds,
- final validation passed on the exact tree being pushed.
