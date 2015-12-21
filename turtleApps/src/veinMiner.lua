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

--- If part of larger task, from caller
veinMiner.previousDistance = 0

--- The kind of block it's looking for
veinMiner.targetBlockName = ""

--- Defines cube's surrounding loci, in
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

--- Collection of "cubes", which are
-- spaces to explore, defined by 
-- central locations.
veinMiner.cubeStack = {}

--- Array of locations which have been
-- inspected.
veinMiner.inspected = {}

veinMiner.setInspected=function(x,y,z)
  vm.inspected[
      string.format("%d,%d,%d",x,y,z)]= 
      true
end

veinMiner.isInspected=function(x,y,z)
  local indx= string.format(
      "%d,%d,%d", x, y, z )
  local val= vm.inspected[indx]
  local isInspctd = not ( val == nil )
  return isInspctd
end

--- Determines whether the mining/
-- felling task is complete.
veinMiner.isVeinExplored= function()
  local isExplored = false

  if table.maxn(vm.cubeStack)== 0 then
    isExplored = true
  end
  
  return isExplored
end

--- If there's enough fuel to explore
-- one last cube and move back to the
-- original place.
veinMiner.isFuelOK = function()
  local isOK = false
  local fuel = t.getFuelLevel()
  if fuel == "unlimited" then
    isOK = true
  else
    local fuelNeed = 
        veinMiner.previousDistance +
        dr.howFarFromHome() +
        vm.MOVESPERCUBE
    isOK= fuel > fuelNeed
  end
  return isOK
end

--- If the target has not already been 
-- inspected it gets checked here.
-- If so it gets added to the inspected
-- array, to avoid redundancy.
-- If inspection shows block is wanted,
-- its location gets added to the 
-- cubeStack
-- @param way is dr.AHEAD, dr.UP or
-- dr.DOWN
-- @return true if target block matches
-- what was wanted.
veinMiner.check= function(way)
  local isWanted = false
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
  
  -- If it still needs to be inspected,
  if not vm.isInspected(ix,iy,iz) then
    local ok, item
    if way== dr.AHEAD then
      ok, item= t.inspect()
    elseif way== dr.UP then
      ok, item= t.inspectUp()
    else
      ok, item= t.inspectDown()
    end
    
    if ok then
      if item.name==vm.targetBlockName 
          then
        isWanted = true
        local locus= Locus.new(ix,iy,iz)
        table.insert(vm.cubeStack, locus)
      end -- match
    end -- ok
    
    -- adds to the inspected array.
    vm.setInspected(ix, iy, iz )
  end

  return isWanted
end

--- Digs.
-- @param way must be dr.AHEAD, dr.UP
-- or dr.DOWN
-- @return isAble true if it really was able
-- to dig
-- @return whyNot if isAble, nil. Else,
-- reason why not.
veinMiner.dig= function( way )
  local dug= false
  local whyNot
  if way== dr.AHEAD then
    dug, whyNot= t.dig()
  elseif way== dr.UP then
    dug, whyNot= t.digUp()
  elseif way== dr.DOWN then
    dug, whyNot= t.digDown()
  end
  return dug, whyNot
end

--- Moves, checks, and pushes to stack
-- when applicable.
-- @param way is either dr.AHEAD, 
-- STARBOARD, PORT, FORE, or AFT 
-- dr.UP, or dr.DOWN where dr is 
-- deadReckoner
-- @param moves
-- @return isAble true if it really was
-- able to move and dig.
-- @return whyNot if isAble, nil. Else,
-- reason why not.
veinMiner.explore= function(way, moves)
  
  -- If way is fore, starboard, aft or
  -- port, then bear to that direction
  if way < 4 then
    dr.bearTo( way )
    way = dr.AHEAD
  end
  
  local isAble, whynot
  
  for i = 1, moves do
    isAble, whynot = dr.move(way)
    
    -- if cannot, because obstructed
    if not isAble then
    
      if whynot=="Movement obstructed"
          then
        vm.checks( way )
        isAble, whynot = vm.dig( way )
        isAble, whynot= dr.move( way )
      else
        print( "Stuck. ".. whynot )
      end
      
    end
    
  end -- end moves loop
  
  return isAble, whynot
end

--- Moves starboard, port, fore or aft, 
-- depending on where dest is compared 
-- to the robot's current location.  
-- Inspects and/or breaks when needed.
-- @param dest a target location on
-- the same x/z plane
veinMiner.exploreToX= function( dest )

  local diff = dest.x - dr.place.x
  local moves = math.abs(diff)
  local way = 0
  if diff > 0 then
    way = dr.STARBOARD
  elseif diff < 0 then
    way = dr.PORT
  end
  
  vm.explore( way, moves)
  
end

--- Up or down
veinMiner.exploreToY= function( dest )

  local diff = dest.y - dr.place.y
  local moves = math.abs(diff)
  local way = 0
  if diff > 0 then
    way = dr.UP
  elseif diff < 0 then
    way = dr.DOWN
  end
  
  vm.explore( way, moves)
  
end

--- Fore or aft
veinMiner.exploreToZ= function( dest )
  local diff = dest.z - dr.place.z
  local moves = math.abs(diff)
  local way = 0
  if diff > 0 then
    way = dr.FORE
  elseif diff < 0 then
    way = dr.AFT
  end
  
  vm.explore( way, moves)
end

--- Moves to the location, inspecting,
-- pushing and breaking when needed
-- @param place is location relative
-- to turtle's original location
veinMiner.exploreTo= function( place )
  vm.exploreToX( place )
  vm.exploreToZ( place )
  vm.exploreToY( place )
end

--- Inspects block at the given 
-- coordinates, moving if needed.
-- Pushes matching loci via check()
-- Digs matching loci via dig()
veinMiner.goLookAt= function(x, y, z)
  
  local dest = {x, y, z}
  
  local diffs= {x- dr.place.x,
                y- dr.place.y,
                z- dr.place.z }

  -- count of non-zero dimensions
  local nzCount= 0
  for i = 1, 3 do
    if diffs[i] ~= 0 then
      nzCount= nzCount+ 1
    end
  end
  
  local direction = 0
  local dist = 0
  local dest = Locus.new(x,y,z)
  
  -- All three coordinates differ
  if nzCount > 2 then
    -- Explore the farthest way
    direction, dist= 
        dr.furthestWay(dest)
    vm.explore(direction, dist)    
  end
  
  -- Two or three coords were different
  if nzCount > 1 then
    -- Explore (what is now) the 
    -- farthest way
    direction, dist= 
        dr.furthestWay(dest)
    vm.explore(direction, dist)
  end
  
  -- Unless it's to inspect self
  if nzCount > 0 then
    -- Explore *Up To* dest, farthest
    direction, dist= 
        dr.furthestWay(dest)
    dist = dist - 1
    vm.explore(direction, dist)
    -- Check it
    if direction <= dr.PORT then
      direction= dr.AHEAD
    end
    if vm.check(direction) then
      vm.dig(direction)
    end
  end
  
end

--- Pulls a location from the stack,
-- inspects it surrounding blocks. Each
-- matching location gets added to the
-- stack.
veinMiner.inspectACube= function()
  
  -- Pops one
  local cube= table.remove(vm.cubeStack)
  
  -- Moves to the cube central locus
  vm.exploreTo( cube )
  
  -- shorthand
  local cis= vm.cubeInspectionSequence
  
  -- For each surrounding locus sl
  for sl= 1, table.maxn( 
      vm.cubeInspectionSequence ) do
    local x= cube.x + cis[sl][0]
    local y= cube.y + cis[sl][1]
    local z= cube.z + cis[sl][2]
    -- If not already inspected
    if not(vm.isInspected(x,y,z)) then
      vm.goLookAt( x, y, z )
    end -- if not inspected
  end
end

--- Sees if there's enough space in
-- the inventory for another cube
-- of target material
veinMiner.isInvtrySpaceAvail = function()
  
  local isAvail = false
  local frSpace = 0
  for i = 1, 16 do
    local itmCount = t.getItemCount(i)
    
    if itmCount == 0 then
      frSpace= frSpace+ 64
    else
      local slName= 
          t.getItemDetail(i).name
          
      if slName==vm.targetBlockName then
        frSpace= frSpace+ 64- itmCount
      end -- match
    end -- count zero-else
    
  end -- inventory loop
  
  -- Assuming a cube could be no more
  -- than 25 blocks, realistically
  if frSpace >= 25 then
    isAvail = true
  else
    print( "There might not be ".. 
    "enough inventory \nspace to ".. 
    "hold the target material" )
  end
  return isAvail
end

--- The main function: Inspects the 
-- block in front of it and sets its
-- name of that as the target material.
veinMiner.mine= function()
  local isOK = false
  local block = {}
  
  isOK, block = t.inspect()
  
  if isOK then
  
    veinMiner.targetBlockName = 
        block.name
    
    -- Includes place in the array of
    -- inspected places
    vm.setInspected(0, 0, 0)
    
    -- Start to work on a stack
    local cube = Locus.new(0, 0, 0)
    table.insert(vm.cubeStack, cube)
    while vm.isFuelOK() and
        vm.isInvtrySpaceAvail() and 
        (not vm.isVeinExplored()) do
      vm.inspectACube()
    end
    
    -- Comes back and faces forward
    vm.exploreTo( Locus.new(0,0,0) )
    dr.bearTo( dr.FORE )
    
    -- Possibly more found on way back
    -- If so, report it.
    local cubesYet= 
        table.maxn(vm.cubeStack)
    if table.maxn(cubesYet) > 0 then
      print( "There are still ".. 
          cubesYet.. 
          " cubes to be explored." )
    end
  else
    print( "To start, there must \n"..
      "be a block of interest \n"..
      "in front of the turtle." )
  end
end

return veinMiner