# Continuous FI Workflow

## Run states

| State                 | Meaning                                 | Advances integrated upstream? |
| --------------------- | --------------------------------------- | ----------------------------- |
| `started`             | Lock acquired and run allocated.        | No                            |
| `recon`               | Recon completed.                        | No                            |
| `applied`             | FI worktree changed and committed.      | No                            |
| `validated`           | Final candidate tree passed validation. | No                            |
| `pr_open`             | PR created and awaiting merge.          | No                            |
| `merged`              | Work landed on target branch.           | Yes                           |
| `failed`              | Recoverable failure.                    | No                            |
| `failed-catastrophic` | Human intervention required.            | No                            |
| `blocked`             | Waiting on decision.                    | No                            |

## Drift detection

Run FI when any is true:

- upstream head changed since last merged FI,
- fork or target branch changed since last attempt,
- previous run did not finish as `merged`,
- manual override requested,
- queued webhook head differs from last attempt.

Skip only when all are unchanged and previous state is `merged`.

## Validation

Capture baseline failures before APPLY. After APPLY, fail only on new failures, removed expected tests, command crash, or dirty tree.
