--[[ Obsidian Miner 2

Copyright (c) 2016
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

local onlyOneLayer = false

-- NOTE remember to update D_BASE
--- Base URL for dependencies
local D_BASE = "https://".. 
    "raw.githubusercontent.com/".. 
    "rdalkire/"..
    "computercraft-programs/".. 
    "dalkire-obsidian2/turtleApps/src/"

--- Ensures dependency exists.
local function ensureDep(depNme,depVer)

  print("Ensuring presence of "..
      depNme.. " ".. depVer)
      
  local drFile= loadfile( depNme )
  local isGood = false
  
  if drFile ~= nil then
    drFile()
    if depVer == DEP_VERSION then
      isGood = true
    else
      print("existing version: ".. 
          DEP_VERSION)
      
      shell.run("rename", depNme, 
          depNme.."_".. DEP_VERSION )
      
    end
  end
  
  if isGood== false then
    print("getting latest version")
    shell.run("wget", 
        D_BASE.. depNme, depNme )
    drFile= loadfile(depNme)
    drFile()
  end
  
end

ensureDep("deadReckoner.lua", "1.1.1" )
local dr = deadReckoner

ensureDep("getopt.lua", "2.0" )

local lf = loadfile( "mockTurtle.lua")
if lf ~= nil then lf() end
local t = turtle

--- A collection of squares, which are
-- 9x9 areas, each defined by a place 
-- just above its central block. 
local squareStack = {}

local function initOptions( args )

  local someOptions = {
    ["one"] = { "(o)ne layer only", 
        "o", nil}
  }
  
  local tbl= getopt.init(
      "Obsidian Miner 2",
      "Mines obby from lava pit",
      someOptions, args )
      
  if tbl ~= nil then
    if tbl["one"] then
      onlyOneLayer= true
    end
  end

end

-- constants for the 3 materials
local ITM_OBBY = "minecraft:obsidian"
local ITM_CBBLE="minecraft:cobblestone"
local ITM_LAVA="minecraft:lava"
local ITM_WTR_BCKT=
    "minecraft:water_bucket"

--- A place to start for dealing with 
-- the next layer below. 
local lowerLayerLocus

--- Select the slot that has the item
-- @param itmName the item to match
-- @return true if item is found
local function selectSltWthItm(itmName)
  -- XXX maybe move selectSltWthItm()
  -- to an enhanced turtle API. Now 
  -- it's copied from wallSherpa
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

obbyMiner = {}
local om = obbyMiner

--- Moves in the given direction,
-- digging as needed
-- @param way is either dr.AHEAD, 
-- STARBOARD, PORT, FORE, or AFT 
-- dr.UP, or dr.DOWN where dr is 
-- deadReckoner
-- @param moves number of blocks to 
--    move
-- @return isAble true if it really was
--    able to move and dig.
-- @return whyNot if isAble, nil. Else,
--    reason why not.
obbyMiner.moveVector= function( way, 
    moves )
  -- XXX maybe move & modify move...()
  -- functions to separate API like
  -- the deadreckoner.
  
  local isAble = true
  local whynot = nil
  
  for i = 1, moves do
    isAble, whynot = dr.move(way)
    
    if not isAble then
    
      if whynot=="Movement obstructed"
          then
        dr.dig( way )
        isAble, whynot= dr.move( way )
      end -- obstructed
      
    end -- if not isAble
    
  end -- loop
  
  return isAble, whynot
end

--- Makes a vector and moves that way
-- @param destCrd The destination X,
--    Y or Z coordinate
-- @param thisCrd The current X, Y, or
--    Z coordinate
-- @param posWay the positive 
--    direction: dr.FORE, STARBOARD, 
--    or UP 
-- @param negWay the negative direction
--    opposite of the positive: dr.AFT,
--    PORT or DOWN
-- @return isAble true if it really was
--    able to move and dig.
-- @return whyNot if isAble, nil. Else,
--    reason why not.
obbyMiner.moveDimension = function(
    destCrd, thisCrd, posWay, negWay )
  
  local diff = destCrd - thisCrd
  local moves = math.abs(diff)
  local way = 0
  if diff > 0 then
    way = posWay
  elseif diff < 0 then
    way = negWay
  end
  
  return om.moveVector( way, moves)
end


--- Moves to the destination, digging
-- on the way as needed
-- @param coords relative to
--    where bot started at main()
-- @return isAble true if it really was
--    able to move and dig.
-- @return whyNot if isAble, nil. Else,
--    reason why not.
obbyMiner.moveToPlace=function(x, y, z)
    
  -- X
  local isAble, whynot= 
      om.moveDimension( x, dr.place.x, 
      dr.STARBOARD, dr.PORT)
  
  -- Y
  if isAble then
    isAble, whynot = om.moveDimension( 
        y, dr.place.y, 
        dr.UP, dr.DOWN)
  end
  
  -- Z
  if isAble then
    isAble, whynot = om.moveDimension( 
        z, dr.place.z, 
        dr.FORE, dr.AFT )
  end
  
  return isAble, whynot
  
end


---
-- Moves to right above lava or obby
-- @param isFromStart indicates whether
-- this is from main's starting place,
-- @return false if it wasn't able to
-- get to the start due to fuel 
-- constraints or whatever
obbyMiner.getToIt=function(isFromStart)
  
  local isAble, whynot
  
  if isFromStart then
    
    -- moves forward/ down until it's
    -- above lava or obby
    local keepGoing = true
    while keepGoing do
      local isThng, what= 
          t.inspectDown()
          
      if isThng == false then
        isAble, whynot=dr.move(dr.DOWN)
      elseif what.name== ITM_OBBY or 
          (what.name== ITM_LAVA and
           what.state.level == 0) then
           
         keepGoing= false
      else
        isAble, whynot=dr.move(dr.FORE)
      end
      
    end
    
  else -- Continue from previous layer

    isAble, whynot = om.moveToPlace( 
        lowerLayerLocus.x, 
        lowerLayerLocus.y, 
        lowerLayerLocus.z )

  end
  
  -- Once there, adds coords to the 
  -- squareStack
  local square = Locus.new( 
          dr.place.x, dr.place.y,
          dr.place.y )
          
  table.insert(squareStack, square)
  
  if not isAble then
    print( "Unable to getToIt(): "..
        whynot )
  end
  
  return isAble
end

--- Message and solution for fuel
problemWithFuel = {}
problemWithFuel.message = 
    "Place fuel in selected slot."

--- To be called if user puts fuel into
-- selected slot and indicates they
-- want to continue
problemWithFuel.callback = function()
  return t.refuel()
end

--- Message and solution for inventory
problemWithInventory = {}
problemWithInventory.message = 
    "Clear inventory for obsidian."

problemWithInventory.callback= 
    function()
  -- Assuming user took care of it
  return true 
end

--- Comes back to starting (home) 
-- position, requests action from user,
-- and if applicable, goes back to 
-- where it left off.
-- @param whatsTheMatter with message
-- and callback
-- @return true if it could continue
obbyMiner.comeHomeWaitAndGoBack=
    function( whatsTheMatter )
  local isToContinue = false
  
  local returnPlace = Locus.new(
      dr.place.x, dr.place.y,
      dr.place.z)
      
  om.moveToPlace(0, 0, 0)
  print( whatsTheMatter.message )
  print( "Then press C to continue "..
      "or any other key to quit." )
  
  local event, key= os.pullEvent("key")
  if key == keys.c then
    isToContinue = 
        whatsTheMatter.callback()
  end
  
  return isToContinue
end

--- Checks fuel level depending on 
-- distance from starting place plus
-- a buffer.  If not it'll come back
-- and prompt user to either supply
-- fuel or cancel.
-- @return true if fuel level seems
--  to be sufficient
obbyMiner.isFuelOKForSquare= function()
  
  local isOK = false
  local fuel = t.getFuelLevel()
  if fuel == "unlimited" then
    isOK = true
  else
    local fuelNeed=dr.howFarFromHome()+
        10 + -- For mining a square
        50   -- Arbitrary buffer
        
    if fuel- fuelNeed > 0 then
      isOK = true
    else
      isOK = om.comeHomeWaitAndGoBack(
          problemWithFuel )
    end
  end

  return isOK
end

obbyMiner.isInventorySpaceAvail = 
    function()
  -- XXX move to common API- this is
  -- in large part copied from 
  -- veinMiner
  
  local isAvail = false
  local frSpace = 0
  for i = 1, 16 do
    local itmCount = t.getItemCount(i)
    
    if itmCount == 0 then
      frSpace= frSpace+ 64
    else
      local slName= 
          t.getItemDetail(i).name
          
      if slName == ITM_OBBY then
        frSpace= frSpace+ 64- itmCount
      end -- match
      
    end -- count zero-else
    
  end -- inventory loop
  
  -- Assuming a square could be no more
  -- than 9 blocks, realistically
  if frSpace >= 9 then
    isAvail = true
  else
    isAvail= om.comeHomeWaitAndGoBack(
        problemWithInventory ) 
  end
  
  return isAvail
  
end

obbyMiner.isLayerFinished= function()
  return table.maxn(squareStack) < 1
end

--- Array of 2D places that have been
-- inspected for the current layer
local layerPlacesChecked = {}

--- Determines if a place has already
-- been inspected
obbyMiner.isChecked= function(x, z)
  local indx= string.format(
      "%d,%d", x, z )
  local val= layerPlacesChecked[indx]
  local isInspctd = not ( val == nil )
  return isInspctd
end

obbyMiner.setChecked = function(x, z)
  layerPlacesChecked[
      string.format( "%d,%d",
          x, z ) ] = true
end

--- Inspects down. Full lava blocks
-- get turned to obby and mined. Obby
-- and cobble are mined. If full lava
-- or Obby, the place is added to the
-- square stack.
obbyMiner.mineAPlace = function()
  local isWanted = false
  local ok, item= dr.inspect(dr.DOWN)
  om.setChecked(dr.place.x, dr.place.z)
  
  if ok then
  
    if item.name== ITM_LAVA and
        item.state.level == 0 then
      isWanted = true
      om.moveVector(dr.UP, 1)
      selectSltWthItm(ITM_WTR_BCKT)
      t.placeDown()
      t.placeDown()
      om.moveVector(dr.DOWN, 1)
      t.digDown()
    elseif item.name== ITM_OBBY then
      isWanted = true
      t.digDown()
    elseif item.name== ITM_CBBLE then
      t.digDown()
    end
    
    if isWanted then
      local square = Locus.new( 
          dr.place.x, dr.place.y,
          dr.place.y )
          
      table.insert(squareStack, square)
      
      -- If lower layer not yet 
      -- found, this probes below 
      if lowerLayerLocus== nil then
        om.moveVector(dr.DOWN, 1)
        ok, item= dr.inspect(dr.DOWN)
        
        if ok then
        
          if item.name== ITM_LAVA and
              item.state.level== 0 then
              
            lowerLayerLocus= Locus.new( 
                dr.place.x, dr.place.y,
                dr.place.y )
                
          end -- lava below
          
        end -- ok (there was something)
        
        om.moveVector(dr.UP, 1)
      end -- lowerLayerLocus== nil
      
    end -- isWanted
    
  end -- ok (something to inspect)
  
end

---
-- Removes a square from the square 
-- stack and mines it, delegating to 
-- add more squares when needed.
obbyMiner.mineASquare = function()
  
  local places= {
    {0,0}, {0,1}, {1,1}, {1,0}, {1,-1},
    {0,-1}, {-1,-1}, {-1,0}, {-1,1}
  }
  
  local square= table.remove(
      squareStack )
  
  local maxOfSequence = 
      table.maxn(places)
      
  for ix=1, maxOfSequence do
    local x= square.x+ places[ix][1]
    local z= square.z+ places[ix][2]
    
    if not om.isChecked(x, z) then
      
      local isAble, whyNot = 
          om.moveToPlace(x, dr.place.y,
              z )
      
      if isAble then
        om.mineAPlace()
      end
    end
    
  end
  
end

---
-- Mines a layer of lava, removing all
-- obsidian and cobblestone, as long 
-- as there's enough fuel and inventory
-- space
-- @return true if mining could be 
--    continued afterward.
obbyMiner.mineALayer= function()
  
  local couldContinue = false
  lowerLayerLocus = nil
  layerPlacesChecked = {}
  
  while om.isFuelOKForSquare() and
        om.isInventorySpaceAvail() and
        (not om.isLayerFinished() ) do
    om.mineASquare()
  end
  
  if lowerLayerLocus ~= nil then
    couldContinue = true
  end
  
  return couldContinue
end

--- Checks for sufficient fuel and
-- a water bucket
obbyMiner.checkPrereqs= function()
  
  local isOK = om.isFuelOKForSquare()
  
  if isOK then
    isOK= selectSltWthItm(ITM_WTR_BCKT)
    if not isOK then
      print("Need water bucket")
    end
  end
  
  return isOK
  
end

obbyMiner.main= function( args )
  
  -- From args, learns: get it all
  -- or just one layer?
  initOptions(args)
  
  local keepGoing= om.checkPrereqs()
  local isFirst = true
  
  -- Mine the layer(s) of lava
  while keepGoing do
    -- Get down to the lava/cobble/obby
    local keepGoing=om.getToIt(isFirst)
    isFirst = false
    
    if keepGoing then
      keepGoing= om.mineALayer()
    end
    
    if onlyOneLayer then
      keepGoing = false
    end
    
  end
  
  -- comes back
  om.moveToPlace( 0, 0, 0 )
  dr.bearTo(dr.FORE)
  
end

-- TODO uncomment when tested. 
-- om.main({...})
