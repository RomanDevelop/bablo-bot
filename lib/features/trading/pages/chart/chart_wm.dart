import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../repositories/chart_repository.dart';

class ChartState {
  const ChartState({
    this.snapshot,
    this.isLoading = true,
    this.error,
    this.visibleFrom = 0,
    this.visibleCount = 26,
  });

  final ChartSnapshot? snapshot;
  final bool isLoading;
  final String? error;
  final int visibleFrom;
  final int visibleCount;

  ChartState copyWith({
    ChartSnapshot? snapshot,
    bool? isLoading,
    String? error,
    int? visibleFrom,
    int? visibleCount,
    bool clearError = false,
  }) {
    return ChartState(
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      visibleFrom: visibleFrom ?? this.visibleFrom,
      visibleCount: visibleCount ?? this.visibleCount,
    );
  }
}

class ChartWidgetModel extends WidgetModel {
  ChartWidgetModel(this._repository) : super(const WidgetModelDependencies());

  final ChartRepository _repository;
  final BehaviorSubject<ChartState> stateStream =
      BehaviorSubject.seeded(const ChartState());
  Timer? _pollTimer;

  @override
  void onLoad() {
    super.onLoad();
    refresh();
    _pollTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      refresh(silent: true);
    });
  }

  Future<void> refresh({bool silent = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(
          isLoading: current.snapshot == null,
          clearError: true,
        ),
      );
    }
    try {
      final snapshot = await _repository.load();
      final count = current.visibleCount;
      final from = (snapshot.candles.length - count).clamp(0, 1 << 30);
      stateStream.add(
        ChartState(
          snapshot: snapshot,
          isLoading: false,
          visibleFrom: silent ? current.visibleFrom.clamp(0, from) : from,
          visibleCount: count,
        ),
      );
    } catch (e, st) {
      handleError(e, st);
      final message = e is DataError
          ? e.displayMessage
          : 'Ошибка загрузки графика. Нажми Retry.';
      stateStream.add(
        current.copyWith(
          isLoading: false,
          error: message,
        ),
      );
    }
  }

  void panBy(int candleDelta) {
    final s = stateStream.value;
    final snap = s.snapshot;
    if (snap == null) return;
    final maxFrom = (snap.candles.length - s.visibleCount).clamp(0, 1 << 30);
    final next = (s.visibleFrom + candleDelta).clamp(0, maxFrom);
    stateStream.add(s.copyWith(visibleFrom: next));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    stateStream.close();
    super.dispose();
  }
}
