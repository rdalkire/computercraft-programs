-- NOTE this is NOT the stand-alone
-- version.  See deploy directory

--[[ This is for after you've used the 
excavate script, and you have a deep 
hole in front of you.  Finds out how 
many ladders and torches you need, and
places them

Copyright (c) 2015 
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

-- TODO at release, in-line deadReckoner
local dr = require "deadReckoner"

-- TODO at release, use native turtle
local t = require "mockTurtle"

local COBBLE_MIN = 12

local ITM_COBBLE="minecraft:cobblestone"
local ITM_LADDER = "minecraft:ladder"
local ITM_TORCH = "minecraft:torch"

local g_stop = false

--- estimates and inventories torches, 
-- ladders and cobbles
-- @param height is turtle Y coordinate
-- @return how many torches, ladders, 
-- and cobbles are needed to make up, 
-- and how many cobbles you actually 
-- have
local function lddrsNTrchsDiff(height)

  local n = height - 5
  local ladderReq = n * 2
  local torchReq= math.ceil( n/5 )
  local cobbleReq= n * 3
  
  -- inventories ladders & torches
  local laddersHave = 0
  local torchesHave = 0
  local cobbleHave = 0
  for iSlot = 1, 16 do
    local sltDt= t.getItemDetail(iSlot)
    if t.getItemCount(iSlot)==0 then
      -- no op
    elseif sltDt.name==
        ITM_LADDER then
      laddersHave= laddersHave +
          sltDt.count
    elseif sltDt.name==
        ITM_TORCH then
      torchesHave = torchesHave +
          sltDt.count
    elseif sltDt.name== ITM_COBBLE then
      cobbleHave= cobbleHave+sltDt.count 
    end -- slotname if
  end -- slots loop
  
  local ladderDif = math.max(0, 
      ladderReq - laddersHave )
  local torchDif = math.max( 0,
      torchReq - torchesHave )
  local cobbleDif = math.max( 0, 
      cobbleReq - cobbleHave )
      
  return ladderDif, torchDif, cobbleDif,
      cobbleHave

end

--- Finds how many sticks needed for
-- ladders, and how many sticks for 
-- torches
local function lddrNTrchSticks( 
    ladderDif, torchDif )
  
  local trchStcks = 0
  if torchDif > 0 then
    print("== need ".. torchDif..
        " more torches")
    -- Nearest higher factor of 4
    torchDif= math.ceil(torchDif/4)*4
    print("Craft ".. torchDif.. 
        " torches" )
    local coalCnt= math.ceil(
        torchDif / 4 )
    trchStcks= coalCnt
    print("coal & sticks needed for ".. 
        "torches: ".. coalCnt ) 
  end
  
  local lddrStcks = 0
  if ladderDif > 0 then
    print("== more ladders needed: "..
        ladderDif )
    -- Nearest higher factor of 3
    ladderDif= math.ceil(ladderDif/3)*3
    print("Ladders to craft: "..
        ladderDif )
    lddrStcks= math.ceil(
        ladderDif * 7 / 3 )
    print("ladder-sticks needed: "..
        lddrStcks )
  end
  
  return lddrStcks, trchStcks
  
end

--- @return true if fuel is enough
local function checkFuel( height )
  local isGood = false
  local fuel = t.getFuelLevel()
  if fuel == "unlimited" then
    isGood = true
  else
    local d = height - 5
    
    -- returning fuel
    local rtn = d
    if g_stop then
      rtn = 0
    end
    
    local needed = d * 2 + -- ladders
                  (d/5)*2+ -- torches
                   rtn +   -- returning
                   20      -- buffer
                   
    local diff = math.max(0, 
        needed - fuel )
    
    if diff == 0 then
      isGood = true
    else
      print("fuel is too low: ".. fuel)
      print("needs at least: "..needed)
      print("difference: ".. diff)
    end  
  end
  return isGood
end

--- Finds out if there are enough 
-- ladders and torches.  If not it
-- displays a manifest of what's needed
local function checkSupplies(height)
  local areOK = false
  
  local ladderDif, torchDif, cobbleDif, 
      cobbleHave = lddrsNTrchsDiff(
          height )
  
  local lddrStcks, trchStcks = 
      lddrNTrchSticks( ladderDif,
          torchDif )
  
  if ladderDif + torchDif == 0 then
    areOK = true
  else
    local stickCnt= lddrStcks +
        trchStcks
    
    -- Nearest higher factor of 4
    stickCnt= math.ceil(stickCnt/4 )*4
    print( "total sticks to craft: "..
        stickCnt )
    
    local plankCnt= math.ceil(
        stickCnt * 2 / 4 )
    
    plankCnt= math.ceil(plankCnt/4)*4
    
    print(
        "planks to craft for sticks "..
        plankCnt )
    
    local logCnt = math.ceil(
        plankCnt / 4 )
    print("logs for planks: ".. 
        logCnt )
    
  end
  
  if cobbleHave < COBBLE_MIN then
    areOK = false
    print("You should have at least "..
        COBBLE_MIN.. " cobbles")
    print("If building whole wall "..
        "you'd need ".. cobbleDif..
        " more cobblestone blocks")
  end
  
  if not checkFuel(height) then
    areOK = false
  end
  
  return areOK
end

local function checkPrereqs(targs)
  local isOK = true
  local aarhgIndx = table.maxn(targs) 
  if aarhgIndx < 1 then
    isOK = false
    print("usage: shaftSafety [-s] ".. 
          "<height>")
    print("  The [-s] option would "..
        "tell the turtle to Stop ".. 
        "afterward and not come back.")
    print("  For <height>, put in "..
        "the turtle's Y coordinate."  )
  else
  
    -- checks options and operand
    if aarhgIndx == 2 then
      if targs[1] == "-s" then
        isOK = true
        g_stop = true
      else
        print("First arg must be -s")
        isOK = false
      end
    end 

    local n= tonumber(targs[aarhgIndx])
    if n == nil then
      isOK = false
      print("argument not a number")
    elseif n < 6 then
      isOK = false
      print("arg should be 6 or more")
    elseif isOK then
      isOK = checkSupplies(n)
    end
    
  end
  return isOK
end

--- Select the slot that has the item
-- @param itmName the item to match
-- @return true if item is found
local function selectSltWthItm(itmName)
  local itm = t.getItemDetail()
  local isFound = false
  local nme
  if itm ~= nill then
    nme = itm.name
    isFound = itmName == nme
  end
  
  if not isFound then
    local slt = t.getSelectedSlot()
    local i = 1
    while not isFound and i <= 16 do
      if i ~= slt then
        itm = t.getItemDetail(i)
        if itm ~= nill then
          nme = itm.name
          if nme == itmName then
            isFound = true
            t.select(i)
          end
        end -- not nill
      end -- not current slot
      i = i + 1
    end -- while
  end -- not yet found
  return isFound
end

--- Meant for placing torches or ladders
-- @param itmName
-- @return true if successful
local function placeItemAft( itmName )
  local isAble= selectSltWthItm(itmName)
  local whyNt = nil
  if isAble then
    isAble, whyNt=dr.placeItem(dr.AFT)
  
    if not isAble then
      -- Assuming due to empty space, so
      -- go back and place cobble
      isAble, whyNt = dr.move(dr.AFT)
      
      if isAble then
        isAble = selectSltWthItm(
            ITM_COBBLE )
        
        if isAble then
          isAble, whyNt = dr.placeItem( 
              dr.AFT )
          dr.move(dr.FORE)
          
          -- try again
          selectSltWthItm(itmName)
          isAble, whyNt = dr.placeItem(
              dr.AFT )
        else
          whyNt = "out of cobble"
        end -- if there's cobble
      end -- able to move aft
    end -- wasn't able to place
  else
    whyNt = "Out of ".. itmName
  end
  
  if not isAble then
    print("unable to place; ".. whyNt)
  end
  
  return isAble
end

--- if fifth, move starboard, 
--  place a torch and come back
--  @param d is distance down so far
local function placeFthTrchStrbrd(d)
  if d % 5 == 0 then
    dr.move(dr.STARBOARD)
    placeItemAft(ITM_TORCH)
    dr.move(dr.PORT)
  end
end

--- Moves down the shaft wall, placing
-- ladders and torches.
local function goDownPlacing(n)
  
  local lmt = n - 5
  local actlDst = 0
  local keepGoing = true
  
  while keepGoing and actlDst < lmt do
    
    keepGoing = dr.move(dr.DOWN)
    if keepGoing then
      
      if actlDst % 2 == 0 then --even

        placeItemAft( ITM_LADDER )
        dr.move(dr.STARBOARD)
        placeItemAft( ITM_LADDER )
        placeFthTrchStrbrd(actlDst)
        
      else -- odd
        
        placeFthTrchStrbrd(actlDst)
        placeItemAft( ITM_LADDER )
        dr.move(dr.PORT)
        placeItemAft( ITM_LADDER )
        
      end -- if even
      actlDst = actlDst + 1
    end -- if keepgoing
  end -- while
  return actlDst
end -- function

--- Moves the turtle to the original
-- location. First left/right, then
-- up/down (in this app's case up, to be
-- realistic), then for/aft
local function comeBack()
  
  -- left/right
  local x = dr.place.x
  if x < 0 then
    -- move right abs x places
    for m = 1, math.abs(x) do
      dr.move(dr.STARBOARD)
    end
  elseif x > 0 then
    -- move left x times
    for m = 1, x do
      dr.move(dr.PORT)
    end
  end
  
  -- up/down
  local y = dr.place.y
  if y < 0 then
    for m = 1, math.abs(y) do
      dr.move(dr.UP)
    end
  elseif y > 0 then
    for m = 1, y do
      dr.move(dr.DOWN)
    end
  end
  
  -- fore/aft
  local z = dr.place.z
  if z < 0 then
    for m = 1, math.abs(z) do
      dr.move(dr.FORE)
    end
  elseif z > 0 then
    for m = 1, z do
      dr.move(dr.AFT)
    end
  end
end

local function main( targs )

  -- Check prereqs; warn as applicable
  if checkPrereqs(targs) then
    print("prereqs OK")
    
    -- Adjust starting location:
    -- so turtle can start 1 from edge
    -- afterward, trtl is 1 away from 
    -- wall, giving room to place
    if t.inspectDown() then
      dr.move(dr.AHEAD)
    end
    dr.move(dr.AHEAD)
    dr.bearTo(dr.AFT);
    
    local n = tonumber(
        targs[ table.maxn( targs ) ] )
    
    -- Go down, placing things
    local d = goDownPlacing(n)

    if not g_stop then
      comeBack()
    end
    
    dr.bearTo(dr.FORE)
    
  end

end

local tArgs = {...}
main(tArgs)
