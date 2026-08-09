import 'package:flutter/material.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _ctrl = TextEditingController();
  String _query = '';

  static const _entries = <_SearchEntry>[
    _SearchEntry('Dashboard', 'Баланс и позиция', AppRoutes.home, Icons.home_outlined),
    _SearchEntry('Chart', 'Свечи и Alligator', AppRoutes.chart, Icons.candlestick_chart_outlined),
    _SearchEntry('US Stocks', 'UTEX market', AppRoutes.usStocks, Icons.ssid_chart_outlined),
    _SearchEntry('Portfolio', 'Кошелёк и позиция', AppRoutes.portfolio, Icons.account_balance_wallet_outlined),
    _SearchEntry('История / Trades', 'Сделки бота', AppRoutes.trades, Icons.history_outlined),
    _SearchEntry('Stats', 'PnL эпохи', AppRoutes.stats, Icons.insights_outlined),
    _SearchEntry('AI Assistant', 'Помощник', AppRoutes.aiAssistant, Icons.auto_awesome_outlined),
    _SearchEntry('Подписки', 'Тарифы', AppRoutes.subscriptions, Icons.workspace_premium_outlined),
    _SearchEntry('Партнёрство', 'Донат / банк', AppRoutes.partner, Icons.card_giftcard_outlined),
    _SearchEntry('About', 'Bablo Community', AppRoutes.about, Icons.info_outline_rounded),
    _SearchEntry('Documents', 'Official papers', AppRoutes.documents, Icons.description_outlined),
    _SearchEntry('Help', 'Центр взаимопомощи', AppRoutes.help, Icons.help_outline_rounded),
    _SearchEntry('Settings', 'Admin бота', AppRoutes.settings, Icons.tune_outlined),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _entries
        : _entries
            .where(
              (e) =>
                  e.title.toLowerCase().contains(q) ||
                  e.subtitle.toLowerCase().contains(q),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Поиск: рынок, история, функции…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = filtered[i];
          return Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (e.route == AppRoutes.home) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  return;
                }
                Navigator.of(context).pop();
                AppNavigator.pushNamed(context, e.route);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Icon(e.icon, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            e.subtitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchEntry {
  const _SearchEntry(this.title, this.subtitle, this.route, this.icon);

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}
