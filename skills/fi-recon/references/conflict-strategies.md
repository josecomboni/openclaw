# FI Recon Conflict Strategies

## Definitions

- `fork_files`: unique files touched by fork-only commits.
- `overlapping_files`: fork files touched by upstream since merge base.
- `overlap_ratio = overlapping_files / fork_files`.
- `predicted_conflict_ratio = commits_predicted_to_conflict / fork_commits`.
- `deleted_upstream_count`: fork files that no longer exist at upstream HEAD.

## Strategy decision tree

| Predicate                                                                                 | Strategy                    |
| ----------------------------------------------------------------------------------------- | --------------------------- |
| `fork_commits == 0` and upstream moved                                                    | `trivial-ff`                |
| `upstream_commits < 50` and `overlapping_files < 5` and `deleted_upstream_count == 0`     | `cherry-pick`               |
| `upstream_commits < 500` and `overlap_ratio < 0.30` and `predicted_conflict_ratio < 0.50` | `cherry-pick-with-fallback` |
| Otherwise                                                                                 | `concept-reimpl`            |

## Already-fixed proof levels

| Level            | Allowed action                                                                       |
| ---------------- | ------------------------------------------------------------------------------------ |
| `textual-proof`  | Skip if fork hunk or equivalent text already exists upstream.                        |
| `semantic-audit` | Skip if upstream implements the same behavior through different code, with evidence. |
| `test-backed`    | Skip if existing or added tests prove the behavior exists.                           |
| `partial`        | Reimplement only missing pieces.                                                     |
| `unknown`        | Do not skip.                                                                         |

## Learning use

Use only active learnings from validated or merged runs. Quarantined learnings from failed runs may inform reports, but must not drive automatic skips.
