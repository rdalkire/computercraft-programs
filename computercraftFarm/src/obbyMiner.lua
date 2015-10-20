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

-- Fills the groove with lava:
oMnr.MxSlt = 11
oMnr.MXLTH = 50

local slotLngth = 0

oMnr.fillSlot = function()
  
  print("Starting fillSlot().")
  
  slotLngth = 0
  
  local sltDone = false
  local lp = false
  local theresLava = false
  
  while not sltDone do
  
    -- Fetches a bucket-full
    local gotBckt = false
    local canGo = true
    local cntFwds = 0
    
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
    if slotLngth >= oMnr.MxSlt or 
        not canGo then
      sltDone = true
      print( "slotLngth, canGo: ", 
          slotLngth, canGo )
    end
    
  end
  print( "theresLava: ", theresLava )
  return theresLava
end

oMnr.getAndPlaceWater = function()

  print("Starting getAndPlaceWater()")
  
  -- Go to the infinite water source
  for n = 1, 2 do
    trtl.forward()
  end
  local lp = trtl.placeDown() -- gets water
  
  -- TODO Improve water place choice
  for n = 1, 5 do
    trtl.back()
  end
  lp = trtl.placeDown()
  
  -- Back to start again
  for n = 1, 3 do
    trtl.forward()
  end
  trtl.turnLeft()

end

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
  
  -- TODO watch fuel level
  
  while theresLava and invHasSpace and
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