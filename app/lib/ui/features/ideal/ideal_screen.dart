import 'package:flutter/material.dart';
import 'package:imc_calculadora/app.dart';
import 'package:imc_calculadora/data/repositories/history_repository.dart';
import 'package:imc_calculadora/domain/calculators/ideal_weight.dart';
import 'package:imc_calculadora/domain/calculators/units.dart';
import 'package:imc_calculadora/domain/models/history_entry.dart';
import 'package:imc_calculadora/ui/core/theme.dart';
import 'package:imc_calculadora/ui/core/widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class IdealScreen extends StatefulWidget {
  const IdealScreen({super.key});

  static const route = '/ideal';

  @override
  State<IdealScreen> createState() => _IdealScreenState();
}

class _IdealScreenState extends State<IdealScreen> {
  bool _metric = true;
  final _cm = TextEditingController();
  final _ft = TextEditingController();
  final _inch = TextEditingController();
  IdealWeightResult? _result;
  String? _error;

  @override
  void dispose() {
    _cm.dispose();
    _ft.dispose();
    _inch.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final heightM = _metric
        ? UnitConversion.mFromCm(
            double.tryParse(_cm.text.replaceAll(',', '.')) ?? 0,
          )
        : UnitConversion.mFromFtIn(
            double.tryParse(_ft.text.replaceAll(',', '.')) ?? 0,
            double.tryParse(_inch.text.replaceAll(',', '.')) ?? 0,
          );
    final result = IdealWeightCalculator.calculate(heightM: heightM);
    if (result == null) {
      setState(() {
        _error = 'Escribe una estatura válida.';
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
        type: 'ideal',
        title: 'Peso ideal: ${result.kgText}',
        summary:
            'Rango de peso normal (IMC 18.5 a 24.9) para tu estatura. También ${result.lbText}.',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _share() async {
    final r = _result;
    if (r == null) return;
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Mi rango de peso ideal es ${r.kgText} (${r.lbText}), según el IMC normal 18.5 a 24.9.\nIMC Calculadora.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      title: 'Peso ideal',
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
                  metricLabel: 'cm',
                  imperialLabel: 'ft-in',
                  isMetric: _metric,
                  onChanged: (v) => setState(() => _metric = v),
                ),
                const SizedBox(height: 16),
                if (_metric) ...[
                  const FieldLabel('Estatura (cm)'),
                  TextField(
                    controller: _cm,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '170'),
                  ),
                ] else ...[
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
              number: _result!.kgText,
              subtitle: _result!.lbText,
              categoryLabel: 'Peso normal',
              categoryColor: ImcColors.normal,
              message:
                  'Rango de peso normal (IMC 18.5 a 24.9) para tu estatura.',
            ),
          ],
        ],
      ),
    );
  }
}
