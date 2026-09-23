import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/daily_constants.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data_management/data_manager.dart';
import '../../../models/daily_article.dart';
import '../../../repositories/daily_repository.dart';
import 'daily_network_image.dart';

/// BABLO DAILY — top 3 in carousel, older items as horizontal rows.
class DailyCarousel extends StatefulWidget {
  const DailyCarousel({super.key});

  @override
  State<DailyCarousel> createState() => _DailyCarouselState();
}

class _DailyCarouselState extends State<DailyCarousel> {
  late final DailyRepository _repository;
  late final PageController _pageController;

  List<DailyArticle> _items = const [];
  String _category = '';
  int _page = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = context.read<DataManager>().dailyRepository;
    _pageController = PageController(viewportFraction: 0.86);
    _items = _repository.peekArticles();
    _loading = _items.isEmpty;
    _load(forceRefresh: _items.isNotEmpty);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    try {
      final items = await _repository.getArticles(
        category: _category.isEmpty ? null : _category,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        if (forceRefresh || _page >= items.length) _page = 0;
      });
      if (_pageController.hasClients && _page == 0) {
        _pageController.jumpToPage(0);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items.isEmpty) _error = e.toString();
      });
    }
  }

  void _open(DailyArticle item) {
    context.push(AppRoutes.dailyArticle(item.id), extra: item);
  }

  void _selectCategory(String id) {
    if (id == _category) return;
    final cached = _repository.peekArticles(category: id);
    setState(() {
      _category = id;
      _items = cached;
      _loading = cached.isEmpty;
      _page = 0;
      _error = null;
    });
    _load(forceRefresh: cached.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final carouselItems =
        _items.take(DailyConstants.carouselLimit).toList(growable: false);
    final listItems =
        _items.skip(DailyConstants.carouselLimit).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'BABLO DAILY',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _selectCategory(''),
              child: Text(
                'Все',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: DailyConstants.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = DailyConstants.categories[index];
              final selected = cat.id == _category;
              return _CategoryChip(
                label: cat.label,
                selected: selected,
                onTap: () => _selectCategory(cat.id),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const SizedBox(height: 200, child: _CarouselSkeleton())
        else if (_error != null)
          _CarouselError(
            message: _error!,
            onRetry: () => _load(forceRefresh: true),
          )
        else if (_items.isEmpty)
          const _CarouselEmpty()
        else ...[
          if (carouselItems.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    itemCount: carouselItems.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, index) {
                      final item = carouselItems[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == carouselItems.length - 1 ? 0 : 10,
                        ),
                        child: _DailyCard(
                          article: item,
                          onTap: () => _open(item),
                        ),
                      );
                    },
                  ),
                ),
                if (carouselItems.length > 1) ...[
                  const SizedBox(height: 10),
                  _Dots(count: carouselItems.length, index: _page),
                ],
              ],
            ),
          if (listItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...List.generate(listItems.length, (index) {
              final item = listItems[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == listItems.length - 1 ? 0 : 10,
                ),
                child: _DailyHorizontalCard(
                  article: item,
                  onTap: () => _open(item),
                ),
              );
            }),
          ],
        ],
      ],
    );
  }
}

class _DailyHorizontalCard extends StatelessWidget {
  const _DailyHorizontalCard({
    required this.article,
    required this.onTap,
  });

  final DailyArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = article.categoryLabel.isNotEmpty
        ? article.categoryLabel
        : article.category;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 88,
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 88,
                child: Hero(
                  tag: 'daily-hero-${article.id}',
                  child: DailyNetworkImage(url: article.imageUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.isNotEmpty)
                        Text(
                          category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.primaryHover,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.55,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.article, required this.onTap});

  final DailyArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'daily-hero-${article.id}',
              child: DailyNetworkImage(url: article.imageUrl),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000814),
                    Color(0x00000814),
                    Color(0xE6000814),
                  ],
                  stops: [0, 0.38, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(
                    label: article.categoryLabel.isNotEmpty
                        ? article.categoryLabel
                        : article.category,
                  ),
                  const Spacer(),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xCC0B1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.55)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.primaryHover,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.onPrimary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _CarouselError extends StatelessWidget {
  const _CarouselError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Новости недоступны',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}

class _CarouselEmpty extends StatelessWidget {
  const _CarouselEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        'Пока нет выпусков',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }
}
