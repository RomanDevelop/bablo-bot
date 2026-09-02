import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/constants/backtest_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/backtest_model.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/money_format.dart';
import 'di/lab_wm_builder.dart';
import 'lab_wm.dart';

class LabPage extends CoreMwwmWidget<LabWidgetModel> {
  const LabPage({super.key}) : super(widgetModelBuilder: createLabWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.lab),
        builder: (_) => LabPage(),
      );

  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends MwwmWidgetState<LabPage, LabWidgetModel> {
  late final TextEditingController _symbolCtrl;

  @override
  void initState() {
    super.initState();
    _symbolCtrl = TextEditingController(text: wm.stateStream.value.symbolInput);
    _symbolCtrl.addListener(() {
      wm.setSymbolInput(_symbolCtrl.text);
    });
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return StreamBuilder<LabState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const LabState();

        if (_symbolCtrl.text != state.symbolInput &&
            !state.isRunning &&
            state.result == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_symbolCtrl.text != state.symbolInput) {
              _symbolCtrl.text = state.symbolInput;
              _symbolCtrl.selection = TextSelection.collapsed(
                offset: state.symbolInput.length,
              );
            }
          });
        }

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
            title: const Text('Lab'),
          ),
          body: state.isBootstrapping
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  children: [
                    Text(
                      BacktestConstants.title,
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      BacktestConstants.subtitle,
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
                      BacktestConstants.intro,
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    if (state.config != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.config!.strategyNote,
                        style: TextStyle(
                          color: p.textMuted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (state.error != null) ...[
                      ErrorBanner(
                        message: state.error!,
                        onRetry: state.config == null
                            ? wm.bootstrap
                            : wm.runBacktest,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TradingCard(
                      borderColor: p.primary.withValues(alpha: 0.35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('Symbol'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _symbolCtrl,
                            textCapitalization: TextCapitalization.characters,
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: 'AVAX or AVAXUSDT',
                              suffixText: '→ ${state.normalizedSymbol}',
                              suffixStyle: TextStyle(
                                color: p.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (state.symbolSuggestions.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.symbolSuggestions
                                  .map(
                                    (symbol) => _SymbolChip(
                                      symbol: symbol,
                                      selected: symbol == state.normalizedSymbol,
                                      onTap: () {
                                        wm.selectSymbol(symbol);
                                        _symbolCtrl.text = symbol;
                                      },
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const SectionLabel('Period'),
                          const SizedBox(height: 10),
                          _DaySegmented(
                            presets: state.dayPresets,
                            selected: state.days,
                            onSelected: wm.selectDays,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            BacktestConstants.runHint,
                            style: TextStyle(
                              color: p.textMuted,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: state.isRunning ? null : wm.runBacktest,
                              icon: state.isRunning
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: p.onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow_rounded),
                              label: Text(
                                state.isRunning ? 'Running…' : 'Run backtest',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.result != null) ...[
                      const SizedBox(height: 16),
                      _SummarySection(result: state.result!),
                      const SizedBox(height: 12),
                      _TradesSection(result: state.result!),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.borderSubtle),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: p.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              BacktestConstants.disclaimer,
                              style: TextStyle(
                                color: p.textMuted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SymbolChip extends StatelessWidget {
  const _SymbolChip({
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  final String symbol;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Material(
      color: selected ? p.primary.withValues(alpha: 0.18) : p.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? p.primary : p.borderSubtle,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            symbol,
            style: TextStyle(
              color: selected ? p.primary : p.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DaySegmented extends StatelessWidget {
  const _DaySegmented({
    required this.presets,
    required this.selected,
    required this.onSelected,
  });

  final List<int> presets;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Row(
      children: [
        for (var i = 0; i < presets.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _DayChip(
              days: presets[i],
              selected: presets[i] == selected,
              onTap: () => onSelected(presets[i]),
              palette: p,
            ),
          ),
        ],
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.days,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  final int days;
  final bool selected;
  final VoidCallback onTap;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? palette.primary.withValues(alpha: 0.18) : palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? palette.primary : palette.borderSubtle,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              '$days d',
              style: TextStyle(
                color: selected ? palette.primary : palette.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.result});

  final BacktestResult result;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final summary = result.summary;
    final pnlColor = MoneyFormat.isPositive(summary.totalPnlPct)
        ? p.buy
        : MoneyFormat.isNegative(summary.totalPnlPct)
            ? p.sell
            : p.textSecondary;

    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            'Summary · ${result.symbol}',
            trailing: Text(
              '${result.days}d',
              style: TextStyle(
                color: p.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            MoneyFormat.pct(summary.totalPnlPct),
            style: context.tradingText.monoLarge.copyWith(
              color: pnlColor,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total PnL',
            style: TextStyle(color: p.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              MetricTile(
                label: 'Win rate',
                value: summary.winRate.isEmpty
                    ? '—'
                    : MoneyFormat.pct(summary.winRate, signed: false),
              ),
              MetricTile(
                label: 'Trades',
                value: '${summary.trades}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MetricTile(
                label: 'Max DD',
                value: summary.maxDrawdownPct.isEmpty
                    ? '—'
                    : MoneyFormat.pct(summary.maxDrawdownPct, signed: false),
                valueColor: p.sell,
              ),
              if (summary.wins != null && summary.losses != null)
                MetricTile(
                  label: 'W / L',
                  value: '${summary.wins} / ${summary.losses}',
                )
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (summary.periodStart != null || summary.periodEnd != null) ...[
            const SizedBox(height: 12),
            KeyValueRow(
              label: 'Period',
              value:
                  '${MoneyFormat.dateTime(summary.periodStart)} — '
                  '${MoneyFormat.dateTime(summary.periodEnd)}',
              mono: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _TradesSection extends StatelessWidget {
  const _TradesSection({required this.result});

  final BacktestResult result;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final trades = result.trades;

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Trades (${trades.length})'),
          if (trades.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'No trades in this period.',
              style: TextStyle(color: p.textMuted, fontSize: 13),
            ),
          ] else ...[
            const SizedBox(height: 8),
            ...trades.map((trade) => _TradeRow(trade: trade)),
          ],
        ],
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({required this.trade});

  final BacktestTrade trade;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final pnlColor = MoneyFormat.isPositive(trade.pnlPct)
        ? p.buy
        : MoneyFormat.isNegative(trade.pnlPct)
            ? p.sell
            : p.textSecondary;
    final sideColor = trade.isLong ? p.buy : p.sell;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sideColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trade.side.isEmpty ? '—' : trade.side.toUpperCase(),
              style: TextStyle(
                color: sideColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MoneyFormat.pct(trade.pnlPct),
                  style: context.tradingText.monoMedium.copyWith(
                    color: pnlColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trade.exitReason.isEmpty ? '—' : trade.exitReason,
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
                if (trade.exitAt != null || trade.entryAt != null)
                  Text(
                    MoneyFormat.dateTime(trade.exitAt ?? trade.entryAt),
                    style: TextStyle(color: p.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
