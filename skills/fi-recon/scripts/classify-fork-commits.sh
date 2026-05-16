#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(pwd)}"
merge_base="${2:?merge base is required}"
fork_ref="${3:-origin/main}"

cd "$repo"

printf '['
first=1
while IFS= read -r sha; do
  [ -n "$sha" ] || continue
  message="$(git log -1 --format=%s "$sha")"
  files_json="$(git diff-tree --no-commit-id --name-only -r "$sha" | node -e 'const fs=require("fs"); const files=fs.readFileSync(0,"utf8").trim().split(/\n/).filter(Boolean); console.log(JSON.stringify(files));')"
  component="$(printf '%s' "$message" | sed -E 's/^([^:]+):.*/\1/; t; s/.*/misc/')"
  [ "$first" -eq 1 ] || printf ','
  first=0
  SHA="$sha" MESSAGE="$message" FILES_JSON="$files_json" COMPONENT="$component" node -e '
const entry = {
  sha: process.env.SHA,
  message: process.env.MESSAGE,
  files: JSON.parse(process.env.FILES_JSON || "[]"),
  component: process.env.COMPONENT,
};
console.log(JSON.stringify(entry));
'
done < <(git rev-list --reverse --no-merges "$merge_base..$fork_ref")
printf ']\n'

