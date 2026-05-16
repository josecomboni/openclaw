#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(pwd)}"
upstream="${2:-upstream}"
fork="${3:-origin}"
branch="${4:-main}"

cd "$repo"
mkdir -p .fi

git fetch "$fork" --quiet
git fetch "$upstream" --quiet

upstream_head="$(git rev-parse "$upstream/$branch")"
fork_head="$(git rev-parse "$fork/$branch")"
main_head="$(git rev-parse "$branch" 2>/dev/null || git rev-parse HEAD)"

history_json="$(cat .fi/fi-history.jsonl 2>/dev/null || true)"

HISTORY_JSON="$history_json" UPSTREAM_HEAD="$upstream_head" FORK_HEAD="$fork_head" MAIN_HEAD="$main_head" node -e '
const lines = (process.env.HISTORY_JSON || "").split(/\n/).filter(Boolean);
const history = lines.flatMap((line) => {
  try {
    return [JSON.parse(line)];
  } catch {
    return [];
  }
});
const lastAttempt = history.at(-1) || null;
const integratedStates = new Set(["merged", "succeed"]);
const lastMerged = [...history].reverse().find((entry) => integratedStates.has(entry.state)) || null;
const upstreamHead = process.env.UPSTREAM_HEAD;
const forkHead = process.env.FORK_HEAD;
const mainHead = process.env.MAIN_HEAD;
const reasons = [];
if (!lastMerged || lastMerged.upstream_head !== upstreamHead) reasons.push("upstream_changed");
if (!lastAttempt || lastAttempt.fork_head !== forkHead) reasons.push("fork_changed");
if (!lastAttempt || lastAttempt.main_head !== mainHead) reasons.push("main_changed");
if (lastAttempt && !integratedStates.has(lastAttempt.state)) reasons.push("previous_not_merged");
console.log(JSON.stringify({
  should_run: reasons.length > 0,
  reasons,
  upstream_head: upstreamHead,
  fork_head: forkHead,
  main_head: mainHead,
  last_merged_state: lastMerged?.state || null,
  last_attempt_state: lastAttempt?.state || null
}, null, 2));
'
