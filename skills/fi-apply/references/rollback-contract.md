# FI Apply Rollback Contract

Run before retry, halt, or quarantine:

```bash
git cherry-pick --abort 2>/dev/null || true
git merge --abort 2>/dev/null || true
git rebase --abort 2>/dev/null || true
git reset --hard "$UPSTREAM_HEAD"
git clean -fdx
```

If cleanup fails:

1. Stop mutation.
2. Rename branch to `fi/failed/<run-id>` if possible.
3. Move worktree to `../openclaw-fi/failed/<run-id>` if possible.
4. Return `failed-catastrophic` with cleanup logs.

Never continue applying after a failed cleanup.
