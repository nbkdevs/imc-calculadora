import 'package:imc_calculadora/domain/calculators/adult_bmi.dart';
import 'package:imc_calculadora/domain/models/category.dart';

class PregnancyResult {
  const PregnancyResult({
    required this.preBmi,
    required this.category,
    required this.totalGainMinKg,
    required this.totalGainMaxKg,
    required this.recommendedMinAtWeek,
    required this.recommendedMaxAtWeek,
    required this.week,
    required this.message,
    required this.progressMessage,
  });

  final double preBmi;
  final ImcCategory category;
  final double totalGainMinKg;
  final double totalGainMaxKg;
  final double recommendedMinAtWeek;
  final double recommendedMaxAtWeek;
  final int week;
  final String message;
  final String progressMessage;
}

class _IomBand {
  const _IomBand({
    required this.minTotal,
    required this.maxTotal,
    required this.minWeekly,
    required this.maxWeekly,
  });

  final double minTotal;
  final double maxTotal;
  final double minWeekly;
  final double maxWeekly;
}

class PregnancyCalculator {
  /// Embarazo único según IOM/ACOG (publicado en la página del sitio).
  static _IomBand _bandFor(double bmi) {
    if (bmi < 18.5) {
      return const _IomBand(
        minTotal: 12.5,
        maxTotal: 18,
        minWeekly: 0.44,
        maxWeekly: 0.58,
      );
    }
    if (bmi < 25) {
      return const _IomBand(
        minTotal: 11.5,
        maxTotal: 16,
        minWeekly: 0.35,
        maxWeekly: 0.50,
      );
    }
    if (bmi < 30) {
      return const _IomBand(
        minTotal: 7,
        maxTotal: 11.5,
        minWeekly: 0.23,
        maxWeekly: 0.33,
      );
    }
    return const _IomBand(
      minTotal: 5,
      maxTotal: 9,
      minWeekly: 0.17,
      maxWeekly: 0.27,
    );
  }

  static PregnancyResult? calculate({
    required double preWeightKg,
    required double heightM,
    required int week,
    double? currentWeightKg,
  }) {
    if (preWeightKg <= 0 || heightM <= 0 || week < 1 || week > 42) {
      return null;
    }

    final preBmi = preWeightKg / (heightM * heightM);
    final cat = AdultBmiCalculator.categoryFor(preBmi);
    final band = _bandFor(preBmi);

    // Primer trimestre: 0.5 a 2 kg. Después, ritmo semanal del IOM.
    double recMin;
    double recMax;
    if (week <= 13) {
      final t = (week - 1) / 12;
      recMin = 0.5 * t;
      recMax = 0.5 + (2.0 - 0.5) * t;
    } else {
      const firstMin = 0.5;
      const firstMax = 2.0;
      final weeksAfter = week - 13;
      recMin = (firstMin + weeksAfter * band.minWeekly).clamp(0, band.minTotal);
      recMax = (firstMax + weeksAfter * band.maxWeekly).clamp(0, band.maxTotal);
    }

    final message =
        'Según tu IMC antes del embarazo (${preBmi.toStringAsFixed(1)}, ${cat.label.toLowerCase()}), '
        'el aumento recomendado en un embarazo único es de '
        '${band.minTotal.toStringAsFixed(1)} a ${band.maxTotal.toStringAsFixed(1)} kg en total.';

    String progress;
    if (currentWeightKg != null && currentWeightKg > 0) {
      final gained = currentWeightKg - preWeightKg;
      progress =
          'En la semana $week llevas ${gained.toStringAsFixed(1)} kg de aumento. '
          'La referencia orientativa para esta semana es '
          '${recMin.toStringAsFixed(1)} a ${recMax.toStringAsFixed(1)} kg. '
          'Habla con tu médico u obstetra si quedas fuera del rango.';
    } else {
      progress =
          'En la semana $week, la referencia orientativa de aumento es '
          '${recMin.toStringAsFixed(1)} a ${recMax.toStringAsFixed(1)} kg '
          '(0.5 a 2 kg en el primer trimestre; la mayor parte en el segundo y el tercero).';
    }

    return PregnancyResult(
      preBmi: preBmi,
      category: cat,
      totalGainMinKg: band.minTotal,
      totalGainMaxKg: band.maxTotal,
      recommendedMinAtWeek: recMin,
      recommendedMaxAtWeek: recMax,
      week: week,
      message: message,
      progressMessage: progress,
    );
  }
}
