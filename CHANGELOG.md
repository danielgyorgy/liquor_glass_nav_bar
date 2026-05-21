## 0.3.0

- Pill now renders through a `CustomPainter` with **chromatic-aberration**
  edges: a cyan/magenta fringe is always present (real glass refracts light at
  its edges) and intensifies as the pill crosses an item boundary.
- A **rainbow streak** sweeps across the pill when it sits over the corner
  between two items, fading back out as it settles on a tab.
- Drag the pill and a **trailing droplet** lags behind the leading edge — the
  lens visibly "flows" in the direction of swipe.
- Refined top highlight + bottom rim light for a wetter, more believable
  glass body.
- New parameter: `chromaticAberration` (0..2) to tune or disable the prismatic
  effect.

## 0.2.0

- **Breaking:** removed `LiquorGlassIndicatorStyle` and the `indicatorStyle`
  parameter. The bar now always renders a single water-drop pill.
- The pill is **draggable**: drag it horizontally to move between tabs; it
  snaps to the nearest tab on release.
- Pill **squashes and stretches** based on its velocity, mimicking a liquid
  drop.
- Icons within range of the pill are **magnified** like a lens, with a
  configurable falloff. Implemented as a single `Transform.scale` per item per
  frame — no shaders, no per-item `BackdropFilter`.
- All per-frame motion is driven by one `ValueNotifier`, so only the pill and
  the affected icons rebuild on each tick. The rest of the bar stays static.
- New parameters: `pillColor`, `magnification`, `magnificationFalloff`,
  `snapDuration`, `snapCurve`.

## 0.1.0

- Initial release with `pill / dot / line / none` indicator styles.
