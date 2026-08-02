import 'package:flutter/material.dart';

import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';

/// Partner CTA — product Stats design (gift + text + gold CTA + details link).
class PartnerPromoCard extends StatelessWidget {
  const PartnerPromoCard({super.key});

  static const _gold = Color(0xFFF0B429);
  static const _goldBorder = Color(0xFFC9A227);
  static const _btnText = Color(0xFF1A1200);

  void _open(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.partner);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _goldBorder, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 400;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (narrow) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _GiftIcon(),
                          const SizedBox(width: 12),
                          const Expanded(child: _Copy()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: _PartnerButton(onPressed: () => _open(context)),
                      ),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const _GiftIcon(),
                          const SizedBox(width: 12),
                          const Expanded(child: _Copy()),
                          const SizedBox(width: 10),
                          _PartnerButton(onPressed: () => _open(context)),
                        ],
                      ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _open(context),
                      child: const Text(
                        'Подробнее в разделе «Партнёрская программа»',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftIcon extends StatelessWidget {
  const _GiftIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Icon(
        Icons.card_giftcard_rounded,
        color: PartnerPromoCard._gold,
        size: 24,
      ),
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Поддержите бота и зарабатывайте вместе!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            height: 1.25,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Перешлите донат — и получайте от 20% до 40% '
          'прибыли бота ежемесячно.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PartnerButton extends StatelessWidget {
  const _PartnerButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: PartnerPromoCard._gold,
        foregroundColor: PartnerPromoCard._btnText,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Стать партнёром',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}
