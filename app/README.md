# IMC Calculadora (Android)

Flutter app for [imccalculadora.app](https://imccalculadora.app/) — offline IMC calculators for adults, children, ideal weight, and pregnancy.

## Develop

```bash
cd app
flutter pub get
flutter test
flutter run
```

## Release builds

See [STORE.md](STORE.md) for Play Store and Amazon Appstore packaging.

```bash
flutter build appbundle --release
flutter build apk --release
```

Artifacts land in `dist/` after a successful store build.
