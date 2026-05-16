#!/usr/bin/env bash
set -euo pipefail

repo="${1:?repo path is required}"
run_id="${2:?run id is required, e.g. 2026.0516.01}"
upstream_ref="${3:-upstream/main}"
base_dir="${4:-../openclaw-fi}"

branch="fi/$run_id"
worktree="$base_dir/$run_id"

cd "$repo"

if git rev-parse --verify "$branch" >/dev/null 2>&1; then
  echo "FI branch already exists: $branch" >&2
  exit 2
fi

if [ -e "$worktree" ]; then
  echo "FI worktree already exists: $worktree" >&2
  exit 2
fi

mkdir -p "$base_dir"
git worktree add "$worktree" -b "$branch" "$upstream_ref"

BRANCH="$branch" WORKTREE="$worktree" UPSTREAM_REF="$upstream_ref" node -e '
console.log(JSON.stringify({
  branch: process.env.BRANCH,
  worktree: process.env.WORKTREE,
  upstream_ref: process.env.UPSTREAM_REF
}, null, 2));
'
