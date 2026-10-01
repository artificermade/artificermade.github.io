# artificermade.com

The website for Artificer Made LLC, served by GitHub Pages from this repository (`main`, root) at <https://artificermade.com>.

## Layout

| Path | What it is | Edited where |
| --- | --- | --- |
| `index.html`, `style.css`, `404.html` | The company pages. The header and footer sit between `SHARED HEADER/FOOTER` comments so other pages can reuse them | Here, by hand |
| `assets/` | The Hooked icons on the home page card (light and dark) | Here |
| `favicon.ico`, `favicon.svg`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png`, `site.webmanifest` | The company mark as browser and home-screen icons | Here |
| `og-image.png` | The preview image shown when the site is shared (1200×630) | Here |
| `robots.txt`, `sitemap.xml`, `.well-known/security.txt` | Site metadata. `security.txt` has an `Expires` date to renew each year | Here |
| `hooked/` | Hooked's help page and privacy policy | Generated in the Hooked app's repository; do not edit here |
| `CNAME` | The custom domain for GitHub Pages | Here |
| `.nojekyll` | Tells Pages to serve the files as they are, including `.well-known/` | Here |
| `scripts/`, `docs/go-live.md` | First-time publishing, the DNS steps, and a check that the site is live | Here |

The site is plain HTML and CSS. It loads no scripts, fonts, or third-party resources, and sets no cookies.

## Updating the Hooked pages

`hooked/` is rendered from the Hooked app's own source, so the site cannot say something the app does not. In the Hooked repository run `make support-site`, then replace this repository's `hooked/` folder with the contents of `build/support-site/` and push.

The privacy policy's address, `https://artificermade.com/hooked/privacy.html`, is registered with the App Store. Keep that path stable.

## Previewing

```sh
python3 -m http.server 8000
```

Then open <http://localhost:8000>.

## DNS

The records and the order to add them in are in [docs/go-live.md](docs/go-live.md). The mail records (`MX`, SPF, DKIM, DMARC, and the Apple domain `TXT`) are separate and must not be changed when editing the web records. `bash scripts/check-live.sh` checks both.
