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

local function main( targs )
  -- TODO go back & forth like mowing
  
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
  
  -- Go down, repeat lower layers until
  -- out of lava
  
end

local tArgs = {...}
main(tArgs)
