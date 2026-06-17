import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A reusable network image widget with shimmer loading and error fallback.
class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData errorIcon;
  final double errorIconSize;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.broken_image_outlined,
    this.errorIconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _errorWidget(context);
    }

    final image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _shimmerPlaceholder(context),
      errorWidget: (context, url, error) => _errorWidget(context),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _shimmerPlaceholder(BuildContext context) {
    final baseColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade300;
    final highlightColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade100;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: baseColor),
      child: _ShimmerEffect(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(width: width, height: height, color: baseColor),
      ),
    );
  }

  Widget _errorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        errorIcon,
        size: errorIconSize,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }
}

/// Cached circle avatar with shimmer loading.
class AppCachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData fallbackIcon;

  const AppCachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 30,
    this.fallbackIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          fallbackIcon,
          size: radius * 0.8,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder:
          (context, imageProvider) =>
              CircleAvatar(radius: radius, backgroundImage: imageProvider),
      placeholder: (context, url) {
        final baseColor =
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade300;
        final highlightColor =
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade100;
        return _ShimmerEffect(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: CircleAvatar(radius: radius, backgroundColor: baseColor),
        );
      },
      errorWidget:
          (context, url, error) => CircleAvatar(
            radius: radius,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              fallbackIcon,
              size: radius * 0.8,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
    );
  }
}

/// Lightweight shimmer animation without external packages.
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerEffect({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops:
                  [
                    _controller.value - 0.3,
                    _controller.value,
                    _controller.value + 0.3,
                  ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
