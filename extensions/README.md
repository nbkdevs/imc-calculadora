# Browser packages — IMC Calculadora

| Package | Path | Store |
|---------|------|--------|
| Firefox extension | `dist/IMC-Calculadora-firefox-1.0.0.zip` | [addons.mozilla.org](https://addons.mozilla.org/) |
| Edge extension | `dist/IMC-Calculadora-edge-1.0.0.zip` | [Microsoft Edge Add-ons](https://partner.microsoft.com/dashboard) |
| Chrome theme (*Mist Meadow*) | `dist/IMC-Calculadora-chrome-theme-1.0.0.zip` | Chrome Web Store → Theme |

Source folders: `firefox/`, `edge/`, `chrome-theme/`. Shared UI lives in `shared/` and is copied when packaging.

## Load unpacked (dev)

- **Firefox:** `about:debugging` → This Firefox → Load Temporary Add-on → select `firefox/manifest.json`
- **Edge:** `edge://extensions` → Developer mode → Load unpacked → `edge/`
- **Chrome theme:** `chrome://extensions` → Load unpacked → `chrome-theme/`

## Rebuild ZIPs

```bash
python3 extensions/package.py
```

Store copy (EN/ES): [STORE_LISTINGS.md](STORE_LISTINGS.md)
