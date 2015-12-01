--[[ Mines a contiguous aggregation of
resource blocks.  Meant for trees or
veins of ore.

Copyright (c) 2015 
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]
local dr = require "deadReckoner"
local t = require "mockTurtle"

local veinMiner = {}
local vm = veinMiner

veinMiner.MOVESPERCUBE = 10

-- If part of larger task, from caller
veinMiner.previousDistance = 0
veinMiner.targetBlockName = ""

-- Defines cube's surrounding loci, in
  -- the order in which they are to
  -- be inspected.
veinMiner.cubeInspectionSequence = {
  {0, 1, 0}, {0, -1, 0}, {0, 0, 1},
  {0, 1, 1}, {0, -1, 1}, {1, 0, 1},
  {1, 1, 1}, {1, -1, 1}, {1, 0, 0},
  -- 10
  {1, 1, 0}, {1, -1, 0}, {1, 0,-1},
  {1, 1,-1}, {1, -1,-1}, {0, 0,-1},
  {0, 1,-1}, {0, -1,-1}, {-1,1,-1},
  -- 19
  {-1,1,-1}, {-1,-1,-1}, {-1,0, 0},
  {-1, 1,0}, {-1,-1, 0}, {-1,0, 1},
  {-1, 1,1}, {-1,-1, 1}
}

-- Collection of "cubes", which are
-- spaces to explore, defined by 
-- central locations.
veinMiner.cubeStack = {}

veinMiner.isVeinExplored= function()
  local isExplored = false

  if table.maxn(vm.cubeStack)== 0 then
    isExplored = true
  end
  
  return isExplored
end

veinMiner.isFuelOK = function()
  local isOK = false
  local fuel = t.getFuelLevel()
  if fuel == "unlimited" then
    isOK = true
  else
    local fuelNeed = 
        veinMiner.previousDistance +
        dr.howFarFromHome +
        vm.MOVESPERCUBE
  end
  return true
end



-- Moves, checks, pushes to stack
-- when applicable.
veinMiner.exploreAhead= function(moves)
  -- TODO change to explore(way), where
  -- way is dr.AHEAD, UP or DOWN
  
  for i = 1, moves do
    local isAble, whynot
    isAble, whynot = dr.moveAhead()
    
    -- if cannot, because obstructed
    if not isAble then
      if whynot=="Movement obstructed"
          then
        -- Check for match.  If good
        
        -- TODO use param instead
        if checks( dr.AHEAD ) then
          -- dig
          -- move forward
          -- add this location to stack
        -- else
          -- move forward
        end
      else
        print( "Stuck. ".. whynot )
      end
    end
    
  end -- end for loop
  -- TODO return success status
end

-- Moves starboard, port, fore or aft, 
-- depending on where dest is compared 
-- to the robot's current location.  
-- Inspects and/or breaks when needed.
veinMiner.exploreToX= function( dest )

  -- TODO implement exploreToX
  local diff = dest.x - dr.place.x
  local moves = math.abs(diff)
  if diff > 0 then
    dr.bearTo(dr.STARBOARD)
  elseif diff < 0 then
    dr.bearTo(dr.PORT)
  end
  
  vm.exploreAhead(moves)
  
end

-- Up or down
veinMiner.exploreToY= function( dest )
  -- TODO implement exploreToY
end

-- Fore or aft
veinMiner.exploreToZ= function( dest )
  -- TODO implement exploreToZ
end

-- Moves to the location, inspecting,
-- pushing and breaking when needed
-- @param place is location relative
-- to turtle's original location
veinMiner.exploreTo= function( place )
  vm.exploreToX( place )
  vm.exploreToZ( place )
  vm.exploreToY( place )
end

-- Pulls a location from the stack,
-- inspects it surrounding blocks. Each
-- matching location gets added to the
-- stack.
veinMiner.inspectACube= function()
  
  -- TODO implement inspectACube()...
  
  -- Pops one
  local cube= table.remove(vm.cubeStack)
  
  -- Moves to the cube central locus
  exploreTo( cube )
  
  -- For each surrounding locus
    -- If not already inspected
      -- Inspect it, moving if needed
      -- (push matching loci)
  
end

veinMiner.mine= function()
  local isOK = false
  local block = {}
  local isUp = false 
  local isDown = false
  
  -- TODO make it only for front, to
  -- avoid confusion
  
  isOK, block = t.inspect()
  if not isOK then
    isOK, block = t.inspectDown()
  end
  if not isOK then
    isOK, block = t.inspectUp()
  end
  
  if isOK then
  
    veinMiner.targetBlockName = 
        block.name
    
    local cube = Locus.new(0, 0, 0)
    
    table.insert(vm.cubeStack, cube)
    
    while vm.isFuelOK() and 
        not vm.isVeinExplored() do
      vm.inspectACube()
    end
  else
    print( "To start, there must \n"..
      "be a block of interest \n"..
      "in front, right beneath, or\n".. 
      "right above the turtle." )
  end
end

return veinMiner