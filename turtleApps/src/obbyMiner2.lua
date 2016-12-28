--[[ Obsidian Miner 2

Copyright (c) 2016
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

local onlyOneLayer = false

-- TODO remember to update D_BASE
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

ensureDep("deadReckoner.lua", "1.1" )
local dr = deadReckoner

ensureDep("getopt.lua", "2.0" )

local lf = loadfile( "mockTurtle.lua")
if lf ~= nil then lf() end
local t = turtle

--- A collection of squares, which are
-- 9x9 areas, each defined by the 
-- relative location of its central 
-- position
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
---
-- Moves to right above lava, obby or
-- cobble
-- @param isFromStart indicates whether
-- this is from main's starting place,
-- @return false if it wasn't able to
-- get to the start due to fuel 
-- constraints or whatever
local function getToIt( isFromStart )
  -- TODO implement getToIt()
  
  -- TODO Once there, add coords to the 
  -- squareStack
  
  return false
end

--- In case of a problem that the user
-- could solve, such as needing more
-- fuel or more space in the inventory
local WhatsTheMatter = {}
--- a message for user ("clear 
-- inventory" or "put fuel in selected 
-- slot")
WhatsTheMatter.message = "-"
--- callback function [refuel() or 
-- something, or a do-nothing function]
WhatsTheMatter.callback = nil

--- Comes back to starting (home) 
-- position, requests action from user,
-- and if applicable, goes back to 
-- where it left off.
-- @param whatsTheMatter with message
-- and callback
-- @return true if it could continue
local function comeHomeWaitAndGoBack( 
    whatsTheMatter )
  local isToContinue = false
  -- TODO code comeHomeWaitAndGoBack()
  
  return isToContinue
end

local function isFuelOKForSquare()
  -- TODO implement isFuelOKForSquare()
  -- use comeHomeWaitAndGoBack() if 
  -- applicable
  return false
end

local function isInventorySpaceAvail()
  -- TODO isInventorySpaceAvail()
  -- use comeHomeWaitAndGoBack() if 
  -- applicable
  return false
end

local function isLayerFinished()
  -- TODO implement isLayerFinished()
  return false
end

--- Determines if a place has already
-- been inspected
local function isChecked(x, z)
  -- TODO implement isChecked
end

--- Moves in the given direction,
-- digging as needed
-- @param way is either dr.AHEAD, 
-- STARBOARD, PORT, FORE, or AFT 
-- dr.UP, or dr.DOWN where dr is 
-- deadReckoner
-- @param moves
-- @return isAble true if it really was
--    able to move and dig.
-- @return whyNot if isAble, nil. Else,
--    reason why not.
local function moveVector(way, moves)
  
  way = dr.correctHeading(way, true)
  
  local isAble, whynot
  -- TODO finish moveVector()
  
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
local function moveDimension(destCrd,
    thisCrd, posWay, negWay )
  
  local diff = destCrd - thisCrd
  local moves = math.abs(diff)
  local way = 0
  if diff > 0 then
    way = posWay
  elseif diff < 0 then
    way = negWay
  end
  
  return moveVector( way, moves)
end


--- Moves to the destination, digging
-- on the way as needed
-- @param coords relative to
--    where bot started at main()
-- @return isAble true if it really was
--    able to move and dig.
-- @return whyNot if isAble, nil. Else,
--    reason why not.
local function moveToPlace(x, y, z)
    
  -- X
  local isAble, whynot = moveDimension( 
      x, dr.place.x, 
      dr.STARBOARD, dr.PORT)
  
  -- Y
  if isAble then
    isAble, whynot = moveDimension( 
        y, dr.place.y, 
        dr.UP, dr.DOWN)
  end
  
  -- Z
  if isAble then
    isAble, whynot = moveDimension( 
        z, dr.place.z, 
        dr.FORE, dr.AFT )
  end
  
  return isAble, whynot
  
end

---
-- @return true if there was any obby
-- or cobble to mine
local function mineASquare()

  local isProductive = false
  -- TODO implement mineASquare()
  -- TODO Probe lower, until a lower 
  -- lava layer is found. If so, store
  -- location for next layer iteration
  
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
    if not isChecked(x, z) then
      -- TODO go there. Use moveTo
      -- TODO check
    end
  end
  
  return isProductive
  
end

---
-- Mines a layer of lava, removing all
-- obsidian and cobblestone, as long 
-- as there's enough fuel and inventory
-- space
-- @return true if there was any 
-- obsidian or cobblestone in the 
-- layer
local function mineALayer()
  
  local isLayerProductive = false
  
  while isFuelOKForSquare() and
        isInventorySpaceAvail() and
        (not isLayerFinished() ) do
        
    if mineASquare() then
      isLayerProductive = true
    end
    
  end
  
  return isLayerProductive 
end

local function comeBack()
  -- TODO implement comeBack()
end

local function main( args )
  
  -- From args, learns: get it all
  -- or just one layer?
  initOptions(args)
  
  -- Get down to the lava/cobble/obby
  local keepGoing= getToIt()
  
  -- Mine the layer(s) of lava
  while keepGoing do
    keepGoing= mineALayer()
    if onlyOneLayer then
      keepGoing = false
    end
  end
  
  comeBack()
  
end

main({...})
