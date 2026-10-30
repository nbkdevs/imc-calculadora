import 'package:flutter/material.dart';
import 'package:imc_calculadora/app.dart';
import 'package:imc_calculadora/data/repositories/history_repository.dart';
import 'package:imc_calculadora/ui/core/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const route = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = context.read<HistoryRepository>();
    final items = repo.load();
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return ShellScaffold(
      title: 'Historial',
      actions: [
        if (items.isNotEmpty)
          TextButton(
            onPressed: () async {
              await repo.clear();
              setState(() {});
            },
            child: const Text('Borrar'),
          ),
      ],
      child: items.isEmpty
          ? const Text(
              'Aún no hay resultados guardados en este teléfono. El historial no se sube a ningún servidor.',
              style: TextStyle(color: ImcColors.support, height: 1.45),
            )
          : Column(
              children: [
                for (final item in items)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ImcColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ImcColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.summary,
                          style: const TextStyle(
                            color: ImcColors.ink,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          fmt.format(item.createdAt.toLocal()),
                          style: const TextStyle(
                            color: ImcColors.support,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
