import 'package:flutter/material.dart';

import '../../../../../core/constants/temki_constants.dart';
import '../../../../../core/navigation/app_navigator.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../daily/widgets/daily_network_image.dart';

class TemkiCarousel extends StatefulWidget {
  const TemkiCarousel({
    super.key,
    required this.label,
    required this.items,
  });

  final String label;
  final List<TemkiListing> items;

  @override
  State<TemkiCarousel> createState() => _TemkiCarouselState();
}

class _TemkiCarouselState extends State<TemkiCarousel> {
  late final PageController _pageController;
  int _page = 0;

  static const _fraction = 0.86;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _fraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _open(TemkiListing item) {
    context.push(AppRoutes.temkiItem(item.id), extra: item);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardSize = constraints.maxWidth * _fraction - 10;
            return Column(
              children: [
                SizedBox(
                  height: cardSize,
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _TemkiCard(
                          item: item,
                          onTap: () => _open(item),
                        ),
                      );
                    },
                  ),
                ),
                if (items.length > 1) ...[
                  const SizedBox(height: 10),
                  _Dots(count: items.length, index: _page),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TemkiCard extends StatelessWidget {
  const _TemkiCard({required this.item, required this.onTap});

  final TemkiListing item;
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
              tag: TemkiConstants.heroTag(item.id),
              child: DailyNetworkImage(url: item.imageUrl),
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
                  _Badge(label: item.shortLabel),
                  const Spacer(),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.priceUsd} / ${item.unit}',
                    style: TextStyle(
                      color: AppColors.primaryHover,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

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
