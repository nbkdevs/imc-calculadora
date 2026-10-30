# IMC Calculadora

Open-source tools behind [Calculadora IMC](https://imccalculadora.app/): an adult BMI (IMC) calculator with the WHO classification, the healthy-weight range for a height, metric and imperial input, and Spanish and English labels.

| Folder | What |
|---|---|
| `app/` | Flutter Android app (`app.imccalculadora.android`), on the [Amazon Appstore](https://www.amazon.com/gp/product/B0HM6VJWH3) |
| `packages/npm` | `imc-calculadora` for Node.js (library + CLI) |
| `packages/pypi` | `imc-calculadora` for Python |
| `packages/crates` | `imc-calculadora` for Rust |
| `packages/pub` | `imc_calculadora` for Dart |
| `packages/nuget` | `ImcCalculadora` for .NET |
| `packages/rubygems` | `imc_calculadora` for Ruby |
| `packages/packagist` | `imccalculadora/imc-calculadora` for PHP (root `composer.json`) |
| `packages/docker` | `iamnazzal/imc-calculadora`: BMI API + calculator page |
| `packages/hf-space` | static bilingual calculator page (Hugging Face Space) |
| `extensions/`, `skills/` | browser extension, theme and agent skill |

Every package implements the same rules and passes the same test vectors: BMI rounded to 1 decimal before it is classified, WHO classes from *delgadez severa* (< 16) to *obesidad grado III* (≥ 40), and a healthy range of BMI 18.5–24.9.

```
$ npx imc-calculadora 82 175
IMC 26,8: Sobrepeso
Tu IMC indica sobrepeso. Te sobran 5,7 kg respecto al rango normal.
```

BMI is a general screening measure for adults and is not medical advice.

## Links

- [Calculadora IMC](https://imccalculadora.app/)

## License

MIT
