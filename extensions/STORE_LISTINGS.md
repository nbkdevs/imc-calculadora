# Browser store listings: BMI Pocket Calculator (Firefox AMO, Edge) and Mist Meadow (Chrome Web Store theme)

Updated 3 Nov 2026 (PKT). Browser-store items carry no brand, trademark or place names, and the listing copy has no site link or site name.
The site goes ONLY in the URL fields below. (The Android app copy now lives in `app/APP_STORE_LISTING.md`.)

## URL fields (the only place the site appears)

| Field | AMO (Firefox) | Edge Add-ons | Chrome Web Store (theme) |
|---|---|---|---|
| Homepage / website | https://imccalculadora.app/ | https://imccalculadora.app/ | https://imccalculadora.app/ (Store listing → Homepage URL) |
| Support | https://imccalculadora.app/contacto/ | https://imccalculadora.app/contacto/ | https://imccalculadora.app/contacto/ (Support URL) |
| Privacy policy | leave blank (playbook rule; no data collected) | The site has **no privacy page** (checked 3 Nov: sitemap lists /, /sobre-nosotros/, /metodologia/, /peso-ideal/, /imc-embarazo/, /imc-ninos/, /app/, /contacto/; /privacidad/, /politica-de-privacidad/, /privacy-policy/ all 404). The extension collects no personal data, so Edge does not require one: leave it blank, or add https://imccalculadora.app/privacidad/ once Nazzal publishes that page | leave blank |

## Packages

| Store | Zip | Name in manifest |
|---|---|---|
| Firefox AMO | `dist/bmi-pocket-calculator-firefox-1.0.0.zip` (gecko id `bmi-pocket-calculator@nbkdevs`) | BMI Pocket Calculator |
| Edge Add-ons | `dist/bmi-pocket-calculator-edge-1.0.0.zip` | BMI Pocket Calculator |
| Chrome Web Store (theme only) | `dist/mist-meadow-chrome-theme-1.0.0.zip` | Mist Meadow |

## Images (store-assets/)

| Store | Asset | File |
|---|---|---|
| AMO | Screenshots (1280x800, AMO shows them at 1280x800 / 700x438) | `store-assets/screenshot-{1-adult,2-child,3-pregnancy,4-history}-1280x800.png` |
| AMO | Icon 128 (inside the package too) | `store-assets/amo-icon-128x128.png` |
| Edge | Screenshots 1280x800 (or 640x400) | `store-assets/screenshot-*-1280x800.png` / `*-640x400.png` |
| Edge | Logo 300x300 | `store-assets/edge-logo-300x300.png` |
| Edge | Small promotional tile 440x280 (optional) | `store-assets/promo-small-440x280.png` |
| CWS theme | Screenshot 1280x800 (or 640x400) | `store-assets/theme/mist-meadow-screenshot-1280x800.png` / `-640x400.png` |
| CWS theme | Small promo tile 440x280 | `store-assets/theme/mist-meadow-small-promo-440x280.png` |

`store-assets/make_assets.py` redraws the icon set and composes the screenshots from popup captures in `store-assets/raw/` (captured from the unpacked extension in Chrome for Testing).

---

## Firefox AMO: BMI Pocket Calculator

**Name:** BMI Pocket Calculator
**Category:** Other
**Tags:** bmi, health, calculator, fitness, offline
**License:** MIT

**Summary (≤250):**
Offline BMI calculator in your toolbar: adult BMI with WHO classes, child BMI-for-age percentiles (2-19), ideal weight range and pregnancy weight gain. No account, nothing uploaded.

**Description:**
BMI Pocket Calculator puts four body-mass calculators in one small toolbar popup. Everything is calculated on your device: there is no account, no server and no tracking.

- Adult BMI: enter weight (kg) and height (cm) to get your BMI rounded to one decimal and its WHO class (underweight, normal, overweight, obesity I-III), plus how many kilograms you are from the normal range for your height.
- Child BMI (ages 2-19): BMI-for-age percentile by age and sex from the CDC LMS growth tables, not adult cut-offs, with a plain-language category.
- Ideal weight: the weight range that matches a normal BMI (18.5-24.9) for a given height, in kilograms and pounds.
- Pregnancy weight gain: the total recommended gain for a singleton pregnancy from pre-pregnancy BMI (IOM/ACOG), and a check of your current gain against the reference for your week.
- History: save a result to a short history kept only in this browser, copy any result in one tap, and clear the history whenever you like.

The interface is in Spanish. This tool is educational and does not replace advice from a doctor, pediatrician or midwife.

**Permission justification:**
- `storage`: keeps the optional result history in the browser's local storage on this device. Nothing is synced or sent anywhere.
- No host permissions, no tabs/activeTab, no content scripts, no remote code.

**Data collection:** none (`data_collection_permissions.required: ["none"]`).
**Privacy policy:** blank.
**Notes to reviewer:** No build step; the zip is the source (plain HTML/CSS/JS). Open the toolbar button → "Adultos" → enter 72 kg / 175 cm → "Calcular" shows BMI 23.5 "Peso normal"; "Guardar" adds it to "Historial".

---

## Microsoft Edge Add-ons: BMI Pocket Calculator

**Name:** BMI Pocket Calculator
**Category:** Productivity
**Short description (manifest, ≤132):** Offline BMI calculator for adults, children (2-19), ideal weight and pregnancy weight gain. Private, no account.

**Description (≥250):**
BMI Pocket Calculator is a private, offline body-mass toolkit that opens from the Edge toolbar.

Adult BMI: enter weight and height to see your BMI and WHO class, plus how many kilograms you are from the normal range for your height.
Child BMI (2-19 years): BMI-for-age percentile by age and sex using the CDC LMS growth tables.
Ideal weight: the healthy weight range (BMI 18.5-24.9) for your height, in kg and lb.
Pregnancy weight gain: the recommended total gain for a singleton pregnancy from your pre-pregnancy BMI (IOM/ACOG), with a check for your current week.
History: save results locally in this browser, copy a result in one tap, clear it at any time.

Everything runs on your device. No account, no ads, no analytics, and no data leaves the browser. The interface is in Spanish. Educational use only; it does not replace medical advice.

**Single purpose:** Calculate body mass index (and related healthy-weight ranges) offline in a toolbar popup.

**Permission justification:**
- `storage`: saves the optional calculation history locally on this device so the user can review it later. Data is never uploaded.

**Privacy policy URL:** see the URL table above (no privacy page on the site yet; no personal data is collected).
**Website:** https://imccalculadora.app/  **Support:** https://imccalculadora.app/contacto/

**Notes for certification (test steps):**
1. Click the toolbar icon to open the popup (no sign-in, works offline).
2. "Adultos": weight 72, height 175 → "Calcular" → BMI 23.5, "Peso normal". Click "Guardar".
3. "Niños": age 9, months 4, sex Niño, weight 31, height 134 → percentile result.
4. "Peso ideal": height 168 → 52.2-70.3 kg.
5. "Embarazo": pre-weight 62, height 165, week 24, current 68 → 11.5-16.0 kg total band.
6. "Historial" lists the saved results; "Borrar historial" clears them.

---

## Chrome Web Store (theme): Mist Meadow

**Name:** Mist Meadow
**Category:** Themes
**Summary (manifest, ≤132):** A calm Chrome theme: a misty sage meadow at dawn, a soft teal frame and a quiet cream toolbar.

**Description:**
Mist Meadow is a quiet, low-contrast Chrome theme. The new tab page shows a misty sage meadow at first light, framed by a deep teal title bar and a soft cream toolbar that keeps text easy to read. Background tabs use a muted green-grey so the active tab stands out without bright colours.

- New tab background: hand-picked misty meadow illustration (1920x1080), anchored to the bottom
- Deep teal frame, cream toolbar, white address bar
- Readable tab, bookmark and new-tab text colours

Themes have no permissions and collect no data.

**Permissions:** none (theme). **Privacy:** no data collected; privacy URL left blank. Data-use disclosures: "does not collect user data".

---

## Español (AMO / Edge, traducción del texto de arriba)

**Resumen:** Calculadora de IMC sin conexión en la barra: IMC de adultos con clases OMS, percentiles infantiles (2-19 años), rango de peso ideal y aumento de peso en el embarazo. Sin cuenta, sin enviar datos.

**Descripción:**
BMI Pocket Calculator reúne cuatro calculadoras en un pequeño popup de la barra de herramientas. Todo se calcula en tu dispositivo: sin cuenta, sin servidor y sin rastreo.

- IMC de adultos: peso y estatura → IMC con un decimal y clase OMS, y cuántos kg te separan del rango normal para tu estatura.
- IMC infantil (2-19 años): percentil de IMC para la edad según edad y sexo, con las tablas LMS del CDC.
- Peso ideal: rango de peso para un IMC normal (18.5-24.9) según la estatura, en kg y lb.
- Embarazo: aumento total recomendado para embarazo único según el IMC previo (IOM/ACOG) y comparación con la referencia de tu semana.
- Historial: guarda resultados solo en este navegador, cópialos en un toque y bórralos cuando quieras.

Es una herramienta educativa y no sustituye el consejo médico.

**Permiso `storage`:** guarda el historial opcional en el almacenamiento local del navegador; nunca se sube ni se sincroniza.
