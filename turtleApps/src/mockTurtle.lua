
--[[ This is to test turtle scripts 
from IDEs outside of computercraft ]]
local mockTurtle = {}

local fuelLevel = 35 --or "unlimited"

mockTurtle.popCount = 5
mockTurtle.itms = {}
local itms = mockTurtle.itms 
local slts

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
  for i, v in pairs(mockTurtle.itms)do
    print(i, v.name, v.count)
  end
end

mockTurtle.dig = function()
  return true
end

mockTurtle.digDown = function()
  return true
end

mockTurtle.digUp = function()
  return true
end

local function checkAndDecrementFuel()
  local rtrn = true
  local whyNot = nil
  if fuelLevel ~= "unlimited" then
    if fuelLevel <= 0 then
      rtrn = false
      -- TODO find out real message
      whyNot = "Out of fuel"
    else
      fuelLevel = fuelLevel - 1
    end
  end
  return rtrn, whyNot
end

mockTurtle.back = function()
  return checkAndDecrementFuel()
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
  
  itms[mockTurtle.selected] = nill
  
  print("Pretended to drop: ", amt)
end

mockTurtle.forward = function()
  return checkAndDecrementFuel()
end

-- Can return a number or "unlimited"
mockTurtle.getFuelLevel= function()
  return fuelLevel
end

mockTurtle.getItemCount = 
    function( slotNum )
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
  return itms[slot]
end

mockTurtle.getItemSpace= function(slt)
  local rtrn = 0
  if slt then
    rtrn = 64 - slts[slt]
  else
    rtrn= 64- slts[mockTurtle.selected]
  end
  return rtrn
end

mockTurtle.getSelectedSlot = function()
  return mockTurtle.selected
end

mockTurtle.inspect = function()
  local itm = {}
  itm.name = "minecraft:log"
  return true, itm
end
mockTurtle.inspectDown = function()
  local itm = {}
  itm.name = "minecraft:log"
  return true, itm
end
mockTurtle.inspectUp = function()
  local itm = {}
  itm.name = "minecraft:log"
  return true, itm
end

mockTurtle.placeDown = function()
  local slctd = mockTurtle.selected 
  if slts[slctd] > 0 then
    slts[slctd] = slts[slctd] - 1
    
    if slts[slctd] == 0 then
      itms[slctd] = nil
    else
      local itm = itms[slctd]
      itm.count = slts[slctd]  
    end 
  end
  
  
end

mockTurtle.refuel = function()
  if fuelLevel ~= "unlimited" then
    fuelLevel = fuelLevel + 400
  end
end

mockTurtle.select= function( slotNum )
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

--[[ This function derived from: 
http://stackoverflow.com/a/641993/2620333 ]]
local function shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

mockTurtle.transferTo = function( slot,
    quantity )
  
  local isAble = true
  
  local slctdItem= itms[
      mockTurtle.selected]
  local destItem = itms[ slot ] 
  
  if (not quantity) or 
      (slts[mockTurtle.selected] < 
      quantity) then
    quantity= slts[mockTurtle.selected] 
  end
  
  -- Checks compatiblity and room
  local destRoom = 64-slts[slot]
  if slts[slot] >= 64 or 
      slts[mockTurtle.selected]<= 0 or
      ( destItem ~= nill and
      slctdItem.name ~= destItem.name)
      then 
    isAble = false
  elseif quantity > destRoom then
    quantity= destRoom
  end
  
  if isAble then
    
    -- Update the source
    slts[mockTurtle.selected] = 
        slts[mockTurtle.selected] - 
        quantity
    
    if slts[mockTurtle.selected] == 0 
        then
      itms[mockTurtle.selected] = nill
    else
      slctdItem.value = 
          slts[mockTurtle.selected]
    end
    
    -- If the destination slot type was 
    -- nill, update it
    slts[slot] = slts[slot] + quantity
    if itms[slot] == nill then
      destItem= shallow_copy( 
          slctdItem )
      itms[slot] = destItem 
    end
    destItem.count = slts[slot]
    
  end
  
  return isAble
  
end

mockTurtle.up = function()
  return checkAndDecrementFuel()
end

mockTurtle.init = function()
  
  -- Initializes the inventory
  -- with 4 kinds of items
  
  slts = 
    { 25, 50, 42, 43,
      0, 50, 0, 44,
      25, 50, 0, 45,
      25, 1, 0, 46 }
  
  --[[ Other item names:
    minecraft:melon_block
    minecraft:melon
    minecraft:iron_ingot
  ]]
  
  itms[1] = {
    name = "minecraft:carrot",
    count = slts[1],
    damage = 0,
  }
  itms[2] = {
    name = "minecraft:wheat_seeds",
    count = slts[2],
    damage = 0,
   }
  itms[3] = {
    name = "minecraft:potato",
    count = slts[3],
    damage = 0,
  } 
  itms[4] = {
    name = "minecraft:wheat_seeds",
    count = slts[4],
    damage = 0,
  }
  
  for i = 5, 16 do
    local ref = (i % 4) + 1
    if slts[i] ~= 0 then
      local nw= shallow_copy(itms[ref])
      nw.count = slts[i]
      itms[i] = nw
    end 
  end
  
end

mockTurtle.init()

print("mockTurtle 0.5.1")

return mockTurtle