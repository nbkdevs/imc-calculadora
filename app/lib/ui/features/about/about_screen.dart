import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imc_calculadora/app.dart';
import 'package:imc_calculadora/ui/core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const route = '/about';

  @override
  Widget build(BuildContext context) {
    return ShellScaffold(
      title: 'Sobre la app',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'IMC Calculadora',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: ImcColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Versión offline de las calculadoras de imccalculadora.app. '
            'El cálculo se hace en el teléfono. El historial se guarda solo en este dispositivo.',
            style: TextStyle(height: 1.45),
          ),
          const SizedBox(height: 20),
          const Text(
            'Fuentes',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Adultos: categorías de IMC de la OMS.\n'
            '• Niños: percentil de IMC de los CDC (extensión Wei et al. 2020).\n'
            '• Peso ideal: rango de IMC 18.5 a 24.9.\n'
            '• Embarazo: aumento recomendado IOM/ACOG para embarazo único.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(
                  text: 'https://imccalculadora.app/metodologia/',
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enlace de metodología copiado'),
                  ),
                );
              }
            },
            child: const Text('Copiar enlace de metodología'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta app es informativa y no sustituye una consulta médica profesional.',
            style: TextStyle(color: ImcColors.support, height: 1.4),
          ),
        ],
      ),
    );
  }
}
