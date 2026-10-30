# SourceForge project: imc-calculadora

| Field | Value |
|---|---|
| Project name | Calculadora IMC |
| URL name (unix name) | `imc-calculadora` → https://sourceforge.net/projects/imc-calculadora/ |
| Website | https://imccalculadora.app/ |
| Licence | MIT |
| Categories | Health / Medical Science Apps; Fitness; Libraries |
| Languages | JavaScript, Python, Rust, Dart, C#, Ruby, PHP |
| Natural languages | Spanish, English |
| OS | OS Independent; Android |
| Audience | End users, healthcare/fitness developers |
| Repository (external) | https://github.com/nbkdevs/imc-calculadora |

## Summary (≤ 70 chars)

Bilingual BMI (IMC) calculator with WHO classes and healthy weight

## Description

Calculadora IMC computes the adult body mass index from kg/cm or lb/in, classifies it with the WHO table (including the three thinness subclasses and obesity classes I–III) and shows the healthy-weight range for your height, plus how many kilos you are above or below it. The BMI is rounded to one decimal before it is classified, so a 24.96 is reported as 25.0 and classed as overweight, the same way it is printed. Comma and dot decimals both work, and everything is available in Spanish and English.

It ships as a browser page, a Docker image (API + page) and libraries with a CLI for npm, PyPI, crates.io, pub.dev, NuGet, RubyGems and Packagist, all sharing the same test vectors. The full online calculator and methodology are at [Calculadora IMC](https://imccalculadora.app/).

BMI is a general screening measure for adults and is not medical advice.

## Features

- WHO adult classes with ES/EN labels
- Healthy-weight range (BMI 18.5–24.9) and kg to reach it
- Metric (cm or metres) and imperial (703 · lb / in²) input
- Comma or dot decimals; rounding before classification
- Works offline; no account, no tracking

## Files plan

| Folder / file | Source | Notes |
|---|---|---|
| `/web/calculadora-imc-1.0.0.zip` | `packages/hf-space/` (index.html, README.md, LICENSE) | self-contained page, open index.html directly |
| `/cli/imc-calculadora-1.0.0.tgz` | `npm pack` in `packages/npm` | `npx imc-calculadora 70 1,75` |
| `/cli/imc_calculadora-1.0.0-py3-none-any.whl` + sdist | `python -m build` in `packages/pypi` | |
| `/source/imc-calculadora-1.0.0-src.zip` | `git archive --format zip HEAD packages/` | all libraries + Docker |
| `/android/` (optional) | the Amazon-listed app (`app/`) after a release build | only if the owner wants the APK mirrored |
| `README.md` (shown on Files page) | this description | |

Default download: the web zip. Upload only after the owner approves; screenshots from `/workspace/uploads/imc-screens/`.
