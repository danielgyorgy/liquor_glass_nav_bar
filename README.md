# liquor_glass_nav_bar

A **dark liquid-glass** bottom navigation bar for Flutter. The active tab is
marked by a translucent **water-drop pill** that you can drag with your finger
between tabs — it squashes and stretches like a real drop, and the icons it
passes over magnify subtly, as if seen through the lens of the drop.

- Drag-and-drop pill that follows your finger and snaps to the nearest tab on
  release
- Liquid squash / stretch on the pill driven by its current velocity
- Lens-style magnification of the icon under the drop, falling off smoothly
  with distance — implemented with one `Transform.scale` per item, no
  expensive shaders or per-item `BackdropFilter`s
- Single `ValueNotifier` drives all per-frame motion, so only the pill and the
  scaled icons rebuild — the rest of the tree stays static
- Frosted-glass background via a single `BackdropFilter`
- Safe-area aware, accessible via `Semantics`, no extra runtime dependencies

## Install

```yaml
dependencies:
  liquor_glass_nav_bar: ^0.2.0
```

## Usage

```dart
import 'package:liquor_glass_nav_bar/liquor_glass_nav_bar.dart';
import 'package:flutter/material.dart';

class MyShell extends StatefulWidget {
  const MyShell({super.key});
  @override
  State<MyShell> createState() => _MyShellState();
}

class _MyShellState extends State<MyShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: const Center(child: Text('Content')),
      bottomNavigationBar: LiquorGlassNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          LiquorGlassNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          LiquorGlassNavItem(
            icon: Icons.search,
            label: 'Search',
            badge: '3',
          ),
          LiquorGlassNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
```

Use `extendBody: true` on the `Scaffold` so the page content blurs through the
bar.

## Customization

```dart
LiquorGlassNavBar(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  pillColor: Colors.deepPurpleAccent.withValues(alpha: 0.25),
  backgroundColor: const Color(0xCC0B0B0F),
  activeColor: Colors.white,
  inactiveColor: Colors.white60,
  blurSigma: 32,
  borderRadius: 24,
  height: 72,
  magnification: 0.4,
  magnificationFalloff: 1.4,
  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
  items: items,
)
```

| Parameter | Description |
| --- | --- |
| `items` | List of [`LiquorGlassNavItem`] — at least two. |
| `currentIndex` / `onTap` | Selected index and tap/drag-snap callback. |
| `backgroundColor` | Translucent tint behind the blur. |
| `activeColor` / `inactiveColor` | Icon & label colors per state. |
| `pillColor` | Base color of the water-drop pill. |
| `borderColor` | 1px outer border; pass `Colors.transparent` to hide. |
| `blurSigma` | `ImageFilter.blur` sigma for the frosted background. |
| `borderRadius`, `height`, `margin`, `padding` | Geometry. |
| `showLabels`, `iconSize`, `labelStyle` | Item rendering. |
| `snapDuration`, `snapCurve` | Snap-to-tab animation. |
| `magnification` | Extra scale (0..1) applied to the icon under the drop. |
| `magnificationFalloff` | How quickly the magnification fades with distance. |
| `elevation` | Soft drop shadow under the bar. |
| `safeArea` | Respect the bottom safe-area inset. |

See the [`example/`](example/) folder for a full demo app.

## License

MIT
