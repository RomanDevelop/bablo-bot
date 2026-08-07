import 'package:flutter/material.dart';

import '../../../../../core/constants/subscription_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';

Color accentColor(SubscriptionAccent accent) {
  switch (accent) {
    case SubscriptionAccent.mint:
      return AppColors.buy;
    case SubscriptionAccent.gold:
      return AppColors.hold;
    case SubscriptionAccent.teal:
      return AppColors.primary;
    case SubscriptionAccent.pro:
      return const Color(0xFF7C9CFF);
  }
}

class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onSelect,
    this.fundSlot,
  });

  final SubscriptionPlan plan;
  final bool selected;
  final VoidCallback onSelect;
  final Widget? fundSlot;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor(plan.accent);
    final border = selected ? accent : AppColors.borderSubtle;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: selected ? 1.6 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RadioDot(selected: selected, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (plan.isPopular)
                              const _Badge(
                                label: 'Популярный',
                                color: AppColors.primary,
                              ),
                            if (plan.id == SubscriptionPlanId.pro)
                              const _Badge(
                                label: 'Максимум',
                                color: Color(0xFF7C9CFF),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.tagline,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _PriceBlock(
                    price: plan.priceLabel,
                    billing: plan.billingLabel,
                    accent: accent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...plan.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_rounded, size: 16, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (fundSlot != null && selected) ...[
                const SizedBox(height: 8),
                fundSlot!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FundAmountPicker extends StatelessWidget {
  const FundAmountPicker({
    super.key,
    required this.plan,
    required this.controller,
    required this.selectedAmount,
    required this.onSuggested,
    required this.onCustomChanged,
  });

  final SubscriptionPlan plan;
  final TextEditingController controller;
  final double selectedAmount;
  final ValueChanged<int> onSuggested;
  final ValueChanged<String> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'СУММА ИНВЕСТИЦИИ, USD',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plan.suggestedAmountsUsd.map((usd) {
              final active = selectedAmount == usd.toDouble() &&
                  controller.text == usd.toString();
              return ChoiceChip(
                label: Text('\$$usd'),
                selected: active,
                onSelected: (_) => onSuggested(usd),
                selectedColor: AppColors.holdBg,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: active ? AppColors.hold : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: active ? AppColors.hold : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onCustomChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: context.tradingText.monoMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: context.tradingText.monoMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              hintText: 'Своя сумма',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Минимум \$${plan.minAmountUsd.toStringAsFixed(0)}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class PaymentTrustRow extends StatelessWidget {
  const PaymentTrustRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Оплата через Stripe · Apple Pay · Google Pay',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: const [
            _PayChip(label: 'Stripe', icon: Icons.credit_card_rounded),
            _PayChip(label: 'Apple Pay', icon: Icons.apple),
            _PayChip(label: 'Google Pay', icon: Icons.g_mobiledata_rounded),
          ],
        ),
      ],
    );
  }
}

class _PayChip extends StatelessWidget {
  const _PayChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : AppColors.border,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.price,
    required this.billing,
    required this.accent,
  });

  final String price;
  final String billing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          price,
          style: context.tradingText.monoMedium.copyWith(
            color: accent,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          billing,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
