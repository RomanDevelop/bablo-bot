import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/documents_constants.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/theme_controller.dart';

/// Documents vault — Midnight Signal cabinet surface.
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => navigateBackOrHome(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Documents'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: const [
          _Header(),
          SizedBox(height: 16),
          _IntroCard(),
          SizedBox(height: 22),
          SectionLabel('Внутри раздела'),
          SizedBox(height: 12),
          _CategoriesList(),
          SizedBox(height: 18),
          _VaultNote(),
          SizedBox(height: 22),
          _FooterSignature(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.35),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.primaryDim,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.primary.withValues(alpha: 0.45)),
            ),
            child: Icon(
              Icons.folder_special_rounded,
              color: p.primaryHover,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DocumentsConstants.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DocumentsConstants.tagline,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DocumentsConstants.intro,
            style: TextStyle(color: p.textPrimary, fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 12),
          Text(
            DocumentsConstants.body,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList();

  static const _icons = <IconData>[
    Icons.handshake_outlined,
    Icons.pie_chart_outline_rounded,
    Icons.policy_outlined,
    Icons.gavel_rounded,
    Icons.slideshow_outlined,
    Icons.lock_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < DocumentsConstants.categories.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CategoryTile(
              title: DocumentsConstants.categories[i].$1,
              subtitle: DocumentsConstants.categories[i].$2,
              locked: DocumentsConstants.categories[i].$3,
              icon: _icons[i % _icons.length],
            ),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.subtitle,
    required this.locked,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool locked;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      borderColor: locked ? p.primary.withValues(alpha: 0.45) : null,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              locked
                  ? 'Confidential — доступ только по приглашению'
                  : '$title — архив скоро откроется',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: p.primaryDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.primary.withValues(alpha: 0.45)),
            ),
            child: Icon(icon, color: p.primaryHover, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    if (locked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: p.primaryDim,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: p.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'LOCKED',
                          style: TextStyle(
                            color: p.primaryHover,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      )
                    else
                      Text(
                        'PDF',
                        style: TextStyle(
                          color: p.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
            color: p.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _VaultNote extends StatelessWidget {
  const _VaultNote();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: p.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              DocumentsConstants.emptyHint,
              style: TextStyle(color: p.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSignature extends StatelessWidget {
  const _FooterSignature();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: p.divider,
        ),
        const SizedBox(height: 16),
        Text(
          DocumentsConstants.footer,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 6),
        const Text('😎', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
