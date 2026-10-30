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
pip install imc-calculadora
```

## Library

```python
import imc_calculadora as imc

r = imc.calculate(82, 175)
r.bmi, r.key, r.label, r.diff_kg      # (26.8, 'sobrepeso', 'Sobrepeso', 5.7)
r.min_kg, r.max_kg                    # (56.7, 76.3)

imc.calculate(weight_lb=154, height_in=69, lang="en").label   # 'Normal weight'
imc.classify(24.96).key               # 'sobrepeso' (rounded to 25.0 first)
imc.healthy_range("1,68")             # (52.2, 70.3)
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
