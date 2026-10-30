import 'package:imc_calculadora/imc_calculadora.dart';

void main() {
  final r = calculateMetric(82, 175);
  print('IMC ${r.bmi}: ${r.label}'); // IMC 26.8: Sobrepeso
  print(r.message);
  final range = healthyRange(168);
  print('${range.minKg} - ${range.maxKg} kg'); // 52.2 - 70.3 kg
  print(calculateImperial(154, 69, lang: Lang.en).label); // Normal weight
}
