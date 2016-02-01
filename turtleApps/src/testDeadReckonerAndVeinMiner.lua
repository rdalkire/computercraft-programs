local dr = require "deadReckoner"
local loc= Locus.new(0,0,0)

local function testBearTo()
  dr.bearTo(dr.PORT)
  assert(dr.heading==dr.PORT, 
      "should be PORT now; instead"..
      " it's ".. dr.WAYS[dr.heading] )
  dr.bearTo(dr.FORE)
  assert(dr.heading==dr.FORE, 
      "should be FORE; instead"..
      " it's ".. dr.WAYS[dr.heading])
  print("heading: ".. 
      dr.WAYS[dr.heading] )
end
-- testBearTo()

local function testLocus()
  loc.x = 1
  assert( loc.x==1, "Locus.x 1" )
end
local function testHowFarFromHome()
  dr.place.x= 1
  dr.place.y= 2
  dr.place.z= 3
  assert(6== dr.howFarFromHome(), 
      "howFarFromHome() FAILED")
end
local function testMove()
  dr.place.x= 0
  dr.place.y= 0
  dr.place.z= 0
  dr.move(dr.AHEAD)
  assert(dr.place.z==1, "z should be 1")
  dr.bearTo( dr.PORT )
  dr.move(dr.AHEAD)
  assert(dr.place.x==-1,"x should be -1")
end
local function testFurthestWay()
  dr.place.x= 0
  dr.place.y= 0
  dr.place.z= 0
  loc.x= -50
  loc.y= 25
  loc.z= 10
  local way = 0
  local dist = 0
  way, dist= dr.furthestWay(loc)
  assert( way==dr.PORT, 
      "furthestWay way is wrong" )
  assert( dist==50, 
      "furthestWay dist is wrong" )
end

local vm = require "veinMiner"
local function testIsVeinExplored()
  
  table.insert(vm.cubeStack, loc )
  assert( not vm.isVeinExplored(), 
      "isVeinExplored should be false")
      
  local l=table.remove(vm.cubeStack)
  
  assert( vm.isVeinExplored(), 
      "isVeinExplored should be true")
  
end
local function testIsFuelOK()
  assert( vm.isFuelOK(), 
      "fuel should be OK" )
  vm.previousDistance = 145
  assert( not vm.isFuelOK(), 
      "fuel should *not* be OK" )
end
local function testCheck()
  vm.targetBlockName="minecraft:log"
  assert(vm.check(dr.AHEAD),"AHEAD")
  assert(vm.check(dr.DOWN),"DOWN")
  assert(vm.check(dr.UP),"UP")
  assert(table.maxn(vm.cubeStack)==3,
      "Should be 3 cubes in stack." )
  vm.explore(dr.STARBOARD,1)
  vm.targetBlockName="somethingElse"
  assert(not vm.check(dr.AHEAD),"AHEAD")
  assert(not vm.check(dr.DOWN),"DOWN")
  assert(not vm.check(dr.UP),"UP")
  assert(table.maxn(vm.cubeStack)==3,
      "Should be 3 cubes in stack." )
  
end
local function testInspected()
  vm.setInspected(1,-20,3)
  vm.setInspected(100,-20,3)
  assert( vm.isInspected(1,-20,3), 
      "1,-2,3 should be inspected." )
  assert( not vm.isInspected(1,2,3), 
      "1,2,3 should not be inspected.")
end
local function testDig()
  assert( vm.dig(dr.AHEAD), "AHEAD" )
  assert( vm.dig(dr.UP), "UP" )
  assert( vm.dig(dr.DOWN), "DOWN" )
end
local function testExplore()
  vm.explore( dr.FORE, 2 )
  assert(dr.place.z==2,"z should be 2")
end
local function testXYandZ()
  local dest= Locus.new(10,20,30)
  vm.exploreTo(dest)
end
local function testGolookAt()
  vm.goLookAt(-1,1,1)
  assert(dr.place.x==-1, "X no good")
  assert(dr.place.y==0,  "Y no good")
  assert(dr.place.z==1,  "Z no good")
end
local function testInspectACube()
  table.insert( vm.cubeStack, loc )
  vm.inspectACube()
  local count=vm.inspectedCount
  assert(count==26,
      "inspected count: ".. count )
end
local function testIsInvtrySpaceAvail()
  local isOK = vm.isInvtrySpaceAvail()
  assert(isOK,"should've been enough")
end
local function testMine()
  local args = { "-r" }
  vm.mine( args )
--  assert( not vm.isFuelOK4Cube(), 
--      "fuel should be low" )
end
testMine()
