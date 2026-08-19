# Remote View Favorites

Pin a surface as your **default Remote View destination**. Toggle map (default **TAB**) then opens Remote View on that surface instead of your character's current surface.

This is a small Factorio **2.1** QoL mod. It does not change recipes, combat, or progression.

**0.1.0** is the MVP: a single per-player default surface. Numbered favorites (for example Alt+2) are planned for a later version.

## Why a companion list?

The vanilla upper-left surface selector is engine GUI. Mods cannot add pin buttons to it. This mod shows a small pin list on the left while you are in Remote View.

## Install

Requires Factorio 2.1. Space Age is optional.

- **Play:** download `remote-view-favorites_<version>.zip` from a GitHub Release (Actions builds it) and drop it in Factorio’s `mods` folder.
- **Develop:** symlink this repo as `mods/remote-view-favorites`.

GitHub Actions runs `scripts/package_mod.sh` in CI. You do not need to run that script locally. Release steps: [docs/releasing.md](docs/releasing.md).

## Settings

Per-player:

- **Open Remote View on pinned surface** — apply the default when Toggle map enters Remote View
- **Show pin list in Remote View** — show or hide the companion list

## How it works

Factorio has no “player pressed TAB” event. The mod links a custom input to the vanilla **Toggle map** control (`linked_game_control = "toggle-map"`), lets vanilla open Remote View, then switches the remote camera with `LuaPlayer.set_controller` when a valid pinned surface exists.

Preferences are stored per player in `storage` using `LuaSurface.index` (stable until the surface is deleted). Invalid or deleted surfaces are cleared; vanilla behavior is left unchanged.

## Test checklist

### Single player

- [ ] Start on Nauvis
- [ ] Open Remote View, pin Fulgora (Space Age) or another surface
- [ ] Move the character to a different surface
- [ ] Press TAB (Toggle map)
- [ ] Remote View opens on the pinned surface
- [ ] Change the pin and TAB again
- [ ] Save / reload — pin remains
- [ ] Delete or disable the pinned surface — fallback is vanilla, no error

### Multiplayer

- [ ] Player A pins one surface, Player B pins another
- [ ] Each player’s TAB uses only their own pin
- [ ] Join / leave does not copy another player’s pin

### Vanilla (no Space Age)

- [ ] Nauvis and any extra surfaces (editor, platforms if present) can be pinned

### Space Age

- [ ] Nauvis, Fulgora, Vulcanus, Gleba, Aquilo
- [ ] Space platforms appear unless hidden from the vanilla surface list
- [ ] No other Space Age behavior is changed

## License

See the repository for license details if present. The Mod Portal zip is built by GitHub Actions (no executables or maintainer scripts inside).
