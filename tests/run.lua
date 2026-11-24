--- Pure-Lua tests. Run with: lua tests/run.lua (no Factorio runtime needed).
package.path = "./?.lua;./?/init.lua;" .. package.path

local h = require("tests.harness")
local fav = require("scripts.favorites")

local function player() return { favorites = {}, last_positions = {} } end

print("favorites")

h.run("slot <-> dropdown index round-trips", function()
  h.assert_eq(fav.slot_to_selected_index(nil), 1)
  h.assert_eq(fav.slot_to_selected_index(1), 2)
  h.assert_eq(fav.slot_to_selected_index(10), 11)
  h.assert_eq(fav.selected_index_to_slot(1), nil)
  h.assert_eq(fav.selected_index_to_slot(nil), nil)
  for slot = 1, fav.COUNT do
    h.assert_eq(fav.selected_index_to_slot(fav.slot_to_selected_index(slot)), slot)
  end
end)

h.run("set_slot assigns and slot_for_surface finds it", function()
  local d = player()
  fav.set_slot(d, 7, 3)
  h.assert_eq(d.favorites[3], 7)
  h.assert_eq(fav.slot_for_surface(d, 7), 3)
  h.assert_eq(fav.slot_for_surface(d, 8), nil)
end)

h.run("a surface holds only one slot", function()
  local d = player()
  fav.set_slot(d, 7, 3)
  fav.set_slot(d, 7, 5)
  h.assert_eq(d.favorites[3], nil)
  h.assert_eq(d.favorites[5], 7)
end)

h.run("a slot holds only one surface (new one steals it)", function()
  local d = player()
  fav.set_slot(d, 7, 2)
  fav.set_slot(d, 9, 2)
  h.assert_eq(d.favorites[2], 9)
  h.assert_eq(fav.slot_for_surface(d, 7), nil)
end)

h.run("set_slot nil clears; out-of-range slot only clears", function()
  local d = player()
  fav.set_slot(d, 7, 4)
  fav.set_slot(d, 7, nil)
  h.assert_eq(fav.slot_for_surface(d, 7), nil)
  fav.set_slot(d, 7, 4)
  fav.set_slot(d, 7, 11)
  h.assert_eq(fav.slot_for_surface(d, 7), nil)
  fav.set_slot(d, 7, 0)
  h.assert_eq(fav.slot_for_surface(d, 7), nil)
end)

h.run("slot 10 (key 0) works", function()
  local d = player()
  fav.set_slot(d, 7, 10)
  h.assert_eq(fav.slot_for_surface(d, 7), 10)
end)

h.run("clear_surface removes default, slot and remembered position", function()
  local d = player()
  d.default_surface_index = 7
  fav.set_slot(d, 7, 1)
  fav.set_slot(d, 8, 2)
  fav.remember_position(d, 7, 1, 2)
  fav.clear_surface(d, 7)
  h.assert_eq(d.default_surface_index, nil)
  h.assert_eq(fav.slot_for_surface(d, 7), nil)
  h.assert_eq(fav.recall_position(d, 7), nil)
  h.assert_eq(fav.slot_for_surface(d, 8), 2, "other surfaces untouched")
end)

h.run("clear_surface leaves a different default alone", function()
  local d = player()
  d.default_surface_index = 8
  fav.clear_surface(d, 7)
  h.assert_eq(d.default_surface_index, 8)
end)

h.run("remembered positions are per surface and copied", function()
  local d = player()
  fav.remember_position(d, 1, 10, 20)
  fav.remember_position(d, 2, -5, 6)
  local p = fav.recall_position(d, 1)
  h.assert_eq(p.x, 10)
  h.assert_eq(p.y, 20)
  p.x = 999
  h.assert_eq(fav.recall_position(d, 1).x, 10, "recall returns a copy")
  h.assert_eq(fav.recall_position(d, 2).x, -5)
  h.assert_eq(fav.recall_position(d, 3), nil)
end)

h.run("functions tolerate old saves without the new fields", function()
  local d = {}
  h.assert_eq(fav.slot_for_surface(d, 1), nil)
  h.assert_eq(fav.recall_position(d, 1), nil)
  fav.remember_position(d, 1, 3, 4)
  h.assert_eq(fav.recall_position(d, 1).y, 4)
  fav.set_slot(d, 1, 2)
  h.assert_eq(d.favorites[2], 1)
  fav.clear_surface({}, 1)
end)

h.run("surface_less: planets, then platforms, then others", function()
  local list = {
    { kind = "other", name = "zeta" },
    { kind = "platform", name = "beta" },
    { kind = "planet", name = "vulcanus", order = "b[vulcanus]" },
    { kind = "platform", name = "Alpha" },
    { kind = "planet", name = "nauvis", order = "a[nauvis]" },
    { kind = "other", name = "alpha-other" },
    { kind = "planet", name = "aaa-noorder" },
  }
  table.sort(list, fav.surface_less)
  local names = {}
  for i, e in ipairs(list) do names[i] = e.name end
  h.assert_eq(table.concat(names, ","), "aaa-noorder,nauvis,vulcanus,Alpha,beta,alpha-other,zeta")
end)

h.run("surface_less: same-order planets fall back to name; ties are strict", function()
  local a = { kind = "planet", name = "b", order = "x" }
  local b = { kind = "planet", name = "a", order = "x" }
  h.assert_eq(fav.surface_less(b, a), true)
  h.assert_eq(fav.surface_less(a, b), false)
  h.assert_eq(fav.surface_less(a, a), false)
  local p1 = { kind = "platform", name = "Foo" }
  local p2 = { kind = "platform", name = "foo" }
  h.assert_eq(fav.surface_less(p1, p2) ~= fav.surface_less(p2, p1), true)
end)

h.run("is_listable: filter on keeps planets and platforms only", function()
  h.assert_eq(fav.is_listable(true, false, false, true), true)
  h.assert_eq(fav.is_listable(false, true, false, true), true)
  h.assert_eq(fav.is_listable(false, false, false, true), false)
end)

h.run("is_listable: filter off lists everything except hidden platforms", function()
  h.assert_eq(fav.is_listable(false, false, false, false), true)
  h.assert_eq(fav.is_listable(true, false, false, false), true)
  h.assert_eq(fav.is_listable(false, true, false, false), true)
  h.assert_eq(fav.is_listable(false, true, true, false), false)
  h.assert_eq(fav.is_listable(false, true, true, true), false)
end)

os.exit(h.summary() and 0 or 1)
