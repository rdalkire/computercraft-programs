-- Starting at top of hole/cliff/wall,
-- this places ladders and torches
-- downward so you can climb safetly
--
-- NOTE this is NOT the stand-alone
-- version.  See deploy directory
-- Run with no args or -h for usage

--[[ wallSherpa
Copyright (c) 2016
Robert David Alkire II, AKA rdalkire, 
IGN ian_xw
(some parts contributed by others. I 
credit them at the top of those parts)
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

-- TODO RELEASE IN-LINE deadReckoner
local dr = require "deadReckoner"
-- END RELEASE IN-LINE deadReckoner

-- TODO RELEASE IN-LINE getopt
local getopt = require "getopt"
-- END RELEASE IN-LINE getopt

-- TODO RELEASE use native turtle
local t = require "mockTurtle"

local FILL_MIN = 12

local ITM_FILL="minecraft:cobblestone"
local ITM_LADDER = "minecraft:ladder"
local ITM_TORCH = "minecraft:torch"

local g_stay = false
local g_height = 0
local g_bed = true -- stops at bedrock
local g_up = false
local g_gap = false -- stops at gap

local g_torchInterval = 5

--- estimates and inventories torches, 
-- ladders and cobbles
-- @return how many torches, ladders, 
-- and cobbles are needed to make up, 
-- and how many cobbles you actually 
-- have
local function lddrsNTrchsDiff()

  local n = g_height
  if g_bed then
    n = n - 5
  end
  
  local ladderReq = n * 2
  local torchReq= math.ceil( n/ 
      g_torchInterval )
      
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
    elseif sltDt.name== ITM_FILL then
      cobbleHave=cobbleHave+sltDt.count 
    end -- slotname if
  end -- slots loop
  
  local ladderDif = math.max(0, 
      ladderReq - laddersHave )
  local torchDif = math.max( 0,
      torchReq - torchesHave )
  local cobbleDif = math.max( 0, 
      cobbleReq - cobbleHave )
      
  return ladderDif,torchDif, cobbleDif,
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
local function checkFuel()
  local isGood = false
  local fuel = t.getFuelLevel()
  if fuel == "unlimited" then
    isGood = true
  else
  
    local d = g_height
    if g_bed then
      d = d - 5
    end
    
    -- returning fuel
    local rtn = d
    if g_stay then
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
local function checkSupplies()
  local areOK = false
  
  local ladderDif, torchDif, cobbleDif, 
      cobbleHave = lddrsNTrchsDiff()
  
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
  
  if cobbleHave < FILL_MIN then
    areOK = false
    
    -- TODO parse fill item for warning
    print("You should have at least "..
        FILL_MIN.. " cobbles")
    print("If building whole wall "..
        "you'd need ".. cobbleDif..
        " more cobblestone blocks")
  end
  
  if not checkFuel() then
    areOK = false
  end
  
  return areOK
end

--- Manages the input arguments. 
-- Validates and parses them.
-- @param targs the arguments passed
-- in when starting the program
local function mngArgs(targs)
  local _optionsExample = {
      ["stay"] = {
          "Stay and don't come back.",
          "s", nill },
      ["bedrock"] = {
          "go all the way to "..
          "Bedrock (true if not "..
          "specified and going "..
          "down.  If going up, "..
          "this isn't applicable).",
          "b", "<true|false>"},
      ["up"] = {
          "go Up instead.",
          "u", nill },
      ["gap"] = {
          "stop at the first Gap "..
          "(If not specified, "..
          "defaults true going up,"..
          " false going down).",
          "g", "<true|false>"},
      ["torchInterval"] = {
          "Define Interval between "..
          "torches. Defaults to 5",
          "i", "<num>"}
  }
  
  local isOK = true
  
  local tbl= getopt.init("wallSherpa",
      "This is for after you've "..
      "used the excavate script, "..
      "and you have a deep hole in"..
      " front of you.  Finds out "..
      "how many ladders and torches "..
      "you need, and places them. "..
      "\nUse turtle's Y coord "..
      "as the argument to go all "..
      "the way to bedrock", 
      _optionsExample, targs )
  
  if tbl== nil then
    -- user had used -h as option
    isOK = false
  elseif next(tbl)== nil then
    -- no options or args specified
    isOK = false
    getopt.help()
  else
  
    if tbl["stay"] then
      g_stay = true
    end
    
    if tbl["up"] then
      g_up = true
      g_bed = false
      g_gap = true
    end
    
    if tbl["bedrock"] then
    
      local bedTxt = string.lower( 
          tbl["bedrock"] )
      
      if "true" == bedTxt then
        g_bed = true
      elseif "false" == bedTxt then
        g_bed = false
      elseif g_up then
        isOK = false
        print("Going up, so bedrock"..
            "doesn't really apply.")
      else
        isOK = false
        print("For Bedrock, you ".. 
            "must specify true or "..
            "false.")
      end
      
    end
    
    if tbl["gap"] then
      local gapTxt = string.lower(
          tbl["gap"])
          
      if "true" == gapTxt then
        g_gap = true
      elseif "false" == gapTxt then
        g_gap = false
      else
        print("Gap option requires"..
            " true|false argument.")
        isOK = false
      end
    end
    
    if tbl["torchInterval"] then
      g_torchInterval = tonumber( 
          tbl["torchInterval"] )
      if g_torchInterval == nil then
        isOK = false
        print("TorchInterval option"..
            " requires number.")
      end
    end
    
    if tbl["opt-1"] then
      g_height= tonumber( tbl["opt-1"])
      if g_height== nil then
        isOK = false
        print("Arg must be numeric.")
      elseif g_bed and g_height< 6 then
        isOK = false
        print("Arg must be 6 or more.")
      end
    elseif isOK then
      isOK = false
      print("Arg required for height.")
    end -- opt-1
  end
  
  return isOK
end

--- Manages prerequisites. Validates
-- and parses the options, arguments,
-- and inventory supplies.
-- @param targs the raw arguments
-- @return true if prerequisites
-- are OK
local function mngPrereqs(targs)
  local isOK = true
  
    isOK = mngArgs(targs)
    if isOK then
      isOK = checkSupplies()
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

---Meant for placing torches or ladders
-- AFT if going down, or FORE if going 
-- up. When encountering a gap, it will
-- depend on whether it's supposed to
-- stop at gaps.  If so (g_gap, default
-- true going up), it will return 
-- false.  Otherwise will fill in the
-- gap with ITM_FILL and continue.
-- @param itmName
-- @return true if successful
local function placeItem( itmName )
  local isAble=selectSltWthItm(itmName)
  local whyNt = nil
  local way = dr.AFT
  if g_up then
    way = dr.FORE
  end
  if isAble then
    
    dr.dig(way)
    isAble, whyNt=dr.placeItem(way)
  
    if not isAble and not g_gap then
      
      -- go back and place filler
      
      isAble, whyNt = dr.move(way)
      
      if isAble then
        isAble = selectSltWthItm(
            ITM_FILL )
        
        if isAble then
          -- Could be abandoned mine
          -- with fencing or cobweb
          dr.dig(way)
          
          isAble, whyNt = dr.placeItem( 
              way )

          dr.move(dr.BACK)
          
          -- try again
          selectSltWthItm(itmName)
          isAble, whyNt = dr.placeItem(
              way )
        else
          -- TODO parse fill item
          whyNt = "out of ".. itmName
        end -- if there's cobble
      end -- able to move aft
    elseif not isAble then
      print("Not filling gap")
      print(
        "isAble: "..tostring(isAble)..
        " g_gap: "..tostring(g_gap))
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
local function placeNthTrchStrbrd(d)
  local rtrn = true
  if d % g_torchInterval == 0 then
    dr.move(dr.STARBOARD)
    rtrn = placeItem(ITM_TORCH)
    dr.move(dr.PORT)
  end
  return rtrn
end

--- Moves down the shaft wall, placing
-- ladders and torches.
-- @return vertical distance traveled
local function goPlaceThings()
  
  local lmt = g_height
  if g_bed then
    lmt = lmt - 5
  end
  
  local actlDst = 0
  local keepGoing = true
  
  local vert = dr.DOWN
  if g_up then
    vert = dr.UP
  end
  
  local isFirstGoingUp = g_up
  
  while keepGoing and actlDst < lmt do
    
    if isFirstGoingUp then
      isFirstGoingUp = false
    else
      keepGoing = dr.move(vert)
    end
    
    if keepGoing then
      
      if actlDst % 2 == 0 then --even
        
        keepGoing =
            placeItem( ITM_LADDER) and
            dr.move(dr.STARBOARD ) and
            placeItem( ITM_LADDER) and
            placeNthTrchStrbrd(actlDst)
        
      else -- odd
        
        keepGoing =
            placeNthTrchStrbrd(actlDst)
            and
            placeItem( ITM_LADDER) and
            dr.move(dr.PORT) and
            placeItem( ITM_LADDER )
        
      end -- even/odd
      actlDst = actlDst + 1
    end -- if keepgoing
  end -- while
  return actlDst
end -- function

--- Moves the turtle to the original
-- location. First left/right, then
-- up/down (in this app's case up, to 
-- be realistic), then for/aft
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

local function adjStartLocation()

  if g_up then
    -- If up against wall, back up
    -- so that a ladder can be placed
    if t.inspect() then
      dr.move(dr.BACK)
    end
  else
    -- so turtle can start 1 from edge
    -- afterward, trtl is 1 away from 
    -- wall, giving room to place
    if t.inspectDown() then
      dr.move(dr.AHEAD)
    end
    dr.move(dr.AHEAD)
    dr.bearTo(dr.AFT);
  end
end

local function main( targs )

  -- Check prereqs; warn as applicable
  if mngPrereqs(targs) then
    print("prereqs OK")
    
    adjStartLocation()
    
    -- Go down, placing things
    local d = goPlaceThings()

    if not g_stay then
      comeBack()
    end
    
    dr.bearTo(dr.FORE)
    
  end

end

local tArgs = {...}
main(tArgs)
