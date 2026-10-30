/// Adult BMI (IMC) with WHO classes, healthy-weight range, metric/imperial
/// input and Spanish/English labels.
///
/// The BMI is rounded to 1 decimal **before** it is classified
/// (24.96 -> 25.0 -> overweight).
library;

/// Kilograms per pound.
const double lbKg = 0.45359237;

/// Centimetres per inch.
const double inCm = 2.54;

/// Output language.
enum Lang {
  /// Spanish (default).
  es,

  /// English.
  en,
}

/// One WHO adult class.
class ImcClass {
  /// Creates a class.
  const ImcClass(this.key, this.upper, this.es, this.en, this.group);

  /// Stable key, e.g. `sobrepeso`.
  final String key;

  /// Exclusive upper bound on the 1-decimal BMI.
  final double upper;

  /// Spanish label.
  final String es;

  /// English label.
  final String en;

  /// Group: bajo, normal, sobrepeso or obesidad.
  final String group;
}

/// WHO adult classes, including the three thinness subclasses.
const List<ImcClass> imcClasses = [
  ImcClass('delgadez_severa', 16, 'Delgadez severa', 'Severe thinness', 'bajo'),
  ImcClass('delgadez_moderada', 17, 'Delgadez moderada', 'Moderate thinness', 'bajo'),
  ImcClass('delgadez_leve', 18.5, 'Delgadez leve', 'Mild thinness', 'bajo'),
  ImcClass('normal', 25, 'Peso normal', 'Normal weight', 'normal'),
  ImcClass('sobrepeso', 30, 'Sobrepeso', 'Overweight', 'sobrepeso'),
  ImcClass('obesidad_1', 35, 'Obesidad grado I', 'Obesity class I', 'obesidad'),
  ImcClass('obesidad_2', 40, 'Obesidad grado II', 'Obesity class II', 'obesidad'),
  ImcClass('obesidad_3', double.infinity, 'Obesidad grado III', 'Obesity class III', 'obesidad'),
];

/// Not-medical-advice note.
String disclaimer(Lang lang) => lang == Lang.en
    ? 'BMI is a general guide for adults and is not medical advice.'
    : 'El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.';

/// Round half up to 1 decimal.
double round1(num x) => (x * 10 + 0.5 + 1e-9).floorToDouble() / 10;

final _num = RegExp(r'^\+?(\d+(\.\d+)?|\.\d+)$');

/// Parse "70,5" or "70.5". Throws [FormatException] otherwise.
double parseNumber(String s) {
  final t = s.trim().replaceFirst(',', '.');
  if (!_num.hasMatch(t)) throw FormatException('invalid number', s);
  return double.parse(t);
}

/// Height in cm; values below 3 are taken as metres (1.75 -> 175).
double heightCm(num h) => h < 3 ? h * 100.0 : h.toDouble();

/// A classified BMI.
class ImcCategory {
  /// Creates a category.
  const ImcCategory(this.key, this.label, this.group, this.bmi);

  /// Stable key.
  final String key;

  /// Label in the chosen language.
  final String label;

  /// Group: bajo, normal, sobrepeso or obesidad.
  final String group;

  /// BMI rounded to 1 decimal.
  final double bmi;
}

/// WHO class for a BMI; the value is rounded to 1 decimal first.
ImcCategory classify(num bmi, {Lang lang = Lang.es}) {
  final b = round1(bmi);
  final c = imcClasses.firstWhere((c) => b < c.upper);
  return ImcCategory(c.key, lang == Lang.en ? c.en : c.es, c.group, b);
}

/// Raw BMI from kg and cm (or m).
double bmi(num weightKg, num height) {
  final h = heightCm(height) / 100;
  if (!(weightKg > 0) || !(h > 0)) {
    throw ArgumentError('weight and height must be greater than 0');
  }
  return weightKg / (h * h);
}

/// Raw BMI from pounds and inches: 703 * lb / in^2.
double bmiImperial(num weightLb, num heightIn) {
  if (!(weightLb > 0) || !(heightIn > 0)) {
    throw ArgumentError('weight and height must be greater than 0');
  }
  return 703 * weightLb / (heightIn * heightIn);
}

/// Healthy-weight range (BMI 18.5 to 24.9) in kg, 1 decimal.
({double minKg, double maxKg}) healthyRange(num height) {
  final h = heightCm(height) / 100;
  if (!(h > 0)) throw ArgumentError('height must be greater than 0');
  return (minKg: round1(18.5 * h * h), maxKg: round1(24.9 * h * h));
}

/// Full result.
class ImcResult {
  /// Creates a result.
  const ImcResult({
    required this.bmi,
    required this.key,
    required this.label,
    required this.group,
    required this.minKg,
    required this.maxKg,
    required this.diffKg,
    required this.message,
    required this.disclaimer,
  });

  /// BMI rounded to 1 decimal.
  final double bmi;

  /// Class key.
  final String key;

  /// Class label.
  final String label;

  /// Class group.
  final String group;

  /// Healthy range lower bound in kg.
  final double minKg;

  /// Healthy range upper bound in kg.
  final double maxKg;

  /// Kg to gain (underweight) or lose (overweight/obesity) to reach the range.
  final double diffKg;

  /// One-line explanation.
  final String message;

  /// Not-medical-advice note.
  final String disclaimer;

  /// JSON-friendly map.
  Map<String, Object> toJson() => {
        'bmi': bmi, 'key': key, 'label': label, 'group': group, 'minKg': minKg,
        'maxKg': maxKg, 'diffKg': diffKg, 'message': message, 'disclaimer': disclaimer,
      };
}

String _message(ImcCategory c, double diff, Lang lang) {
  final low = c.label.toLowerCase();
  if (lang == Lang.en) {
    final d = diff.toStringAsFixed(1);
    if (c.group == 'normal') return 'Your BMI is in the normal range for your height.';
    final side = c.group == 'bajo' ? 'below' : 'above';
    return 'Your BMI shows $low. You are $d kg $side the normal range.';
  }
  final d = diff.toStringAsFixed(1).replaceAll('.', ',');
  if (c.group == 'normal') return 'Tu IMC está dentro del rango normal para tu estatura.';
  if (c.group == 'bajo') return 'Tu IMC indica $low. Te faltan $d kg para llegar al rango normal.';
  return 'Tu IMC indica $low. Te sobran $d kg respecto al rango normal.';
}

ImcResult _build(double raw, double kg, double cm, Lang lang) {
  final c = classify(raw, lang: lang);
  final r = healthyRange(cm);
  var diff = 0.0;
  if (c.group == 'bajo') {
    diff = round1((r.minKg - kg).clamp(0, double.infinity));
  } else if (c.group != 'normal') {
    diff = round1((kg - r.maxKg).clamp(0, double.infinity));
  }
  return ImcResult(
    bmi: c.bmi, key: c.key, label: c.label, group: c.group, minKg: r.minKg,
    maxKg: r.maxKg, diffKg: diff, message: _message(c, diff, lang), disclaimer: disclaimer(lang),
  );
}

/// Full result from kg and cm (or m).
ImcResult calculateMetric(num weightKg, num height, {Lang lang = Lang.es}) =>
    _build(bmi(weightKg, height), weightKg.toDouble(), heightCm(height), lang);

/// Full result from pounds and inches.
ImcResult calculateImperial(num weightLb, num heightIn, {Lang lang = Lang.es}) =>
    _build(bmiImperial(weightLb, heightIn), weightLb * lbKg, heightIn * inCm, lang);
