import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color kblackcolor = Colors.black;
const Color kgreycolor = Colors.grey;
const Color textfieldcolor = Color.fromARGB(255, 213, 211, 211);
const Color kdarkgrey = CupertinoColors.secondarySystemFill;

// Premium palette
const Color kPrimaryDark = Color(0xFF0D0D2B);
const Color kPrimaryAccent = Color(0xFF6C63FF);
const Color kSecondaryAccent = Color(0xFF00D9FF);
const Color kSurfaceWhite = Color(0xFFF8F9FE);

/// Gradient used as background for auth screens
const LinearGradient kAuthGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0D0D2B), Color(0xFF1A1A40), Color(0xFF2D2B55)],
);

/// Glass card wrapper
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.blur = 12,
    this.opacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
