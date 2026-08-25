import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class DailyNetworkImage extends StatelessWidget {
  const DailyNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.expand = true,
  });

  final String url;
  final BoxFit fit;
  final Alignment alignment;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _DailyImageFallback(expand: expand);

    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        alignment: alignment,
        width: double.infinity,
        height: expand ? double.infinity : null,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _DailyImageFallback(loading: true, expand: expand);
        },
        errorBuilder: (_, __, ___) => _DailyImageFallback(expand: expand),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: expand ? double.infinity : null,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => _DailyImageFallback(loading: true, expand: expand),
      errorWidget: (_, __, ___) => _DailyImageFallback(expand: expand),
    );
  }
}

class _DailyImageFallback extends StatelessWidget {
  const _DailyImageFallback({this.loading = false, this.expand = true});

  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceElevated,
      child: SizedBox(
        height: expand ? double.infinity : 220,
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  Icons.image_outlined,
                  color: AppColors.textMuted,
                  size: 28,
                ),
        ),
      ),
    );
  }
}
