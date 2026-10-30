import 'package:imc_calculadora/imc_calculadora.dart';
import 'package:test/test.dart';

void main() {
  test('82 kg / 175 cm is 26.8 overweight', () {
    final r = calculateMetric(82, 175);
    expect([r.bmi, r.key, r.label, r.diffKg], [26.8, 'sobrepeso', 'Sobrepeso', 5.7]);
    expect(r.message, contains('5,7 kg'));
  });

  test('rounds to 1 decimal before classifying', () {
    expect(classify(24.96).key, 'sobrepeso');
    expect(classify(24.94).key, 'normal');
    expect(classify(18.46).key, 'normal');
    expect(classify(29.96).key, 'obesidad_1');
  });

  test('WHO classes incl. thinness subclasses', () {
    String k(num w) => calculateMetric(w, 170).key;
    expect([k(45), k(48), k(50), k(70), k(100), k(110), k(120)], [
      'delgadez_severa', 'delgadez_moderada', 'delgadez_leve', 'normal',
      'obesidad_1', 'obesidad_2', 'obesidad_3',
    ]);
  });

  test('healthy range and underweight difference', () {
    final r = healthyRange(168);
    expect([r.minKg, r.maxKg], [52.2, 70.3]);
    final u = calculateMetric(50, 170, lang: Lang.en);
    expect(u.diffKg, 3.5);
    expect(u.message, contains('3.5 kg below'));
  });

  test('imperial, comma decimals, metres and errors', () {
    expect(round1(bmiImperial(154, 69)), 22.7);
    expect(calculateMetric(parseNumber('70,5'), parseNumber('1,68')).bmi, 25.0);
    expect(() => calculateMetric(0, 170), throwsArgumentError);
    expect(() => parseNumber('abc'), throwsFormatException);
  });
}
