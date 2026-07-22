#!/usr/bin/env bash
# Weekly upstream sync for Accelera's CIPP forks.
# CIPP frontend tracks upstream `main`; CIPP-API tracks upstream `master`.
# Uses merge (not fast-forward) because our forks carry local commits
# (the Azure SWA workflow file, Accelera docs) that upstream doesn't have.
set -euo pipefail
cd "$(dirname "$0")"

sync_repo() {
  local dir=$1 branch=$2
  echo "=== $dir ($branch) ==="
  git -C "$dir" fetch upstream
  git -C "$dir" checkout "$branch"
  git -C "$dir" pull --ff-only origin "$branch"
  git -C "$dir" merge --no-edit "upstream/$branch"
  git -C "$dir" push origin "$branch"
}

sync_repo CIPP main
sync_repo CIPP-API master

echo "Done. SWA + Function App redeploy automatically on push to the deploy branch."
