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

-- The kind of block it's looking for
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

-- Array of locations which have been
-- inspected.
veinMiner.inspected = {}

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

-- If the target has not already been 
-- inspected it gets checked here.
-- If so it gets added to the inspected
-- array, to avoid redundancy.
-- If inspection shows block is wanted,
-- its location gets added to the 
-- cubeStack
-- @param way is dr.AHEAD, dr.UP or
-- dr.DOWN
veinMiner.check= function(way)
  local isWanted = false
  -- (It checks. before inspecting,
  -- it sees that it hasn't already
  -- been inspected.
--  local iTarget= Locus.new( dr.place.x,
--      dr.place.y, dr.place.z )
  local ix = dr.place.x
  local iy = dr.place.y
  local iz = dr.place.z
  if way== dr.AHEAD then
    if dr.heading== dr.AFT then
      iz= iz - 1
    elseif dr.heading== dr.FORE then
      iz= iz + 1
    elseif dr.heading== dr.PORT then
      ix= ix- 1
    else
      ix= ix+ 1
    end
  elseif way== dr.UP then
    iy= iy + 1
  elseif way== dr.DOWN then
    iy= iy - 1
  end
  
  -- If it still needs inspecting,
  if vm.inspected[ix][iy][iz]== nill then
    local item
    if way== dr.AHEAD then
      item= t.inspect()
    elseif way== dr.UP then
      item= t.inspectUp()
    else
      item= t.inspectDown()
    end
    
    if item.name== vm.targetBlockName then
      isWanted = true
      local locus= Locus.new(ix,iy,iz)
      table.insert(vm.cubeStack, locus)
    end
    
    -- adds to the inspected array.
    vm.inspected[ix][iy][iz]= isWanted
  end

  return isWanted
end

-- Moves, checks, pushes to stack
-- when applicable.
-- @param way is either dr.AHEAD, dr.UP 
-- or dr.DOWN where dr is deadReckoner
-- @param moves
veinMiner.explore= function(way, moves)
  -- TODO finish explore()
  
  for i = 1, moves do
    local isAble, whynot
    isAble, whynot = dr.move(way)
    
    -- if cannot, because obstructed
    if not isAble then
      if whynot=="Movement obstructed"
          then
        -- Check for match.
        vm.checks( way )
        -- TODO dig
        -- move to that
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
-- @param dest a target location on
-- the same x/z plane
veinMiner.exploreToX= function( dest )

  local diff = dest.x - dr.place.x
  local moves = math.abs(diff)
  if diff > 0 then
    dr.bearTo(dr.STARBOARD)
  elseif diff < 0 then
    dr.bearTo(dr.PORT)
  end
  
  vm.explore( dr.AHEAD, moves)
  
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
  vm.exploreTo( cube )
  
  -- For each surrounding locus
    -- If not already inspected
      -- Inspect it, moving if needed
      -- (push matching loci)
  
end

veinMiner.mine= function()
  local isOK = false
  local block = {}
  
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
      "in front of the turtle." )
  end
end

return veinMiner