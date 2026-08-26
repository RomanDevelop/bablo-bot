import 'package:rxdart/rxdart.dart';

import '../../../../core/constants/signals_constants.dart';
import '../../../../core/mwwm/widget_model.dart';

class SignalsState {
  const SignalsState({
    this.category = '',
    this.isPremium = false,
    this.message,
  });

  final String category;
  final bool isPremium;
  final String? message;

  SignalsState copyWith({
    String? category,
    bool? isPremium,
    String? message,
    bool clearMessage = false,
  }) {
    return SignalsState(
      category: category ?? this.category,
      isPremium: isPremium ?? this.isPremium,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class SignalsWidgetModel extends WidgetModel {
  SignalsWidgetModel() : super(const WidgetModelDependencies());

  final BehaviorSubject<SignalsState> stateStream =
      BehaviorSubject.seeded(const SignalsState());

  List<TradeSignalItem> filteredSignals(SignalsState state) {
    if (state.category.isEmpty) return SignalsConstants.demoSignals;
    return SignalsConstants.demoSignals
        .where((s) => s.market == state.category)
        .toList();
  }

  void selectCategory(String id) {
    if (id == stateStream.value.category) return;
    stateStream.add(stateStream.value.copyWith(category: id));
  }

  /// UI-only until subscription entitlement comes from API.
  void requestConnect(SignalRobot robot) {
    final state = stateStream.value;
    if (!state.isPremium) {
      stateStream.add(
        state.copyWith(message: 'premium_gate:${robot.id}'),
      );
      return;
    }
    stateStream.add(
      state.copyWith(
        message: '${SignalsConstants.connectSoonMessage} (${robot.exchange})',
      ),
    );
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
