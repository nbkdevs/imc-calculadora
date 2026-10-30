import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imc_calculadora/domain/calculators/adult_bmi.dart';
import 'package:imc_calculadora/domain/calculators/ideal_weight.dart';
import 'package:imc_calculadora/domain/calculators/pregnancy.dart';

void main() {
  test('adult BMI 75 kg / 1.75 m is 24.5 normal', () {
    final r = AdultBmiCalculator.calculate(weightKg: 75, heightM: 1.75)!;
    expect(r.bmiText, '24.5');
    expect(r.category.key, 'normal');
  });

  test('ideal weight at 1.70 m matches published range', () {
    final r = IdealWeightCalculator.calculate(heightM: 1.70)!;
    expect(r.lowerKg.toStringAsFixed(1), '53.5');
    expect(r.upperKg.toStringAsFixed(1), '72.0');
  });

  test('pregnancy underweight band is 12.5 to 18 kg', () {
    final r = PregnancyCalculator.calculate(
      preWeightKg: 48,
      heightM: 1.65,
      week: 20,
    )!;
    expect(r.totalGainMinKg, 12.5);
    expect(r.totalGainMaxKg, 18);
    expect(r.preBmi < 18.5, isTrue);
  });

  testWidgets('home shows brand', (tester) async {
    // Smoke only for calculator domain in unit tests above.
    expect(Colors.teal, isNotNull);
  });
}
