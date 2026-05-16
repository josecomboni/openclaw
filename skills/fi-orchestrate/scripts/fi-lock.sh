#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(pwd)}"
action="${2:-acquire}"
ttl_minutes="${3:-120}"

cd "$repo"
mkdir -p .fi
lock_dir=".fi/fi.lock"

case "$action" in
  acquire)
    if mkdir "$lock_dir" 2>/dev/null; then
      {
        printf 'pid=%s\n' "$$"
        printf 'created_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf 'ttl_minutes=%s\n' "$ttl_minutes"
      } > "$lock_dir/meta"
      echo "acquired"
      exit 0
    fi

    if [ -f "$lock_dir/meta" ]; then
      created_at="$(grep '^created_at=' "$lock_dir/meta" | cut -d= -f2- || true)"
      if [ -n "$created_at" ]; then
        created_epoch="$(date -u -d "$created_at" +%s 2>/dev/null || echo 0)"
        now_epoch="$(date -u +%s)"
        age_minutes="$(( (now_epoch - created_epoch) / 60 ))"
        if [ "$age_minutes" -ge "$ttl_minutes" ]; then
          mv "$lock_dir" ".fi/fi.lock.stale.$(date -u +%Y%m%dT%H%M%SZ)"
          mkdir "$lock_dir"
          printf 'pid=%s\ncreated_at=%s\nttl_minutes=%s\nrecovered_stale=true\n' "$$" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$ttl_minutes" > "$lock_dir/meta"
          echo "acquired-after-stale"
          exit 0
        fi
      fi
    fi

    echo "locked"
    exit 3
    ;;
  release)
    rm -rf "$lock_dir"
    echo "released"
    ;;
  status)
    if [ -d "$lock_dir" ]; then
      cat "$lock_dir/meta" 2>/dev/null || true
      exit 3
    fi
    echo "unlocked"
    ;;
  *)
    echo "usage: fi-lock.sh <repo> acquire|release|status [ttl_minutes]" >&2
    exit 2
    ;;
esac

