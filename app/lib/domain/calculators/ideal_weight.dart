class IdealWeightResult {
  const IdealWeightResult({
    required this.lowerKg,
    required this.upperKg,
    required this.heightM,
  });

  final double lowerKg;
  final double upperKg;
  final double heightM;

  String get kgText =>
      '${lowerKg.toStringAsFixed(1)} - ${upperKg.toStringAsFixed(1)} kg';

  String get lbText {
    final lo = lowerKg / 0.45359237;
    final hi = upperKg / 0.45359237;
    return '${lo.toStringAsFixed(1)} - ${hi.toStringAsFixed(1)} lb';
  }
}

class IdealWeightCalculator {
  /// Rango de peso normal (IMC 18.5 a 24.9) para la estatura.
  static IdealWeightResult? calculate({required double heightM}) {
    if (heightM <= 0) return null;
    final h2 = heightM * heightM;
    return IdealWeightResult(
      lowerKg: 18.5 * h2,
      upperKg: 24.9 * h2,
      heightM: heightM,
    );
  }
}
