import 'package:flutter/material.dart';

/// Small badge rendered on top of a nav item.
///
/// If [text] is empty the badge becomes a small dot.
class LiquorGlassBadge extends StatelessWidget {
  const LiquorGlassBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor = Colors.white,
  });

  /// Text shown inside the badge. Pass an empty string to render a dot only.
  final String text;

  /// Background color of the badge. Defaults to a system-red.
  final Color? color;

  /// Color used for [text]. Defaults to white.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isDot = text.isEmpty;
    final badgeColor = color ?? const Color(0xFFFF3B30);

    if (isDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.45),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
