#!/usr/bin/env bash
# One-time setup: create the GitHub repository, push this checkout, and turn on GitHub Pages.
# Safe to re-run; each step is skipped when it is already done.
set -euo pipefail

REPO="artificermade/artificermade.github.io"
HERE="$(cd "$(dirname "$0")/.." && pwd -P)"

step() { printf '\n== %s\n' "$1"; }

step "1/4 repository"
if gh repo view "$REPO" >/dev/null 2>&1; then
  echo "exists: $REPO"
else
  gh repo create "$REPO" --public \
    --description "Website for Artificer Made LLC — artificermade.com" \
    --homepage "https://artificermade.com"
  echo "created: $REPO"
fi

step "2/4 remote"
if git -C "$HERE" remote get-url origin >/dev/null 2>&1; then
  echo "origin: $(git -C "$HERE" remote get-url origin)"
else
  git -C "$HERE" remote add origin "git@github.com:${REPO}.git"
  echo "added origin"
fi

step "3/4 push main"
git -C "$HERE" push --no-follow-tags -u origin main:refs/heads/main
local_sha="$(git -C "$HERE" rev-parse main)"
remote_sha="$(git -C "$HERE" ls-remote origin refs/heads/main | cut -f1)"
if [ "$local_sha" != "$remote_sha" ]; then
  echo "FAIL: remote main is ${remote_sha:-missing}, local is $local_sha" >&2
  exit 1
fi
echo "pushed: $local_sha"

step "4/4 GitHub Pages"
if gh api "repos/$REPO/pages" >/dev/null 2>&1; then
  echo "Pages already on"
else
  gh api -X POST "repos/$REPO/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null
  echo "Pages turned on (main, root)"
fi
gh api "repos/$REPO/pages" --jq '"status=\(.status // "pending") cname=\(.cname // "none") url=\(.html_url)"'

cat <<'NEXT'

Done. The site is not reachable at artificermade.com yet. Next, in this order:
  1. Verify the domain for the organization (GitHub: organization Settings -> Pages -> Add a domain).
  2. Add the web DNS records. Both steps are in docs/go-live.md.
  3. Run scripts/check-live.sh until it prints PASS.
NEXT
