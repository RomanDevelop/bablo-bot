import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/auth/auth_session.dart';
import 'core/navigation/app_routes.dart';
import 'core/constants/courses_constants.dart';
import 'core/constants/temki_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data_management/data_manager.dart';
import 'features/trading/pages/about/about_page.dart';
import 'features/trading/pages/ai/ai_assistant_page.dart';
import 'features/trading/pages/ai/global_search_page.dart';
import 'features/trading/models/daily_article.dart';
import 'features/trading/pages/chart/chart_page.dart';
import 'features/trading/pages/courses/courses_page.dart';
import 'features/trading/pages/courses/mentor_course_page.dart';
import 'features/trading/pages/daily/daily_article_page.dart';
import 'features/trading/pages/documents/documents_page.dart';
import 'features/trading/pages/exchange/exchange_page.dart';
import 'features/trading/pages/help/help_page.dart';
import 'features/trading/pages/microloans/microloans_page.dart';
import 'features/trading/pages/partner/partner_page.dart';
import 'features/trading/pages/portfolio/portfolio_page.dart';
import 'features/trading/pages/profile/profile_page.dart';
import 'features/trading/pages/settings/settings_page.dart';
import 'features/trading/pages/shell/trading_shell_page.dart';
import 'features/trading/pages/signals/signals_page.dart';
import 'features/trading/pages/stats/stats_page.dart';
import 'features/trading/pages/subscriptions/subscriptions_page.dart';
import 'features/trading/pages/temki/temki_detail_page.dart';
import 'features/trading/pages/temki/temki_page.dart';
import 'features/trading/pages/trades/trades_page.dart';
import 'features/trading/pages/us_stocks/us_stocks_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initializeDateFormatting('ru');

  final dataManager = await DataManager.create();
  final themeController = await ThemeController.create();
  final authSession = await AuthSession.create();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataManager>.value(value: dataManager),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<AuthSession>.value(value: authSession),
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
      onGenerateInitialRoutes: _initialRoutes,
      onGenerateRoute: (settings) => _routeFor(settings),
    );
  }

  static List<Route<void>> _initialRoutes(String name) {
    final home = MaterialPageRoute<void>(
      settings: const RouteSettings(name: AppRoutes.home),
      builder: (_) => const TradingShellPage(),
    );
    final path = AppRoutes.pathOf(name);
    final dailyId = AppRoutes.dailyArticleId(path);
    if (dailyId != null) {
      return [
        home,
        _fade(
          RouteSettings(name: path),
          DailyArticlePage(articleId: dailyId),
        ),
      ];
    }
    if (path == AppRoutes.home) {
      return [home];
    }
    return [home, _routeFor(RouteSettings(name: path))];
  }

  static Route<void> _routeFor(RouteSettings settings) {
    final path = AppRoutes.pathOf(settings.name);
    final dailyId = AppRoutes.dailyArticleId(path);
    if (dailyId != null) {
      final preview = settings.arguments is DailyArticle
          ? settings.arguments as DailyArticle
          : null;
      return _fade(
        settings,
        DailyArticlePage(articleId: dailyId, preview: preview),
      );
    }

    final mentorId = AppRoutes.mentorCourseId(path);
    if (mentorId != null) {
      final content = settings.arguments is MentorCourseContent
          ? settings.arguments as MentorCourseContent
          : MentorCourses.byId(mentorId);
      if (content != null) {
        return _fade(settings, MentorCoursePage(content: content));
      }
    }

    final temkiId = AppRoutes.temkiItemId(path);
    if (temkiId != null) {
      final item = settings.arguments is TemkiListing
          ? settings.arguments as TemkiListing
          : TemkiCatalog.byId(temkiId);
      if (item != null) {
        return _fade(settings, TemkiDetailPage(item: item));
      }
    }

    switch (path) {
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
      case AppRoutes.signals:
        return _fade(settings, SignalsPage());
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
      case AppRoutes.about:
        return _fade(settings, const AboutPage());
      case AppRoutes.documents:
        return _fade(settings, const DocumentsPage());
      case AppRoutes.help:
        return _fade(settings, const HelpPage());
      case AppRoutes.courses:
        return _fade(settings, const CoursesPage());
      case AppRoutes.temki:
        return _fade(settings, const TemkiPage());
      case AppRoutes.exchange:
        return _fade(settings, const ExchangePage());
      case AppRoutes.microloans:
        return _fade(settings, MicroloansPage());
      case AppRoutes.profile:
        return _fade(settings, ProfilePage());
      case AppRoutes.home:
      default:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.home),
          builder: (_) => const TradingShellPage(),
        );
    }
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
