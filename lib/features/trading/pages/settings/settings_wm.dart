import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/bot_config_model.dart';
import '../../repositories/trading_repository.dart';

class SettingsState {
  const SettingsState({
    this.config,
    this.draft,
    this.isLoading = true,
    this.isSaving = false,
    this.isBusy = false,
    this.error,
    this.message,
  });

  final BotConfig? config;
  final BotConfig? draft;
  final bool isLoading;
  final bool isSaving;
  final bool isBusy;
  final String? error;
  final String? message;

  bool get isDirty => config != null && draft != null && !_same(config!, draft!);

  static bool _same(BotConfig a, BotConfig b) =>
      a.symbol == b.symbol &&
      a.interval == b.interval &&
      a.macdFast == b.macdFast &&
      a.macdSlow == b.macdSlow &&
      a.macdSignal == b.macdSignal &&
      a.positionSizePct == b.positionSizePct &&
      a.stopLossPct == b.stopLossPct &&
      a.takeProfitPct == b.takeProfitPct &&
      a.maxDailyLossPct == b.maxDailyLossPct &&
      a.tradeCooldownMinutes == b.tradeCooldownMinutes &&
      a.useCrossoverSignals == b.useCrossoverSignals &&
      a.requireMacdAboveZeroForBuy == b.requireMacdAboveZeroForBuy;

  SettingsState copyWith({
    BotConfig? config,
    BotConfig? draft,
    bool? isLoading,
    bool? isSaving,
    bool? isBusy,
    String? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return SettingsState(
      config: config ?? this.config,
      draft: draft ?? this.draft,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class SettingsWidgetModel extends WidgetModel {
  SettingsWidgetModel(this._repository)
      : super(const WidgetModelDependencies());

  final TradingRepository _repository;
  final BehaviorSubject<SettingsState> stateStream =
      BehaviorSubject.seeded(const SettingsState());

  @override
  void onLoad() {
    super.onLoad();
    refresh();
  }

  Future<void> refresh() async {
    final current = stateStream.value;
    stateStream.add(current.copyWith(isLoading: true, clearError: true));
    try {
      final config = await _repository.getConfig();
      stateStream.add(
        SettingsState(config: config, draft: config, isLoading: false),
      );
    } catch (e, st) {
      handleError(e, st);
      stateStream.add(
        current.copyWith(
          isLoading: false,
          error: e is DataError ? e.displayMessage : e.toString(),
        ),
      );
    }
  }

  void updateDraft(BotConfig Function(BotConfig) updater) {
    final draft = stateStream.value.draft;
    if (draft == null) return;
    stateStream.add(stateStream.value.copyWith(draft: updater(draft)));
  }

  Future<void> save() async {
    final current = stateStream.value;
    final draft = current.draft;
    final original = current.config;
    if (draft == null || original == null || !current.isDirty) return;

    stateStream.add(current.copyWith(isSaving: true, clearError: true, clearMessage: true));
    try {
      final saved = await _repository.saveConfig(draft, original);
      stateStream.add(
        SettingsState(
          config: saved,
          draft: saved,
          isLoading: false,
          message: 'Конфиг сохранён',
        ),
      );
    } catch (e, st) {
      handleError(e, st);
      stateStream.add(
        current.copyWith(
          isSaving: false,
          error: e is DataError ? e.displayMessage : e.toString(),
        ),
      );
    }
  }

  Future<void> startBot() async {
    final draft = stateStream.value.draft;
    if (draft == null) return;
    await _runControl(
      () => _repository.start(symbol: draft.symbol, interval: draft.interval),
      success: 'Бот запущен',
    );
  }

  Future<void> stopBot() async {
    await _runControl(() => _repository.stop(), success: 'Бот остановлен');
  }

  Future<void> panic() async {
    await _runControl(
      () => _repository.emergencyStop(),
      success: 'Emergency stop выполнен',
    );
  }

  Future<void> _runControl(
    Future<void> Function() action, {
    required String success,
  }) async {
    final current = stateStream.value;
    stateStream.add(current.copyWith(isBusy: true, clearError: true, clearMessage: true));
    try {
      await action();
      stateStream.add(
        stateStream.value.copyWith(isBusy: false, message: success),
      );
    } catch (e, st) {
      handleError(e, st);
      stateStream.add(
        stateStream.value.copyWith(
          isBusy: false,
          error: e is DataError ? e.displayMessage : e.toString(),
        ),
      );
    }
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
