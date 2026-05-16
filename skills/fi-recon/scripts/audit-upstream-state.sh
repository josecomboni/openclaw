#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(pwd)}"
shift || true

cd "$repo"

patterns=("$@")
if [ "${#patterns[@]}" -eq 0 ]; then
  patterns=(
    "Math.random"
    "normalize(\"NFKC\")"
    "credentials in URL"
    "Reflect.construct"
    "MAX_SUBAGENT_TASK"
    "sandbox.workspaceRoot must not"
    "providerKey"
    "no-new-privileges"
  )
fi

printf '['
first=1
for pattern in "${patterns[@]}"; do
  matches="$(git grep -n -- "$pattern" -- ':!node_modules' 2>/dev/null | head -20 || true)"
  [ "$first" -eq 1 ] || printf ','
  first=0
  PATTERN="$pattern" MATCHES="$matches" node -e '
const matches = (process.env.MATCHES || "").split(/\n/).filter(Boolean);
console.log(JSON.stringify({
  pattern: process.env.PATTERN,
  status: matches.length > 0 ? "present" : "missing",
  matches,
}));
'
done
printf ']\n'

