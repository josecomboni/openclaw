# FI Learnings

## Catastrophic (1 learning)

- **[high]** At 36K+ upstream commit divergence, direct cherry-pick of fork commits produces 100% conflicts. Must re-implement fork concepts on top of upstream rather than mechanically merge.
  _Source: FI-2026-05-16-1, iter 1_

## Strategy (6 learnings)

- **[high]** Skip fork dep update commits when upstream has 900+ commits touching the same files — fork dep changes are stale and superseded.
  _Files: package.json, pnpm-lock.yaml — Source: FI-2026-05-16-1, iter 1_
- **[medium]** Documentation files with 30+ upstream commits should use re-apply-concept strategy: extract the fork's added sections and insert them into upstream's current version.
  _Files: AGENTS.md, README.md, SECURITY.md — Source: FI-2026-05-16-1, iter 1_
- **[high]** CI workflow pinning must be re-done against upstream's current action versions. Fork pinned old versions that upstream has since changed.
  _Files: .github/workflows/\* — Source: FI-2026-05-16-1, iter 1_
- **[high]** Concept re-implementation works when cherry-pick fails at extreme divergence. Extract security concepts from fork, audit upstream state, apply fresh.
  _Source: FI-2026-05-16-1, iter 2_
- **[high]** Audit upstream before re-implementing — some fork fixes were independently applied upstream (Docker security*opt, crypto.randomBytes).
  \_Source: FI-2026-05-16-1, iter 2*
- **[high]** Parallel recon agents (upstream security audit + CI check + docs check) before implementation saves significant time by identifying what's already fixed.
  _Source: FI-2026-05-16-1, iter 2_

## Structural (1 learning)

- **[high]** 7 files modified by the fork were deleted upstream. Fork patches targeting these files must be skipped or rewritten for current upstream equivalents.
  _Files: .secrets.baseline, src/agents/openclaw-tools.subagents.sessions-spawn-depth-limits.test.ts, src/gateway/server.auth.e2e.test.ts, + 4 more — Source: FI-2026-05-16-1, iter 1_

---

_Auto-generated from `.fi/learnings.jsonl` on 2026-05-16_
