import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data_management/data_manager.dart';
import 'features/trading/pages/partner/partner_page.dart';
import 'features/trading/pages/shell/trading_shell_page.dart';
import 'features/trading/pages/stats/stats_page.dart';
import 'core/navigation/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
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
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.partner:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => PartnerPage(),
            );
          case AppRoutes.stats:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => StatsPage(),
            );
          case AppRoutes.home:
          default:
            return MaterialPageRoute<void>(
              settings: const RouteSettings(name: AppRoutes.home),
              builder: (_) => const TradingShellPage(),
            );
        }
      },
    );
  }
}
