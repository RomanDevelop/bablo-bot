import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/documents_constants.dart';
import '../../../../core/navigation/navigate_back.dart';

/// Black & gold Documents vault — brand surface, placeholder archive.
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  static const _bg = Color(0xFF070707);
  static const _card = Color(0xFF121212);
  static const _gold = Color(0xFFD4AF37);
  static const _goldSoft = Color(0xFFC9A227);
  static const _goldDim = Color(0x33D4AF37);
  static const _text = Color(0xFFF5F0E6);
  static const _muted = Color(0xFFA89F8E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => navigateBackOrHome(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _text),
        ),
        title: Text(
          'Documents',
          style: GoogleFonts.dmSans(
            color: _text,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: const [
          _Header(),
          SizedBox(height: 18),
          _IntroCard(),
          SizedBox(height: 22),
          _SectionLabel(),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1508),
            Color(0xFF0A0A0A),
            Color(0xFF14100A),
          ],
        ),
        border: Border.all(color: DocumentsPage._gold.withValues(alpha: 0.45)),
        boxShadow: const [
          BoxShadow(
            color: DocumentsPage._goldDim,
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DocumentsPage._goldDim,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: DocumentsPage._gold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.folder_special_rounded,
                  color: DocumentsPage._gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  DocumentsConstants.title,
                  style: GoogleFonts.playfairDisplay(
                    color: DocumentsPage._gold,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            DocumentsConstants.tagline,
            style: GoogleFonts.dmSans(
              color: DocumentsPage._text,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DocumentsPage._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DocumentsPage._gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DocumentsConstants.intro,
            style: GoogleFonts.dmSans(
              color: DocumentsPage._text,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            DocumentsConstants.body,
            style: GoogleFonts.dmSans(
              color: DocumentsPage._muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      DocumentsConstants.sectionsLabel,
      style: GoogleFonts.playfairDisplay(
        color: DocumentsPage._gold,
        fontSize: 20,
        fontWeight: FontWeight.w700,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: DocumentsPage._card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DocumentsPage._gold.withValues(alpha: locked ? 0.45 : 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DocumentsPage._goldDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DocumentsPage._gold.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(icon, color: DocumentsPage._gold, size: 20),
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
                            style: GoogleFonts.dmSans(
                              color: DocumentsPage._text,
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
                              color: DocumentsPage._goldDim,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: DocumentsPage._gold.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'LOCKED',
                              style: GoogleFonts.dmSans(
                                color: DocumentsPage._gold,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          )
                        else
                          Text(
                            'PDF',
                            style: GoogleFonts.dmSans(
                              color: DocumentsPage._goldSoft,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        color: DocumentsPage._muted,
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
                color: DocumentsPage._muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultNote extends StatelessWidget {
  const _VaultNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DocumentsPage._gold.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: DocumentsPage._goldSoft,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              DocumentsConstants.emptyHint,
              style: GoogleFonts.dmSans(
                color: DocumentsPage._muted,
                fontSize: 13,
                height: 1.4,
              ),
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
    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                DocumentsPage._gold.withValues(alpha: 0.55),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          DocumentsConstants.footer,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            color: DocumentsPage._gold,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '😎',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 18),
        ),
      ],
    );
  }
}
