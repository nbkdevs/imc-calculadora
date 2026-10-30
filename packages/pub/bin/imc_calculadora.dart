import 'dart:convert';
import 'dart:io';

import 'package:imc_calculadora/imc_calculadora.dart';

const _help = '''imc_calculadora: adult BMI (IMC) with WHO classes

Usage:
  imc_calculadora <peso-kg> <altura-cm|m> [--en] [--json]
  imc_calculadora --lb <peso-lb> --in <altura-in> [--en] [--json]
  imc_calculadora --rango <altura-cm|m> [--en]

Examples: imc_calculadora 82 175 | imc_calculadora 70,5 1,68 --en | imc_calculadora --rango 168''';

String? _take(List<String> a, String flag) {
  final i = a.indexOf(flag);
  if (i < 0) return null;
  final v = i + 1 < a.length ? a[i + 1] : '';
  a.removeRange(i, i + 1 < a.length ? i + 2 : i + 1);
  return v;
}

void main(List<String> argv) {
  final a = [...argv];
  if (a.isEmpty || a.contains('-h') || a.contains('--help')) {
    stdout.writeln(_help);
    return;
  }
  final en = a.remove('--en');
  final json = a.remove('--json');
  final lang = en ? Lang.en : Lang.es;
  String fmt(double n) => en ? n.toStringAsFixed(1) : n.toStringAsFixed(1).replaceAll('.', ',');
  final hw = en ? 'Healthy weight' : 'Peso saludable';
  try {
    final rango = _take(a, '--rango');
    if (rango != null) {
      final r = healthyRange(parseNumber(rango));
      stdout.writeln(json ? jsonEncode({'minKg': r.minKg, 'maxKg': r.maxKg}) : '$hw: ${fmt(r.minKg)} - ${fmt(r.maxKg)} kg');
      return;
    }
    final lb = _take(a, '--lb');
    final inch = _take(a, '--in');
    final r = (lb != null || inch != null)
        ? calculateImperial(parseNumber(lb ?? ''), parseNumber(inch ?? ''), lang: lang)
        : calculateMetric(parseNumber(a.isNotEmpty ? a[0] : ''), parseNumber(a.length > 1 ? a[1] : ''), lang: lang);
    if (json) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(r.toJson()));
      return;
    }
    stdout
      ..writeln('${en ? 'BMI' : 'IMC'} ${fmt(r.bmi)}: ${r.label}')
      ..writeln(r.message)
      ..writeln('$hw: ${fmt(r.minKg)} - ${fmt(r.maxKg)} kg')
      ..writeln(r.disclaimer);
  } on Object catch (e) {
    stderr.writeln('error: $e\n\n$_help');
    exitCode = 2;
  }
}
