--[[ Obsidian Miner 2

Copyright (c) 2016-2017
Robert David Alkire II, 
IGN Hephaestus_Page 
FKA goatsbuster, ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

local VERSION = "2.0.4"

--- Set by users (l)imit option, so
-- if they want to do only a few layers
-- at a time. 0 means no limit
local g_layerlimit = 0

--- How long to wait for water to 
-- spread
local g_waterWait = 0.5

--- The initial limit for going down
-- and forward to find the lava
local FINDING_LIMIT = 128

-- BEGIN BOILERPLATE

local lf = loadfile( "mockTurtle.lua")
if lf ~= nil then
  lf()
  lf= loadfile("mockMiscellaneous.lua")
  lf()
end
local t = turtle

--- Base URL for dependencies
local getDependencyBase= function()
  local myBranch = "master/"
  
  if MY_BRANCH then
    myBranch = MY_BRANCH 
  end
  
  return
    "https://".. 
    "raw.githubusercontent.com/".. 
    "rdalkire/"..
    "computercraft-programs/".. 
    myBranch..
    "turtleApps/src/"

end

--- Ensures dependency exists.
local function ensureDep(depNme,depVer)

  print("Ensuring presence of "..
      depNme.. " ".. depVer)
      
  local drFile= loadfile( depNme )
  local isGood = false
  
  if drFile ~= nil then
    DEP_VERSION = nil
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
        getDependencyBase().. depNme, 
        depNme )
    
    drFile= loadfile(depNme)
    drFile()
  end
  
end

ensureDep("getMy.lua", "1.1")
-- END BOILERPLATE

ensureDep("deadReckoner.lua", "1.2.0" )
local dr = deadReckoner

ensureDep("getopt.lua", "2.1" )

ensureDep(
    "fuelAndInventory.lua", 
    "0.8" )

--- A collection of squares, each 
-- defined by a place just above its 
-- central block.
local squareStack = {}

local function initOptions( args )

  local isOK = true

  local someOptions = {
      ["limit"] = {
        "(l)imit how many lava layers",
        "l", "<num>" },
      ["w"] = {
        "wait time before "..
        "retrieving water bucket "..
        "just placed.  Defaults "..
        "to 0.5", "w", "<num>"}
  }

  local tbl= getopt.init(
    "obbyMiner2",
    "Obsidian Miner, Version "..  
    VERSION.." mines obby. "..
    "Give it a water bucket, fuel"..
    " it, point it at a "..
    "lava pit, and run it.",
    someOptions, args )

  if tbl == nil then
    -- this is for the -h option
    isOK= false
  else

    if tbl["limit"] then
      g_layerlimit= tonumber(
          tbl["limit"] )
        
      if g_layerlimit== nil then
        isOK= false
        print("The (l)imit option "..
          "requires a number.")
      end
    end

    if tbl["wait"] then
      g_waterWait = tonumber(
          tbl["wait"] )
        
      if g_waterWait == nil then
        isOK= false
        print("The (w)ait option "..
            "requires a number.")
      end

    end

  end

  return isOK

end

-- constants for the 3 materials
local ITM_BEDROCK= "minecraft:bedrock"
local ITM_CHEST= "minecraft:chest"
local ITM_OBBY = "minecraft:obsidian"
local ITM_CBBLE="minecraft:cobblestone"
local ITM_LAVA="minecraft:lava"
local ITM_LAVA_FLW=
    "minecraft:flowing_lava"
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
    isAble, whynot = dr:move(way)

    if not isAble then

      if whynot== "Movement obstructed"
          then
        dr:dig( way )
        isAble, whynot= dr:move( way )
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

--- Checks for lava/flowing_lava
-- that's mine-able
-- @param what the thing inspected
-- @return true if minable
obbyMiner.isLavaMinable=function(what)
  local rslt= false
  if ( what.name== ITM_LAVA_FLW or
       what.name== ITM_LAVA ) and
      what.state.level == 0 then
      
    rslt= true
  end
  return rslt
end

---
-- Moves to right above lava or obby
-- @param isFromStart indicates whether
-- this is from main's starting place,
-- @return false if it wasn't able to
-- get to the start due to fuel
-- constraints or whatever
obbyMiner.getToIt=function(isFromStart)

  local isAble= true 
  local whynot= "(shrugs)"

  print("isFromStart:", isFromStart)

  if isFromStart then

    local fuel= t.getFuelLevel()
    local fwdLmt = FINDING_LIMIT

    if not (fuel == "unlimited") then
      if fuel <= FINDING_LIMIT* 2 then
        fwdLmt = fuel / 2
      end
    end

    print("forward limit:", fwdLmt)

    -- moves forward/ down until it's
    -- above lava or obby
    local keepGoing = true
    while keepGoing do
      local isThng, what=
          t.inspectDown()

      if dr:howFarFromHome() >=
          fwdLmt then

        keepGoing= false
        isAble= false
        whynot= "Too far from home."
      elseif isThng == false then
        print("Nothing; descending.")
        isAble, whynot=dr:move(dr.DOWN)
      elseif what.name== ITM_OBBY or
          om.isLavaMinable(what) then

        print(what.name,
            what.state.level)

        keepGoing= false
      else
        
        print(what.name,
            what.state.level)

        isAble, whynot=dr:move(dr.FORE)
        keepGoing= isAble
      end

    end

  else

    print( "Continuing to "..
        "next layer." )

    print( "lowerLayerLocus:",
        lowerLayerLocus )

    isAble, whynot = om.moveToPlace(
        lowerLayerLocus.x,
        lowerLayerLocus.y,
        lowerLayerLocus.z )

  end

  if isAble then
    -- Once there, adds coords to the
    -- squareStack
    local square = Locus.new(
        dr.place.x, dr.place.y,
        dr.place.z )
      
    table.insert(squareStack, square)
  else
    print( "Unable to getToIt(): "..
        whynot )
  end

  return isAble
end

--- Checks for sufficient fuel,
-- inventory space and a water bucket
-- (forward declaration)
obbyMiner.checkPrereqs = nil

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
  
  local returnPlace = whatsTheMatter.
      returnPlace
  
  if returnPlace== nil then
    returnPlace= Locus.new(
        dr.place.x, dr.place.y,
        dr.place.z)
  end
  
  om.moveToPlace(0, 0, 0)
  
  term.clear()
  print( whatsTheMatter.getMessage() )
  print( "Then press c to continue "..
    "or q to quit." )

  local event = ""
  local key = keys.x

  while not ( key == keys.c or 
      key == keys.q ) do

    event, key= os.pullEvent("key")
    
    if key == keys.c and
        whatsTheMatter.callback() and
        om.checkPrereqs() then
  
      isToContinue = true
      
      om.moveToPlace(returnPlace.x,
          returnPlace.y, returnPlace.z)
          
    end
    
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
    local fuelNeed=dr:howFarFromHome()+
      10 + -- For traversing a square
      18 + -- possible mine up-downs
      18   -- max probing up-downs

    if fuel > fuelNeed then
      isOK = true
    else
  
      local xtraFuelForFueling =
          dr:howFarFromHome() * 2
  
      fuelNeed = fuelNeed +
          xtraFuelForFueling
  
      local dif= fuelNeed- fuel
  
      problemWithFuel.needMin= dif
  
      isOK = om.comeHomeWaitAndGoBack(
          problemWithFuel )
    end
  end

  return isOK
end

--- 
-- Comes back to home and tries to
-- dump inventory into a chest a la
-- excavate.
-- @return isChest true if there was a 
-- chest to dump to
-- @return returnPlace in case
-- caller needs to know how to get
-- back to work.  Applicable when
-- isChest is false
obbyMiner.dumpToChest = function()

-- XXX Centralize

  local isHappy = false

  local returnPlace = Locus.new(
      dr.place.x, dr.place.y,
      dr.place.z)

  om.moveToPlace(0, 0, 0)
  
  local isItm, itm= dr:inspect(dr.AFT)
  if isItm and 
      itm.name== ITM_CHEST then

    -- dump everything except w. bucket
    for i= 1, 16 do
      local thg= t.getItemDetail(i)
      if thg ~= nil and 
          thg.name ~= ITM_WTR_BCKT then
        t.select(i)
        t.drop() 
      end
    end
    
    -- and go back to where working
    om.moveToPlace(returnPlace.x,
        returnPlace.y, returnPlace.z)
    
    returnPlace = nil
    isHappy = true
    
  end
    
  return isHappy, returnPlace

end

obbyMiner.isInventorySpaceAvail =
    function()

  local isAvail = false
  -- Counts free spaces for Obbsidian
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
    local returnPlace= nil
    
    isAvail, returnPlace= 
        om.dumpToChest()

    problemWithInventory.returnPlace=
        returnPlace
    
    -- If chest isn't there
    -- ask user to place chest or clear
    -- inventory
    if not isAvail then

      problemWithInventory.message=
          "Please clear inventory "..
          "space for obsidian or "..
          "place a chest."
  
      isAvail=om.comeHomeWaitAndGoBack(
        problemWithInventory )
    end
  end

  return isAvail

end

obbyMiner.isWaterBucketThere=function()
  local isOK= selectSltWthItm(
    ITM_WTR_BCKT)

  if not isOK then
    problemWithInventory.message=
      "Need water bucket, please"

    isOK = om.comeHomeWaitAndGoBack(
      problemWithInventory )

  end
  return isOK
end

obbyMiner.isLayerFinished= function()
  local done =
    table.maxn(squareStack) < 1

  if done then
    print("Layer is finished")
  end

  return done
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

local g_isToStopProbing = false

--- Inspects down. Full lava blocks
-- get turned to obby and mined. Obby
-- and cobble are mined. If full lava
-- or Obby, the place is added to the
-- square stack.
-- @param isEligible true if the 
--   current place is eligible to be
--   added to the stack of squares
obbyMiner.mineAPlace = function(
    isEligible )
  
  local isWanted = false
  local ok, item= dr:inspect(dr.DOWN)
  om.setChecked(dr.place.x, dr.place.z)

  if ok then

    if om.isLavaMinable(item) then
      isWanted = true

      -- Makes room for water below
      om.moveVector(dr.UP, 1)

      -- Makes obby below
      selectSltWthItm(ITM_WTR_BCKT)
      t.placeDown()
      os.sleep( g_waterWait )
      t.placeDown()

      om.moveVector(dr.DOWN, 1)
      t.digDown()
    elseif item.name== ITM_OBBY then
      isWanted = true
      t.digDown()
    elseif item.name== ITM_CBBLE then
      t.digDown()
    elseif item.name==ITM_BEDROCK then
      g_isToStopProbing= true
      lowerLayerLocus= nil
    end

    if isWanted then
    
      if isEligible then
        local square = Locus.new(
            dr.place.x, dr.place.y,
            dr.place.z )
  
        table.insert( squareStack, 
            square )
      
      end
      
      -- If lower layer not yet
      -- found, this probes below
      if lowerLayerLocus== nil and
          not g_isToStopProbing then

        om.moveVector(dr.DOWN, 1)
        ok, item= dr:inspect(dr.DOWN)

        if ok then

          if om.isLavaMinable(item) or 
              item.name== ITM_OBBY then
            
            lowerLayerLocus= Locus.new(
                dr.place.x, dr.place.y,
                dr.place.z )

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
        -- The first location {0,0} was
        -- already a square location
        -- list entry, so shouldn't be
        -- considered eligible to be
        -- added
        om.mineAPlace( ix > 1 )
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
--    continued afterward, because a
--    lower layer of lava was found
obbyMiner.mineALayer= function()

  local couldContinue = false
  lowerLayerLocus = nil
  layerPlacesChecked = {}

  while om.checkPrereqs() and
      (not om.isLayerFinished() ) do
    om.mineASquare()
  end

  if lowerLayerLocus ~= nil then
    couldContinue = true
  end

  return couldContinue
end

--- Checks for sufficient fuel,
-- inventory space and a water bucket
-- (forward declared previously)
obbyMiner.checkPrereqs= function()

  return om.isFuelOKForSquare() and
    om.isInventorySpaceAvail() and
    om.isWaterBucketThere()

end

obbyMiner.main= function( args )

  -- From args, learns: get it all
  -- or limit layers?
  local keepGoing=initOptions(args) and
    om.checkPrereqs()

  local isFirst = true

  -- Mine the layer(s) of lava
  local countLayers= 0
  while keepGoing do
  
    -- Get down to the lava/cobble/obby
    keepGoing=om.getToIt(isFirst)
    isFirst = false

    if keepGoing then
      keepGoing= om.mineALayer()
    end

    countLayers= countLayers+ 1
        
    if g_layerlimit > 0 then
    
      if countLayers >= 
          g_layerlimit-1 then
        g_isToStopProbing= true
      end
      
      if countLayers>= g_layerlimit then
        keepGoing = false
      end
      
    end

  end

  -- comes back
  om.moveToPlace( 0, 0, 0 )
  dr:bearTo(dr.FORE)

end
 
om.main({...})
