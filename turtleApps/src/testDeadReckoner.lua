local drFile = require "deadReckoner"
local dr = deadReckoner.new()
local loc= Locus.new(0,0,0)

local function testBearTo()
  print("testBearTo()...")
  dr:bearTo(dr.PORT)
  assert(dr.heading==dr.PORT, 
      "should be PORT now; instead"..
      " it's ".. dr.WAYS[dr.heading] )
  dr:bearTo(dr.FORE)
  assert(dr.heading==dr.FORE, 
      "should be FORE; instead"..
      " it's ".. dr.WAYS[dr.heading])
  print("heading: ".. 
      dr.WAYS[dr.heading] )
end
testBearTo()

local function testLocus()
  print("testLocus()...")
  loc.x = 1
  assert( loc.x==1, "Locus.x 1" )
end
testLocus()

local function testHowFarFromHome()
  print("testHowFarFromHome()...")
  dr.place.x= 1
  dr.place.y= 2
  dr.place.z= 3
  assert(6== dr:howFarFromHome(), 
      "howFarFromHome() FAILED")
end
testHowFarFromHome()

local function testMove()
  print("testMove()...")
  dr.place.x= 0
  dr.place.y= 0
  dr.place.z= 0
  dr:move(dr.AHEAD)
  assert(dr.place.z==1, "z should be 1")
  dr:bearTo( dr.PORT )
  dr:move(dr.AHEAD)
  assert(dr.place.x==-1,"x should be -1")
end
testMove()

local function testFurthestWay()
  print "testFurthestWay()..."
  dr.place.x= 0
  dr.place.y= 0
  dr.place.z= 0
  loc.x= -50
  loc.y= 25
  loc.z= 10
  local way = 0
  local dist = 0
  way, dist= dr:furthestWay(loc)
  assert( way==dr.PORT, 
      "furthestWay way is wrong" )
  assert( dist==50, 
      "furthestWay dist is wrong" )
end
testFurthestWay()
