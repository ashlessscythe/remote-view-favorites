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
  },
})
