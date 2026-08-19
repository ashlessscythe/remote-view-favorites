-- Linked to the vanilla Toggle map control (default TAB). consuming = "none"
-- so Factorio still enters/exits Remote View; we only mark the press.
data:extend({
  {
    type = "custom-input",
    name = "rvf-toggle-map",
    key_sequence = "",
    linked_game_control = "toggle-map",
    consuming = "none",
    action = "lua",
    order = "a",
  },
  {
    type = "sprite",
    name = "rvf-crt-icon",
    filename = "__remote-view-favorites__/graphics/crt-icon.png",
    size = 64,
    flags = { "gui-icon" },
  },
})

-- Slots 1–3 default to Alt+N. 4–10 (0) are listed in Controls with no key.
local favorites = {}
for slot = 1, 10 do
  local key_sequence = ""
  if slot <= 3 then
    key_sequence = "ALT + " .. tostring(slot)
  end
  favorites[slot] = {
    type = "custom-input",
    name = "rvf-favorite-" .. tostring(slot),
    key_sequence = key_sequence,
    consuming = "game-only",
    action = "lua",
    order = "b-" .. string.format("%02d", slot),
  }
end
data:extend(favorites)
