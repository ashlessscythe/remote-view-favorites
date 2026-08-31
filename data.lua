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

local gui_styles = data.raw["gui-style"].default

gui_styles["rvf_panel_frame"] = {
  type = "frame_style",
  parent = "inside_deep_frame",
  use_header_filler = false,
  padding = 4,
}

gui_styles["rvf_list_scroll_pane"] = {
  type = "scroll_pane_style",
  parent = "list_box_scroll_pane",
}

gui_styles["rvf_list_row"] = {
  type = "frame_style",
  parent = "frame",
  padding = 4,
  left_padding = 8,
  right_padding = 8,
  minimal_height = 28,
  vertically_stretchable = "off",
  horizontally_stretchable = "on",
  graphical_set = {
    base = { position = { 208, 17 }, corner_size = 8 },
  },
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    horizontal_spacing = 4,
    vertical_align = "center",
  },
}

gui_styles["rvf_list_row_pinned"] = {
  type = "frame_style",
  parent = "rvf_list_row",
  graphical_set = {
    base = { position = { 51, 17 }, corner_size = 8 },
  },
}

gui_styles["rvf_surface_label"] = {
  type = "label_style",
  parent = "label",
  font = "default-listbox",
  default_font_color = { 1, 1, 1 },
}

gui_styles["rvf_surface_label_pinned"] = {
  type = "label_style",
  parent = "rvf_surface_label",
  default_font_color = { 255, 230, 192 },
}
