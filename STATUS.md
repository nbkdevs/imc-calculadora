# Status: IMC Calculadora (https://imccalculadora.app/)

Audited 30 Oct 2026 (Asia/Karachi, PKT). This was a read-only check: nothing was published and nothing was committed to nbkdevs/imc-calculadora. Rules: one Chrome theme, one extension (Firefox + Edge) and one skill per project. Browser-store items carry no brand, trademark or place names. Brand names are fine in packages and skills.

## Live

| Platform | Item | Live URL | Target URL | Link placement | Dofollow | Live? | Date | Notes |
|---|---|---|---|---|---|---|---|---|
| GitHub | `nbkdevs/imc-calculadora` (public repo) | https://github.com/nbkdevs/imc-calculadora | https://imccalculadora.app/ | root README Links section, anchor "Calculadora IMC" (added 30 Oct) | no (GitHub README links are nofollow) | yes after push | 2026-10-30 | About "Website" field still EMPTY: set `--homepage https://imccalculadora.app/` (needs Nazzal's OK) |

I found no store or registry listing for IMC.

## Built but not published
| Asset | Where | Blocker before submitting |
|---|---|---|
| Firefox extension "IMC Calculadora" 1.0.0 | extensions/dist/IMC-Calculadora-firefox-1.0.0.zip (gecko id imc-calculadora@imccalculadora.app) | **Breaks the no-brand rule.** Rename it, e.g. "BMI Pocket Calculator" / "Calculadora de Peso Saludable", and change the gecko id. Remove "Website: https://imccalculadora.app/" from the description in extensions/STORE_LISTINGS.md (extensions carry no in-text site link); put the site in the homepage/support fields only |
| Edge extension (same) | extensions/dist/IMC-Calculadora-edge-1.0.0.zip | Same rename. Privacy URL = the site's own privacy page |
| Chrome theme "IMC Calculadora — Mist Meadow" | extensions/dist/IMC-Calculadora-chrome-theme-1.0.0.zip | Rename it to "Mist Meadow" only (CWS is for themes only) |
| Flutter Android app `app.imccalculadora.android` 1.0.0 | app/ (app/STORE.md mentions dist/*.aab/.apk, which are gitignored and not in the repo or on the box) | Rebuild. Amazon (Fire) is the target. The about screen links to /metodologia/ |

## To build

| Platform | Suggested asset | Target URL | Link placement |
|---|---|---|---|
| Amazon Appstore (Fire) | Ship the existing app (ES/EN BMI + classification) | https://imccalculadora.app/ | developer website + in-app link |
| npm | `imc-calculadora`: BMI/IMC with WHO adult classes, healthy-weight range for a height, metric/imperial, ES/EN labels | https://imccalculadora.app/ | `homepage` + README anchor (e.g. "calculadora de IMC") |
| PyPI | `imc-infantil`: child/teen BMI percentile and z-score from the CDC 2000 LMS tables (2–20 y), with a CLI | https://imccalculadora.app/ (or a children's page if one exists) | Homepage + README |
| crates.io | `imc_embarazo`: pregnancy weight-gain ranges by pre-pregnancy BMI (IOM 2009), singleton/twins | https://imccalculadora.app/ | `homepage` + README |
| pub.dev | `imc_calculadora_core`: the Dart BMI/classification logic pulled out of the Flutter app | https://imccalculadora.app/metodologia/ | `homepage` + README |
| NuGet | `ImcCalculadora.BodyMetrics`: BMI + BMI Prime + ponderal index + waist-to-height ratio | https://imccalculadora.app/ | `PackageProjectUrl` + README |
| RubyGems | `imc_calculadora`: ideal-weight formulas (Devine, Robinson, Miller, Hamwi) next to the BMI range | https://imccalculadora.app/ | `homepage` + README |
| Packagist | `nbkdevs/imc-calculadora`: PHP BMI + classification (useful for WP/Laravel forms), from a root composer.json | https://imccalculadora.app/ | `homepage` + README |
| Docker Hub (iamnazzal) | `iamnazzal/imc-calculadora`: a tiny BMI API (GET /imc?peso=&altura=) + static page | https://imccalculadora.app/ | README anchor + OCI url label |
| HF Space (iamnazzal) | `iamnazzal/imc-calculadora`: a static bilingual BMI calculator page | https://imccalculadora.app/ | README anchor |
| ClawHub (nbkdevs) - the ONE skill | `bmi-calculator` / `calculadora-imc` SKILL.md: adult BMI + WHO class, child percentile note, healthy-weight range, safe wording (not medical advice). Slug `bmi-calculator` is free (404) | https://imccalculadora.app/metodologia/ | SKILL.md Links anchor + `metadata.openclaw.homepage` |
| Smithery skills (nbkdevs) | The same SKILL.md. **Smithery API/CLI shuts down 31 Oct 2026, so this must be published by tomorrow or dropped** | same | SKILL.md anchor (dofollow) |
| SourceForge | Project with the APK + README | https://imccalculadora.app/ | project homepage field |
| Product Hunt | Launch "IMC Calculadora": a free bilingual BMI calculator with methodology | https://imccalculadora.app/ | product website field |
| (stores, after rename) | AMO + Edge extension and CWS theme from "Built but not published" | https://imccalculadora.app/ | homepage/support/privacy fields |

## Searches and inconclusive results (30 Oct 2026 PKT)
- Firefox AMO: no match. The guid imc-calculadora@imccalculadora.app returned 404, and the NBK Devs (user 19655220) list of 35 add-ons has no IMC item. Conclusive.
- Edge: none of the 16 NBK Devs publisher items is IMC. Conclusive.
- Chrome Web Store: name searches for "IMC Calculadora" and "Mist Meadow" showed no NBK Devs item. CWS search is fuzzy, so this is mostly but not fully conclusive.
- **Amazon Appstore: inconclusive.** I hit the same bot interstitial as for BJ's and did not bypass it. Web searches only show other developers' "Calculadora IMC" apps. Nazzal should confirm in the Amazon developer console.
- Google Play: not in the AppBrain NBK Devs list (11 apps). This came from a search snippet.
- Registries, all 404/none: npm (names imc-calculadora, imccalculadora, calculadora-imc are free, and none of the 13 packages of maintainer iamnazzal.com is IMC), PyPI (imc-calculadora free; `calculadora-imc` is TAKEN by an unrelated author, Ytalo Hanieri Brito), crates.io, pub.dev (imc_calculadora and calculadora_imc are free; an unrelated `calculator_imc` exists), RubyGems, NuGet, Packagist (search 0; an unrelated vendor `imc/calculator` exists), Docker Hub iamnazzal (15 repos, none), HF iamnazzal (12 Spaces, none).
- ClawHub / Smithery / SourceForge / Product Hunt: same limits as for BJ's. There was no match, but there is no per-owner listing (ClawHub), the search is weak (Smithery), and curl got 403 (SourceForge, Product Hunt). Inconclusive.
- Tracking sheet (tab Softrank): no IMC rows.

## Live
- Amazon Appstore: https://www.amazon.com/gp/product/B0HM6VJWH3

## Skills (published 2026-10-30, v1.0.1, homepage anchor "Calculadora IMC")
- ClawHub: https://clawhub.ai/nbkdevs/bmi-calculator
- Smithery: https://smithery.ai/skills/nbkdevs/bmi-calculator (dofollow)

## Packages built 30 Oct 2026 (registries now published, see below)

All packages: version 1.0.0, MIT, author "IMC Calculadora", homepage https://imccalculadora.app/, README Links anchor [Calculadora IMC](https://imccalculadora.app/). Same spec and test vectors in every language (WHO classes, BMI rounded to 1 decimal before classifying, healthy range 18.5–24.9, metric/imperial, comma decimals, ES/EN). Names checked free on 30 Oct. Each folder has a LISTING.md with the publish command. Nothing was published.

| Registry | Package | Version | Planned URL | Dry-run (30 Oct, PKT) |
|---|---|---|---|---|
| npm | `imc-calculadora` (packages/npm) | 1.0.0 | https://www.npmjs.com/package/imc-calculadora | 5 tests pass; `npm pack --dry-run` OK (5.0 kB, 5 files) |
| PyPI | `imc-calculadora` (packages/pypi) | 1.0.0 | https://pypi.org/project/imc-calculadora/ | pytest 12 pass; `python -m build` OK; `twine check` PASSED (wheel + sdist) |
| crates.io | `imc-calculadora` (packages/crates) | 1.0.0 | https://crates.io/crates/imc-calculadora | 5 unit + 1 doc test pass; `cargo package` verified |
| pub.dev | `imc_calculadora` (packages/pub) | 1.0.0 | https://pub.dev/packages/imc_calculadora | 5 tests pass; `dart pub publish --dry-run`: 0 warnings |
| NuGet | `ImcCalculadora` (packages/nuget) | 1.0.0 | https://www.nuget.org/packages/ImcCalculadora | 14 tests pass; `dotnet pack` OK (README, LICENSE, lib/net8.0) |
| RubyGems | `imc_calculadora` (packages/rubygems) | 1.0.0 | https://rubygems.org/gems/imc_calculadora | minitest 5 runs / 16 assertions pass; `gem build` OK |
| Packagist | `imccalculadora/imc-calculadora` (root composer.json → packages/packagist) | 1.0.0 | https://packagist.org/packages/imccalculadora/imc-calculadora | `composer validate --strict` OK; phpunit 5 tests / 13 assertions OK |
| Docker Hub | `iamnazzal/imc-calculadora` (packages/docker) | 1.0.0 | https://hub.docker.com/r/iamnazzal/imc-calculadora | server test pass; no Docker daemon on the box, so built daemonless (amd64 + arm64, OCI url label = site), smoke-tested, not pushed |
| HF Space | `iamnazzal/imc-calculadora` (packages/hf-space, sdk static) | 1.0.0 | https://huggingface.co/spaces/iamnazzal/imc-calculadora | page renders in headless Chrome; calculator works |
| SourceForge | `imc-calculadora` (packages/sourceforge/PROJECT.md) | 1.0.0 | https://sourceforge.net/projects/imc-calculadora/ | description + files plan drafted |
| Product Hunt | "Calculadora IMC" (packages/producthunt/LISTING.md) | – | https://www.producthunt.com/ | draft; tagline 52 chars |

Screenshots for listings: /workspace/uploads/imc-screens/ (box only).

## Registry packages published 30 Oct 2026 (~18:35–18:40 PKT), v1.0.0

Owner approved publishing. Link checked on the rendered live page; "dofollow" = no nofollow/ugc on the rel attribute.

| Registry | Package | Live URL | HTTP | Link to https://imccalculadora.app/ | Link type |
|---|---|---|---|---|---|
| npm | imc-calculadora | https://www.npmjs.com/package/imc-calculadora | 200 (browser) | Homepage sidebar + README anchor | nofollow (sidebar `noopener noreferrer nofollow`, README `nofollow`). npm also shows its own staging placeholder version 0.0.0-stage; latest = 1.0.0 |
| PyPI | imc-calculadora | https://pypi.org/project/imc-calculadora/ | 200 | Homepage/Documentation project links + README anchor | nofollow |
| crates.io | imc-calculadora | https://crates.io/crates/imc-calculadora | 200 | Homepage sidebar + README anchor | **dofollow** sidebar homepage (no rel); README `nofollow noopener noreferrer` |
| pub.dev | imc_calculadora | https://pub.dev/packages/imc_calculadora | 200 | Homepage sidebar + README anchor | ugc |
| NuGet | ImcCalculadora | https://www.nuget.org/packages/ImcCalculadora | 200 | Project website + README anchor | nofollow (search index/flat container still catching up at check time) |
| RubyGems | imc_calculadora | https://rubygems.org/gems/imc_calculadora | 200 | Homepage sidebar | nofollow |
| Docker Hub | iamnazzal/imc-calculadora:1.0.0, latest (amd64+arm64) | https://hub.docker.com/r/iamnazzal/imc-calculadora | 200 | Overview = README, anchor "Calculadora IMC"; OCI url label | **dofollow** (`noopener noreferrer`) |
| Packagist | imccalculadora/imc-calculadora (root composer.json) | https://packagist.org/packages/submit | – | – | **Blocked:** no Packagist API token on the box; submit https://github.com/nbkdevs/imc-calculadora in the browser |

Docker push: daemonless (go-containerregistry), user iamnazzal. Index digest sha256:62fe0c6c97c5678818c2417d5b090f35b26feced9eb3a37a7ce04b0474501e0b (amd64 sha256:297ec480…, arm64 sha256:aec2fa51…). Hub short description and overview set via the Hub API.

Not uploaded yet (waiting for the owner): HF Space, SourceForge, Product Hunt.
