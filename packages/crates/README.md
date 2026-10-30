# imc-calculadora

Calculadora IMC / BMI calculator for adults: body mass index with the WHO classification, the healthy-weight range for a height, metric and imperial input, and Spanish and English labels.

- **WHO adult classes** with the three thinness subclasses (severa, moderada, leve) and obesity classes I–III.
- **Rounds to 1 decimal before classifying**, the way BMI is reported: 24.96 → 25.0 → *Sobrepeso*. No more "24.96 is normal" edge cases.
- **Healthy-weight range** for a height (BMI 18.5 to 24.9) and how many kg are missing or extra.
- **Metric and imperial**: kg + cm (or metres, `1,75`), or lb + in using 703 · lb / in².
- **Comma or dot decimals** (`70,5` and `70.5` both work), handy for Spanish-language forms.
- **Spanish and English** labels and messages, with a not-medical-advice note.
- Library + CLI, no dependencies.

## Install

```
cargo add imc-calculadora   # library
cargo install imc-calculadora   # CLI
```

## Library

```rust
use imc_calculadora::{calculate_imperial, calculate_metric, classify, healthy_range, parse_number, Lang};

let r = calculate_metric(82.0, 175.0, Lang::Es).unwrap();
assert_eq!((r.bmi, r.key, r.diff_kg), (26.8, "sobrepeso", 5.7));

assert_eq!(calculate_imperial(154.0, 69.0, Lang::En).unwrap().label, "Normal weight");
assert_eq!(classify(24.96, Lang::Es).key, "sobrepeso"); // rounded to 25.0 first
assert_eq!(healthy_range(parse_number("1,68").unwrap()).unwrap(), (52.2, 70.3));
```

## CLI

```
$ imc-calculadora 82 175
IMC 26,8: Sobrepeso
Tu IMC indica sobrepeso. Te sobran 5,7 kg respecto al rango normal.
Peso saludable: 56,7 - 76,3 kg
El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.

$ imc-calculadora --lb 154 --in 69 --en
BMI 22.7: Normal weight
Your BMI is in the normal range for your height.
Healthy weight: 56.8 - 76.5 kg
BMI is a general guide for adults and is not medical advice.

$ imc-calculadora --rango 1,68
Peso saludable: 52,2 - 70,3 kg
```

Add `--json` for machine-readable output.

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

The BMI is rounded half up to 1 decimal first, then compared with these bounds.

## Note

BMI is a general screening measure for adults (18+). It does not tell muscle from fat and is not medical advice. For children and teens, use age- and sex-specific percentiles.

## Links

- [Calculadora IMC](https://imccalculadora.app/): free online BMI calculator in Spanish with the WHO table, healthy-weight range and methodology.
- Source: https://github.com/nbkdevs/imc-calculadora

## License

MIT
