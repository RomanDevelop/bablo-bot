import 'package:rxdart/rxdart.dart';

import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/mwwm/widget_model.dart';

class SubscriptionsState {
  const SubscriptionsState({
    this.selectedPlanId = SubscriptionPlanId.premium,
    this.fundAmountUsd = 100,
    this.customAmountText = '100',
    this.isCheckingOut = false,
    this.message,
  });

  final SubscriptionPlanId selectedPlanId;
  final double fundAmountUsd;
  final String customAmountText;
  final bool isCheckingOut;
  final String? message;

  SubscriptionsState copyWith({
    SubscriptionPlanId? selectedPlanId,
    double? fundAmountUsd,
    String? customAmountText,
    bool? isCheckingOut,
    String? message,
    bool clearMessage = false,
  }) {
    return SubscriptionsState(
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      fundAmountUsd: fundAmountUsd ?? this.fundAmountUsd,
      customAmountText: customAmountText ?? this.customAmountText,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class SubscriptionsWidgetModel extends WidgetModel {
  SubscriptionsWidgetModel() : super(const WidgetModelDependencies());

  final BehaviorSubject<SubscriptionsState> stateStream =
      BehaviorSubject.seeded(const SubscriptionsState());

  List<SubscriptionPlan> get plans => SubscriptionConstants.plans;

  SubscriptionPlan planById(SubscriptionPlanId id) =>
      plans.firstWhere((p) => p.id == id);

  void selectPlan(SubscriptionPlanId id) {
    stateStream.add(stateStream.value.copyWith(selectedPlanId: id));
  }

  void selectSuggestedAmount(int usd) {
    stateStream.add(
      stateStream.value.copyWith(
        fundAmountUsd: usd.toDouble(),
        customAmountText: usd.toString(),
        selectedPlanId: SubscriptionPlanId.fund,
      ),
    );
  }

  void onCustomAmountChanged(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\d.]'), '');
    final parsed = double.tryParse(cleaned);
    stateStream.add(
      stateStream.value.copyWith(
        customAmountText: cleaned,
        fundAmountUsd: parsed ?? stateStream.value.fundAmountUsd,
        selectedPlanId: SubscriptionPlanId.fund,
      ),
    );
  }

  Future<void> checkout() async {
    final state = stateStream.value;
    final plan = planById(state.selectedPlanId);

    if (plan.allowsCustomAmount) {
      final amount = state.fundAmountUsd;
      if (amount < plan.minAmountUsd) {
        stateStream.add(
          state.copyWith(
            message: 'Минимум для фонда — \$${plan.minAmountUsd.toStringAsFixed(0)}',
          ),
        );
        return;
      }
    }

    stateStream.add(state.copyWith(isCheckingOut: true));

    // Backend will create Stripe Checkout Session (Apple Pay / Google Pay / card).
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (isDisposed) return;

    if (!SubscriptionConstants.checkoutReady) {
      stateStream.add(
        stateStream.value.copyWith(
          isCheckingOut: false,
          message: plan.allowsCustomAmount
              ? 'Stripe Checkout: ${plan.title} · \$${state.fundAmountUsd.toStringAsFixed(0)} — подключим API'
              : 'Stripe Checkout: ${plan.title} · ${plan.priceLabel}${plan.billingLabel} — подключим API',
        ),
      );
      return;
    }

    stateStream.add(
      stateStream.value.copyWith(
        isCheckingOut: false,
        message: 'Открываем оплату…',
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
