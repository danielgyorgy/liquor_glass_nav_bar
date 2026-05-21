import 'package:flutter/widgets.dart';

/// A single item in a [LiquorGlassNavBar].
///
/// Provide at least an [icon]. The [activeIcon] is shown when the item is
/// selected; if omitted, [icon] is used in both states.
class LiquorGlassNavItem {
  const LiquorGlassNavItem({
    required this.icon,
    this.activeIcon,
    this.label,
    this.badge,
    this.tooltip,
  });

  /// Icon shown when the item is not selected.
  final IconData icon;

  /// Icon shown when the item is selected. Falls back to [icon] if null.
  final IconData? activeIcon;

  /// Optional label rendered below the icon.
  final String? label;

  /// Optional badge text (e.g. "3", "99+"). Pass an empty string to render
  /// a small dot badge with no number.
  final String? badge;

  /// Optional tooltip shown on long-press.
  final String? tooltip;
}
