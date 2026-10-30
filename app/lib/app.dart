import 'package:flutter/material.dart';
import 'package:imc_calculadora/ui/core/theme.dart';
import 'package:imc_calculadora/ui/features/about/about_screen.dart';
import 'package:imc_calculadora/ui/features/adult/adult_screen.dart';
import 'package:imc_calculadora/ui/features/child/child_screen.dart';
import 'package:imc_calculadora/ui/features/history/history_screen.dart';
import 'package:imc_calculadora/ui/features/home/home_screen.dart';
import 'package:imc_calculadora/ui/features/ideal/ideal_screen.dart';
import 'package:imc_calculadora/ui/features/pregnancy/pregnancy_screen.dart';

class ImcApp extends StatelessWidget {
  const ImcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMC Calculadora',
      debugShowCheckedModeBanner: false,
      theme: buildImcTheme(),
      home: const HomeScreen(),
      routes: {
        AdultScreen.route: (_) => const AdultScreen(),
        ChildScreen.route: (_) => const ChildScreen(),
        IdealScreen.route: (_) => const IdealScreen(),
        PregnancyScreen.route: (_) => const PregnancyScreen(),
        HistoryScreen.route: (_) => const HistoryScreen(),
        AboutScreen.route: (_) => const AboutScreen(),
      },
    );
  }
}

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ImcColors.bg,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: ImcColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: child,
        ),
      ),
    );
  }
}
