import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data_management/data_manager.dart';
import 'features/trading/pages/shell/trading_shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0E141B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final dataManager = await DataManager.create();

  runApp(
    Provider<DataManager>.value(
      value: dataManager,
      child: const BabloApp(),
    ),
  );
}

class BabloApp extends StatelessWidget {
  const BabloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bablo Trading',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const TradingShellPage(),
    );
  }
}
