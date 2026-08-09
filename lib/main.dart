import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data_management/data_manager.dart';
import 'features/trading/pages/ai/ai_assistant_page.dart';
import 'features/trading/pages/ai/global_search_page.dart';
import 'features/trading/pages/chart/chart_page.dart';
import 'features/trading/pages/partner/partner_page.dart';
import 'features/trading/pages/portfolio/portfolio_page.dart';
import 'features/trading/pages/settings/settings_page.dart';
import 'features/trading/pages/shell/trading_shell_page.dart';
import 'features/trading/pages/stats/stats_page.dart';
import 'features/trading/pages/subscriptions/subscriptions_page.dart';
import 'features/trading/pages/trades/trades_page.dart';
import 'features/trading/pages/us_stocks/us_stocks_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeDateFormatting('ru');

  final dataManager = await DataManager.create();
  final themeController = await ThemeController.create();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataManager>.value(value: dataManager),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ],
      child: const BabloApp(),
    ),
  );
}

class BabloApp extends StatelessWidget {
  const BabloApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return MaterialApp(
      title: 'Bablo Trading',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.resolvedMode,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.partner:
            return _fade(settings, PartnerPage());
          case AppRoutes.subscriptions:
            return _fade(settings, SubscriptionsPage());
          case AppRoutes.usStocks:
            return _fade(settings, UsStocksPage());
          case AppRoutes.stats:
            return _fade(settings, StatsPage());
          case AppRoutes.chart:
            return _fade(settings, ChartPage());
          case AppRoutes.portfolio:
            return _fade(settings, PortfolioPage());
          case AppRoutes.trades:
            return _fade(settings, TradesPage());
          case AppRoutes.settings:
            return _fade(settings, SettingsPage());
          case AppRoutes.aiAssistant:
            return _fade(settings, const AiAssistantPage());
          case AppRoutes.search:
            return _fade(settings, const GlobalSearchPage());
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

  static PageRoute<void> _fade(RouteSettings settings, Widget page) {
    return PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 220),
    );
  }
}
