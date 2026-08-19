# Mod Portal description (copy-paste)

Paste everything **below the horizontal rule** into the Factorio Mod Portal **Description** field.

The Mod Portal accepts a limited markdown subset (headings, lists, bold, italic, links, images). Keep images on a `public` branch under `media/` if you add screenshots later; `media/` and `docs/` are omitted from the release ZIP.

---

# Remote View Favorites

> **Pin where TAB opens Remote View.**

Factorio Remote View normally opens on the surface your character is standing on. This mod lets **each player** pin one default surface. Toggle map (default **TAB**) then opens Remote View there instead.

Built for **Factorio 2.1**. Space Age is supported but not required. Nothing about recipes, combat, or progression is changed.

**0.1.0** pins a single default surface. Numbered favorites (jump keys such as Alt+2) are planned later.

---

## How to use

1. Press **TAB** (or your **Toggle map** binding) to enter Remote View.
2. Click the CRT icon in the top-left button cluster if the list is hidden.
3. In the **Default surface** list, click the pin next to a surface.
4. Exit Remote View, move wherever you like, and press TAB again.
5. Remote View opens on the pinned surface.

Click the same pin again to clear the default and restore vanilla TAB behavior.

The pin is **per player**. In multiplayer, each person keeps their own default.

---

## Why a separate list?

The vanilla surface selector in the upper left is engine UI. Mods cannot add buttons to it. This companion list is the supported way to pin a surface without replacing the vanilla selector.

---

## Settings

Per player, in **Settings → Mod settings**:

- **Open Remote View on pinned surface** — turn the TAB override on or off
- **Show pin list in Remote View** — hide the companion list if you do not need it

TAB always follows your **Toggle map** key binding. If you rebound that control, the mod follows the new key.

---

## Compatibility

- Factorio **2.1**
- Vanilla and **Space Age** (planets and space platforms that appear in the surface list)
- No extra dependencies

If the pinned surface is deleted or no longer exists, the pin is cleared and TAB behaves as in vanilla. The mod does not error in that case.

---

## FAQ

**Does this teleport my character?**
No. Only the Remote View camera changes.

**Does it affect other ways of opening Remote View?**
No. Only **Toggle map** (default TAB) applies the pin. Opening Remote View from an entity, Factoriopedia, and similar stays vanilla.

**Can two players pin different planets?**
Yes. Defaults are stored per player, not per force.
