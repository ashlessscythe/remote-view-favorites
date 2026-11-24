-- Pure favorite-slot and position bookkeeping (no Factorio API), unit-tested in tests/.
local favorites = {}

favorites.COUNT = 10

--- Dropdown selected_index <-> slot. Index 1 is the "none" entry.
--- @param slot uint|nil
--- @return uint
function favorites.slot_to_selected_index(slot)
  if not slot then
    return 1
  end
  return slot + 1
end

--- @param index uint|nil
--- @return uint|nil
function favorites.selected_index_to_slot(index)
  if not index or index <= 1 then
    return nil
  end
  return index - 1
end

--- @param data table
--- @param surface_index uint
--- @return uint|nil
function favorites.slot_for_surface(data, surface_index)
  local slots = data.favorites
  if not slots then
    return nil
  end
  for slot = 1, favorites.COUNT do
    if slots[slot] == surface_index then
      return slot
    end
  end
  return nil
end

--- One surface per slot, one slot per surface. slot = nil clears this surface's assignment.
--- @param data table
--- @param surface_index uint
--- @param slot uint|nil
function favorites.set_slot(data, surface_index, slot)
  data.favorites = data.favorites or {}
  for s = 1, favorites.COUNT do
    if data.favorites[s] == surface_index then
      data.favorites[s] = nil
    end
  end
  if slot and slot >= 1 and slot <= favorites.COUNT then
    data.favorites[slot] = surface_index
  end
end

--- Drop every reference to a deleted surface from one player's data.
--- @param data table
--- @param surface_index uint
function favorites.clear_surface(data, surface_index)
  if data.default_surface_index == surface_index then
    data.default_surface_index = nil
  end
  if data.last_positions then
    data.last_positions[surface_index] = nil
  end
  if data.favorites then
    for slot = 1, favorites.COUNT do
      if data.favorites[slot] == surface_index then
        data.favorites[slot] = nil
      end
    end
  end
end

--- @param data table
--- @param surface_index uint
--- @param x number
--- @param y number
function favorites.remember_position(data, surface_index, x, y)
  data.last_positions = data.last_positions or {}
  data.last_positions[surface_index] = { x = x, y = y }
end

--- @param data table
--- @param surface_index uint
--- @return MapPosition|nil
function favorites.recall_position(data, surface_index)
  local last = data.last_positions and data.last_positions[surface_index]
  if last then
    return { x = last.x, y = last.y }
  end
  return nil
end

return favorites
