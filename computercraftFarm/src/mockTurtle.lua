
--[[ This is to test turtle scripts 
from IDEs outside of computercraft ]]
local mockTurtle = {}

local fuelLevel = 0 --or "unlimited"

mockTurtle.popCount = 5
mockTurtle.itms = {}
local itms = mockTurtle.itms 
itms[0] = {
  name = "minecraft:melon_block",
  --[[ NOTE the count will be resolved
  by using the slts table.  See 
  getItemDetail() ]]
  count = 0,
  damage = 0,
}
itms[1] = {
  name = "minecraft:melon",
  count = 0,
  damage = 0,
}
itms[2] = {
  name = "minecraft:iron_ingot",
  count = 0,
  damage = 0,
}
itms[3] = nill
--itms[3] = {
--  name = "minecraft:melon",
--  count = 0,
--  damage = 0,
--}

local slts = 
    { 25, 50, 0, 42,
      25, 50, 0, 42,
      25, 50, 0, 42,
      25, 1, 0, 42 }

mockTurtle.selected = 1 -- Slot Num

local function getItemName(indx)

  local itm = mockTurtle.
      getItemDetail( indx )

  local rtn = nill
  
  if itm then
    rtn = itm.name
  end

  return rtn
end

mockTurtle.compareTo= function( indx )

  local thisItm = getItemName(
      mockTurtle.selected )

  local thatItm = getItemName(indx)
   
  return thisItm == thatItm
   
end

mockTurtle.craft = function()
  print("Pretending to craft.")
  for i, v in ipairs(slts) do
    print(i, v)
  end
end

mockTurtle.digDown = function()
  return true
end

local function checkAndDecrementFuel()
  local rtrn = true
  if fuelLevel ~= "unlimited" then
    if fuelLevel <= 0 then
      rtrn = false
    else
      fuelLevel = fuelLevel - 1
    end
  end
  return rtrn
end

mockTurtle.down = function()
  return checkAndDecrementFuel()
end

mockTurtle.drop = function( amt )
  if amt then
    slts[mockTurtle.selected] = 
      slts[mockTurtle.selected]- amt
  else
    amt = slts[mockTurtle.selected] 
    slts[mockTurtle.selected] = 0
  end
  
  print("Pretended to drop: ", amt)
end

mockTurtle.forward = function()
  return checkAndDecrementFuel()
end

-- Can return a number or "unlimited"
mockTurtle.getFuelLevel= function()
  return fuelLevel
end

mockTurtle.getItemCount= function( slotNum )
  local rtrn = 0
  if slotNum then
    rtrn = slts[slotNum]
  else
    rtrn = slts[mockTurtle.selected]
  end
  return rtrn
end

mockTurtle.getItemDetail = function( 
    slot )
  local r = slot % 4
  local stuff = mockTurtle.itms[r]
  if stuff then
    stuff.count = slts[slot]
  end
  return stuff
end

mockTurtle.getSelectedSlot = function()
  return mockTurtle.selected
end

mockTurtle.placeDown = function()
  local slctd = mockTurtle.selected 
  if slts[slctd] > 0 then
    slts[slctd] = slts[slctd] - 1 
  end
end

mockTurtle.refuel = function()
  if fuelLevel ~= "unlimited" then
    fuelLevel = fuelLevel + 400
  end
end

mockTurtle.select = function ( slotNum )
  mockTurtle.selected = slotNum  
end

mockTurtle.suck = function()
  print("fake suction", 
      mockTurtle.popCount)
  local isAble = false
  if mockTurtle.popCount > 1 then
    mockTurtle.popCount = 
        mockTurtle.popCount - 1
    isAble = true
  end
  return isAble
end -- end suck

mockTurtle.turnRight = function()
  print("Play-turning right.")
end

mockTurtle.turnLeft = function()
  print("Play-turning left.")
end

mockTurtle.transferTo = function( slot,
    quantity )
    
  slts[mockTurtle.selected] = 
      slts[mockTurtle.selected]- quantity
  
  slts[slot] = slts[slot] + quantity 
  
  -- TODO simulate transferTo API if needed.
end

mockTurtle.up = function()
  return checkAndDecrementFuel()
end

print("mockTurtle 0.5.0")

return mockTurtle