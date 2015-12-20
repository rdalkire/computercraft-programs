
local function assertEquals( A, B)
  if A == B then
    print("OK")
  else
    print("FAIL")
  end
end

local dr = require "deadReckoner"
local loc= Locus.new(0,0,0)

loc.x = 1
print( "loc.x= ".. loc.x )

dr.place.x= 1
dr.place.y= 2
dr.place.z= 3
print("howFarFromHome()")
assertEquals(6,dr.howFarFromHome())

-- vMiner = require "veinMiner"
