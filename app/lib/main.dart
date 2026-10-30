import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imc_calculadora/app.dart';
import 'package:imc_calculadora/data/repositories/history_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(
    Provider(
      create: (_) => HistoryRepository(prefs),
      child: const ImcApp(),
    ),
  );
}
