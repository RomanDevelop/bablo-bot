import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/constants/daily_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_format.dart';
import '../../models/daily_article.dart';
import 'daily_article_wm.dart';
import 'di/daily_article_wm_builder.dart';
import 'widgets/daily_network_image.dart';

class DailyArticlePage extends CoreMwwmWidget<DailyArticleWidgetModel> {
  DailyArticlePage({
    super.key,
    required this.articleId,
    this.preview,
  }) : super(
          widgetModelBuilder: (context) => createDailyArticleWidgetModel(
            context,
            articleId: articleId,
            preview: preview,
          ),
        );

  final String articleId;
  final DailyArticle? preview;

  @override
  State<DailyArticlePage> createState() => _DailyArticlePageState();
}

class _DailyArticlePageState
    extends MwwmWidgetState<DailyArticlePage, DailyArticleWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DailyArticleState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const DailyArticleState();
        final article = state.article;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            leading: IconButton(
              tooltip: 'Назад',
              onPressed: () => navigateBackOrHome(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('BABLO DAILY'),
            actions: [
              IconButton(
                tooltip: 'Поделиться',
                onPressed: article == null ? null : wm.share,
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          body: _buildBody(state, article),
        );
      },
    );
  }

  Widget _buildBody(DailyArticleState state, DailyArticle? article) {
    if (article == null && state.isLoading) {
      return const PageLoading();
    }
    if (article == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          ErrorBanner(
            message: state.error ?? 'Статья не найдена',
            onRetry: wm.refresh,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        if (state.error != null) ...[
          ErrorBanner(message: state.error!, onRetry: wm.refresh),
          const SizedBox(height: 12),
        ],
        _HeroImage(article: article),
        const SizedBox(height: 16),
        _CategoryBadge(
          label: article.categoryLabel.isNotEmpty
              ? article.categoryLabel
              : article.category,
        ),
        const SizedBox(height: 10),
        Text(
          article.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.25,
            letterSpacing: -0.4,
          ),
        ),
        if (article.subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            article.subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 14),
        _AuthorRow(article: article),
        if (article.summary.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            article.summary,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (state.isLoading && !article.hasBody)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: PageLoading(),
          )
        else if (article.hasBody)
          MarkdownBody(
            data: article.body!,
            selectable: true,
            onTapLink: (text, href, title) {
              if (href == null) return;
              final uri = Uri.tryParse(href);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15.5,
                height: 1.55,
              ),
              h1: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              h2: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
              h3: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              strong: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              a: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              listBullet: TextStyle(color: AppColors.textSecondary),
              blockquote: TextStyle(color: AppColors.textSecondary),
              blockquoteDecoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
            ),
          ),
        if (article.babloVerdict.isNotEmpty) ...[
          const SizedBox(height: 22),
          _VerdictCard(text: article.babloVerdict),
        ],
        if (article.sourceUrls.isNotEmpty) ...[
          const SizedBox(height: 22),
          const SectionLabel('Источники'),
          const SizedBox(height: 10),
          for (final url in article.sourceUrls)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SourceTile(url: url),
            ),
        ],
        const SizedBox(height: 22),
        _ReactionBar(
          article: article,
          myReaction: state.myReaction,
          reacting: state.reacting,
          onDig: () => wm.react(DailyReactionType.dig),
          onShit: () => wm.react(DailyReactionType.shit),
        ),
        const SizedBox(height: 18),
        Text(
          article.imageCredit.isNotEmpty
              ? 'Фото: ${article.imageCredit}'
              : 'Фото: Unsplash',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.article});

  final DailyArticle article;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Hero(
          tag: 'daily-hero-${article.id}',
          child: DailyNetworkImage(url: article.imageUrl),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColors.primaryHover,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.article});

  final DailyArticle article;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryDim,
          child: Text(
            'A',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.displayAuthor,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                MoneyFormat.dateTimeFull(article.publishedAt),
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TradingCard(
      borderColor: AppColors.hold.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BABLO VERDICT',
            style: TextStyle(
              color: AppColors.hold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final host = Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? url;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(Icons.link_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionBar extends StatelessWidget {
  const _ReactionBar({
    required this.article,
    required this.myReaction,
    required this.reacting,
    required this.onDig,
    required this.onShit,
  });

  final DailyArticle article;
  final String? myReaction;
  final bool reacting;
  final VoidCallback onDig;
  final VoidCallback onShit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReactionButton(
            label: 'Dig',
            count: article.reactions.dig,
            icon: Icons.thumb_up_alt_outlined,
            selected: myReaction == DailyReactionType.dig,
            color: AppColors.buy,
            onTap: reacting ? null : onDig,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ReactionButton(
            label: 'Shit',
            count: article.reactions.shit,
            icon: Icons.thumb_down_alt_outlined,
            selected: myReaction == DailyReactionType.shit,
            color: AppColors.sell,
            onTap: reacting ? null : onShit,
          ),
        ),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.16) : AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? color : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '$label  $count',
                style: TextStyle(
                  color: selected ? color : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
