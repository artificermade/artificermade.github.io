# Going live

The steps that put this repository on `https://artificermade.com`. Do them in order. Step 2 comes before step 3 on purpose: a DNS record that points at GitHub Pages before the domain is verified can be claimed by another GitHub account.

## 1. Publish the repository

```sh
bash scripts/publish-first-time.sh
```

It creates the public repository, pushes `main`, and turns on GitHub Pages from `main` / root. The `CNAME` file in the repository sets the custom domain.

## 2. Verify the domain for the organization

1. On GitHub, open the `artificermade` organization, then **Settings → Pages → Add a domain**.
2. Enter `artificermade.com`. GitHub shows a `TXT` record named `_github-pages-challenge-artificermade` and a value.
3. At the DNS host, add that `TXT` record (host `_github-pages-challenge-artificermade`, the value GitHub shows).
4. Back on GitHub, choose **Verify**. It can take a few minutes for the record to be visible.

Leave the `TXT` record in place afterwards; removing it removes the protection.

## 3. Add the web DNS records

Remove these if they are present: a `URL Redirect` record on `@`, and a `CNAME` on `www` that points at a parking page.

Add these:

| Type | Host | Value |
| --- | --- | --- |
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |
| AAAA | `@` | `2606:50c0:8000::153` |
| AAAA | `@` | `2606:50c0:8001::153` |
| AAAA | `@` | `2606:50c0:8002::153` |
| AAAA | `@` | `2606:50c0:8003::153` |
| CNAME | `www` | `artificermade.github.io.` |

Do not change any mail record: the two `MX` records, the SPF and Apple domain `TXT` records on `@`, the `sig1._domainkey` `CNAME`, and the `_dmarc` `TXT`.

## 4. Turn on HTTPS and check

GitHub issues the certificate after the DNS records are visible, usually within an hour. Then:

```sh
gh api -X PUT repos/artificermade/artificermade.github.io/pages -F https_enforced=true
bash scripts/check-live.sh
```

`check-live.sh` prints `PASS` when both `https://artificermade.com` and `https://www.artificermade.com` serve the site, the Hooked pages load, the `A`, `AAAA` and `www` records point at GitHub Pages, and the mail records match: both `MX` records, the SPF and Apple domain `TXT` records, the DKIM `CNAME`, and a DMARC record of any policy.
