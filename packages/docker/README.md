# iamnazzal/imc-calculadora

A tiny BMI (IMC) API with the WHO adult classification and a bilingual (ES/EN) calculator page. No dependencies, runs as a non-root user, about 60 MB.

```
docker run --rm -p 8080:8080 iamnazzal/imc-calculadora
```

Open http://localhost:8080/ for the calculator page, or call the API:

| Endpoint | Example | Returns |
|---|---|---|
| `GET /api/imc` | `/api/imc?peso=82&altura=175` | `{"bmi":26.8,"key":"sobrepeso","label":"Sobrepeso","healthyRange":{"minKg":56.7,"maxKg":76.3},"diffKg":5.7,…}` |
| `GET /api/imc` (imperial) | `/api/imc?lb=154&in=69&lang=en` | `"label":"Normal weight"` |
| `GET /api/rango` | `/api/rango?altura=168` | `{"minKg":52.2,"maxKg":70.3}` |
| `GET /api/clases` | `/api/clases` | the 8 WHO classes with ES/EN labels |
| `GET /healthz` | | `{"ok":true}` (used by HEALTHCHECK) |

Comma decimals work (`peso=70,5&altura=1,68`). `lang=en` switches labels and messages to English. English aliases: `/api/bmi`, `/api/range`, `/api/classes`.

- **WHO adult classes** with the three thinness subclasses (severa, moderada, leve) and obesity classes I–III.
- **Rounds to 1 decimal before classifying**, the way BMI is reported: 24.96 → 25.0 → *Sobrepeso*. No more "24.96 is normal" edge cases.
- **Healthy-weight range** for a height (BMI 18.5 to 24.9) and how many kg are missing or extra.
- **Metric and imperial**: kg + cm (or metres, `1,75`), or lb + in using 703 · lb / in².
- **Comma or dot decimals** (`70,5` and `70.5` both work), handy for Spanish-language forms.
- **Spanish and English** labels and messages, with a not-medical-advice note.
- Library + CLI, no dependencies.

## WHO classes

| Key | Español | English | BMI (1 decimal) |
|---|---|---|---|
| `delgadez_severa` | Delgadez severa | Severe thinness | < 16.0 |
| `delgadez_moderada` | Delgadez moderada | Moderate thinness | 16.0 – 16.9 |
| `delgadez_leve` | Delgadez leve | Mild thinness | 17.0 – 18.4 |
| `normal` | Peso normal | Normal weight | 18.5 – 24.9 |
| `sobrepeso` | Sobrepeso | Overweight | 25.0 – 29.9 |
| `obesidad_1` | Obesidad grado I | Obesity class I | 30.0 – 34.9 |
| `obesidad_2` | Obesidad grado II | Obesity class II | 35.0 – 39.9 |
| `obesidad_3` | Obesidad grado III | Obesity class III | ≥ 40.0 |

BMI is a general screening measure for adults and is not medical advice.

## Links

- [Calculadora IMC](https://imccalculadora.app/): free online BMI calculator in Spanish with the WHO table, healthy-weight range and methodology.
- Source: https://github.com/nbkdevs/imc-calculadora (`packages/docker`). The core is the npm package `imc-calculadora`.

## License

MIT
