import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../chart/chart_page.dart';
import '../dashboard/dashboard_page.dart';
import '../portfolio/portfolio_page.dart';
import '../settings/settings_page.dart';
import '../stats/stats_page.dart';
import '../trades/trades_page.dart';

class TradingShellPage extends StatefulWidget {
  const TradingShellPage({super.key});

  @override
  State<TradingShellPage> createState() => _TradingShellPageState();
}

class _TradingShellPageState extends State<TradingShellPage> {
  int _index = 0;

  Widget _pageFor(int index) {
    switch (index) {
      case 0:
        return DashboardPage();
      case 1:
        return ChartPage();
      case 2:
        return PortfolioPage();
      case 3:
        return TradesPage();
      case 4:
        return SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_index),
        child: _pageFor(_index),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          color: AppColors.surface,
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 64,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primaryDim,
            selectedIndex: _index,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.candlestick_chart_outlined),
                selectedIcon:
                    Icon(Icons.candlestick_chart, color: AppColors.primary),
                label: 'Chart',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon:
                    Icon(Icons.account_balance_wallet, color: AppColors.primary),
                label: 'Portfolio',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
                label: 'Trades',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune, color: AppColors.primary),
                label: 'Admin',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keep Stats reachable from dashboard via route helper if needed later.
class StatsRoute {
  static Route<void> route() => MaterialPageRoute(builder: (_) => StatsPage());
}
