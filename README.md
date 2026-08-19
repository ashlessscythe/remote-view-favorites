# Remote View Favorites

Pin a surface as your **default Remote View destination**. Toggle map (default **TAB**) then opens Remote View on that surface instead of your character's current surface. Assign **numbered favorites** to jump straight to a surface.

This is a small Factorio **2.1** QoL mod. It does not change recipes, combat, or progression.

## Why a companion list?

The vanilla upper-left surface selector is engine GUI. Mods cannot add pin buttons to it. This mod shows a small pin list on the left while you are in Remote View. A CRT icon in the top-left mod button cluster (with other mods) shows or hides that list.

## Install

Requires Factorio 2.1. Space Age is optional.

- **Play:** download `remote-view-favorites_<version>.zip` from a GitHub Release (Actions builds it) and drop it in Factorio’s `mods` folder.
- **Develop:** symlink this repo as `mods/remote-view-favorites`.

GitHub Actions runs `scripts/package_mod.sh` in CI. You do not need to run that script locally. Release steps: [docs/releasing.md](docs/releasing.md).

## Settings

Per-player, in **Settings → Mod settings**:

- **Open Remote View on pinned surface** — apply the default when Toggle map enters Remote View
- **Show pin list in Remote View** — show or hide the companion list

Jump keys are in **Settings → Controls → Mods → Remote View Favorites**, not Mod settings.

## Shortcuts

Each row in the pin list has a slot drop-down (`—`, `1`–`9`, `0`). One surface per slot; assigning a used slot moves it.

| Slot | Default key |
| --- | --- |
| 1–3 | **Alt+1**, **Alt+2**, **Alt+3** |
| 4–9 and 0 | Unbound. Bind them in **Settings → Controls** |

Pressing a bound favorite enters Remote View on that surface, or switches to it if you are already in Remote View. Empty slots and deleted surfaces do nothing (the assignment is cleared). TAB still uses the pin, not a numbered slot.

## How it works

Factorio has no “player pressed TAB” event. The mod links a custom input to the vanilla **Toggle map** control (`linked_game_control = "toggle-map"`), lets vanilla open Remote View, then switches the remote camera with `LuaPlayer.set_controller` when a valid pinned surface exists.

Numbered favorites call `set_controller` directly: they enter Remote View from the character, or switch surfaces while already remote.

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

### Numbered favorites

- [ ] In Remote View, assign slot 1 to one surface and slot 2 to another
- [ ] From the character, press Alt+1 — Remote View opens on slot 1
- [ ] Press Alt+2 — camera switches to slot 2
- [ ] Assign slot 1 to a third surface — the previous slot 1 row goes back to `—`
- [ ] Assign slot 4, confirm it has no key until bound in Settings → Controls
- [ ] Save / reload — slots remain
- [ ] Delete a slotted surface — that slot clears, no error

### Multiplayer

- [ ] Player A pins one surface, Player B pins another
- [ ] Each player’s TAB uses only their own pin
- [ ] Favorite slots are per player
- [ ] Join / leave does not copy another player’s pin or slots

### Vanilla (no Space Age)

- [ ] Nauvis and any extra surfaces (editor, platforms if present) can be pinned and slotted

### Space Age

- [ ] Nauvis, Fulgora, Vulcanus, Gleba, Aquilo
- [ ] Space platforms appear unless hidden from the vanilla surface list
- [ ] Platform rows show the custom name (for example Planet Express), not `platform-1`
- [ ] No other Space Age behavior is changed

## License

See the repository for license details if present. The Mod Portal zip is built by GitHub Actions (no executables or maintainer scripts inside).
