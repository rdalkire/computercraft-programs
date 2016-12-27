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
