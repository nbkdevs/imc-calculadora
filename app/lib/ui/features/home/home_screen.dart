import 'package:flutter/material.dart';
import 'package:imc_calculadora/ui/core/theme.dart';
import 'package:imc_calculadora/ui/features/about/about_screen.dart';
import 'package:imc_calculadora/ui/features/adult/adult_screen.dart';
import 'package:imc_calculadora/ui/features/child/child_screen.dart';
import 'package:imc_calculadora/ui/features/history/history_screen.dart';
import 'package:imc_calculadora/ui/features/ideal/ideal_screen.dart';
import 'package:imc_calculadora/ui/features/pregnancy/pregnancy_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ImcColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          children: [
            const Text(
              'IMC Calculadora',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w600,
                fontSize: 32,
                color: ImcColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Calcula tu índice de masa corporal sin conexión. No pedimos registro ni enviamos tus datos.',
              style: TextStyle(height: 1.45, color: ImcColors.support, fontSize: 16),
            ),
            const SizedBox(height: 28),
            _ToolCard(
              title: 'IMC adultos',
              subtitle: 'Peso y estatura. Categoría según la OMS.',
              onTap: () => Navigator.pushNamed(context, AdultScreen.route),
            ),
            _ToolCard(
              title: 'IMC infantil',
              subtitle: 'Percentil de 2 a 19 años (CDC).',
              onTap: () => Navigator.pushNamed(context, ChildScreen.route),
            ),
            _ToolCard(
              title: 'Peso ideal',
              subtitle: 'Rango normal solo con la estatura.',
              onTap: () => Navigator.pushNamed(context, IdealScreen.route),
            ),
            _ToolCard(
              title: 'IMC en el embarazo',
              subtitle: 'Aumento recomendado según el IMC previo.',
              onTap: () => Navigator.pushNamed(context, PregnancyScreen.route),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, HistoryScreen.route),
              child: const Text('Historial en este teléfono'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AboutScreen.route),
              child: const Text('Sobre la app y las fuentes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: ImcColors.surface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ImcColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: ImcColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: ImcColors.support, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
