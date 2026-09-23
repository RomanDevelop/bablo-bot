import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/auth_constants.dart';
import '../core/theme/theme_controller.dart';

/// User photo from [url], or the Bablo Community placeholder when it is missing.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.url,
    this.size = 48,
  });

  final String? url;
  final double size;

  static String? normalize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final resolved = normalize(url);
    final radius = (size * 0.29).clamp(10.0, 22.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: p.primary.withValues(alpha: 0.18),
            blurRadius: 8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: resolved == null
          ? const _AvatarPlaceholder()
          : _NetworkAvatar(url: resolved, size: size),
    );
  }
}

class _NetworkAvatar extends StatelessWidget {
  const _NetworkAvatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.45),
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _AvatarPlaceholder(loading: true);
        },
        errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.45),
      fadeInDuration: const Duration(milliseconds: 160),
      placeholder: (_, __) => const _AvatarPlaceholder(loading: true),
      errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AuthConstants.avatarPlaceholder,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.48),
        ),
        if (loading)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.28),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}
