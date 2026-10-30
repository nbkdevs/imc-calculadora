# IMC Calculadora — Android store builds

Offline Flutter app mirroring [imccalculadora.app](https://imccalculadora.app/): adult IMC, kids percentiles (CDC LMS), ideal weight, and pregnancy gain bands.

## Release artifacts

| File | Use |
|------|-----|
| `dist/IMC-Calculadora-1.0.0.aab` | **Google Play Console** (preferred) |
| `dist/IMC-Calculadora-1.0.0.apk` | **Amazon Appstore** and sideload testing |

Application ID: `app.imccalculadora.android`  
Version: `1.0.0` (versionCode `1`)  
Min SDK: 24 · Target SDK: Flutter default (35+)

## Signing (keep private)

- Keystore: `android/keystore/imc-release.jks` (gitignored)
- Config: `android/key.properties` (gitignored)
- Alias: `imc`

Back up the `.jks` and passwords offline. Losing them blocks updates on both stores.

Rebuild:

```bash
cd app
export JAVA_HOME=… ANDROID_HOME=… GRADLE_USER_HOME=~/.gradle
flutter build appbundle --release   # Play
flutter build apk --release         # Amazon / universal APK
```

## Google Play

1. Create app → package name must match `app.imccalculadora.android`.
2. Upload the **AAB** under Production (or Internal testing first).
3. Complete store listing (ES primary): title *IMC Calculadora*, short/full description, screenshots (phone + 7" tablet if needed), feature graphic 1024×500, icon 512×512.
4. Privacy policy URL: `https://imccalculadora.app/` (or dedicated privacy page).
5. Content rating questionnaire; declare Health app; medical disclaimer (not a diagnostic device).
6. Data safety: local history only via `shared_preferences`; no account, no analytics SDK in this build.

## Amazon Appstore

1. Create Android app; upload the **APK** (universal).
2. Same listing assets; set category Health & Fitness.
3. Target Fire OS / Android; min API 24 is fine for current Fire tablets.
4. Use the **same signing key** as Play so binary fingerprints stay consistent.

## App contents

- Adult IMC (OMS categories)
- Niño/a BMI-for-age percentiles (CDC LMS)
- Peso ideal (IMC 18.5–24.9)
- Embarazo (IOM gain bands)
- Local history + share text
- No network required for calculators
