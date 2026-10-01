#!/usr/bin/env bash
# Checks that the site is live and that mail was left alone.
# Usage: scripts/check-live.sh            checks https://artificermade.com and DNS
#        scripts/check-live.sh <base-url> checks the pages at another address (for example a local preview) and skips DNS
# CHECK_DOMAIN overrides the domain, to prove the checks fail against a domain that is not this one.
set -uo pipefail

DOMAIN="${CHECK_DOMAIN:-artificermade.com}"
BASE="${1:-}"
fail=0

ok()  { printf 'ok    %s\n' "$1"; }
bad() { printf 'FAIL  %s\n' "$1"; fail=1; }

page() { # url, text the page must contain
  local body code
  body="$(command curl -sS -L --max-time 15 --proto '=http,https' -w '\n%{http_code}' --url "$1" 2>/dev/null)" || { bad "$1 (no response)"; return; }
  code="${body##*$'\n'}"
  if [ "$code" != "200" ]; then bad "$1 (HTTP $code)"; return; fi
  if printf '%s' "$body" | grep -q -F -- "$2"; then ok "$1"; else bad "$1 (200, but missing: $2)"; fi
}

records() { # type, name -> the sorted answers on one line, quotes removed
  dig +short "$1" "$2" | tr -d '"' | sort | tr '\n' ' ' | sed 's/ $//'
}

same() { # label, got, want
  if [ "$2" = "$3" ]; then ok "$1"; else bad "$1: got '${2:-none}'"; fi
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

  same "A records point at GitHub Pages" "$(records A "$DOMAIN")" \
    "185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153"
  same "AAAA records point at GitHub Pages" "$(records AAAA "$DOMAIN")" \
    "2606:50c0:8000::153 2606:50c0:8001::153 2606:50c0:8002::153 2606:50c0:8003::153"
  same "www CNAME" "$(records CNAME "www.$DOMAIN")" "artificermade.github.io."

  same "mail: MX records" "$(records MX "$DOMAIN")" "10 mx01.mail.icloud.com. 10 mx02.mail.icloud.com."
  same "mail: SPF and Apple domain TXT" "$(records TXT "$DOMAIN")" \
    "apple-domain=pz6OQkxjVZNskHKA v=spf1 include:icloud.com ~all"
  same "mail: DKIM CNAME" "$(records CNAME "sig1._domainkey.$DOMAIN")" \
    "sig1.dkim.artificermade.com.at.icloudmailadmin.com."
  dmarc="$(records TXT "_dmarc.$DOMAIN")"
  case "$dmarc" in
    "v=DMARC1; p="*) ok "mail: DMARC record present ($dmarc)" ;;
    *) bad "mail: DMARC record: got '${dmarc:-none}'" ;;
  esac
fi

if [ "$fail" -eq 0 ]; then echo "PASS"; else echo "NOT LIVE YET (see FAIL lines)"; fi
exit "$fail"
