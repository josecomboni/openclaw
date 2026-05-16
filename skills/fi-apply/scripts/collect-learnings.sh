#!/usr/bin/env bash
set -euo pipefail

run_id="${1:?run id is required}"
iteration="${2:-1}"
category="${3:-strategy}"
confidence="${4:-low}"
learning="${5:-}"

if [ -z "$learning" ]; then
  echo "learning text is required" >&2
  exit 2
fi

RUN_ID="$run_id" ITERATION="$iteration" CATEGORY="$category" CONFIDENCE="$confidence" LEARNING="$learning" node -e '
console.log(JSON.stringify([{
  run_id: process.env.RUN_ID,
  iteration: Number(process.env.ITERATION),
  category: process.env.CATEGORY,
  confidence: process.env.CONFIDENCE,
  learning: process.env.LEARNING,
  quarantine: true
}], null, 2));
'

