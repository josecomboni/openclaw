#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(pwd)}"
run_id="${2:?run id is required}"
state="${3:?state is required}"
upstream_head="${4:?upstream head is required}"
fork_head="${5:?fork head is required}"
main_head="${6:?main head is required}"
report="${7:-fi-reports/FI-$run_id.md}"

cd "$repo"
mkdir -p .fi

RUN_ID="$run_id" STATE="$state" UPSTREAM_HEAD="$upstream_head" FORK_HEAD="$fork_head" MAIN_HEAD="$main_head" REPORT="$report" node -e '
const entry = {
  run_id: process.env.RUN_ID,
  date: new Date().toISOString(),
  state: process.env.STATE,
  upstream_head: process.env.UPSTREAM_HEAD,
  fork_head: process.env.FORK_HEAD,
  main_head: process.env.MAIN_HEAD,
  report: process.env.REPORT,
};
console.log(JSON.stringify(entry));
' >> .fi/fi-history.jsonl

{
  echo "# FI Run History"
  echo
  echo "| Run ID | State | Upstream HEAD | Fork HEAD | Main HEAD | Report |"
  echo "|---|---|---|---|---|---|"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    LINE="$line" node -e '
const e = JSON.parse(process.env.LINE);
console.log(`| ${e.run_id} | ${e.state} | \`${(e.upstream_head || "").slice(0, 10)}\` | \`${(e.fork_head || "").slice(0, 10)}\` | \`${(e.main_head || "").slice(0, 10)}\` | ${e.report || ""} |`);
'
  done < .fi/fi-history.jsonl
} > .fi/fi-history.md

