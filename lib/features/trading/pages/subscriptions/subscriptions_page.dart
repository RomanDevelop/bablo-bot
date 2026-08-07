import 'package:flutter/material.dart';

import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import 'components/subscription_plan_card.dart';
import 'di/subscriptions_wm_builder.dart';
import 'subscriptions_wm.dart';

class SubscriptionsPage extends CoreMwwmWidget<SubscriptionsWidgetModel> {
  SubscriptionsPage({super.key})
      : super(widgetModelBuilder: createSubscriptionsWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.subscriptions),
        builder: (_) => SubscriptionsPage(),
      );

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState
    extends MwwmWidgetState<SubscriptionsPage, SubscriptionsWidgetModel> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _syncAmountField(SubscriptionsState state) {
    if (_amountCtrl.text == state.customAmountText) return;
    _amountCtrl.value = TextEditingValue(
      text: state.customAmountText,
      selection: TextSelection.collapsed(
        offset: state.customAmountText.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SubscriptionsState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SubscriptionsState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            wm.clearMessage();
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncAmountField(state);
        });

        final selected = wm.planById(state.selectedPlanId);
        final ctaAccent = accentColor(selected.accent);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Подписки')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
            children: [
              const _Hero(),
              const SizedBox(height: 18),
              ...wm.plans.map((plan) {
                final isSelected = plan.id == state.selectedPlanId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SubscriptionPlanCard(
                    plan: plan,
                    selected: isSelected,
                    onSelect: () => wm.selectPlan(plan.id),
                    fundSlot: plan.allowsCustomAmount
                        ? FundAmountPicker(
                            plan: plan,
                            controller: _amountCtrl,
                            selectedAmount: state.fundAmountUsd,
                            onSuggested: wm.selectSuggestedAmount,
                            onCustomChanged: wm.onCustomAmountChanged,
                          )
                        : null,
                  ),
                );
              }),
              const SizedBox(height: 8),
              const PaymentTrustRow(),
              const SizedBox(height: 12),
              const Text(
                'Оплату обрабатывает Stripe. Подписку можно отменить '
                'в любой момент. Pro подключает API-ключи вашего аккаунта '
                'только после оплаты.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ctaAccent,
                    foregroundColor: selected.accent == SubscriptionAccent.gold
                        ? const Color(0xFF1A1200)
                        : AppColors.onPrimary,
                    disabledBackgroundColor: ctaAccent.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: state.isCheckingOut ? null : wm.checkout,
                  child: state.isCheckingOut
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: selected.accent == SubscriptionAccent.gold
                                ? const Color(0xFF1A1200)
                                : AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          selected.ctaLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A3D36),
            Color(0xFF151C25),
            Color(0xFF0E141B),
          ],
        ),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите уровень доступа',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'От символической поддержки до робота на вашем счёте. '
            'Оплата картой, Apple Pay или Google Pay.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
