-- Headless in-game tests (factorio-test). No player is needed.
local function make_surface(name)
  return game.get_surface(name) or game.create_surface(name)
end

describe("Remote View Favorites loads", function()
  test("mod is active", function()
    assert(script.active_mods["remote-view-favorites"], "mod not active")
  end)

  test("custom inputs exist", function()
    assert(prototypes.custom_input["rvf-toggle-map"], "toggle-map input missing")
    for slot = 1, 10 do
      assert(prototypes.custom_input["rvf-favorite-" .. slot], "favorite input " .. slot .. " missing")
    end
  end)

  test("storage is initialised", function()
    assert(storage.players, "storage.players missing")
    assert(storage.pending_toggle, "storage.pending_toggle missing")
  end)
end)

describe("surface deletion cleanup", function()
  local fake_player = 9999

  after_each(function()
    storage.players[fake_player] = nil
  end)

  test("deleting a surface clears its pin, slot and remembered position", function()
    local surface = make_surface("rvf-test-doomed")
    local keep = make_surface("rvf-test-keep")
    local idx, keep_idx = surface.index, keep.index
    storage.players[fake_player] = {
      default_surface_index = idx,
      window_open = true,
      favorites = { [2] = idx, [3] = keep_idx },
      last_positions = { [idx] = { x = 1, y = 1 }, [keep_idx] = { x = 2, y = 2 } },
    }
    game.delete_surface(surface)
    after_ticks(3, function()
      local d = storage.players[fake_player]
      assert(d.default_surface_index == nil, "pin not cleared")
      assert(d.favorites[2] == nil, "slot not cleared")
      assert(d.last_positions[idx] == nil, "position not cleared")
      assert(d.favorites[3] == keep_idx, "unrelated slot was touched")
      assert(d.last_positions[keep_idx], "unrelated position was touched")
      game.delete_surface(keep)
    end)
  end)
end)

describe("hidden pinned platform", function()
  local fake_player = 9998

  after_each(function()
    storage.players[fake_player] = nil
  end)

  test("TAB default ignores a hidden platform pin without clearing it", function()
    if not (script.active_mods["space-age"] and prototypes.space_location["nauvis"]) then
      log("[rvf-test] space platforms unavailable; skipping")
      return
    end
    local platform = game.forces.player.create_space_platform({
      name = "rvf-test-platform", planet = "nauvis", starter_pack = "space-platform-starter-pack",
    })
    if not platform then
      log("[rvf-test] could not create platform; skipping")
      return
    end
    platform.apply_starter_pack()
    local surface = platform.surface
    assert(surface and surface.valid, "platform has no surface")
    storage.players[fake_player] = {
      default_surface_index = surface.index, window_open = true, favorites = {}, last_positions = {},
    }
    assert(remote.call("rvf-test", "default_surface", fake_player) == surface.index, "visible pin not used")
    platform.hidden = true
    assert(remote.call("rvf-test", "default_surface", fake_player) == nil, "hidden pin was used")
    assert(storage.players[fake_player].default_surface_index == surface.index, "hidden pin was cleared")
    platform.hidden = false
    assert(remote.call("rvf-test", "default_surface", fake_player) == surface.index, "pin not restored")
    platform.destroy(1)
  end)
end)

describe("surface list filtering", function()
  local function contains(list, idx)
    for _, i in ipairs(list) do
      if i == idx then return true end
    end
    return false
  end

  test("plain extra surface is listed only when the filter is off", function()
    local surface = make_surface("rvf-test-plain")
    assert(not contains(remote.call("rvf-test", "listed", true), surface.index), "listed with filter on")
    assert(contains(remote.call("rvf-test", "listed", false), surface.index), "missing with filter off")
    local nauvis = game.get_surface("nauvis")
    assert(contains(remote.call("rvf-test", "listed", true), nauvis.index), "nauvis not listed with filter on")
    game.delete_surface(surface)
  end)

  test("filtered pin and favorite are ignored, not cleared", function()
    local surface = make_surface("rvf-test-plain2")
    local fake_player = 9997
    storage.players[fake_player] = {
      default_surface_index = surface.index, window_open = true,
      favorites = { [2] = surface.index }, last_positions = {},
    }
    assert(remote.call("rvf-test", "default_surface", fake_player) == nil, "filtered pin was used")
    assert(remote.call("rvf-test", "favorite_surface", fake_player, 2) == nil, "filtered favorite was used")
    assert(storage.players[fake_player].default_surface_index == surface.index, "pin cleared")
    assert(storage.players[fake_player].favorites[2] == surface.index, "favorite cleared")
    storage.players[fake_player] = nil
    game.delete_surface(surface)
  end)
end)

describe("hotkey feedback", function()
  test("pressing an empty slot does not error", function()
    local p = game.connected_players[1]
    if not p then
      log("[rvf-test] no connected player; skipping")
      return
    end
    local data = storage.players[p.index]
    local saved = data.favorites[5]
    data.favorites[5] = nil
    remote.call("rvf-test", "jump", p.index, 5)
    data.favorites[5] = saved
  end)
end)
