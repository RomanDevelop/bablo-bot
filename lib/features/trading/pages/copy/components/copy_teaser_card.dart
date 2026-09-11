import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/copy_constants.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/copy_model.dart';

class CopyTeaserCard extends StatelessWidget {
  const CopyTeaserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSession>();
    if (!auth.isAuthenticated) return const SizedBox.shrink();

    final p = context.watch<ThemeController>().palette;
    final dto = auth.bootstrap?.copy;
    final status = dto == null ? null : CopyStatus.fromDto(dto);
    final stake = status?.stake;
    final gated = !auth.canUseCopyTrading && !(status?.eligible ?? false);

    final title = stake != null
        ? CopyConstants.rsv(stake.equityRsv)
        : gated
            ? CopyConstants.premiumTitle
            : CopyConstants.subtitle;
    final subtitle = stake != null
        ? 'PnL ${_signed(stake.pnlRsv)} · ${CopyConstants.countdown(stake.remainingSeconds)}'
        : gated
            ? CopyConstants.premiumBody
            : 'Залочь Earned RSV и копируй сделки бота';

    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.3),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.copy),
      child: Row(
        children: [
          Icon(Icons.sync_alt_rounded, color: p.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CopyConstants.title,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.textMuted),
        ],
      ),
    );
  }

  static String _signed(num value) {
    final body = CopyConstants.rsv(value.abs());
    if (value > 0) return '+$body';
    if (value < 0) return '−$body';
    return body;
  }
}
