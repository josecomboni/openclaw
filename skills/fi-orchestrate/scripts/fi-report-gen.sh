#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(pwd)}"
run_id="${2:?run id is required}"
state="${3:-started}"
summary="${4:-No summary provided.}"

cd "$repo"
mkdir -p .fi/fi-reports
report=".fi/fi-reports/FI-$run_id.md"

cat > "$report" <<EOF
# Fork Integration Report — $run_id

## Summary

| Field | Value |
|---|---|
| Run ID | \`$run_id\` |
| State | \`$state\` |

## Details

$summary

## Validation

Pending.

## Learnings

Pending.
EOF

echo "$report"

