import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/market_constants.dart';
import '../../../../core/mwwm/widget_model.dart';

class UsStocksState {
  const UsStocksState({
    this.isLoading = true,
    this.hasError = false,
    this.message,
  });

  final bool isLoading;
  final bool hasError;
  final String? message;

  UsStocksState copyWith({
    bool? isLoading,
    bool? hasError,
    String? message,
    bool clearMessage = false,
  }) {
    return UsStocksState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class UsStocksWidgetModel extends WidgetModel {
  UsStocksWidgetModel() : super(const WidgetModelDependencies());

  final BehaviorSubject<UsStocksState> stateStream =
      BehaviorSubject.seeded(const UsStocksState());

  Uri get exchangeUri => Uri.parse(MarketConstants.usStocksExchangeUrl);

  void onPageStarted() {
    stateStream.add(
      stateStream.value.copyWith(isLoading: true, hasError: false),
    );
  }

  void onPageFinished() {
    stateStream.add(stateStream.value.copyWith(isLoading: false));
  }

  void onWebResourceError() {
    stateStream.add(
      stateStream.value.copyWith(
        isLoading: false,
        hasError: true,
        message: 'Не удалось загрузить биржу',
      ),
    );
  }

  Future<void> openExternal() async {
    final ok = await launchUrl(exchangeUri, mode: LaunchMode.externalApplication);
    if (!ok) {
      stateStream.add(
        stateStream.value.copyWith(message: 'Не удалось открыть UTEX'),
      );
    }
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
