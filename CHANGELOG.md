# Changelog

All notable changes to Remote View Favorites are documented here.

## [0.2.0] — 2026-08-19

### Added

- Numbered favorites: assign slot 1–9 or 0 on each surface in the pin list.
- Jump keys enter Remote View on that surface, or switch to it if you are already in Remote View.
- Defaults: Alt+1, Alt+2, Alt+3. Slots 4–9 and 0 are unbound; bind them in Settings → Controls.
- Pin list shows space platform names instead of internal ids such as `platform-1`.

## [0.1.2] — 2026-08-19

### Added

- Portal thumbnail (CRT monitor) and a stencil CRT icon for the toggle button.

### Changed

- Toggle lives in the top-left mod-gui button cluster with other mods, not as a separate top-bar control.

## [0.1.1] — 2026-08-19

### Added

- Button to show or hide the pin list while in Remote View.

### Changed

- Pin list is compact (no title-bar filler, no stretch-to-fill of the left GUI column).

### Fixed

- Crash on entering Remote View (`Unknown style quick_bar_window_frame`).

## [0.1.0] — 2026-08-19

### Added

- Per-player pin for a default Remote View surface.
- Toggle map (default TAB) opens Remote View on the pinned surface when it is still valid.
- Companion pin list in Remote View (vanilla surface list cannot be modified by the Lua API).
