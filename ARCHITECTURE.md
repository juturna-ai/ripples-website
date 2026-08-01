# Ripples Website — Architecture

Static marketing site for the Ripples desktop app. No build step, no framework,
no JavaScript — plain HTML served as files, with one shared stylesheet.

Served locally via `serve.sh`.

## Route map

| File | Route | Purpose |
|---|---|---|
| `index.html` | `/` | Hero landing page — wordmark, tagline, droplet logo |
| `about.html` | `/about.html` | Features, screenshots, how it works, specs, CTA |
| `download.html` | `/download.html` | Windows installer download button |

All three share the same shell: `.page` wrapper → `.bg-wash` + `.starfield`
ambient layers → `.site-nav` → page content → `.site-footer`.

Nav links live in `.nav-links` on every page; the current page carries
`.nav-link.is-active`. Adding a page means adding a link to all three navs.

## Styling

Single stylesheet: `styles.css`, linked with a cache-busting query
(`styles.css?v=5`). **Bump the version on every page when the stylesheet
changes** — otherwise browsers serve stale CSS and media queries silently fail
to apply.

Design tokens are defined once in `:root`:

| Token | Purpose |
|---|---|
| `--color-starlight` | Primary text |
| `--color-glacier-mist` | Subtle highlight |
| `--color-electric-cyan` | Accent, glows, kickers |
| `--color-sky-frost` | Muted text base |
| `--color-electric-blue` | Primary accent |
| `--color-midnight-navy` | Elevated surfaces |
| `--color-void-black` | Base background |
| `--gradient-beam` | electric-blue → electric-cyan, used on icons/CTAs |
| `--text-muted` | Body copy on dark surfaces |
| `--glow-primary` / `--glow-secondary` | Cyan glow shadows |
| `--border-subtle` | Standard card border |

Typography: **Audiowide** for the wordmark and nav, **Space Grotesk** for
headings and labels, **Inter** for body copy — all from Google Fonts.

### Layout note

`.page` uses `overflow: hidden` and a viewport-height flex column, which suits
the single-screen home and download pages. The About page scrolls, so
`.page:has(.about)` relaxes `overflow` and switches the ambient layers to
`position: fixed` — otherwise the gradient wash and starfield clip to the first
viewport.

Below 640px the nav drops from absolute centring back into normal flow and
stacks under the brand, preventing the links from overlapping the wordmark.

## About page sections

| Section | Class | Content |
|---|---|---|
| Intro | `.about-hero` | Lede + feature chips |
| Features | `.feature-grid` | 9 cards — auto-fit grid, min 260px |
| Screenshots | `.shot-row` | 3 captured app screenshots with captions |
| How it works | `.steps` | 4 numbered steps |
| Mastering | `.chain` | 4 stages of the mastering chain |
| Specs | `.specs` | Definition list of formats and limits |
| CTA | `.about-cta` | Link to `download.html` |

All grids use `repeat(auto-fit, minmax(…, 1fr))` so they reflow to one column on
narrow screens without extra breakpoints. Screenshots are `loading="lazy"` with
explicit `width`/`height` to avoid layout shift.

## Assets

| Path | Purpose |
|---|---|
| `assets/icon.png` | Droplet logo (home hero) |
| `assets/icon.ico` | Favicon source |
| `assets/morrizen-logo.png` | Footer MorrizeN mark |
| `assets/shots/audio.png` | App screenshot — Audio tab |
| `assets/shots/video.png` | App screenshot — Video tab |
| `assets/shots/sources.png` | App screenshot — Twitter/X source |
| `downloads/Ripples-Setup-<version>.exe` | Windows installer |

### Regenerating screenshots

The screenshots are real captures of the app renderer, not mockups. To refresh
them after a UI change:

1. Build the app renderer in `ripples-app/ripples` (`npm run build`).
2. Load `dist-renderer/index.html` in an Electron `BrowserWindow` with a preload
   that stubs the `window.ripples` IPC surface (the renderer calls it on mount).
3. Seed `localStorage` (`ripples.activeSubTab`, `ripples.source`,
   `ripples.video.mode`, `ripples.video.resolution`, and the `outDir` keys so the
   Save-To field shows a path instead of "Loading…"), reload, then
   `webContents.capturePage()`.

Gotchas when scripting this: unset `ELECTRON_RUN_AS_NODE` or Electron starts as
plain Node; use `show: true`, since `capturePage()` on a hidden window fails
under WSLg; and reuse one window across shots — destroying a window mid-loop
aborts the next `loadFile`.

## Download flow

`download.html` links directly at the installer in `downloads/`. The filename,
version, and size are hardcoded in the markup — **update all three** when
shipping a new build, and keep the version in sync with `package.json` in
`ripples-app`.

## Security

No backend, no forms, no analytics, no secrets. Everything is a static asset.
External links (`morrizen.io`, `juturna.io`) carry
`target="_blank" rel="noopener noreferrer"`.
