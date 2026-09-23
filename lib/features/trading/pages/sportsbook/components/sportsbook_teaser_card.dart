import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/sportsbook_model.dart';

class SportsbookTeaserCard extends StatelessWidget {
  const SportsbookTeaserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSession>();
    if (!auth.isAuthenticated) return const SizedBox.shrink();

    final p = context.watch<ThemeController>().palette;
    final dto = auth.bootstrap?.sportsbook;
    final status = dto == null ? null : SportsbookStatus.fromDto(dto);
    final gated = !auth.canUseSportsbook && !(status?.eligible ?? false);

    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.3),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.sportsbook),
      child: Row(
        children: [
          Icon(Icons.sports_basketball_outlined, color: p.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SportsbookConstants.title,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gated
                      ? SportsbookConstants.premiumTitle
                      : SportsbookConstants.subtitle,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gated
                      ? SportsbookConstants.premiumBody
                      : status == null
                          ? 'NBA · только RSV'
                          : '${SportsbookConstants.rsv(status.availableRsv)} available',
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
}
