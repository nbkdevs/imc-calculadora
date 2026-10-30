import 'package:flutter/material.dart';
import 'package:imc_calculadora/data/repositories/history_repository.dart';
import 'package:imc_calculadora/domain/calculators/adult_bmi.dart';
import 'package:imc_calculadora/domain/calculators/units.dart';
import 'package:imc_calculadora/domain/models/history_entry.dart';
import 'package:imc_calculadora/ui/core/widgets.dart';
import 'package:imc_calculadora/app.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class AdultScreen extends StatefulWidget {
  const AdultScreen({super.key});

  static const route = '/adult';

  @override
  State<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends State<AdultScreen> {
  bool _metric = true;
  final _pesoKg = TextEditingController();
  final _estaturaCm = TextEditingController();
  final _pesoLb = TextEditingController();
  final _ft = TextEditingController();
  final _inch = TextEditingController();
  AdultBmiResult? _result;
  String? _error;

  @override
  void dispose() {
    _pesoKg.dispose();
    _estaturaCm.dispose();
    _pesoLb.dispose();
    _ft.dispose();
    _inch.dispose();
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

    final result = AdultBmiCalculator.calculate(
      weightKg: weightKg,
      heightM: heightM,
    );
    if (result == null) {
      setState(() {
        _error = 'Escribe un peso y una estatura válidos.';
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
        type: 'adult',
        title: 'IMC adultos: ${result.bmiText}',
        summary: '${result.category.label}. ${result.message}',
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
            'Mi IMC es ${r.bmiText} (${r.category.label}). ${r.message}\nCalculado con IMC Calculadora.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      title: 'IMC adultos',
      actions: [
        if (_result != null)
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Compartir',
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
                  const FieldLabel('Peso (kg)'),
                  TextField(
                    controller: _pesoKg,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '70'),
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Estatura (cm)'),
                  TextField(
                    controller: _estaturaCm,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '170'),
                  ),
                ] else ...[
                  const FieldLabel('Peso (lb)'),
                  TextField(
                    controller: _pesoLb,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '154'),
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Estatura'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ft,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '5'),
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
                          decoration: const InputDecoration(hintText: '7'),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('pulg.'),
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
              number: _result!.bmiText,
              categoryLabel: _result!.category.label,
              categoryColor: _result!.category.color,
              message: _result!.message,
            ),
            const SizedBox(height: 12),
            const Text(
              'Resultado orientativo: no diagnostica ni sustituye una consulta médica.',
              style: TextStyle(color: Color(0xFF3B5B6D), height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
