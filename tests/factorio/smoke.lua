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
