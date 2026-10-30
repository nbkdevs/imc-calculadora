import 'package:flutter/material.dart';
import 'package:imc_calculadora/ui/core/theme.dart';

class CalculatorPanel extends StatelessWidget {
  const CalculatorPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ImcColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ImcColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1A2421),
            blurRadius: 24,
            offset: Offset(0, 4),
            spreadRadius: -8,
          ),
        ],
      ),
      child: child,
    );
  }
}

class UnitToggle extends StatelessWidget {
  const UnitToggle({
    super.key,
    required this.metricLabel,
    required this.imperialLabel,
    required this.isMetric,
    required this.onChanged,
  });

  final String metricLabel;
  final String imperialLabel;
  final bool isMetric;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: metricLabel,
            selected: isMetric,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            label: imperialLabel,
            selected: !isMetric,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ImcColors.accent : ImcColors.bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? ImcColors.accent : ImcColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : ImcColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.number,
    required this.categoryLabel,
    required this.categoryColor,
    required this.message,
    this.subtitle,
  });

  final String number;
  final String categoryLabel;
  final Color categoryColor;
  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return CalculatorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w600,
              fontSize: 56,
              height: 1.05,
              color: ImcColors.ink,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ImcColors.support),
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                categoryLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.45, color: ImcColors.ink),
          ),
        ],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: ImcColors.support,
        ),
      ),
    );
  }
}
