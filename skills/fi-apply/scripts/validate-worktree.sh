#!/usr/bin/env bash
set -euo pipefail

worktree="${1:?worktree path is required}"
mode="${2:-sequential}"

cd "$worktree"

before_status="$(git status --short)"

check_status="not-run"
test_status="not-run"

if [ "$mode" = "sequential" ]; then
  if pnpm check; then
    check_status="pass"
  else
    check_status="fail"
  fi

  if pnpm test; then
    test_status="pass"
  else
    test_status="fail"
  fi
else
  echo "Parallel validation requires isolated lane setup; use sequential for deterministic FI." >&2
  exit 2
fi

after_status="$(git status --short)"
dirty_after=false
if [ "$before_status" != "$after_status" ]; then
  dirty_after=true
fi

CHECK_STATUS="$check_status" TEST_STATUS="$test_status" DIRTY_AFTER="$dirty_after" node -e '
console.log(JSON.stringify({
  check: process.env.CHECK_STATUS,
  test: process.env.TEST_STATUS,
  dirty_after: process.env.DIRTY_AFTER === "true"
}, null, 2));
'

if [ "$check_status" != "pass" ] || [ "$test_status" != "pass" ] || [ "$dirty_after" = "true" ]; then
  exit 1
fi

