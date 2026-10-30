import 'package:flutter/material.dart';
import 'package:imc_calculadora/app.dart';
import 'package:imc_calculadora/data/repositories/history_repository.dart';
import 'package:imc_calculadora/domain/calculators/pregnancy.dart';
import 'package:imc_calculadora/domain/calculators/units.dart';
import 'package:imc_calculadora/domain/models/history_entry.dart';
import 'package:imc_calculadora/ui/core/theme.dart';
import 'package:imc_calculadora/ui/core/widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  static const route = '/pregnancy';

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  bool _metric = true;
  final _pesoKg = TextEditingController();
  final _estaturaCm = TextEditingController();
  final _pesoLb = TextEditingController();
  final _ft = TextEditingController();
  final _inch = TextEditingController();
  final _semana = TextEditingController();
  final _actual = TextEditingController();
  PregnancyResult? _result;
  String? _error;

  @override
  void dispose() {
    _pesoKg.dispose();
    _estaturaCm.dispose();
    _pesoLb.dispose();
    _ft.dispose();
    _inch.dispose();
    _semana.dispose();
    _actual.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    late final double weightKg;
    late final double heightM;
    if (_metric) {
      weightKg = double.tryParse(_pesoKg.text.replaceAll(',', '.')) ?? 0;
      heightM = UnitConversion.mFromCm(
        double.tryParse(_estaturaCm.text.replaceAll(',', '.')) ?? 0,
      );
    } else {
      weightKg = UnitConversion.kgFromLb(
        double.tryParse(_pesoLb.text.replaceAll(',', '.')) ?? 0,
      );
      heightM = UnitConversion.mFromFtIn(
        double.tryParse(_ft.text.replaceAll(',', '.')) ?? 0,
        double.tryParse(_inch.text.replaceAll(',', '.')) ?? 0,
      );
    }
    final week = int.tryParse(_semana.text) ?? 0;
    double? current;
    if (_actual.text.trim().isNotEmpty) {
      final v = double.tryParse(_actual.text.replaceAll(',', '.')) ?? 0;
      current = _metric ? v : UnitConversion.kgFromLb(v);
    }

    final result = PregnancyCalculator.calculate(
      preWeightKg: weightKg,
      heightM: heightM,
      week: week,
      currentWeightKg: current,
    );
    if (result == null) {
      setState(() {
        _error =
            'Escribe un peso, una estatura y una semana de embarazo válidos (1 a 42).';
        _result = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _result = result;
    });
    await context.read<HistoryRepository>().add(
      HistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'pregnancy',
        title:
            'Embarazo: ${result.totalGainMinKg.toStringAsFixed(1)}-${result.totalGainMaxKg.toStringAsFixed(1)} kg',
        summary: result.message,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _share() async {
    final r = _result;
    if (r == null) return;
    await SharePlus.instance.share(
      ShareParams(text: '${r.message}\n${r.progressMessage}\nIMC Calculadora.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      title: 'IMC en el embarazo',
      actions: [
        if (_result != null)
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.ios_share_outlined),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalculatorPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UnitToggle(
                  metricLabel: 'kg / cm',
                  imperialLabel: 'lb / ft-in',
                  isMetric: _metric,
                  onChanged: (v) => setState(() => _metric = v),
                ),
                const SizedBox(height: 16),
                if (_metric) ...[
                  const FieldLabel('Peso antes del embarazo (kg)'),
                  TextField(
                    controller: _pesoKg,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '62'),
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Estatura (cm)'),
                  TextField(
                    controller: _estaturaCm,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '165'),
                  ),
                ] else ...[
                  const FieldLabel('Peso antes del embarazo (lb)'),
                  TextField(
                    controller: _pesoLb,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Estatura'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ft,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('pies'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _inch,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const FieldLabel('Semana de embarazo'),
                TextField(
                  controller: _semana,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '24'),
                ),
                const SizedBox(height: 12),
                FieldLabel(
                  _metric
                      ? 'Peso actual (opcional, kg)'
                      : 'Peso actual (opcional, lb)',
                ),
                TextField(
                  controller: _actual,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(hintText: '70'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('Calcular'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Color(0xFFA83A2A))),
                ],
              ],
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            ResultCard(
              number:
                  '${_result!.totalGainMinKg.toStringAsFixed(1)}-${_result!.totalGainMaxKg.toStringAsFixed(1)} kg',
              subtitle: 'Aumento total recomendado',
              categoryLabel:
                  'IMC previo ${_result!.preBmi.toStringAsFixed(1)}, ${_result!.category.label}',
              categoryColor: _result!.category.color,
              message:
                  '${_result!.message}\n\n${_result!.progressMessage}',
            ),
            const SizedBox(height: 12),
            const Text(
              'Calculadora para un embarazo único, con fines informativos. No reemplaza el seguimiento de tu médico u obstetra.',
              style: TextStyle(color: ImcColors.support, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
