import 'package:flutter/material.dart';
import 'package:imc_calculadora/app.dart';
import 'package:imc_calculadora/data/repositories/history_repository.dart';
import 'package:imc_calculadora/domain/calculators/child_bmi.dart';
import 'package:imc_calculadora/domain/calculators/units.dart';
import 'package:imc_calculadora/domain/models/history_entry.dart';
import 'package:imc_calculadora/ui/core/theme.dart';
import 'package:imc_calculadora/ui/core/widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ChildScreen extends StatefulWidget {
  const ChildScreen({super.key});

  static const route = '/child';

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  bool _metric = true;
  bool _loading = true;
  String? _loadError;
  ChildBmiCalculator? _calc;

  final _anos = TextEditingController();
  final _meses = TextEditingController();
  final _pesoKg = TextEditingController();
  final _estaturaCm = TextEditingController();
  final _pesoLb = TextEditingController();
  final _ft = TextEditingController();
  final _inch = TextEditingController();
  String? _sexo;
  ChildBmiResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final calc = await ChildBmiCalculator.load();
      if (!mounted) return;
      setState(() {
        _calc = calc;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'No se pudieron cargar las tablas de percentil.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _anos.dispose();
    _meses.dispose();
    _pesoKg.dispose();
    _estaturaCm.dispose();
    _pesoLb.dispose();
    _ft.dispose();
    _inch.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final calc = _calc;
    if (calc == null) return;
    final years = int.tryParse(_anos.text) ?? -1;
    final months = int.tryParse(_meses.text) ?? 0;
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

    final result = calc.calculate(
      years: years,
      extraMonths: months.clamp(0, 11),
      sexKey: _sexo ?? '',
      weightKg: weightKg,
      heightM: heightM,
    );
    if (result == null) {
      setState(() {
        _error =
            'Revisa los datos: edad (2 a 19 años), sexo, peso y estatura son obligatorios.';
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
        type: 'child',
        title: 'IMC infantil: ${result.bmiText}',
        summary:
            'Percentil ${result.percentileText} — ${result.category.label}. ${result.message}',
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
            'IMC infantil ${r.bmiText}, percentil ${r.percentileText} (${r.category.label}). ${r.message}\nIMC Calculadora.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: ImcColors.accent)),
      );
    }
    if (_loadError != null) {
      return ShellScaffold(
        title: 'IMC infantil',
        child: Text(_loadError!),
      );
    }

    return ShellScaffold(
      title: 'IMC infantil',
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
                const FieldLabel('Edad (años)'),
                TextField(
                  controller: _anos,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '8'),
                ),
                const SizedBox(height: 12),
                const FieldLabel('Meses adicionales'),
                TextField(
                  controller: _meses,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '0'),
                ),
                const SizedBox(height: 12),
                const FieldLabel('Sexo (obligatorio)'),
                DropdownButtonFormField<String>(
                  initialValue: _sexo,
                  items: const [
                    DropdownMenuItem(value: 'nina', child: Text('Niña')),
                    DropdownMenuItem(value: 'nino', child: Text('Niño')),
                  ],
                  onChanged: (v) => setState(() => _sexo = v),
                  decoration: const InputDecoration(
                    hintText: 'Selecciona una opción',
                  ),
                ),
                const SizedBox(height: 12),
                if (_metric) ...[
                  const FieldLabel('Peso (kg)'),
                  TextField(
                    controller: _pesoKg,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '28'),
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Estatura (cm)'),
                  TextField(
                    controller: _estaturaCm,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '128'),
                  ),
                ] else ...[
                  const FieldLabel('Peso (lb)'),
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
              subtitle: 'IMC calculado',
              categoryLabel:
                  'Percentil ${_result!.percentileText} - ${_result!.category.label}',
              categoryColor: _result!.category.color,
              message: _result!.message,
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta calculadora es una herramienta de referencia y no reemplaza una evaluación médica.',
              style: TextStyle(color: ImcColors.support, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
