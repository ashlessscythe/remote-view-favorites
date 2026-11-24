-- Scenarios you can watch in a real window: scripts/watch_factorio_tests.sh
-- Tagged "visual": skipped by the default headless run. Needs a connected player; without one
-- (headless) each scenario just logs and returns.
local function make_surface(name)
  return game.get_surface(name) or game.create_surface(name)
end

local function the_player()
  local p = game.connected_players[1]
  if not p then
    log("[rvf-test] no connected player; skipping scenario")
  end
  return p
end

local function press(player, slot)
  remote.call("rvf-test", "jump", player.index, slot)
end

local function assign(player, slot, surface)
  local data = storage.players[player.index]
  data.favorites[slot] = surface.index
end

local function leave_remote(player, character)
  if character and character.valid then
    pcall(player.set_controller, { type = defines.controllers.character, character = character })
  end
end

tags("visual")
describe("favorite jumps", function()
  local player, character, a, b
  local original = {}

  before_each(function()
    player = the_player()
    if not player then return end
    character = player.character
    a = make_surface("rvf-test-a")
    b = make_surface("rvf-test-b")
    for _, s in pairs({ a, b }) do
      s.request_to_generate_chunks({ 0, 0 }, 3)
      s.force_generate_chunk_requests()
    end
    local data = storage.players[player.index]
    original.favorites = data.favorites
    original.default = data.default_surface_index
    original.positions = data.last_positions
    data.favorites, data.default_surface_index, data.last_positions = {}, nil, {}
    assign(player, 1, a)
    assign(player, 2, b)
    player.zoom = 0.3
  end)

  after_each(function()
    if not player then return end
    leave_remote(player, character)
    local data = storage.players[player.index]
    data.favorites, data.default_surface_index, data.last_positions =
      original.favorites, original.default, original.positions
    game.delete_surface(a)
    game.delete_surface(b)
  end)

  test("a favorite key enters Remote View on that surface", function()
    if not player then return end
    press(player, 1)
    after_ticks(60, function()
      assert(player.controller_type == defines.controllers.remote, "not in remote view")
      assert(player.surface.index == a.index, "wrong surface: " .. player.surface.name)
    end)
  end)

  test("switching favorites changes surface while staying in Remote View", function()
    if not player then return end
    press(player, 1)
    after_ticks(60, function()
      press(player, 2)
      after_ticks(60, function()
        assert(player.controller_type == defines.controllers.remote, "left remote view")
        assert(player.surface.index == b.index, "did not switch to B")
      end)
    end)
  end)

  test("returning to a surface restores where you were looking", function()
    if not player then return end
    press(player, 1)
    after_ticks(30, function()
      player.teleport({ 40, -25 })
      after_ticks(40, function()
        press(player, 2)
        after_ticks(40, function()
          press(player, 1)
          after_ticks(40, function()
            assert(player.surface.index == a.index, "not back on A")
            local pos = player.position
            assert(math.abs(pos.x - 40) < 1 and math.abs(pos.y + 25) < 1,
              "position not restored: " .. serpent.line(pos))
          end)
        end)
      end)
    end)
  end)

  test("an empty slot does nothing", function()
    if not player then return end
    local before = player.controller_type
    press(player, 5)
    after_ticks(30, function()
      assert(player.controller_type == before, "controller changed for an empty slot")
    end)
  end)

  test("favorite keys are ignored outside character / remote view", function()
    if not player then return end
    local ok = pcall(player.set_controller, { type = defines.controllers.spectator })
    if not ok then return end
    press(player, 1)
    after_ticks(30, function()
      assert(player.controller_type == defines.controllers.spectator, "spectator was hijacked")
    end)
  end)
end)

tags("visual")
describe("pin list", function()
  local player, a

  before_each(function()
    player = the_player()
    if not player then return end
    a = make_surface("rvf-test-a")
  end)

  after_each(function()
    if not player then return end
    leave_remote(player, player.character)
    game.delete_surface(a)
  end)

  test("renaming a surface updates the list without recreating it", function()
    if not player then return end
    assign(player, 1, a)
    press(player, 1)
    after_ticks(60, function()
      local root = player.gui.left["rvf_pin_frame"]
      assert(root and root.valid, "pin list not shown")
      local before = root.rvf_list.index
      a.name = "rvf-test-renamed"
      after_ticks(10, function()
        local pane = player.gui.left["rvf_pin_frame"].rvf_list
        assert(pane.index == before, "list was recreated (scroll position would reset)")
        assert(pane["rvf_row_" .. a.index], "row missing after rename")
      end)
    end)
  end)
end)
