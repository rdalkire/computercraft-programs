--[[
Copyright (c) 2016
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

-- TODO RELEASE IN-LINE deadReckoner
local dr = require "deadReckoner"
-- END RELEASE IN-LINE deadReckoner

-- TODO RELEASE use native turtle
local t = require "mockTurtle"

local WTR_BKT="minecraft:water_bucket"

local g_enoughFuel = false

--- processes a column (front-to-back 
-- path)
-- @return true if lava found
local function processAColumn()
  -- TODO finish processAColumn()
end

--- Processes a layer of lava
-- @return true if lava was found
local function processAlayer()
  local lavaFound = false
  
  -- TODO finish processAlayer()
  local columnsDone = 0
  local isInBounds = true
  while g_enoughFuel and isInBounds do
    if processAColumn() then
      lavaFound = true
    end
    
    -- TODO move to next column
    
    -- TODO go to end-bound, face-to
    
  end
  
  return lavaFound
end

local function main( targs )
  -- TODO Starting left, go right
  -- go back & forth like you're mowing

  -- TODO check prereqs: water bucket & 
  -- fuel
  
  local theresLava = true
  while g_enoughFuel and theresLava do
    theresLava = processAlayer()
    -- TODO Get to the next layer
  end -- layers loop


  -- Boundaries are anything except
  -- obby, cobble or lava
  
  -- Where it's nothing (air)
    -- move along
  -- where obby or cobble are below
    -- dig
  -- Where it's lava
    -- dig up, move up, splash water, 
    -- move down, dig
  -- Anything else
    -- boundary is reached
  
  -- end of the "mowing" one layer
  
  -- Go down, repeat lower layers 
  -- until out of lava or low on fuel
    
    
    
  
end

local tArgs = {...}
main(tArgs)
