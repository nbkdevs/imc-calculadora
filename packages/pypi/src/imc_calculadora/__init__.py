"""imc-calculadora: adult BMI (IMC) with WHO classes, healthy-weight range,
metric/imperial input and Spanish/English labels. No dependencies.

The BMI is rounded to 1 decimal BEFORE it is classified (24.96 -> 25.0 -> overweight).
"""
from __future__ import annotations

import math
import re
from dataclasses import dataclass, asdict
from typing import Optional, Union

__version__ = "1.0.0"

LB_KG = 0.45359237
IN_CM = 2.54

# (key, upper bound exclusive on the 1-decimal BMI, es, en, group)
CLASSES = [
    ("delgadez_severa", 16.0, "Delgadez severa", "Severe thinness", "bajo"),
    ("delgadez_moderada", 17.0, "Delgadez moderada", "Moderate thinness", "bajo"),
    ("delgadez_leve", 18.5, "Delgadez leve", "Mild thinness", "bajo"),
    ("normal", 25.0, "Peso normal", "Normal weight", "normal"),
    ("sobrepeso", 30.0, "Sobrepeso", "Overweight", "sobrepeso"),
    ("obesidad_1", 35.0, "Obesidad grado I", "Obesity class I", "obesidad"),
    ("obesidad_2", 40.0, "Obesidad grado II", "Obesity class II", "obesidad"),
    ("obesidad_3", math.inf, "Obesidad grado III", "Obesity class III", "obesidad"),
]

DISCLAIMER = {
    "es": "El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.",
    "en": "BMI is a general guide for adults and is not medical advice.",
}

Number = Union[int, float, str]
_NUM = re.compile(r"^\+?(\d+(\.\d+)?|\.\d+)$")


def round1(x: float) -> float:
    """Round half up to 1 decimal."""
    return math.floor(x * 10 + 0.5 + 1e-9) / 10


def parse_number(v: Number) -> float:
    """Parse "70,5", "70.5" or 70.5. Raises ValueError otherwise."""
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        if not math.isfinite(v):
            raise ValueError("not a finite number")
        return float(v)
    s = str(v).strip().replace(",", ".", 1)
    if not _NUM.match(s):
        raise ValueError(f"invalid number: {v}")
    return float(s)


def height_cm(h: Number) -> float:
    """Height in cm; values below 3 are taken as metres (1,75 -> 175)."""
    n = parse_number(h)
    return n * 100 if n < 3 else n


def _lang(lang: Optional[str]) -> str:
    return "en" if lang == "en" else "es"


@dataclass
class Category:
    key: str
    label: str
    group: str
    bmi: float


def classify(bmi_value: Number, lang: str = "es") -> Category:
    """WHO class for a BMI; the value is rounded to 1 decimal first."""
    b = round1(parse_number(bmi_value))
    for key, upper, es, en, group in CLASSES:
        if b < upper:
            return Category(key, en if _lang(lang) == "en" else es, group, b)
    raise AssertionError("unreachable")


def bmi(weight_kg: Number, height: Number) -> float:
    """Raw BMI from kg and cm (or m), not rounded."""
    w = parse_number(weight_kg)
    h = height_cm(height) / 100
    if w <= 0 or h <= 0:
        raise ValueError("weight and height must be greater than 0")
    return w / (h * h)


def bmi_imperial(weight_lb: Number, height_in: Number) -> float:
    """Raw BMI from pounds and inches: 703 * lb / in^2."""
    w, h = parse_number(weight_lb), parse_number(height_in)
    if w <= 0 or h <= 0:
        raise ValueError("weight and height must be greater than 0")
    return 703 * w / (h * h)


def healthy_range(height: Number) -> tuple[float, float]:
    """Healthy-weight range (BMI 18.5 to 24.9) in kg for a height, 1 decimal."""
    h = height_cm(height) / 100
    if h <= 0:
        raise ValueError("height must be greater than 0")
    return round1(18.5 * h * h), round1(24.9 * h * h)


@dataclass
class Result:
    bmi: float
    key: str
    label: str
    group: str
    min_kg: float
    max_kg: float
    diff_kg: float
    message: str
    disclaimer: str

    def to_dict(self) -> dict:
        return asdict(self)


def _message(cat: Category, diff: float, lang: str) -> str:
    d = f"{diff:.1f}"
    if lang == "en":
        if cat.group == "normal":
            return "Your BMI is in the normal range for your height."
        side = "below" if cat.group == "bajo" else "above"
        return f"Your BMI shows {cat.label.lower()}. You are {d} kg {side} the normal range."
    d = d.replace(".", ",")
    if cat.group == "normal":
        return "Tu IMC está dentro del rango normal para tu estatura."
    if cat.group == "bajo":
        return f"Tu IMC indica {cat.label.lower()}. Te faltan {d} kg para llegar al rango normal."
    return f"Tu IMC indica {cat.label.lower()}. Te sobran {d} kg respecto al rango normal."


def calculate(weight_kg: Optional[Number] = None, height: Optional[Number] = None, *,
              weight_lb: Optional[Number] = None, height_in: Optional[Number] = None,
              lang: str = "es") -> Result:
    """Full result from kg + cm/m, or from weight_lb + height_in."""
    lang = _lang(lang)
    if weight_lb is not None or height_in is not None:
        raw = bmi_imperial(weight_lb, height_in)
        kg, cm = parse_number(weight_lb) * LB_KG, parse_number(height_in) * IN_CM
    else:
        raw = bmi(weight_kg, height)
        kg, cm = parse_number(weight_kg), height_cm(height)
    cat = classify(raw, lang)
    lo, hi = healthy_range(cm)
    diff = 0.0
    if cat.group == "bajo":
        diff = round1(max(0.0, lo - kg))
    elif cat.group != "normal":
        diff = round1(max(0.0, kg - hi))
    return Result(cat.bmi, cat.key, cat.label, cat.group, lo, hi, diff,
                  _message(cat, diff, lang), DISCLAIMER[lang])


__all__ = ["calculate", "classify", "bmi", "bmi_imperial", "healthy_range",
           "parse_number", "height_cm", "round1", "Result", "Category", "CLASSES", "DISCLAIMER"]
