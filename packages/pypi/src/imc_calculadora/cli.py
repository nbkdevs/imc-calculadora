"""Command line: imc-calculadora 82 175 [--en] [--json]."""
from __future__ import annotations

import argparse
import json
import sys

from . import calculate, healthy_range


def main(argv=None) -> int:
    p = argparse.ArgumentParser(
        prog="imc-calculadora",
        description="Adult BMI (IMC) with WHO classes. Examples: 82 175 | 70,5 1,68 --en | --lb 154 --in 69 | --rango 168")
    p.add_argument("peso", nargs="?", help="weight in kg (comma or dot decimals)")
    p.add_argument("altura", nargs="?", help="height in cm, or m when below 3")
    p.add_argument("--lb", help="weight in pounds")
    p.add_argument("--in", dest="inches", help="height in inches")
    p.add_argument("--rango", help="print the healthy-weight range for a height (cm or m)")
    p.add_argument("--en", action="store_true", help="English labels")
    p.add_argument("--json", action="store_true", help="JSON output")
    a = p.parse_args(argv)
    lang = "en" if a.en else "es"
    fmt = (lambda n: f"{n:.1f}") if a.en else (lambda n: f"{n:.1f}".replace(".", ","))
    try:
        if a.rango is not None:
            lo, hi = healthy_range(a.rango)
            if a.json:
                print(json.dumps({"min_kg": lo, "max_kg": hi}))
            else:
                print(f"{'Healthy weight' if a.en else 'Peso saludable'}: {fmt(lo)} - {fmt(hi)} kg")
            return 0
        if a.lb is not None or a.inches is not None:
            r = calculate(weight_lb=a.lb, height_in=a.inches, lang=lang)
        else:
            if a.peso is None or a.altura is None:
                p.print_help()
                return 2
            r = calculate(a.peso, a.altura, lang=lang)
    except (ValueError, TypeError) as e:
        print(f"error: {e}", file=sys.stderr)
        return 2
    if a.json:
        print(json.dumps(r.to_dict(), ensure_ascii=False, indent=2))
        return 0
    print(f"{'BMI' if a.en else 'IMC'} {fmt(r.bmi)}: {r.label}")
    print(r.message)
    print(f"{'Healthy weight' if a.en else 'Peso saludable'}: {fmt(r.min_kg)} - {fmt(r.max_kg)} kg")
    print(r.disclaimer)
    return 0


if __name__ == "__main__":
    sys.exit(main())
