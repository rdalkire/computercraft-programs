--[[ This is to test turtle scripts 
from IDEs outside of computercraft
MIT License (MIT)
2014 Robert David Alkire II ]]
turtle = {}
local mockTurtle= turtle

--- number or "unlimited"
local fuelLevel = 50

turtle.popCount = 5
turtle.itms = {}
local itms = turtle.itms 
local slts

turtle.selected = 1 -- Slot Num

local function getItemName(indx)

  local itm = turtle.
      getItemDetail( indx )

  local rtn = nill
  
  if itm then
    rtn = itm.name
  end

  return rtn
end

turtle.compareTo= function( indx )

  local thisItm = getItemName(
      turtle.selected )

  local thatItm = getItemName(indx)
   
  return thisItm == thatItm
   
end

turtle.craft = function()
  print("Pretending to craft.")
  for i, v in pairs(turtle.itms)do
    print(i, v.name, v.count)
  end
end

turtle.dig = function()
  return true
end

turtle.digDown = function()
  return true
end

turtle.digUp = function()
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

turtle.back = function()
  return checkAndDecrementFuel()
end

turtle.down = function()
  return checkAndDecrementFuel()
end

turtle.drop = function( amt )
  if amt then
    slts[turtle.selected] = 
      slts[turtle.selected]- amt
  else
    amt = slts[turtle.selected] 
    slts[turtle.selected] = 0
  end
  
  itms[turtle.selected] = nill
  
  print("Pretended to drop: ", amt)
end

turtle.forward = function()
  return checkAndDecrementFuel()
end

-- Can return a number or "unlimited"
turtle.getFuelLevel= function()
  return fuelLevel
end

turtle.getItemCount = 
    function( slotNum )
  local rtrn = 0
  if slotNum then
    rtrn = slts[slotNum]
  else
    rtrn = slts[turtle.selected]
  end
  return rtrn
end

turtle.getItemDetail = function( 
    slot )

  if slot == nil then 
    slot= turtle.selected
  end
  
  return itms[slot]
end

turtle.getItemSpace= function(slt)
  local rtrn = 0
  if slt then
    rtrn = 64 - slts[slt]
  else
    rtrn= 64- slts[turtle.selected]
  end
  return rtrn
end

turtle.getSelectedSlot = function()
  return turtle.selected
end

turtle.inspect = function()
  local itm = {}
  itm.name = "minecraft:log"
  return true, itm
end
turtle.inspectDown = function()
  local itm = {}
  itm.name = "minecraft:lava"
  itm.state= {}
  itm.state.level= 1
  
  return true, itm
end
turtle.inspectUp = function()
  local itm = {}
  itm.name = "minecraft:log"
  return true, itm
end

local function adjstInvFromPlacing()
  local slctd = turtle.selected 
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

turtle.place = function()
  adjstInvFromPlacing()
end

turtle.placeDown = function()
  adjstInvFromPlacing()
end

turtle.refuel = function()
  if fuelLevel ~= "unlimited" then
    fuelLevel = fuelLevel + 400
  end
  return true
end

turtle.select= function( slotNum )
  turtle.selected = slotNum  
end

turtle.suck = function()
  print("fake suction", 
      turtle.popCount)
  local isAble = false
  if turtle.popCount > 1 then
    turtle.popCount = 
        turtle.popCount - 1
    isAble = true
  end
  return isAble
end -- end suck

turtle.turnRight = function()
  print("Play-turning right.")
end

turtle.turnLeft = function()
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

turtle.transferTo = function( slot,
    quantity )
  
  local isAble = true
  
  local slctdItem= itms[
      turtle.selected]
  local destItem = itms[ slot ] 
  
  if (not quantity) or 
      (slts[turtle.selected] < 
      quantity) then
    quantity= slts[turtle.selected] 
  end
  
  -- Checks compatiblity and room
  local destRoom = 64-slts[slot]
  if slts[slot] >= 64 or 
      slts[turtle.selected]<= 0 or
      ( destItem ~= nill and
      slctdItem.name ~= destItem.name)
      then 
    isAble = false
  elseif quantity > destRoom then
    quantity= destRoom
  end
  
  if isAble then
    
    -- Update the source
    slts[turtle.selected] = 
        slts[turtle.selected] - 
        quantity
    
    if slts[turtle.selected] == 0 
        then
      itms[turtle.selected] = nill
    else
      slctdItem.value = 
          slts[turtle.selected]
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

turtle.up = function()
  return checkAndDecrementFuel()
end

turtle.init = function()
  
  -- Initializes the inventory
  -- with 4 kinds of items
  
  slts = 
    { 25, 50, 42, 43,
      0, 50, 0, 44,
      25, 50, 0, 45,
      25, 0, 0, 46 }
  
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
    else
      itms[i] = nil
    end 
  end
  
  slts[14] = 1
  itms[14] = {
    name = "minecraft:water_bucket",
    count = slts[14],
    damage = 0,
  }
  
end

turtle.init()

print("turtle 0.5.1")

return mockTurtle
