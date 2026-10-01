#!/usr/bin/env bash
# Checks that the site is live and that mail was left alone.
# Usage: scripts/check-live.sh            checks https://artificermade.com and DNS
#        scripts/check-live.sh <base-url> checks the pages at another address (for example a local preview) and skips DNS
set -uo pipefail

DOMAIN="artificermade.com"
BASE="${1:-}"
fail=0

ok()  { printf 'ok    %s\n' "$1"; }
bad() { printf 'FAIL  %s\n' "$1"; fail=1; }

page() { # url, text the page must contain
  local body code
  body="$(command curl -sS -L --max-time 15 -w '\n%{http_code}' "$1" 2>/dev/null)" || { bad "$1 (no response)"; return; }
  code="${body##*$'\n'}"
  if [ "$code" != "200" ]; then bad "$1 (HTTP $code)"; return; fi
  if printf '%s' "$body" | grep -q -F -- "$2"; then ok "$1"; else bad "$1 (200, but missing: $2)"; fi
}

if [ -n "$BASE" ]; then
  echo "Checking pages at $BASE (DNS checks skipped)"
  page "$BASE/" "Artificer Made LLC"
  page "$BASE/hooked/" "Hooked"
  page "$BASE/hooked/privacy.html" "Privacy Policy"
else
  echo "Checking https://$DOMAIN"
  page "https://$DOMAIN/" "Artificer Made LLC"
  page "https://www.$DOMAIN/" "Artificer Made LLC"
  page "https://$DOMAIN/hooked/" "Hooked"
  page "https://$DOMAIN/hooked/privacy.html" "Privacy Policy"

  want_a="185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153"
  got_a="$(dig +short A "$DOMAIN" | sort | tr '\n' ' ' | sed 's/ $//')"
  if [ "$got_a" = "$want_a" ]; then ok "A records point at GitHub Pages"; else bad "A records: got '${got_a:-none}'"; fi

  got_www="$(dig +short CNAME "www.$DOMAIN")"
  if [ "$got_www" = "artificermade.github.io." ]; then ok "www CNAME"; else bad "www CNAME: got '${got_www:-none}'"; fi

  got_mx="$(dig +short MX "$DOMAIN" | sort | tr '\n' ' ' | sed 's/ $//')"
  want_mx="10 mx01.mail.icloud.com. 10 mx02.mail.icloud.com."
  if [ "$got_mx" = "$want_mx" ]; then ok "mail MX records unchanged"; else bad "MX: got '${got_mx:-none}'"; fi

  if dig +short TXT "$DOMAIN" | grep -q -F 'v=spf1 include:icloud.com'; then ok "SPF record present"; else bad "SPF record missing"; fi
fi

if [ "$fail" -eq 0 ]; then echo "PASS"; else echo "NOT LIVE YET (see FAIL lines)"; fi
exit "$fail"
