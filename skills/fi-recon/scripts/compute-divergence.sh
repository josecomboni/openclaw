#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(pwd)}"
upstream="${2:-upstream}"
fork="${3:-origin}"
branch="${4:-main}"

cd "$repo"

merge_base="$(git merge-base "$fork/$branch" "$upstream/$branch")"
upstream_head="$(git rev-parse "$upstream/$branch")"
fork_head="$(git rev-parse "$fork/$branch")"
main_head="$(git rev-parse "$branch" 2>/dev/null || git rev-parse HEAD)"

upstream_commits="$(git rev-list --count "$merge_base..$upstream/$branch")"
fork_commits="$(git rev-list --count "$merge_base..$fork/$branch" --no-merges)"

fork_files_file="$(mktemp)"
upstream_files_file="$(mktemp)"
trap 'rm -f "$fork_files_file" "$upstream_files_file"' EXIT

git diff --name-only "$merge_base..$fork/$branch" | sort -u > "$fork_files_file"
git diff --name-only "$merge_base..$upstream/$branch" | sort -u > "$upstream_files_file"

fork_files="$(wc -l < "$fork_files_file" | tr -d ' ')"
overlapping_files="$(comm -12 "$fork_files_file" "$upstream_files_file" | wc -l | tr -d ' ')"
deleted_upstream_files="$(while IFS= read -r file; do
  [ -n "$file" ] || continue
  if ! git cat-file -e "$upstream/$branch:$file" 2>/dev/null; then
    printf '%s\n' "$file"
  fi
done < "$fork_files_file" | wc -l | tr -d ' ')"

MERGE_BASE="$merge_base" \
UPSTREAM_HEAD="$upstream_head" \
FORK_HEAD="$fork_head" \
MAIN_HEAD="$main_head" \
UPSTREAM_COMMITS="$upstream_commits" \
FORK_COMMITS="$fork_commits" \
FORK_FILES="$fork_files" \
OVERLAPPING_FILES="$overlapping_files" \
DELETED_UPSTREAM_FILES="$deleted_upstream_files" \
node -e '
const data = {
  merge_base: process.env.MERGE_BASE,
  upstream_head: process.env.UPSTREAM_HEAD,
  fork_head: process.env.FORK_HEAD,
  main_head: process.env.MAIN_HEAD,
  divergence: {
    upstream_commits: Number(process.env.UPSTREAM_COMMITS),
    fork_commits: Number(process.env.FORK_COMMITS),
    fork_files: Number(process.env.FORK_FILES),
    overlapping_files: Number(process.env.OVERLAPPING_FILES),
    deleted_upstream_files: Number(process.env.DELETED_UPSTREAM_FILES),
  },
};
data.divergence.overlap_ratio = data.divergence.fork_files === 0 ? 0 : data.divergence.overlapping_files / data.divergence.fork_files;
console.log(JSON.stringify(data, null, 2));
'
