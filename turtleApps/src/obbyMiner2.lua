--[[ Obsidian Miner 2

Copyright (c) 2016
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

local onlyOneLayer = false

local getopt= require "getopt"

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

---
-- Moves to right above lava or solid 
-- block
-- @param isFromStart indicates whether
-- this is from main's starting place,
-- @return false if it wasn't able to
-- get to the start due to fuel 
-- constraints or whatever
local function getToIt( isFromStart )
  -- TODO implement getToIt()
  return false
end

local function isFuelOKForSquare()
  -- TODO implement isFuelOKForSquare()
  return false
end

local function isInventorySpaceAvail()
  -- TODO isInventorySpaceAvail()
  return false
end

local function isLayerFinished()
  -- TODO implement isLayerFinished()
  return false
end

---
-- @return true if there was any obby
-- or cobble to mine
local function mineASquare()

  local isProductive = false
  -- TODO implement mineASquare()
  -- TODO Probe lower, until a lower 
  -- lava layer is found
  
  local places= {
    {0,0}, {0,1}, {1,1}, {1,0}, {1,-1},
    {0,-1}, {-1,-1}, {-1,0}, {-1,1}
  }
  
  local square= table.remove(
      squareStack )
  
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
