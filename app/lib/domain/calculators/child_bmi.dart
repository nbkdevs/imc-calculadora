import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:imc_calculadora/domain/models/category.dart';
import 'package:imc_calculadora/ui/core/theme.dart';

class ChildBmiResult {
  const ChildBmiResult({
    required this.bmi,
    required this.percentile,
    required this.category,
    required this.message,
  });

  final double bmi;
  final double percentile;
  final ImcCategory category;
  final String message;

  String get bmiText => bmi.toStringAsFixed(1);
  String get percentileText => percentile.round().toString();
}

class ChildBmiCalculator {
  ChildBmiCalculator._(this._boys, this._girls);

  final List<List<double>> _boys;
  final List<List<double>> _girls;

  static ChildBmiCalculator? _instance;

  static Future<ChildBmiCalculator> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString('assets/data/cdc_bmi_lms.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    List<List<double>> parse(String key) {
      return (json[key] as List)
          .map((row) => (row as List).map((v) => (v as num).toDouble()).toList())
          .toList();
    }

    _instance = ChildBmiCalculator._(parse('boys'), parse('girls'));
    return _instance!;
  }

  static double _erf(double x) {
    final sign = x < 0 ? -1.0 : 1.0;
    x = x.abs();
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    const p = 0.3275911;
    final t = 1 / (1 + p * x);
    final y =
        1 -
        (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) *
            t *
            math.exp(-x * x);
    return sign * y;
  }

  static double _normalCdf(double z) => 0.5 * (1 + _erf(z / math.sqrt2));

  List<double> _interpolate(List<List<double>> rows, double ageMonths) {
    if (ageMonths <= rows.first[0]) return rows.first;
    if (ageMonths >= rows.last[0]) return rows.last;
    for (var i = 0; i < rows.length - 1; i++) {
      final a = rows[i];
      final b = rows[i + 1];
      if (ageMonths >= a[0] && ageMonths <= b[0]) {
        final frac = b[0] == a[0] ? 0.0 : (ageMonths - a[0]) / (b[0] - a[0]);
        return [
          for (var k = 0; k < a.length; k++)
            k == 0 ? ageMonths : a[k] + frac * (b[k] - a[k]),
        ];
      }
    }
    return rows.last;
  }

  double percentile({
    required String sexKey,
    required double ageMonths,
    required double bmi,
  }) {
    final table = sexKey == 'nino' ? _boys : _girls;
    final row = _interpolate(table, ageMonths);
    final l = row[1];
    final m = row[2];
    final s = row[3];
    final p95 = row[4];
    final sigma = row[5];
    double percentile;
    if (bmi <= p95) {
      final z = l != 0
          ? ((math.pow(bmi / m, l) - 1) / (l * s))
          : (math.log(bmi / m) / s);
      percentile = _normalCdf(z.toDouble()) * 100;
    } else {
      percentile = 90 + 10 * _normalCdf((bmi - p95) / sigma);
    }
    if (percentile < 0.1) percentile = 0.1;
    if (percentile > 99.9) percentile = 99.9;
    return percentile;
  }

  static ImcCategory categoryFor(double pct) {
    if (pct < 5) {
      return const ImcCategory(
        key: 'bajo',
        label: 'Bajo peso',
        color: ImcColors.bajo,
      );
    }
    if (pct < 85) {
      return const ImcCategory(
        key: 'saludable',
        label: 'Peso saludable',
        color: ImcColors.normal,
      );
    }
    if (pct < 95) {
      return const ImcCategory(
        key: 'sobrepeso',
        label: 'Sobrepeso',
        color: ImcColors.sobrepeso,
      );
    }
    return const ImcCategory(
      key: 'obesidad',
      label: 'Obesidad',
      color: ImcColors.obesidad2,
    );
  }

  static String messageFor(ImcCategory cat) {
    switch (cat.key) {
      case 'bajo':
        return 'El percentil indica bajo peso para la edad y el sexo. Consulta al pediatra, sobre todo si es un cambio reciente.';
      case 'saludable':
        return 'El percentil está dentro del rango de peso saludable para la edad y el sexo.';
      case 'sobrepeso':
        return 'El percentil indica sobrepeso para la edad y el sexo. Un percentil alto de forma aislada no es un diagnóstico: habla con el pediatra.';
      default:
        return 'El percentil indica obesidad para la edad y el sexo. Habla con el pediatra para una evaluación completa.';
    }
  }

  ChildBmiResult? calculate({
    required int years,
    required int extraMonths,
    required String sexKey,
    required double weightKg,
    required double heightM,
  }) {
    if (years < 2 || years > 19) return null;
    if (sexKey != 'nino' && sexKey != 'nina') return null;
    if (weightKg <= 0 || heightM <= 0) return null;
    final ageMonths = (years * 12) + extraMonths;
    final bmi = weightKg / (heightM * heightM);
    final pct = percentile(
      sexKey: sexKey,
      ageMonths: ageMonths.toDouble(),
      bmi: bmi,
    );
    final cat = categoryFor(pct);
    return ChildBmiResult(
      bmi: bmi,
      percentile: pct,
      category: cat,
      message: messageFor(cat),
    );
  }
}
