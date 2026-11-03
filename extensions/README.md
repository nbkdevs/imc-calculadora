# Browser packages

| Package | Path | Store |
|---------|------|--------|
| Firefox extension "BMI Pocket Calculator" | `dist/bmi-pocket-calculator-firefox-1.0.0.zip` | [addons.mozilla.org](https://addons.mozilla.org/) |
| Edge extension "BMI Pocket Calculator" | `dist/bmi-pocket-calculator-edge-1.0.0.zip` | [Microsoft Edge Add-ons](https://partner.microsoft.com/dashboard) |
| Chrome theme "Mist Meadow" | `dist/mist-meadow-chrome-theme-1.0.0.zip` | Chrome Web Store → Theme |

Source folders: `firefox/`, `edge/`, `chrome-theme/`. Shared UI lives in `shared/` and is copied when packaging. The extension has no link to any website; the site goes only in the store URL fields (see STORE_LISTINGS.md).

## Load unpacked (dev)

- **Firefox:** `about:debugging` → This Firefox → Load Temporary Add-on → select `firefox/manifest.json`
- **Edge:** `edge://extensions` → Developer mode → Load unpacked → `edge/`
- **Chrome theme:** `chrome://extensions` → Load unpacked → `chrome-theme/`

## Rebuild ZIPs and store images

```bash
python3 extensions/package.py
python3 extensions/store-assets/make_assets.py   # icons + 1280x800/640x400 screenshots + 440x280 + 300x300 logo
npx web-ext lint -s extensions/firefox
```

Store copy: [STORE_LISTINGS.md](STORE_LISTINGS.md)
