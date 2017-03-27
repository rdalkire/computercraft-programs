--[[ 
Mines a contiguous aggregation of
resource blocks. Meant for trees or 
veins of ore.
1  Place the turtle so it faces the 
   material you want.
2  Refuel the turtle if applicable.
3  Run this script.  
3a Note, if you want it to dig *all* 
   blocks around any matching one, to 
   give the spaces a neater 
   appearance, use 'a' as an argument.
   For example, if the script is 
   called vMiner: 
   vMiner a
3b Even neater but using more time 
   and more fuel: To dig out the whole
   rectangular prism surrounding the 
   vein, use 'r' argument:
   vMiner r
4  NOTE: Dynamically pulls dependencies
   if not present, so HTTP must be 
   available.

Copyright (c) 2015 - 2016
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

-- TODO remember to update D_BASE
--- Base URL for dependencies
local D_BASE = "https://".. 
    "raw.githubusercontent.com/".. 
    "rdalkire/"..
    "computercraft-programs/".. 
    "dalkire-obsidian2/turtleApps/src/"

local ITM_REDSTONE="minecraft:redstone"
local SBSTRNG_REDSTONE_ORE=
    "redstone_ore"

local lf = loadfile( "mockTurtle.lua")
if lf ~= nil then   lf()
  lf= loadfile("mockMiscellaneous.lua")
  lf()
end
local t = turtle

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

local veinMiner = {}
local vm = veinMiner

--- For estimating fuel need
veinMiner.MOVESPERCUBE = 15

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
  {0, 1,-1}, {0, -1,-1}, {-1,0,-1},
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

--- Count of blocks that have been
-- marked as inspected
veinMiner.inspectedCount= 0

--- Count of inspections skipped due
-- to logic with the Check function
-- (when the turtle was right next to
-- it)
veinMiner.inspectedSkipped= 0

--- Count of times that coordinates
-- to goLookAt were actually for the
-- robot's own location
veinMiner.inspectSelfAvoidance = 0

--- If true, then the miner is supposed
-- to *dig* all the blocks from around
-- the target block, even the ones that
-- don't match the target blocks.
veinMiner.isAll = false

--- true if target block is redstone
-- ore, whether lit or not
veinMiner.isRedstone = false

--- Count of goLookAt calls skipped due
-- to logic within inspectACube,
-- therefore avoiding extra movements
veinMiner.goLookSkipped= 0

--- Records a location as having been
-- inspected
veinMiner.setInspected=function(x,y,z)
  vm.inspected[
      string.format("%d,%d,%d",x,y,z)]= 
      true
  vm.inspectedCount=vm.inspectedCount+1 
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
  local cubeCount= 
      table.maxn(vm.cubeStack)

  if cubeCount== 0 then
    isExplored = true
    print("Vein is explored")
  end
  
  return isExplored
end

--- Message and solution for fuel
problemWithFuel = {}
problemWithFuel.needMin= 0
problemWithFuel.getMessage= function()
  return string.format(
          "Please place fuel into "..
          "turtle's inventory & be "..
          "generous. At very "..
          "minimum, %d units.",
          problemWithFuel.needMin )
end

--- To be called if user puts fuel into
-- selected slot and indicates they
-- want to continue
problemWithFuel.callback = function()
  
  local slt= 1
  local isRefueled= false
  while slt<= 16 and not isRefueled do
    t.select(slt)
    isRefueled= t.refuel()
    slt= slt+ 1
  end

  return isRefueled

end

--- Comes back to starting (home)
-- position, requests action from user,
-- and if applicable, goes back to
-- where it left off.
-- @param whatsTheMatter with message
-- and callback
-- @return true if it could continue
veinMiner.comeHomeWaitAndGoBack=
    function( whatsTheMatter )
    
  local isToContinue = false
  
  local returnPlace = whatsTheMatter.
      returnPlace
  
  if returnPlace== nil then
    returnPlace= Locus.new(
        dr.place.x, dr.place.y,
        dr.place.z)
  end
  
  vm.exploreTo( Locus.new(0,0,0) )
  
  term.clear()
  print( whatsTheMatter.getMessage() )
  print( "Then press c to continue "..
    "or any other key to quit." )

  local event, key= os.pullEvent("key")
  if key == keys.c and
      whatsTheMatter.callback() then

    isToContinue = true
    
    vm.exploreTo(returnPlace)
  end

  return isToContinue
end

--- If there's enough fuel to explore
-- one last cube and move back to the
-- original place.
veinMiner.isFuelOK4Cube = function()

  local isOK = false
  local fuel = t.getFuelLevel()
  local fuelNeed= 0
  if fuel == "unlimited" then
    isOK = true
  else
    fuelNeed = 
        veinMiner.previousDistance +
        dr.howFarFromHome() +
        vm.MOVESPERCUBE
    if fuel > fuelNeed then
      isOK = true
    else
      print("Fuel too low: ".. fuel )
    end
  end
  
  -- try to get more fuel from user
  if not isOK then
    -- more fuel for getting fuel
    fuelNeed= fuelNeed+ dr.
        howFarFromHome()
        
    problemWithFuel.needMin= fuelNeed
    
    isOK= vm.comeHomeWaitAndGoBack(
        problemWithFuel )
  end
  
  return isOK
end

--- See's if there's enough fuel to get
-- to the destination then get home
-- @param x, y, z coords for dstnation
-- @return true if fuel OK or unlimited
veinMiner.isFuelOK4Dest= 
    function(x, y, z) 
  local isOK = false
  local fuel = t.getFuelLevel()
  local fuelNeed= 0
  
  if fuel == "unlimited" then
    isOK = true
  else
    local destToHome = math.abs(x)+
        math.abs(y)+ math.abs(z)
    fuelNeed =
        dr.howFarFrom(x,y,z)+
        destToHome+ vm.previousDistance
    if fuel >= fuelNeed then
      isOK = true
    else
      print("Not enough fuel:".. fuel)
    end
  end
  
  -- try to get more fuel from user
  if not isOK then
    -- more fuel for getting fuel
    fuelNeed= fuelNeed+ dr.
        howFarFromHome()
        
    problemWithFuel.needMin= fuelNeed
    
    isOK= vm.comeHomeWaitAndGoBack(
        problemWithFuel )
  end
  
  return isOK
end

--- Determines whether given item
-- is what you're looking for
-- @param name of item you're checking
-- @return true if it matches.  If 
-- isRedStone, then the match will 
-- succeed for redstone ore, lit red-
-- stone ore, or simple redstone.
veinMiner.isTargetMatch= 
    function(itmName)

  local isMatch= false
  
  if vm.isRedstone then
    
    if string.find( itmName, 
        SBSTRNG_REDSTONE_ORE, 11, 
        true ) or 
        itmName== ITM_REDSTONE then
      isMatch= true
    end
    
  elseif itmName == 
      vm.targetBlockName then
    isMatch = true 
  end
  
  return isMatch
end

--- If the target has not already been 
-- inspected it gets checked here.
-- If so it gets added to the inspected
-- array, to avoid redundancy.
-- If inspection shows block is wanted,
-- its location gets added to the 
-- cubeStack
-- @param way is must be dr.FORE, 
-- dr.STARBOARD, dr.FORE, dr.AFT
-- dr.AHEAD, dr.UP or dr.DOWN
-- @return true if target block matches
-- what was wanted.
veinMiner.check= function(way)
  local isWanted = false

  local ix = 0
  local iy = 0
  local iz = 0
  ix, iy, iz= dr.getTargetCoords(way)
  
  way = dr.correctHeading(way)
  
  -- If it still needs to be inspected,
  if vm.isInspected(ix,iy,iz) then
    vm.inspectedSkipped = 
        vm.inspectedSkipped + 1
  else
    local ok, item
    ok, item= dr.inspect(way)
    
    if ok then
      if vm.isTargetMatch( 
          item.name ) then

        isWanted = true
        local locus= Locus.new( ix, 
            iy, iz)
        table.insert( vm.cubeStack, 
            locus)
      end -- match
    end -- ok
    
    -- adds to the inspected array.
    vm.setInspected(ix, iy, iz )
  end

  return isWanted
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
  
  way = dr.correctHeading(way)
  
  local isAble, whynot
  
  for i = 1, moves do
    isAble, whynot = dr.move(way)
    
    -- if cannot, because obstructed
    if not isAble then
    
      if whynot=="Movement obstructed"
          then
        vm.check( way )
        isAble, whynot = dr.dig( way )
        isAble, whynot= dr.move( way )
      else
        print( "Stuck. ".. whynot )
      end
      
    end
    
  end -- end moves loop
  
  return isAble, whynot
end

--- Moves starboard or port 
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
    if vm.check(direction) or 
        vm.isAll then
      dr.dig(direction)
    end
  else -- Coords were turtle's place
    vm.inspectSelfAvoidance= 
        vm.inspectSelfAvoidance + 1
    vm.setInspected(x,y,z)
  end
  
end

--- Pulls a location from the stack,
-- inspects it surrounding blocks. Each
-- matching location gets added to the
-- stack.
veinMiner.inspectACube= function()
  
  -- Pops one
  local cube=table.remove(vm.cubeStack)
  
  -- shorthand
  local cis= vm.cubeInspectionSequence
  
  -- For each surrounding locus sl
  local maxOfSequence = table.maxn( 
      vm.cubeInspectionSequence ) 
  for sl= 1, maxOfSequence do
    local x= cube.x + cis[sl][1]
    local y= cube.y + cis[sl][2]
    local z= cube.z + cis[sl][3]
    -- If not already inspected
    if vm.isInspected(x,y,z) then
      vm.inspectedSkipped = 
          vm.inspectedSkipped + 1
      vm.goLookSkipped = 
          vm.goLookSkipped + 1
    else
      vm.goLookAt( x, y, z )
    end -- if not inspected
  end
end

--- Sees if there's enough space in
-- the inventory for another cube
-- of target material
veinMiner.isInvtrySpaceAvail=function()
  
  -- TODO clear the inventory if there
  -- isn't enough room.  go back to 
  -- start and dump to chest, or get
  -- user to clear it
  
  local isAvail = false
  local frSpace = 0
  for i = 1, 16 do
    local itmCount = t.getItemCount(i)
    
    if itmCount == 0 then
      frSpace= frSpace+ 64
    else
      local slName= 
          t.getItemDetail(i).name

      if vm.isTargetMatch( slName ) then
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

--- Digs out the remaining blocks
-- between the minimum, maximum 
-- coordinates so far
veinMiner.clearRectangle= function()

  local fulOK = true
  local tx = dr.placeMIN.x
  while tx<= dr.placeMAX.x and fulOK do
    local ty = dr.placeMIN.y
    while ty<= dr.placeMAX.y and 
        fulOK do
      local tz = dr.placeMIN.z
      while tz<= dr.placeMAX.z and
          fulOK do
        
        if not vm.isInspected(tx,ty,tz) 
            then
          fulOK= vm.isFuelOK4Dest(
              tx,ty,tz )
          if fulOK then
            vm.exploreTo(
                Locus.new(tx, ty, tz))
          end
        end
        
        tz = tz + 1 
      end
      ty = ty + 1
    end
    tx = tx + 1
  end
  
end

--- The main function: Inspects the 
-- block in front of it and sets its
-- name of that as the target material,
-- then mines for that until the vein
-- has been explored, the fuel is gone
-- or there isn't any more room.
veinMiner.mine= function( args )

  -- TODO normalize options usage with
  -- getopt library

  local isRectangle = false
  local isArgOK = true
  if table.getn( args ) > 0 then
    if args[1] == "a" then
      vm.isAll = true
    elseif args[1] == "r" then
      vm.isAll = true
      isRectangle = true
    else
      print( "Unknown argument: \"" ..
        args[1] .. "\". \n"..
        "Acceptable arguments are "..
        "a or r.  \n"..
        "Edit script for details." )
      isArgOK = false
    end
  end
  
  local isBlockOK = false
  local block = {}
  
  isBlockOK, block = 
      dr.inspect( dr.AHEAD )
  
  if isBlockOK and isArgOK then
    
    veinMiner.targetBlockName = 
        block.name
    
    if string.find(block.name, 
        SBSTRNG_REDSTONE_ORE, 11, 
        true) then
      vm.isRedstone = true
    end
    
    print("target block: ".. 
        block.name)
    
    vm.check( dr.AHEAD )
    
    while vm.isFuelOK4Cube() and
        vm.isInvtrySpaceAvail() and 
        (not vm.isVeinExplored()) do
      vm.inspectACube()
    end
    
    if isRectangle then
      vm.clearRectangle()
    end
    
    -- Comes back and faces forward
    vm.exploreTo( Locus.new(0,0,0) )
    dr.bearTo( dr.FORE )
    
    print( "inspected count: ".. 
        vm.inspectedCount )
    print( "inspections skipped: "..
        vm.inspectedSkipped )
    print( "goLookAt calls skipped: ".. 
        vm.goLookSkipped )
    print( "inspect-self avoidance: "..
        vm.inspectSelfAvoidance )
    
    -- Possibly more found on way back
    -- If so, report it.
    local cubesYet= 
        table.maxn(vm.cubeStack)
    if cubesYet > 0 then
      print( "There are still ".. 
          cubesYet.. 
          " cubes to be explored." )
    end
  elseif not isBlockOK then
    print( "To start, there must \n"..
        "be a block of interest \n"..
        "in front of the turtle." )
  end
end

vm.mine({...})

return veinMiner
