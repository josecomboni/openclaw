#!/usr/bin/env bash
set -euo pipefail

worktree="${1:?worktree path is required}"
shift

cd "$worktree"

printf '['
first=1
for sha in "$@"; do
  [ -n "$sha" ] || continue
  status="applied"
  conflicts="[]"
  error=""

  if ! git cherry-pick "$sha" --no-edit >/tmp/fi-cherry-pick.out 2>/tmp/fi-cherry-pick.err; then
    conflict_files="$(git diff --name-only --diff-filter=U || true)"
    if [ -n "$conflict_files" ]; then
      status="conflict"
      conflicts="$(printf '%s\n' "$conflict_files" | node -e 'const fs=require("fs"); const a=fs.readFileSync(0,"utf8").trim().split(/\n/).filter(Boolean); console.log(JSON.stringify(a));')"
    else
      status="failed"
      error="$(cat /tmp/fi-cherry-pick.err | head -20)"
    fi
    git cherry-pick --abort >/dev/null 2>&1 || true
  fi

  [ "$first" -eq 1 ] || printf ','
  first=0
  SHA="$sha" STATUS="$status" CONFLICTS="$conflicts" ERROR="$error" node -e '
console.log(JSON.stringify({
  sha: process.env.SHA,
  status: process.env.STATUS,
  conflicts: JSON.parse(process.env.CONFLICTS || "[]"),
  error: process.env.ERROR || null
}));
'
done
printf ']\n'

