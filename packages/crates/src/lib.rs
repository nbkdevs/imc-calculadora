//! # imc-calculadora
//!
//! Adult BMI (IMC) with WHO classes, healthy-weight range, metric/imperial input
//! and Spanish/English labels. No dependencies.
//!
//! The BMI is rounded to 1 decimal **before** it is classified (24.96 -> 25.0 -> overweight).
//!
//! ```
//! let r = imc_calculadora::calculate_metric(82.0, 175.0, imc_calculadora::Lang::Es).unwrap();
//! assert_eq!(r.bmi, 26.8);
//! assert_eq!(r.key, "sobrepeso");
//! ```

use std::fmt;

/// Kilograms per pound.
pub const LB_KG: f64 = 0.45359237;
/// Centimetres per inch.
pub const IN_CM: f64 = 2.54;

/// Output language.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Lang {
    /// Spanish (default).
    Es,
    /// English.
    En,
}

/// One WHO class: key, exclusive upper bound, Spanish and English labels, group.
pub struct Class {
    pub key: &'static str,
    pub upper: f64,
    pub es: &'static str,
    pub en: &'static str,
    pub group: &'static str,
}

/// WHO adult classes, including the three thinness subclasses.
pub const CLASSES: [Class; 8] = [
    Class { key: "delgadez_severa", upper: 16.0, es: "Delgadez severa", en: "Severe thinness", group: "bajo" },
    Class { key: "delgadez_moderada", upper: 17.0, es: "Delgadez moderada", en: "Moderate thinness", group: "bajo" },
    Class { key: "delgadez_leve", upper: 18.5, es: "Delgadez leve", en: "Mild thinness", group: "bajo" },
    Class { key: "normal", upper: 25.0, es: "Peso normal", en: "Normal weight", group: "normal" },
    Class { key: "sobrepeso", upper: 30.0, es: "Sobrepeso", en: "Overweight", group: "sobrepeso" },
    Class { key: "obesidad_1", upper: 35.0, es: "Obesidad grado I", en: "Obesity class I", group: "obesidad" },
    Class { key: "obesidad_2", upper: 40.0, es: "Obesidad grado II", en: "Obesity class II", group: "obesidad" },
    Class { key: "obesidad_3", upper: f64::INFINITY, es: "Obesidad grado III", en: "Obesity class III", group: "obesidad" },
];

/// Not-medical-advice note.
pub fn disclaimer(lang: Lang) -> &'static str {
    match lang {
        Lang::Es => "El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.",
        Lang::En => "BMI is a general guide for adults and is not medical advice.",
    }
}

/// Input error.
#[derive(Debug, Clone, PartialEq)]
pub enum ImcError {
    /// Text that is not a number.
    InvalidNumber(String),
    /// Weight or height is zero or negative.
    NonPositive,
}

impl fmt::Display for ImcError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ImcError::InvalidNumber(s) => write!(f, "invalid number: {s}"),
            ImcError::NonPositive => write!(f, "weight and height must be greater than 0"),
        }
    }
}

impl std::error::Error for ImcError {}

/// Round half up to 1 decimal.
pub fn round1(x: f64) -> f64 {
    (x * 10.0 + 0.5 + 1e-9).floor() / 10.0
}

/// Parse "70,5" or "70.5".
pub fn parse_number(s: &str) -> Result<f64, ImcError> {
    let t = s.trim().replacen(',', ".", 1);
    let t2 = t.strip_prefix('+').unwrap_or(&t);
    let ok = !t2.is_empty()
        && t2.chars().all(|c| c.is_ascii_digit() || c == '.')
        && t2.matches('.').count() <= 1
        && !t2.ends_with('.');
    if !ok {
        return Err(ImcError::InvalidNumber(s.to_string()));
    }
    t2.parse::<f64>().map_err(|_| ImcError::InvalidNumber(s.to_string()))
}

/// Height in cm; values below 3 are taken as metres (1.75 -> 175).
pub fn height_cm(h: f64) -> f64 {
    if h < 3.0 { h * 100.0 } else { h }
}

/// A classified BMI.
#[derive(Debug, Clone, PartialEq)]
pub struct Category {
    pub key: &'static str,
    pub label: &'static str,
    pub group: &'static str,
    pub bmi: f64,
}

/// WHO class for a BMI; the value is rounded to 1 decimal first.
pub fn classify(bmi: f64, lang: Lang) -> Category {
    let b = round1(bmi);
    let c = CLASSES.iter().find(|c| b < c.upper).unwrap_or(&CLASSES[7]);
    Category { key: c.key, label: if lang == Lang::En { c.en } else { c.es }, group: c.group, bmi: b }
}

/// Raw BMI from kg and cm (or m).
pub fn bmi(weight_kg: f64, height: f64) -> Result<f64, ImcError> {
    let h = height_cm(height) / 100.0;
    if !(weight_kg > 0.0) || !(h > 0.0) {
        return Err(ImcError::NonPositive);
    }
    Ok(weight_kg / (h * h))
}

/// Raw BMI from pounds and inches: 703 * lb / in^2.
pub fn bmi_imperial(weight_lb: f64, height_in: f64) -> Result<f64, ImcError> {
    if !(weight_lb > 0.0) || !(height_in > 0.0) {
        return Err(ImcError::NonPositive);
    }
    Ok(703.0 * weight_lb / (height_in * height_in))
}

/// Healthy-weight range (BMI 18.5 to 24.9) in kg, 1 decimal.
pub fn healthy_range(height: f64) -> Result<(f64, f64), ImcError> {
    let h = height_cm(height) / 100.0;
    if !(h > 0.0) {
        return Err(ImcError::NonPositive);
    }
    Ok((round1(18.5 * h * h), round1(24.9 * h * h)))
}

/// Full result.
#[derive(Debug, Clone, PartialEq)]
pub struct ImcResult {
    pub bmi: f64,
    pub key: &'static str,
    pub label: &'static str,
    pub group: &'static str,
    pub min_kg: f64,
    pub max_kg: f64,
    pub diff_kg: f64,
    pub message: String,
    pub disclaimer: &'static str,
}

fn message(c: &Category, diff: f64, lang: Lang) -> String {
    let d = format!("{diff:.1}");
    let low = c.label.to_lowercase();
    match lang {
        Lang::En => match c.group {
            "normal" => "Your BMI is in the normal range for your height.".to_string(),
            "bajo" => format!("Your BMI shows {low}. You are {d} kg below the normal range."),
            _ => format!("Your BMI shows {low}. You are {d} kg above the normal range."),
        },
        Lang::Es => {
            let d = d.replace('.', ",");
            match c.group {
                "normal" => "Tu IMC está dentro del rango normal para tu estatura.".to_string(),
                "bajo" => format!("Tu IMC indica {low}. Te faltan {d} kg para llegar al rango normal."),
                _ => format!("Tu IMC indica {low}. Te sobran {d} kg respecto al rango normal."),
            }
        }
    }
}

fn build(raw: f64, kg: f64, cm: f64, lang: Lang) -> Result<ImcResult, ImcError> {
    let c = classify(raw, lang);
    let (lo, hi) = healthy_range(cm)?;
    let diff = match c.group {
        "bajo" => round1((lo - kg).max(0.0)),
        "normal" => 0.0,
        _ => round1((kg - hi).max(0.0)),
    };
    Ok(ImcResult {
        bmi: c.bmi, key: c.key, label: c.label, group: c.group, min_kg: lo, max_kg: hi, diff_kg: diff,
        message: message(&c, diff, lang), disclaimer: disclaimer(lang),
    })
}

/// Full result from kg and cm (or m).
pub fn calculate_metric(weight_kg: f64, height: f64, lang: Lang) -> Result<ImcResult, ImcError> {
    let raw = bmi(weight_kg, height)?;
    build(raw, weight_kg, height_cm(height), lang)
}

/// Full result from pounds and inches.
pub fn calculate_imperial(weight_lb: f64, height_in: f64, lang: Lang) -> Result<ImcResult, ImcError> {
    let raw = bmi_imperial(weight_lb, height_in)?;
    build(raw, weight_lb * LB_KG, height_in * IN_CM, lang)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn overweight_example() {
        let r = calculate_metric(82.0, 175.0, Lang::Es).unwrap();
        assert_eq!((r.bmi, r.key, r.label, r.diff_kg), (26.8, "sobrepeso", "Sobrepeso", 5.7));
        assert!(r.message.contains("5,7 kg"));
    }

    #[test]
    fn rounds_before_classifying() {
        assert_eq!(classify(24.96, Lang::Es).key, "sobrepeso");
        assert_eq!(classify(24.94, Lang::Es).key, "normal");
        assert_eq!(classify(18.46, Lang::Es).key, "normal");
        assert_eq!(classify(29.96, Lang::Es).key, "obesidad_1");
    }

    #[test]
    fn who_classes() {
        let k = |w: f64| calculate_metric(w, 170.0, Lang::Es).unwrap().key;
        assert_eq!(
            [k(45.0), k(48.0), k(50.0), k(70.0), k(100.0), k(110.0), k(120.0)],
            ["delgadez_severa", "delgadez_moderada", "delgadez_leve", "normal", "obesidad_1", "obesidad_2", "obesidad_3"]
        );
    }

    #[test]
    fn range_and_underweight() {
        assert_eq!(healthy_range(168.0).unwrap(), (52.2, 70.3));
        let r = calculate_metric(50.0, 170.0, Lang::En).unwrap();
        assert_eq!(r.diff_kg, 3.5);
        assert!(r.message.contains("3.5 kg below"));
    }

    #[test]
    fn imperial_comma_metres_errors() {
        assert_eq!(round1(bmi_imperial(154.0, 69.0).unwrap()), 22.7);
        let w = parse_number("70,5").unwrap();
        let h = parse_number("1,68").unwrap();
        assert_eq!(calculate_metric(w, h, Lang::Es).unwrap().bmi, 25.0);
        assert!(calculate_metric(0.0, 170.0, Lang::Es).is_err());
        assert!(parse_number("abc").is_err());
    }
}
