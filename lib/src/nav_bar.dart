import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_badge.dart';
import 'nav_item.dart';

/// A frosted-glass bottom navigation bar with a draggable water-drop pill.
///
/// The pill follows the user's finger, squashes like a liquid drop while it
/// moves, and snaps to the nearest tab when released. Icons in range of the
/// drop are subtly magnified, mimicking a lens — at the cost of just one
/// `Transform.scale` per item per frame.
class LiquorGlassNavBar extends StatefulWidget {
  const LiquorGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.pillColor,
    this.borderColor,
    this.blurSigma = 24,
    this.borderRadius = 28,
    this.height = 68,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.showLabels = true,
    this.iconSize = 24,
    this.labelStyle,
    this.snapDuration = const Duration(milliseconds: 360),
    this.snapCurve = Curves.easeOutCubic,
    this.elevation = true,
    this.safeArea = true,
    this.magnification = 0.32,
    this.magnificationFalloff = 1.7,
    this.chromaticAberration = 1.0,
  })  : assert(items.length >= 2, 'At least two items are required.'),
        assert(currentIndex >= 0, 'currentIndex must be non-negative.'),
        assert(height > 0, 'height must be positive.'),
        assert(blurSigma >= 0, 'blurSigma must be non-negative.'),
        assert(
          magnification >= 0 && magnification <= 1.0,
          'magnification must be in [0, 1].',
        ),
        assert(
          chromaticAberration >= 0 && chromaticAberration <= 2.0,
          'chromaticAberration must be in [0, 2].',
        );

  /// The tabs to display.
  final List<LiquorGlassNavItem> items;

  /// Index of the currently selected tab.
  final int currentIndex;

  /// Called with the new index whenever the user taps an item or drags the
  /// pill to it.
  final ValueChanged<int> onTap;

  /// Tint behind the blur. Defaults to a translucent near-black.
  final Color? backgroundColor;

  /// Icon & label color of the magnified (active) item.
  final Color? activeColor;

  /// Icon & label color of items far from the pill.
  final Color? inactiveColor;

  /// Base color of the water-drop pill.
  final Color? pillColor;

  /// Color of the 1px outer border. Pass [Colors.transparent] to disable.
  final Color? borderColor;

  /// Sigma passed to the backdrop [ImageFilter.blur].
  final double blurSigma;

  /// Corner radius of the bar.
  final double borderRadius;

  /// Bar height, excluding [margin] and safe-area insets.
  final double height;

  /// Outer margin around the bar.
  final EdgeInsetsGeometry margin;

  /// Inner padding between the bar edge and the items.
  final EdgeInsetsGeometry padding;

  /// Whether to show item labels (when provided).
  final bool showLabels;

  /// Size of the item icons (before magnification).
  final double iconSize;

  /// Override style for item labels. Color is overridden per state.
  final TextStyle? labelStyle;

  /// Duration of the snap animation back to a tab.
  final Duration snapDuration;

  /// Curve used by the snap animation.
  final Curve snapCurve;

  /// If true, adds a soft drop shadow under the bar.
  final bool elevation;

  /// If true, respects the bottom safe-area inset.
  final bool safeArea;

  /// Extra scale applied to the icon under the pill (0..1).
  final double magnification;

  /// How quickly [magnification] falls off with distance from the pill.
  /// Larger = sharper falloff (only the directly-under-pill item magnifies).
  final double magnificationFalloff;

  /// Strength multiplier for the prismatic edge fringing on the pill.
  /// `0` disables the rainbow effect; `1` is the default; higher values
  /// amplify the colored edges and the streak between items.
  final double chromaticAberration;

  @override
  State<LiquorGlassNavBar> createState() => _LiquorGlassNavBarState();
}

@immutable
class _PillState {
  const _PillState(this.position, this.velocity);

  /// Position in *index space* (0..items.length-1).
  final double position;

  /// Normalized horizontal velocity (delta in index space per frame).
  final double velocity;
}

class _LiquorGlassNavBarState extends State<LiquorGlassNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snap;
  late final ValueNotifier<_PillState> _pill;
  double _snapFrom = 0;
  double _snapTo = 0;
  double _lastSnapPos = 0;
  bool _dragging = false;
  late int _lastInternalTarget;

  @override
  void initState() {
    super.initState();
    final i = widget.currentIndex.toDouble();
    _pill = ValueNotifier(_PillState(i, 0));
    _lastInternalTarget = widget.currentIndex;
    _snap = AnimationController(vsync: this, duration: widget.snapDuration)
      ..addListener(_onSnapTick);
  }

  @override
  void didUpdateWidget(covariant LiquorGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapDuration != widget.snapDuration) {
      _snap.duration = widget.snapDuration;
    }
    if (widget.currentIndex != _lastInternalTarget && !_dragging) {
      _animateTo(widget.currentIndex.toDouble());
    }
  }

  @override
  void dispose() {
    _snap
      ..removeListener(_onSnapTick)
      ..dispose();
    _pill.dispose();
    super.dispose();
  }

  void _onSnapTick() {
    final t = widget.snapCurve.transform(_snap.value);
    final pos = _snapFrom + (_snapTo - _snapFrom) * t;
    final vel = pos - _lastSnapPos;
    _lastSnapPos = pos;
    if (_snap.status == AnimationStatus.completed) {
      _pill.value = _PillState(_snapTo, 0);
    } else {
      _pill.value = _PillState(pos, vel);
    }
  }

  void _animateTo(double target) {
    _snap.stop();
    _snapFrom = _pill.value.position;
    _snapTo = target;
    _lastSnapPos = _snapFrom;
    _lastInternalTarget = target.round();
    _snap.forward(from: 0);
  }

  void _onItemTap(int index) {
    _animateTo(index.toDouble());
    if (index != widget.currentIndex) widget.onTap(index);
  }

  void _onDragStart(DragStartDetails _) {
    _dragging = true;
    _snap.stop();
  }

  void _onDragUpdate(DragUpdateDetails d, double itemWidth) {
    final dx = d.delta.dx / itemWidth;
    final maxIdx = (widget.items.length - 1).toDouble();
    final newPos = (_pill.value.position + dx).clamp(0.0, maxIdx);
    final vel = dx.clamp(-0.5, 0.5);
    _pill.value = _PillState(newPos, vel);
  }

  void _onDragEnd(DragEndDetails _) {
    _dragging = false;
    final target =
        _pill.value.position.round().clamp(0, widget.items.length - 1);
    _animateTo(target.toDouble());
    if (target != widget.currentIndex) widget.onTap(target);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.currentIndex < widget.items.length,
      'currentIndex (${widget.currentIndex}) is out of range for '
      '${widget.items.length} items.',
    );

    final bg = widget.backgroundColor ??
        const Color(0xFF0B0B0F).withValues(alpha: 0.42);
    final active = widget.activeColor ?? Colors.white;
    final inactive =
        widget.inactiveColor ?? Colors.white.withValues(alpha: 0.55);
    final pillColor = widget.pillColor ?? Colors.white.withValues(alpha: 0.22);
    final border = widget.borderColor ?? Colors.white.withValues(alpha: 0.10);
    final radius = BorderRadius.circular(widget.borderRadius);

    Widget bar = RepaintBoundary(
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: widget.elevation
              ? const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurSigma,
              sigmaY: widget.blurSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
                border: Border.all(color: border, width: 1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.07),
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Subtle inner top-edge highlight — the "rim" of the glass.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 1.2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.32),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: widget.padding,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth =
                            constraints.maxWidth / widget.items.length;
                        final pillWidth = itemWidth - 8;
                        final pillHeight = constraints.maxHeight;
                        final pillRadius =
                            math.min(pillHeight / 1, widget.borderRadius - 8);

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              children: [
                                for (var i = 0; i < widget.items.length; i++)
                                  Expanded(
                                    child: _NavItemView(
                                      item: widget.items[i],
                                      index: i,
                                      pill: _pill,
                                      magnification: widget.magnification,
                                      falloff: widget.magnificationFalloff,
                                      activeColor: active,
                                      inactiveColor: inactive,
                                      showLabels: widget.showLabels,
                                      iconSize: widget.iconSize,
                                      labelStyle: widget.labelStyle,
                                      onTap: () => _onItemTap(i),
                                    ),
                                  ),
                              ],
                            ),
                            ValueListenableBuilder<_PillState>(
                              valueListenable: _pill,
                              builder: (context, p, child) {
                                return Positioned(
                                  left: p.position * itemWidth + 4,
                                  top: 0,
                                  width: pillWidth,
                                  height: pillHeight,
                                  child: child!,
                                );
                              },
                              child: GestureDetector(
                                key: const ValueKey('dark_liquid_glass_pill'),
                                behavior: HitTestBehavior.opaque,
                                onHorizontalDragStart: _onDragStart,
                                onHorizontalDragUpdate: (d) =>
                                    _onDragUpdate(d, itemWidth),
                                onHorizontalDragEnd: _onDragEnd,
                                child: _WaterDropPill(
                                  pill: _pill,
                                  color: pillColor,
                                  radius: pillRadius,
                                  chromaticStrength: widget.chromaticAberration,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    bar = Padding(padding: widget.margin, child: bar);
    if (widget.safeArea) bar = SafeArea(top: false, child: bar);
    return bar;
  }
}

class _NavItemView extends StatelessWidget {
  const _NavItemView({
    required this.item,
    required this.index,
    required this.pill,
    required this.magnification,
    required this.falloff,
    required this.activeColor,
    required this.inactiveColor,
    required this.showLabels,
    required this.iconSize,
    required this.labelStyle,
    required this.onTap,
  });

  final LiquorGlassNavItem item;
  final int index;
  final ValueListenable<_PillState> pill;
  final double magnification;
  final double falloff;
  final Color activeColor;
  final Color inactiveColor;
  final bool showLabels;
  final double iconSize;
  final TextStyle? labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseLabelStyle = labelStyle ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600);

    final visual = ValueListenableBuilder<_PillState>(
      valueListenable: pill,
      builder: (context, p, _) {
        final distance = (index - p.position).abs();
        final t = math.exp(-distance * distance * falloff * falloff);
        final scale = 1.0 + magnification * t;
        final color = Color.lerp(inactiveColor, activeColor, t)!;
        final iconData = t > 0.5 ? (item.activeIcon ?? item.icon) : item.icon;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Icon(iconData, size: iconSize, color: color),
                ),
                if (item.badge != null)
                  Positioned(
                    right: -10,
                    top: -4,
                    child: LiquorGlassBadge(text: item.badge!),
                  ),
              ],
            ),
            if (showLabels && item.label != null) ...[
              const SizedBox(height: 2),
              Text(
                item.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: baseLabelStyle.copyWith(color: color),
              ),
            ],
          ],
        );
      },
    );

    final tapTarget = Semantics(
      button: true,
      label: item.label ?? item.tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        child: SizedBox.expand(
          child: Align(alignment: Alignment.center, child: visual),
        ),
      ),
    );

    if (item.tooltip != null) {
      return Tooltip(message: item.tooltip!, child: tapTarget);
    }
    return tapTarget;
  }
}

class _WaterDropPill extends StatelessWidget {
  const _WaterDropPill({
    required this.pill,
    required this.color,
    required this.radius,
    required this.chromaticStrength,
  });

  final ValueListenable<_PillState> pill;
  final Color color;
  final double radius;
  final double chromaticStrength;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<_PillState>(
        valueListenable: pill,
        builder: (context, p, _) {
          final v = p.velocity.clamp(-0.5, 0.5);
          final mag = v.abs();

          // Squash-and-stretch on velocity, exaggerated slightly compared to
          // the previous version for a more lively "liquid" feel.
          final sx = 1.0 + mag * 0.58;
          final sy = 1.0 - mag * 0.26;
          final skew = v * 0.22;
          final transform = Matrix4.identity()
            ..setEntry(0, 0, sx)
            ..setEntry(1, 1, sy)
            ..setEntry(0, 1, skew);

          // How close the pill is to an item-boundary in index space.
          // 0 at integer position (centered on an item), 1 at half-integer
          // (straddling two items — i.e. over an item *corner*).
          final frac = p.position - p.position.floor();
          final cornerEnergy =
              (1 - (frac - 0.5).abs() * 2).clamp(0.0, 1.0).toDouble();

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: CustomPaint(
              painter: _LiquidGlassPillPainter(
                radius: radius,
                color: color,
                velocity: v,
                cornerEnergy: cornerEnergy,
                chromaticStrength: chromaticStrength,
              ),
              isComplex: true,
              willChange: true,
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

/// Paints the glass pill with chromatic-aberration edges, a rainbow streak
/// when sitting between two items, and a trailing "tail" droplet that lags
/// behind during a swipe.
class _LiquidGlassPillPainter extends CustomPainter {
  _LiquidGlassPillPainter({
    required this.radius,
    required this.color,
    required this.velocity,
    required this.cornerEnergy,
    required this.chromaticStrength,
  });

  /// Corner radius of the pill body.
  final double radius;

  /// Base pill tint.
  final Color color;

  /// Horizontal velocity in index-space, clamped to [-0.5, 0.5].
  final double velocity;

  /// 0 when pill is centered on an item, 1 when sitting between two items.
  final double cornerEnergy;

  /// Multiplier on the prismatic edge effect.
  final double chromaticStrength;

  // Cool/warm pair used for the chromatic fringes on the pill edges.
  static const Color _coolFringe = Color(0xFF38C6FF);
  static const Color _warmFringe = Color(0xFFFF4FCB);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final body = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final mag = velocity.abs();
    final chroma = chromaticStrength;

    // 1. Trailing tail: a soft, stretched ghost behind the leading edge.
    //    Only visible during a swipe. Drawn first so it sits under the body.
    if (mag > 0.02) {
      _paintTrail(canvas, size, body);
    }

    // 2. Chromatic fringes — base level always present (real glass refracts
    //    light at its edges), amplified by swipe velocity and by sitting
    //    over an item corner.
    if (chroma > 0) {
      _paintChromaticFringes(canvas, body, mag);
    }

    // 3. Main translucent glass body.
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: (color.a * 1.5).clamp(0, 1)),
          color.withValues(alpha: (color.a * 0.55).clamp(0, 1)),
        ],
      ).createShader(rect);
    canvas.drawRRect(body, bodyPaint);

    // 4. Inner curved top highlight — gives the "wet" look.
    _paintTopHighlight(canvas, size);

    // 5. Bottom rim refraction — concentrated light along the bottom edge.
    final rimPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.22),
        ],
        stops: const [0.0, 0.72, 1.0],
      ).createShader(rect);
    canvas.drawRRect(body, rimPaint);

    // 6. Rainbow streak — fades in when the pill is over an item corner.
    if (cornerEnergy > 0.08 && chroma > 0) {
      _paintRainbowStreak(canvas, body, rect);
    }

    // 7. Border — a faint white outline plus a brighter inner edge that
    //    catches the light on the leading side of the swipe.
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawRRect(body, borderPaint);

    if (mag > 0.04) {
      final dir = velocity.sign;
      final edgePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = LinearGradient(
          begin: dir >= 0 ? Alignment.centerLeft : Alignment.centerRight,
          end: dir >= 0 ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: (0.45 * mag * 2).clamp(0, 0.55)),
          ],
        ).createShader(rect);
      canvas.drawRRect(body, edgePaint);
    }
  }

  void _paintTrail(Canvas canvas, Size size, RRect body) {
    final dir = velocity.sign == 0 ? 1.0 : velocity.sign;
    final mag = velocity.abs();

    // The tail sits opposite to the swipe direction (the trailing edge).
    final tailOffset = size.width * 0.18 * mag * dir;
    final widthShrink = 1.0 - mag * 0.45; // narrower tail
    final heightShrink = 1.0 + mag * 0.10; // slightly taller (oozing)

    final tailWidth = size.width * widthShrink;
    final tailHeight = size.height * heightShrink;
    final tailRect = Rect.fromCenter(
      center: Offset(
        size.width / 2 - tailOffset,
        size.height / 2,
      ),
      width: tailWidth,
      height: tailHeight,
    );
    final tailRRect = RRect.fromRectAndRadius(
      tailRect,
      Radius.circular(radius + mag * 4),
    );

    final tailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10 + mag * 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + mag * 14);
    canvas.drawRRect(tailRRect, tailPaint);

    // A second, smaller droplet further behind for the "drip" feel.
    if (mag > 0.18) {
      final dropletRadius = size.height * 0.34;
      final dropletCenter = Offset(
        size.width / 2 - tailOffset * 1.55,
        size.height / 2,
      );
      final dropletPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.07 + mag * 0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + mag * 10);
      canvas.drawCircle(dropletCenter, dropletRadius, dropletPaint);
    }
  }

  void _paintChromaticFringes(Canvas canvas, RRect body, double mag) {
    // Base separation: a hair, always visible. Grows with velocity and
    // with corner energy (peak refraction happens at edges of items below).
    final separation =
        (0.9 + cornerEnergy * 2.2 + mag * 4.0) * chromaticStrength;
    final fringeAlpha =
        ((0.10 + cornerEnergy * 0.16 + mag * 0.10) * chromaticStrength)
            .clamp(0.0, 0.55);

    // Cool fringe shifted in one direction.
    final coolPaint = Paint()
      ..color = _coolFringe.withValues(alpha: fringeAlpha)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);

    final warmPaint = Paint()
      ..color = _warmFringe.withValues(alpha: fringeAlpha)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);

    // Swipe biases the offsets so the fringes "drag" behind the pill.
    final dirBias = velocity * 1.6;

    canvas.save();
    canvas.translate(-separation + dirBias, 0);
    canvas.drawRRect(body, coolPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(separation + dirBias, 0);
    canvas.drawRRect(body, warmPaint);
    canvas.restore();
  }

  void _paintTopHighlight(Canvas canvas, Size size) {
    final inset = radius * 0.32;
    final highlightRect = Rect.fromLTWH(
      inset,
      1.0,
      size.width - inset * 2,
      size.height * 0.42,
    );
    final highlightRRect = RRect.fromRectAndCorners(
      highlightRect,
      topLeft: Radius.circular(radius * 0.85),
      topRight: Radius.circular(radius * 0.85),
      bottomLeft: Radius.circular(radius * 0.6),
      bottomRight: Radius.circular(radius * 0.6),
    );
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.42),
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(highlightRect);
    canvas.drawRRect(highlightRRect, paint);
  }

  void _paintRainbowStreak(Canvas canvas, RRect body, Rect rect) {
    final t = cornerEnergy;
    final dir = velocity.sign == 0 ? 1.0 : velocity.sign;

    // Position the rainbow band so it sweeps from one edge to the other
    // as the pill crosses a boundary. As `frac` goes 0 → 0.5 → 1, the band
    // animates across.
    final start = dir >= 0 ? Alignment.centerLeft : Alignment.centerRight;
    final end = dir >= 0 ? Alignment.centerRight : Alignment.centerLeft;

    final a = (0.22 * t * chromaticStrength).clamp(0.0, 0.45);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: start,
        end: end,
        colors: [
          const Color(0x00000000),
          Color(0xFFFF005A).withValues(alpha: a * 0.85),
          Color(0xFFFFB800).withValues(alpha: a * 0.85),
          Color(0xFF00FFA3).withValues(alpha: a * 0.85),
          Color(0xFF00B6FF).withValues(alpha: a * 0.85),
          Color(0xFFBF50FF).withValues(alpha: a * 0.85),
          const Color(0x00000000),
        ],
        stops: const [0.0, 0.20, 0.35, 0.50, 0.65, 0.80, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
    canvas.drawRRect(body, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassPillPainter old) {
    return old.radius != radius ||
        old.color != color ||
        old.velocity != velocity ||
        old.cornerEnergy != cornerEnergy ||
        old.chromaticStrength != chromaticStrength;
  }
}
