local drFile = require "deadReckoner"
local dr = deadReckoner.new()
local loc= Locus.new(0,0,0)
require("mockMiscellaneous")
require("getopt")
require("fuelAndInventory")
local vm = require "veinMiner"

local function testIsVeinExplored()
  print("testIsVeinExplored()...")
  table.insert(vm.cubeStack, loc )
  assert( not vm.isVeinExplored(), 
      "isVeinExplored should be false")
      
  local l=table.remove(vm.cubeStack)
  
  assert( vm.isVeinExplored(), 
      "isVeinExplored should be true")
end
testIsVeinExplored()

local function testIsFuelOK4Cube()
  print("testIsFuelOK4Cube()...")
  assert( vm.isFuelOK4Cube(), 
      "fuel should be OK" )
  vm.previousDistance = 145
  assert( not vm.isFuelOK4Cube(), 
      "fuel should *not* be OK" )
end
testIsFuelOK4Cube()

local function testCheck()
  print("testCheck()...")
  vm.targetBlockName="minecraft:log"
  assert(vm.check(dr.AHEAD),"AHEAD")
  assert(not vm.check(dr.DOWN),"DOWN")
  assert(vm.check(dr.UP),"UP")
  assert(table.maxn(vm.cubeStack)==2,
      "Should be 2 cubes in stack." )
  vm.explore(dr.STARBOARD,1)
  vm.targetBlockName="somethingElse"
  assert(not 
      vm.check(dr.AHEAD),"AHEAD")
  assert(not vm.check(dr.DOWN),"DOWN")
  assert(not vm.check(dr.UP),"UP")
  assert(table.maxn(vm.cubeStack)==2,
      "Should be 2 cubes in stack." )  
end
testCheck()

local function testInspected()
  print("testInspected()...")
  vm.setInspected(1,-20,3)
  vm.setInspected(100,-20,3)
  assert( vm.isInspected(1,-20,3), 
      "1,-2,3 should be inspected." )
  assert( not vm.isInspected(1,2,3), 
      "1,2,3 should not be inspected.")
end
testInspected()

local function testDig()
  print("testDig()...")
  assert( dr:dig(dr.AHEAD), "AHEAD" )
  assert( dr:dig(dr.UP), "UP" )
  assert( dr:dig(dr.DOWN), "DOWN" )
end
testDig()

local function testExplore()
  print("testExplore()...")
  vm.explore( dr.FORE, 2 )
  assert(dr.place.z==2,"z should be 2")
end
testExplore()

local function testXYandZ()
  print("testXYandZ()...")
  turtle.refuel()
  local dest= Locus.new(10,20,30)
  vm.exploreTo(dest)
end
testXYandZ()

local function testGolookAt()
  print("testGolookAt()...")
  vm.goLookAt(-1,1,1)
  assert(dr.place.x== 0, "X no good")
  assert(dr.place.y== 1, "Y no good")
  assert(dr.place.z== 1, "Z no good")
end
testGolookAt()

local function testInspectACube()
  print("testInspectACube()...")
  table.insert( vm.cubeStack, loc )
  vm.inspectedCount = 0
  vm.inspectACube()
  local count=vm.inspectedCount
  print( "inspectedSkipped: ".. 
      vm.inspectedSkipped )
  assert(count==20,
      "inspected count: ".. count )
end
testInspectACube()

local function testIsInvtrySpaceAvail()
  print("testIsInvtrySpaceAvail()...")
  local isOK = vm.isInvtrySpaceAvail()
  assert(isOK,"should've been enough")
end
testIsInvtrySpaceAvail()

local function testMine()
  print("testMine()...")
  local args = { "-r" }
  vm.mine( args )
--  assert( not vm.isFuelOK4Cube(), 
--      "fuel should be low" )
end
testMine()
