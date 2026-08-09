import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/bot_config_model.dart';
import 'di/settings_wm_builder.dart';
import 'settings_wm.dart';

class SettingsPage extends CoreMwwmWidget<SettingsWidgetModel> {
  SettingsPage({super.key})
      : super(widgetModelBuilder: createSettingsWidgetModel);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState
    extends MwwmWidgetState<SettingsPage, SettingsWidgetModel> {
  late final TextEditingController _symbolCtrl;
  late final TextEditingController _posSizeCtrl;
  late final TextEditingController _slCtrl;
  late final TextEditingController _tpCtrl;
  late final TextEditingController _maxLossCtrl;
  late final TextEditingController _cooldownCtrl;
  bool _controllersReady = false;

  @override
  void initState() {
    super.initState();
    _symbolCtrl = TextEditingController();
    _posSizeCtrl = TextEditingController();
    _slCtrl = TextEditingController();
    _tpCtrl = TextEditingController();
    _maxLossCtrl = TextEditingController();
    _cooldownCtrl = TextEditingController();
  }

  void _syncControllers(BotConfig draft) {
    void setIfChanged(TextEditingController c, String v) {
      if (c.text != v) {
        c.value = TextEditingValue(
          text: v,
          selection: TextSelection.collapsed(offset: v.length),
        );
      }
    }

    setIfChanged(_symbolCtrl, draft.symbol);
    setIfChanged(_posSizeCtrl, draft.positionSizePct.toString());
    setIfChanged(_slCtrl, draft.stopLossPct.toString());
    setIfChanged(_tpCtrl, draft.takeProfitPct.toString());
    setIfChanged(_maxLossCtrl, draft.maxDailyLossPct.toString());
    setIfChanged(_cooldownCtrl, draft.tradeCooldownMinutes.toString());
    _controllersReady = true;
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _posSizeCtrl.dispose();
    _slCtrl.dispose();
    _tpCtrl.dispose();
    _maxLossCtrl.dispose();
    _cooldownCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SettingsState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SettingsState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            wm.stateStream.add(wm.stateStream.value.copyWith(clearMessage: true));
          });
        }

        final draft = state.draft;
        if (draft != null && (!_controllersReady || !state.isDirty)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _syncControllers(draft);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            leading: IconButton(
              tooltip: 'Назад',
              onPressed: () => navigateBackOrHome(context),
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (state.isDirty)
                TextButton(
                  onPressed: state.isSaving ? null : () => wm.save(),
                  child: Text(
                    state.isSaving ? '...' : 'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SettingsState state) {
    if (state.isLoading && state.draft == null) {
      return const PageLoading();
    }
    final draft = state.draft;
    if (draft == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: state.error != null
            ? ErrorBanner(message: state.error!, onRetry: wm.refresh)
            : const SizedBox.shrink(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (state.error != null) ...[
          ErrorBanner(message: state.error!, onRetry: wm.refresh),
          const SizedBox(height: 12),
        ],
        _AdminControls(
          busy: state.isBusy,
          onStart: () => wm.startBot(),
          onStop: () => wm.stopBot(),
          onPanic: () => _confirmPanic(context),
        ),
        const SizedBox(height: 16),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Futures'),
              const SizedBox(height: 12),
              KeyValueRow(
                label: 'Mode',
                value: draft.mode ?? '—',
                mono: false,
              ),
              if (draft.scanMode != null && draft.scanMode!.isNotEmpty)
                KeyValueRow(
                  label: 'Scan',
                  value: draft.scanMode!,
                  mono: false,
                ),
              KeyValueRow(
                label: 'Leverage',
                value: draft.futuresLabel,
                mono: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Пара и интервал'),
              const SizedBox(height: 12),
              TextField(
                controller: _symbolCtrl,
                decoration: const InputDecoration(labelText: 'Symbol'),
                textCapitalization: TextCapitalization.characters,
                onChanged: (v) => wm.updateDraft(
                  (d) => d.copyWith(symbol: v.trim().toUpperCase()),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(draft.interval),
                initialValue: ApiConstants.binanceIntervals.contains(draft.interval)
                    ? draft.interval
                    : '1h',
                decoration: const InputDecoration(labelText: 'Interval'),
                dropdownColor: AppColors.surfaceElevated,
                items: ApiConstants.binanceIntervals
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    wm.updateDraft((d) => d.copyWith(interval: v));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Стратегия'),
              const SizedBox(height: 12),
              Text(
                'Alligator H1 scanner',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jaw 13/8 · Teeth 8/5 · Lips 5/3\n'
                'Корзина ETH / BNB / SOL / XRP · 1 позиция → manage → scan',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Активная пара: ${draft.symbol} · ${draft.interval}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Риск'),
              const SizedBox(height: 12),
              _NumField(
                controller: _posSizeCtrl,
                label: 'Position size %',
                decimal: true,
                onChanged: (v) => wm.updateDraft(
                  (d) => d.copyWith(
                    positionSizePct: double.tryParse(v) ?? d.positionSizePct,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _NumField(
                      controller: _slCtrl,
                      label: 'Stop loss %',
                      decimal: true,
                      onChanged: (v) => wm.updateDraft(
                        (d) => d.copyWith(
                          stopLossPct: double.tryParse(v) ?? d.stopLossPct,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumField(
                      controller: _tpCtrl,
                      label: 'Take profit %',
                      decimal: true,
                      onChanged: (v) => wm.updateDraft(
                        (d) => d.copyWith(
                          takeProfitPct: double.tryParse(v) ?? d.takeProfitPct,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _NumField(
                controller: _maxLossCtrl,
                label: 'Max daily loss %',
                decimal: true,
                onChanged: (v) => wm.updateDraft(
                  (d) => d.copyWith(
                    maxDailyLossPct: double.tryParse(v) ?? d.maxDailyLossPct,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _NumField(
                controller: _cooldownCtrl,
                label: 'Cooldown (min)',
                onChanged: (v) => wm.updateDraft(
                  (d) => d.copyWith(
                    tradeCooldownMinutes:
                        int.tryParse(v) ?? d.tradeCooldownMinutes,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.isBusy || state.isSaving) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.border,
          ),
        ],
      ],
    );
  }

  Future<void> _confirmPanic(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency stop?'),
        content: const Text(
          'Бот будет аварийно остановлен. Подтвердите ещё раз.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Panic',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final ok2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Точно?'),
        content: const Text('Это второй confirm для emergency-stop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'STOP NOW',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok2 == true) await wm.panic();
  }
}

class _AdminControls extends StatelessWidget {
  const _AdminControls({
    required this.busy,
    required this.onStart,
    required this.onStop,
    required this.onPanic,
  });

  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPanic;

  @override
  Widget build(BuildContext context) {
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Управление ботом'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // TODO: временно отключено исполнение Start/Stop/Panic
                  onPressed: null, // busy ? null : onStart,
                  child: const Text('Start'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: null, // busy ? null : onStop,
                  child: const Text('Stop'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: null, // busy ? null : onPanic,
                  child: const Text('Panic'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: onChanged,
    );
  }
}
