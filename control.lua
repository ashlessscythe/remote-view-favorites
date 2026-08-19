local mod_gui = require("mod-gui")

local GUI_ROOT = "rvf_pin_frame"
local GUI_TOGGLE = "rvf_top_toggle"
local PIN_ACTION = "rvf-pin"
local TOGGLE_ACTION = "rvf-toggle-window"

--- @param player_index uint
--- @return table
local function player_data(player_index)
  storage.players = storage.players or {}
  local data = storage.players[player_index]
  if not data then
    -- default_surface_index is the 0.1.0 hook; later versions can add favorites = {}
    data = { default_surface_index = nil, window_open = true }
    storage.players[player_index] = data
  end
  return data
end

local function ensure_storage()
  storage.players = storage.players or {}
  storage.pending_toggle = storage.pending_toggle or {}
  storage.applying = storage.applying or {}
end

--- @param player LuaPlayer
--- @return boolean
local function setting_enable_default(player)
  local s = player.mod_settings["rvf-enable-default"]
  return s and s.value == true
end

--- @param player LuaPlayer
--- @return boolean
local function setting_show_pin_ui(player)
  local s = player.mod_settings["rvf-show-pin-ui"]
  return s and s.value == true
end

--- @param surface LuaSurface?
--- @return boolean
local function surface_listable(surface)
  if not surface or not surface.valid then
    return false
  end
  local platform = surface.platform
  if platform and platform.valid and platform.hidden then
    return false
  end
  return true
end

--- @param index uint?
--- @return LuaSurface?
local function resolve_surface(index)
  if not index then
    return nil
  end
  local surface = game.get_surface(index)
  if surface and surface.valid then
    return surface
  end
  return nil
end

--- @param player LuaPlayer
--- @return LuaSurface?
local function get_valid_default(player)
  local data = player_data(player.index)
  local surface = resolve_surface(data.default_surface_index)
  if surface then
    return surface
  end
  if data.default_surface_index then
    data.default_surface_index = nil
  end
  return nil
end

--- @param player LuaPlayer
--- @param surface LuaSurface
--- @return MapPosition
local function remote_position_on(player, surface)
  local physical = player.physical_surface
  if physical and physical.valid and physical.index == surface.index then
    return player.physical_position
  end
  local ok, pos = pcall(function()
    return player.force.get_spawn_position(surface)
  end)
  if ok and pos then
    return pos
  end
  return { 0, 0 }
end

--- @param player LuaPlayer
--- @param surface LuaSurface
--- @return boolean
local function switch_remote_to(player, surface)
  if not player.valid or player.controller_type ~= defines.controllers.remote then
    return false
  end
  if player.surface and player.surface.valid and player.surface.index == surface.index then
    return true
  end
  storage.applying[player.index] = true
  local ok = pcall(function()
    player.set_controller({
      type = defines.controllers.remote,
      surface = surface,
      position = remote_position_on(player, surface),
    })
  end)
  storage.applying[player.index] = nil
  return ok
end

--- @param player LuaPlayer
local function destroy_window(player)
  if not player.valid then
    return
  end
  local root = player.gui.left[GUI_ROOT]
  if root and root.valid then
    root.destroy()
  end
end

--- @param player LuaPlayer
local function destroy_toggle(player)
  if not player.valid then
    return
  end
  local flow = mod_gui.get_button_flow(player)
  local toggle = flow[GUI_TOGGLE]
  if toggle and toggle.valid then
    toggle.destroy()
  end
end

--- @param player LuaPlayer
local function destroy_gui(player)
  destroy_window(player)
  destroy_toggle(player)
end

--- @param element LuaGuiElement
local function hug_content(element)
  local style = element.style
  style.horizontally_stretchable = false
  style.vertically_stretchable = false
  style.horizontally_squashable = false
  style.padding = 0
  style.margin = 0
end

--- @return LuaSurface[]
local function listable_surfaces()
  local list = {}
  for _, surface in pairs(game.surfaces) do
    if surface_listable(surface) then
      list[#list + 1] = surface
    end
  end
  table.sort(list, function(a, b)
    return a.name < b.name
  end)
  return list
end

--- @param player LuaPlayer
local function rebuild_toggle(player)
  destroy_toggle(player)
  if not player.valid or not player.connected then
    return
  end
  if not setting_show_pin_ui(player) then
    return
  end

  local data = player_data(player.index)
  if data.window_open == nil then
    data.window_open = true
  end
  local open = data.window_open ~= false

  -- Vanilla mod-gui button row (top-left cluster with other mods).
  mod_gui.get_button_flow(player).add({
    type = "sprite-button",
    name = GUI_TOGGLE,
    sprite = "rvf-crt-icon",
    tooltip = open and { "rvf.hide-window" } or { "rvf.show-window" },
    style = mod_gui.button_style,
    mouse_button_filter = { "left" },
    auto_toggle = false,
    toggled = open,
    tags = { rvf_action = TOGGLE_ACTION },
  })
end

--- @param player LuaPlayer
local function rebuild_window(player)
  destroy_window(player)
  if not player.valid or not player.connected then
    return
  end
  if player.controller_type ~= defines.controllers.remote then
    return
  end
  if not setting_show_pin_ui(player) then
    return
  end

  local data = player_data(player.index)
  if data.window_open == false then
    return
  end

  local default_index = data.default_surface_index
  if default_index and not resolve_surface(default_index) then
    data.default_surface_index = nil
    default_index = nil
  end

  -- gui.left stretches to sibling width (other mods). Disable stretch + header filler
  -- so this frame hugs the pin rows instead of filling the column.
  local frame = player.gui.left.add({
    type = "frame",
    name = GUI_ROOT,
    caption = { "rvf.frame-caption" },
    direction = "vertical",
    style = "no_header_filler_frame",
  })
  hug_content(frame)
  frame.style.padding = 4
  frame.style.use_header_filler = false

  local pane = frame.add({
    type = "scroll-pane",
    name = "rvf_list",
    style = "naked_scroll_pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "auto",
  })
  hug_content(pane)
  pane.style.maximal_height = 220

  for _, surface in ipairs(listable_surfaces()) do
    local row = pane.add({
      type = "flow",
      direction = "horizontal",
      name = "rvf_row_" .. tostring(surface.index),
    })
    hug_content(row)
    row.style.vertical_align = "center"
    row.style.horizontal_spacing = 4

    local pinned = default_index == surface.index
    local button = row.add({
      type = "sprite-button",
      name = "rvf_pin_" .. tostring(surface.index),
      sprite = pinned and "utility/track_button_white" or "utility/track_button",
      tooltip = pinned and { "rvf.unpin-tooltip" } or { "rvf.pin-tooltip" },
      style = "mini_button",
      mouse_button_filter = { "left" },
      auto_toggle = false,
      toggled = pinned,
      tags = {
        rvf_action = PIN_ACTION,
        surface_index = surface.index,
      },
    })
    button.style.size = 20

    local caption
    if pinned then
      caption = { "rvf.pinned", surface.localised_name or surface.name }
    else
      caption = surface.localised_name or surface.name
    end
    local label = row.add({
      type = "label",
      caption = caption,
      ignored_by_interaction = true,
    })
    hug_content(label)
  end
end

--- @param player LuaPlayer
local function rebuild_gui(player)
  rebuild_toggle(player)
  rebuild_window(player)
end

local function rebuild_all_guis()
  for _, player in pairs(game.players) do
    rebuild_gui(player)
  end
end

--- @param player LuaPlayer
local function apply_default_if_needed(player)
  if not player.valid or not player.connected then
    return
  end
  if storage.applying[player.index] then
    return
  end
  if player.controller_type ~= defines.controllers.remote then
    return
  end
  if not setting_enable_default(player) then
    return
  end
  local surface = get_valid_default(player)
  if not surface then
    return
  end
  switch_remote_to(player, surface)
end

local function clear_default_for_surface(surface_index)
  if not storage.players then
    return
  end
  for _, data in pairs(storage.players) do
    if data.default_surface_index == surface_index then
      data.default_surface_index = nil
    end
  end
end

local function process_stale_pending()
  local pending = storage.pending_toggle
  if not pending or not next(pending) then
    return
  end
  local tick = game.tick
  for player_index, pending_tick in pairs(pending) do
    if tick - pending_tick >= 1 then
      pending[player_index] = nil
      local player = game.get_player(player_index)
      if player then
        apply_default_if_needed(player)
        rebuild_gui(player)
      end
    end
  end
end

script.on_init(ensure_storage)
script.on_configuration_changed(ensure_storage)

script.on_event(defines.events.on_tick, function()
  if storage.pending_toggle and next(storage.pending_toggle) then
    process_stale_pending()
  end
end)

-- Fires before vanilla Toggle map when consuming = "none".
script.on_event("rvf-toggle-map", function(event)
  ensure_storage()
  storage.pending_toggle[event.player_index] = event.tick
end)

script.on_event(defines.events.on_player_controller_changed, function(event)
  ensure_storage()
  local player = game.get_player(event.player_index)
  if not player then
    return
  end
  if storage.applying[event.player_index] then
    return
  end

  local pending_tick = storage.pending_toggle[event.player_index]
  local entered_remote = player.controller_type == defines.controllers.remote
    and event.old_type ~= defines.controllers.remote

  if entered_remote and pending_tick and event.tick - pending_tick <= 1 then
    storage.pending_toggle[event.player_index] = nil
    apply_default_if_needed(player)
  elseif not entered_remote then
    storage.pending_toggle[event.player_index] = nil
  end

  rebuild_gui(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not element or not element.valid then
    return
  end
  local tags = element.tags
  if not tags or not tags.rvf_action then
    return
  end
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if tags.rvf_action == TOGGLE_ACTION then
    local data = player_data(player.index)
    data.window_open = data.window_open == false
    rebuild_gui(player)
    return
  end

  if tags.rvf_action ~= PIN_ACTION then
    return
  end
  local data = player_data(player.index)
  local index = tags.surface_index
  if data.default_surface_index == index then
    data.default_surface_index = nil
  else
    local surface = resolve_surface(index)
    if surface_listable(surface) then
      data.default_surface_index = index
    end
  end
  rebuild_window(player)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  ensure_storage()
  player_data(event.player_index)
  local player = game.get_player(event.player_index)
  if player then
    rebuild_gui(player)
  end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.get_player(event.player_index)
  if player then
    destroy_gui(player)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting ~= "rvf-enable-default" and event.setting ~= "rvf-show-pin-ui" then
    return
  end
  if event.player_index then
    local player = game.get_player(event.player_index)
    if player then
      rebuild_gui(player)
    end
  else
    rebuild_all_guis()
  end
end)

script.on_event(defines.events.on_surface_created, rebuild_all_guis)
script.on_event(defines.events.on_surface_renamed, rebuild_all_guis)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
  clear_default_for_surface(event.surface_index)
end)

script.on_event(defines.events.on_surface_deleted, function()
  rebuild_all_guis()
end)
