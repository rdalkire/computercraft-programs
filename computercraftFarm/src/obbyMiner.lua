--[[
Copyright (c) 2015 
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

local trtl
if turtle then 
  trtl = turtle
else
  trtl = require "mockTurtle" 
end

local oMnr = {}

oMnr.MxSlt = 11
oMnr.MXLTH = 50

local slotLngth = 0
local OKFuel = true
local theresLava = false

-- Fetches a bucket of lava and places
-- it into the slot.
-- returns canGo (true if the turtle
--  can move to the next place in the 
--  slot), and sltDone (if this 
-- position is more than MxSlt or it
-- was blocked)
oMnr.fetchLavaBucket = function()
  
    -- Fetches a bucket-full
    local gotBckt = false
    local cntFwds = 0
    local lp = false
    
    local canGo = true
    
    -- Until has bucket or obstructed
    while not gotBckt and canGo do
      canGo = trtl.forward()
      if canGo then
        cntFwds = cntFwds + 1
        -- Tries to get bucket of lava
        gotBckt = trtl.placeDown()
        if gotBckt then
          theresLava = true
        end
      end
      
      -- Limits any robot run-away
      if cntFwds >= oMnr.MXLTH then
        canGo = false
      end
    end
    
    print("gotBckt, canGo: ", 
        gotBckt, canGo )
    
    -- Takes the lava back to the slot
    for bk = 1, cntFwds do
      trtl.back()
    end
    
    -- Into slot, places lava, rises
    trtl.down()
    lp = trtl.placeDown()
    trtl.up()
    
    -- Tries to get to next place in slot
    trtl.turnLeft()
    canGo = trtl.forward()
    trtl.turnRight()
    if canGo then
      slotLngth = slotLngth + 1
    end
    
    -- Sees whether slot is done
    local sltDone = false
    if slotLngth >= oMnr.MxSlt or 
        not canGo then
      sltDone = true
      print( "slotLngth, canGo: ", 
          slotLngth, canGo )
    end
    
    return canGo, sltDone

end

-- Fills the slot.  With lava.
-- Returns true if there was any lava
-- to place in the slot.
oMnr.fillSlot = function()
  
  print("Starting fillSlot().")
  
  slotLngth = 0
  
  local sltDone = false
  local theresLava = false
  
  while OKFuel and not sltDone do
    
    local canGo = true
    
    -- Ensure there's enough fuel to
    -- get the next bucket and finish
    local fuelLvl= trtl.getFuelLevel()
    
    if fuelLvl ~= "unlimited" then
      local fuelNeed = 
          oMnr.MXLTH * 2 + -- a bucket
          10 +          -- place water
          24 +         -- to mine obby
          slotLngth + 2 -- to get back
      
      if fuelNeed > fuelLvl then
        OKFuel = false
        canGo = false
        print( "There may not be "..
            "enough fuel to continue "..
            "safely." )
      end
    end
    
    if canGo then
      canGo, sltDone =
          oMnr.fetchLavaBucket()
    end
    
  end
  
  print( "theresLava: ", theresLava )
  return theresLava
end

-- Gets and places water, to turn lava
-- into obsidian.  Distances are 
-- currently hard-coded.
-- Fuel cost: 10
oMnr.getAndPlaceWater = function()

  print("Starting getAndPlaceWater()")
  
  -- Go to the infinite water source
  for n = 1, 2 do trtl.forward() end
  local lp = trtl.placeDown() -- gets water
  
  -- To start
  for n = 1, 2 do trtl.back() end
  
  -- To middle of slot
  local half = math.floor( slotLngth )
  for n = 1, half do trtl.forward() end
  
  lp = trtl.placeDown()
  
  -- Back to start again
  for n = 1, half do trtl.forward() end
  trtl.turnLeft()

end

-- Mines obsidian.
-- Fuel cost, assuming slotLngth is 
-- MxSlt 11: 24
oMnr.mineObby = function()
  print("Starting mineObby()")
  -- Mine the obby
  trtl.turnLeft()
  trtl.down()
  local canDig = false
  for mn = 1, slotLngth do
    canDig = trtl.digDown()
    trtl.forward()
  end
  trtl.digDown()
  trtl.up()
  -- Come on back
  for b = 1, slotLngth do
    trtl.back()
  end
  trtl.turnRight()
end

oMnr.go = function()
  
  local theresLava = true;
  local invHasSpace = true;
  local countGoRepeats = 0;
  
  while theresLava and invHasSpace and
      OKFuel and
      (countGoRepeats <= oMnr.MXLTH) do
    
    print( "countGoRepeats: ", 
        countGoRepeats )
    
    print("fuel level: ", 
        trtl.getFuelLevel() )
    
    -- TODO Allow longer slots
    theresLava = oMnr.fillSlot()
    
    -- Back to beginning of slot
    trtl.turnRight()
    for bk = 1, slotLngth do
      trtl.forward()
    end
    
    oMnr.getAndPlaceWater()  
    oMnr.mineObby()
    
    -- Checks inventory space
    local frSpace = 0
    for i = 1, 16 do
      frSpace= frSpace+ trtl.getItemSpace(i)
    end
    invHasSpace= frSpace >= slotLngth
    print("free space: ", frSpace)
    
    countGoRepeats= countGoRepeats+ 1
  end
  
end

oMnr.go()

return oMnr