import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../chart/chart_page.dart';
import '../dashboard/dashboard_page.dart';
import '../portfolio/portfolio_page.dart';
import '../settings/settings_page.dart';
import '../trades/trades_page.dart';
import '../us_stocks/us_stocks_page.dart';

class TradingShellPage extends StatefulWidget {
  const TradingShellPage({super.key});

  @override
  State<TradingShellPage> createState() => _TradingShellPageState();
}

class _TradingShellPageState extends State<TradingShellPage> {
  int _index = 0;

  late final List<Widget> _pages = [
    DashboardPage(),
    ChartPage(),
    UsStocksPage(),
    PortfolioPage(),
    TradesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
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
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
                icon: Icon(Icons.ssid_chart_outlined),
                selectedIcon: Icon(Icons.ssid_chart, color: AppColors.primary),
                label: 'US',
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
