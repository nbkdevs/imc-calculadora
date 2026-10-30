import 'package:imc_calculadora/domain/models/category.dart';
import 'package:imc_calculadora/ui/core/theme.dart';

class AdultBmiResult {
  const AdultBmiResult({
    required this.bmi,
    required this.category,
    required this.message,
    required this.weightKg,
    required this.heightM,
  });

  final double bmi;
  final ImcCategory category;
  final String message;
  final double weightKg;
  final double heightM;

  String get bmiText => bmi.toStringAsFixed(1);
}

class AdultBmiCalculator {
  static ImcCategory categoryFor(double imc) {
    if (imc < 18.5) {
      return const ImcCategory(
        key: 'bajo',
        label: 'Bajo peso',
        color: ImcColors.bajo,
      );
    }
    if (imc < 25) {
      return const ImcCategory(
        key: 'normal',
        label: 'Peso normal',
        color: ImcColors.normal,
      );
    }
    if (imc < 30) {
      return const ImcCategory(
        key: 'sobrepeso',
        label: 'Sobrepeso',
        color: ImcColors.sobrepeso,
      );
    }
    if (imc < 35) {
      return const ImcCategory(
        key: 'obesidad1',
        label: 'Obesidad grado 1',
        color: ImcColors.obesidad1,
      );
    }
    if (imc < 40) {
      return const ImcCategory(
        key: 'obesidad2',
        label: 'Obesidad grado 2',
        color: ImcColors.obesidad2,
      );
    }
    return const ImcCategory(
      key: 'obesidad3',
      label: 'Obesidad grado 3 (mórbida)',
      color: ImcColors.obesidad3,
    );
  }

  static String messageFor(ImcCategory cat, double heightM, double weightKg) {
    final lowerKg = 18.5 * heightM * heightM;
    final upperKg = 24.9 * heightM * heightM;
    if (cat.key == 'normal') {
      return 'Tu IMC está dentro del rango normal para tu estatura.';
    }
    if (cat.key == 'bajo') {
      final faltan = (lowerKg - weightKg).toStringAsFixed(1);
      return 'Tu IMC indica bajo peso. Te faltan $faltan kg para llegar al rango normal.';
    }
    final sobran = (weightKg - upperKg).toStringAsFixed(1);
    if (cat.key == 'sobrepeso') {
      return 'Tu IMC indica sobrepeso. Te sobran $sobran kg respecto al rango normal.';
    }
    return 'Tu IMC indica ${cat.label.toLowerCase()}. Te sobran $sobran kg respecto al rango normal.';
  }

  static AdultBmiResult? calculate({
    required double weightKg,
    required double heightM,
  }) {
    if (weightKg <= 0 || heightM <= 0) return null;
    final imc = weightKg / (heightM * heightM);
    final cat = categoryFor(imc);
    return AdultBmiResult(
      bmi: imc,
      category: cat,
      message: messageFor(cat, heightM, weightKg),
      weightKg: weightKg,
      heightM: heightM,
    );
  }
}
