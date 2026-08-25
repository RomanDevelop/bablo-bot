import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/exchange_constants.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  final _amountCtrl = TextEditingController(text: '100');
  ExchangeCurrency _from = ExchangeCatalog.currencies.first;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _amount {
    final raw = _amountCtrl.text.replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  double get _rsvOut {
    if (_from.code == 'RSV') return _amount;
    return _from.toRsv(_amount);
  }

  Future<void> _swap() async {
    if (_amount <= 0) {
      _toast('Enter an amount greater than zero');
      return;
    }
    final uri = ExchangeConstants.swapUri(
      fromCode: _from.code,
      amount: _amountCtrl.text.trim(),
      rsvOut: _formatRsv(_rsvOut),
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      _toast('Open Telegram: @${ExchangeConstants.telegramHandle}');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => navigateBackOrHome(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Currency Exchange'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          Text(
            ExchangeConstants.title,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ExchangeConstants.subtitle,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ExchangeConstants.intro,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          TradingCard(
            borderColor: p.primary.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FROM',
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                _CurrencyPicker(
                  value: _from,
                  onChanged: (c) => setState(() => _from = c),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    suffixText: _from.code,
                    suffixStyle: TextStyle(
                      color: p.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Icon(Icons.swap_vert_rounded, color: p.primary, size: 28),
          ),
          const SizedBox(height: 12),
          TradingCard(
            borderColor: p.primary.withValues(alpha: 0.55),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TO',
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('🪙', style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      ExchangeConstants.rsvName,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      ExchangeConstants.rsvTicker,
                      style: TextStyle(
                        color: p.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _formatRsv(_rsvOut),
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '1 ${ExchangeConstants.rsvTicker} = '
                  '\$${ExchangeConstants.rsvUsd}',
                  style: TextStyle(color: p.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: p.primary,
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            child: InkWell(
              onTap: _swap,
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_horiz_rounded, color: p.onPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'EXCHANGE TO RSV',
                      style: TextStyle(
                        color: p.onPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ExchangeConstants.uiOnlyHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textMuted, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 22),
          TradingCard(
            borderColor: p.primary.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUY RSV HERE',
                  style: TextStyle(
                    color: p.primaryHover,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ExchangeConstants.buyNote,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      AppNavigator.pushNamed(context, AppRoutes.temki),
                  icon: Icon(Icons.rocket_launch_outlined, color: p.primary),
                  label: Text(
                    'Spend RSV on Temki',
                    style: TextStyle(
                      color: p.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TradingCard(
            borderColor: p.buy.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ExchangeConstants.referralTitle.toUpperCase(),
                  style: TextStyle(
                    color: p.buy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ExchangeConstants.referralBody,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '+${ExchangeConstants.referralRewardRsv} RSV · '
                  'admin ${ExchangeConstants.referralAdmin}',
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatRsv(double value) {
    if (value >= 1000) {
      return '${value.toStringAsFixed(value >= 100 ? 0 : 2)} RSV';
    }
    return '${value.toStringAsFixed(2)} RSV';
  }
}

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({required this.value, required this.onChanged});

  final ExchangeCurrency value;
  final ValueChanged<ExchangeCurrency> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Material(
      color: p.surfaceElevated,
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      child: InkWell(
        onTap: () async {
          final picked = await showModalBottomSheet<ExchangeCurrency>(
            context: context,
            backgroundColor: p.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) {
              return SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Select currency',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final c in ExchangeCatalog.currencies)
                      ListTile(
                        leading: Text(c.icon, style: const TextStyle(fontSize: 22)),
                        title: Text(
                          c.code,
                          style: TextStyle(
                            color: p.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          c.name,
                          style: TextStyle(color: p.textSecondary),
                        ),
                        trailing: c.code == value.code
                            ? Icon(Icons.check_rounded, color: p.primary)
                            : null,
                        onTap: () => Navigator.pop(ctx, c),
                      ),
                  ],
                ),
              );
            },
          );
          if (picked != null) onChanged(picked);
        },
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(value.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.code,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      value.name,
                      style: TextStyle(color: p.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.expand_more_rounded, color: p.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
