import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/external_services_config.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_controller.dart';
import '../premium_service_dialog.dart';

class RightSideMenu extends StatelessWidget {
  const RightSideMenu({
    super.key,
    required this.onClose,
    this.onOpenTab,
  });

  final VoidCallback onClose;
  final ValueChanged<int>? onOpenTab;

  Future<void> _openExternal(
    BuildContext context,
    ExternalServiceLink link,
  ) async {
    if (!link.enabled) {
      _toast(context, '${link.title} недоступен');
      return;
    }
    if (!link.hasUrl) {
      _toast(context, '${link.title}: ссылка скоро появится');
      return;
    }
    final uri = Uri.tryParse(link.url);
    if (uri == null) {
      _toast(context, 'Некорректная ссылка');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      _toast(context, 'Не удалось открыть ${link.title}');
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _push(BuildContext context, String route) {
    final nav = Navigator.of(context);
    onClose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nav.pushNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final p = theme.palette;
    final width = MediaQuery.sizeOf(context).width;
    final menuWidth = width.clamp(320, 480) * 0.82;

    return Material(
      color: p.surface,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: menuWidth,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
                child: Row(
                  children: [
                    Text(
                      'Меню',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                      color: p.textSecondary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  children: [
                    SideMenuSection(
                      palette: p,
                      children: [
                        SideMenuItem(
                          palette: p,
                          icon: Icons.candlestick_chart_outlined,
                          title: 'Spot / Trading',
                          iconColor: p.primary,
                          onTap: () => _push(context, AppRoutes.chart),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.bolt_outlined,
                          title: 'Signals',
                          iconColor: p.buy,
                          onTap: () => _push(context, AppRoutes.signals),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Portfolio',
                          iconColor: p.hold,
                          onTap: () => _push(context, AppRoutes.portfolio),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.science_outlined,
                          title: 'Backtest Lab',
                          iconColor: p.primary,
                          onTap: () => _push(context, AppRoutes.lab),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.ssid_chart_outlined,
                          title: 'Market · US Stocks',
                          iconColor: p.primary,
                          onTap: () => _push(context, AppRoutes.usStocks),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SideMenuSection(
                      palette: p,
                      children: [
                        SideMenuItem(
                          palette: p,
                          icon: Icons.school_rounded,
                          title: 'Courses',
                          iconColor: p.primary,
                          onTap: () => _push(context, AppRoutes.courses),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.currency_exchange_rounded,
                          title: 'Currency Exchange',
                          iconColor: p.primary,
                          onTap: () => _push(context, AppRoutes.exchange),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.handshake_outlined,
                          title: 'Microloans',
                          iconColor: p.hold,
                          onTap: () => _push(context, AppRoutes.microloans),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.person_outline_rounded,
                          title: 'Profile',
                          iconColor: p.primary,
                          onTap: () => _push(context, AppRoutes.profile),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SideMenuSection(
                      palette: p,
                      children: [
                        SideMenuItem(
                          palette: p,
                          icon: Icons.auto_awesome_rounded,
                          title: 'AI Assistant',
                          iconColor: p.primary,
                          onTap: () => _push(context, AppRoutes.aiAssistant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SideMenuSection(
                      palette: p,
                      children: [
                        SideMenuItem(
                          palette: p,
                          icon: Icons.forum_outlined,
                          title: 'Telegram Community',
                          iconColor: p.primary,
                          onTap: () => _openExternal(
                            context,
                            ExternalServicesConfig.telegramCommunity,
                          ),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.card_giftcard_outlined,
                          title: 'Партнёрская программа',
                          onTap: () => _push(context, AppRoutes.partner),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.workspace_premium_outlined,
                          title: 'Подписки',
                          onTap: () => _push(context, AppRoutes.subscriptions),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...ExternalServicesConfig.leisure.map(
                      (link) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ExternalServiceMenuItem(
                          palette: p,
                          link: link,
                          onTap: () {
                            if (link.isInternal) {
                              _push(context, link.internalRoute!);
                              return;
                            }
                            if (link.requiresPremium) {
                              showPremiumServiceDialog(
                                context,
                                link,
                                onBeforeNavigate: onClose,
                              );
                              return;
                            }
                            _openExternal(context, link);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SideMenuSection(
                      palette: p,
                      children: [
                        SideMenuItem(
                          palette: p,
                          icon: Icons.tune_outlined,
                          title: 'Admin / Settings',
                          onTap: () => _push(context, AppRoutes.settings),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {
                            onClose();
                            _toast(context, 'Уведомления — скоро');
                          },
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.language_outlined,
                          title: 'Language: Русский',
                          onTap: () {
                            onClose();
                            _toast(context, 'Смена языка — скоро');
                          },
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: theme.isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          title: 'Тема: ${theme.label}',
                          onTap: () async {
                            await context.read<ThemeController>().cycle();
                          },
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.help_outline_rounded,
                          title: 'Help',
                          onTap: () => _push(context, AppRoutes.help),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.description_outlined,
                          title: 'Documents',
                          onTap: () => _push(context, AppRoutes.documents),
                        ),
                        SideMenuItem(
                          palette: p,
                          icon: Icons.info_outline_rounded,
                          title: 'About',
                          onTap: () => _push(context, AppRoutes.about),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SideMenuSection extends StatelessWidget {
  const SideMenuSection({
    super.key,
    required this.children,
    required this.palette,
  });

  final List<Widget> children;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.elevatedCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 54, endIndent: 12, color: palette.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

class SideMenuItem extends StatelessWidget {
  const SideMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.palette,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final AppPalette palette;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? palette.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class ExternalServiceMenuItem extends StatelessWidget {
  const ExternalServiceMenuItem({
    super.key,
    required this.link,
    required this.onTap,
    this.palette,
  });

  final ExternalServiceLink link;
  final VoidCallback onTap;
  final AppPalette? palette;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? context.watch<ThemeController>().palette;

    return Material(
      color: p.elevatedCard,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: link.enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: p.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  switch (link.id) {
                    'pokerstars' => Icons.casino_outlined,
                    'casino' => Icons.sports_esports_outlined,
                    'sports_betting' => Icons.sports_soccer_outlined,
                    'temki_mutki' => Icons.handshake_outlined,
                    _ => Icons.open_in_new_rounded,
                  },
                  color: p.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.subtitle,
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (link.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    link.badge!,
                    style: TextStyle(
                      color: p.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: p.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
