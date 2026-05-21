import 'package:liquor_glass_nav_bar/liquor_glass_nav_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquor Glass Nav Bar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _DemoHome(),
    );
  }
}

class _DemoHome extends StatefulWidget {
  const _DemoHome();

  @override
  State<_DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<_DemoHome> {
  int _index = 0;
  _NavBarOptions _options = const _NavBarOptions();

  static const _pages = <_Page>[
    _Page('Home', Icons.home_outlined, Icons.home_rounded),
    _Page('Search', Icons.search_outlined, Icons.search_rounded),
    _Page('Library', Icons.library_music_outlined, Icons.library_music_rounded),
    _Page('Inbox', Icons.mail_outline_rounded, Icons.mail_rounded),
    _Page('Profile', Icons.person_outline, Icons.person_rounded),
  ];

  static const _tiles = <_Tile>[
    _Tile('Aurora', 'Synthwave drift · 4:21', Icons.graphic_eq_rounded, [
      Color(0xFFFF2D87),
      Color(0xFF7A2BFF),
    ]),
    _Tile('Neon Tide', 'Lo-fi pulse · 3:08', Icons.waves_rounded, [
      Color(0xFF00E1FF),
      Color(0xFF0066FF),
    ]),
    _Tile(
      'Citrus Burn',
      'Indie pop · 2:54',
      Icons.local_fire_department_rounded,
      [Color(0xFFFFB300), Color(0xFFFF3D00)],
    ),
    _Tile('Velvet Sky', 'Ambient · 5:42', Icons.cloud_rounded, [
      Color(0xFFB14BFF),
      Color(0xFF2D1B69),
    ]),
    _Tile('Mint Echo', 'Chillhop · 3:36', Icons.eco_rounded, [
      Color(0xFF00FFA3),
      Color(0xFF006D5B),
    ]),
    _Tile('Coral Drift', 'House · 6:12', Icons.spa_rounded, [
      Color(0xFFFF6F91),
      Color(0xFFC5267C),
    ]),
    _Tile('Solar Flare', 'Electronic · 4:01', Icons.wb_sunny_rounded, [
      Color(0xFFFFC700),
      Color(0xFFFF5722),
    ]),
    _Tile('Glacier', 'Downtempo · 5:18', Icons.ac_unit_rounded, [
      Color(0xFF7DEFFF),
      Color(0xFF1F6FEB),
    ]),
    _Tile('Crimson Loop', 'Trip-hop · 4:47', Icons.album_rounded, [
      Color(0xFFFF1744),
      Color(0xFF7A0029),
    ]),
    _Tile('Lavender Haze', 'Dream pop · 3:55', Icons.bedtime_rounded, [
      Color(0xFFD3A6FF),
      Color(0xFF6A1B9A),
    ]),
    _Tile('Inferno', 'Drum & bass · 5:00', Icons.flash_on_rounded, [
      Color(0xFFFF7043),
      Color(0xFFB71C1C),
    ]),
    _Tile('Deep Cove', 'Bass · 4:33', Icons.water_rounded, [
      Color(0xFF18FFFF),
      Color(0xFF003C8F),
    ]),
  ];

  void _openOptions() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        options: _options,
        onChanged: (next) => setState(() => _options = next),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    final o = _options;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1030), Color(0xFF06060B)],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 24,
                  20,
                  16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.title,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Drag the water drop — tap the dial to tweak the bar.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _OptionsButton(onTap: _openOptions),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                sliver: SliverList.separated(
                  itemCount: _tiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _TrackTile(tile: _tiles[i]),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: LiquorGlassNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        showLabels: o.showLabels,
        elevation: o.elevation,
        blurSigma: o.blurSigma,
        chromaticAberration: o.chromaticAberration,
        magnification: o.magnification,
        magnificationFalloff: o.magnificationFalloff,
        borderRadius: o.borderRadius,
        height: o.height,
        iconSize: o.iconSize,
        items: [
          for (final p in _pages)
            LiquorGlassNavItem(
              icon: p.icon,
              activeIcon: p.activeIcon,
              label: p.title,
              badge: o.showBadge && p.title == 'Inbox' ? '3' : null,
              tooltip: p.title,
            ),
        ],
      ),
    );
  }
}

class _Page {
  const _Page(this.title, this.icon, this.activeIcon);
  final String title;
  final IconData icon;
  final IconData activeIcon;
}

class _Tile {
  const _Tile(this.title, this.subtitle, this.icon, this.colors);
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.tile});

  final _Tile tile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tile.colors,
        ),
        boxShadow: [
          BoxShadow(
            color: tile.colors.first.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Icon(tile.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tile.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tile.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_circle_fill_rounded,
            color: Colors.white.withValues(alpha: 0.92),
            size: 32,
          ),
        ],
      ),
    );
  }
}

class _OptionsButton extends StatelessWidget {
  const _OptionsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: const Icon(Icons.tune_rounded, size: 22),
        ),
      ),
    );
  }
}

/// All knobs the demo exposes for [LiquorGlassNavBar]. Defaults match
/// the widget's own defaults so the initial state is unchanged.
class _NavBarOptions {
  const _NavBarOptions({
    this.showLabels = true,
    this.showBadge = true,
    this.elevation = true,
    this.blurSigma = 24,
    this.chromaticAberration = 1.0,
    this.magnification = 0.32,
    this.magnificationFalloff = 1.7,
    this.borderRadius = 28,
    this.height = 68,
    this.iconSize = 24,
  });

  final bool showLabels;
  final bool showBadge;
  final bool elevation;
  final double blurSigma;
  final double chromaticAberration;
  final double magnification;
  final double magnificationFalloff;
  final double borderRadius;
  final double height;
  final double iconSize;

  _NavBarOptions copyWith({
    bool? showLabels,
    bool? showBadge,
    bool? elevation,
    double? blurSigma,
    double? chromaticAberration,
    double? magnification,
    double? magnificationFalloff,
    double? borderRadius,
    double? height,
    double? iconSize,
  }) {
    return _NavBarOptions(
      showLabels: showLabels ?? this.showLabels,
      showBadge: showBadge ?? this.showBadge,
      elevation: elevation ?? this.elevation,
      blurSigma: blurSigma ?? this.blurSigma,
      chromaticAberration: chromaticAberration ?? this.chromaticAberration,
      magnification: magnification ?? this.magnification,
      magnificationFalloff:
          magnificationFalloff ?? this.magnificationFalloff,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
      iconSize: iconSize ?? this.iconSize,
    );
  }
}

class _OptionsSheet extends StatefulWidget {
  const _OptionsSheet({required this.options, required this.onChanged});

  final _NavBarOptions options;
  final ValueChanged<_NavBarOptions> onChanged;

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  late _NavBarOptions _draft = widget.options;

  void _update(_NavBarOptions next) {
    setState(() => _draft = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF15151D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0x33FFFFFF), width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 4, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Bar options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _update(const _NavBarOptions()),
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.fromLTRB(
                    8,
                    0,
                    8,
                    24 + mq.padding.bottom,
                  ),
                  children: [
                    _SwitchRow(
                      label: 'Show labels',
                      value: _draft.showLabels,
                      onChanged: (v) =>
                          _update(_draft.copyWith(showLabels: v)),
                    ),
                    _SwitchRow(
                      label: 'Inbox badge',
                      value: _draft.showBadge,
                      onChanged: (v) =>
                          _update(_draft.copyWith(showBadge: v)),
                    ),
                    _SwitchRow(
                      label: 'Drop shadow',
                      value: _draft.elevation,
                      onChanged: (v) =>
                          _update(_draft.copyWith(elevation: v)),
                    ),
                    const _SectionDivider(),
                    _SliderRow(
                      label: 'Blur sigma',
                      value: _draft.blurSigma,
                      min: 0,
                      max: 48,
                      divisions: 48,
                      onChanged: (v) =>
                          _update(_draft.copyWith(blurSigma: v)),
                    ),
                    _SliderRow(
                      label: 'Chromatic aberration',
                      value: _draft.chromaticAberration,
                      min: 0,
                      max: 2,
                      divisions: 40,
                      onChanged: (v) =>
                          _update(_draft.copyWith(chromaticAberration: v)),
                    ),
                    const _SectionDivider(),
                    _SliderRow(
                      label: 'Lens magnification',
                      value: _draft.magnification,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      onChanged: (v) =>
                          _update(_draft.copyWith(magnification: v)),
                    ),
                    _SliderRow(
                      label: 'Magnification falloff',
                      value: _draft.magnificationFalloff,
                      min: 0.5,
                      max: 3,
                      divisions: 25,
                      onChanged: (v) => _update(
                        _draft.copyWith(magnificationFalloff: v),
                      ),
                    ),
                    const _SectionDivider(),
                    _SliderRow(
                      label: 'Border radius',
                      value: _draft.borderRadius,
                      min: 0,
                      max: 40,
                      divisions: 40,
                      onChanged: (v) =>
                          _update(_draft.copyWith(borderRadius: v)),
                    ),
                    _SliderRow(
                      label: 'Bar height',
                      value: _draft.height,
                      min: 52,
                      max: 92,
                      divisions: 40,
                      unit: 'px',
                      onChanged: (v) =>
                          _update(_draft.copyWith(height: v)),
                    ),
                    _SliderRow(
                      label: 'Icon size',
                      value: _draft.iconSize,
                      min: 16,
                      max: 36,
                      divisions: 20,
                      unit: 'px',
                      onChanged: (v) =>
                          _update(_draft.copyWith(iconSize: v)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.unit = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final shown = (max - min) >= 5
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$shown$unit',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
    );
  }
}
