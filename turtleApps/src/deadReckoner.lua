--[[ NOTE: This is a component, *not* 
a stand-alone, runnable script.

Copyright (c) 2015 - 2016
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

--- To ensure this is the version
-- you're looking for
DEP_VERSION="1.1.1"

--- assigns fake/real turtle
local t
if turtle then
  t = turtle
else
  t = require "mockTurtle"
end

Locus = {}
Locus.__index = Locus
Locus.x = 0
Locus.y = 0
Locus.z = 0
--- A constructor which sets the 
-- current location
Locus.new= function( x, y, z )
  local self = setmetatable({}, Locus)
  self.x = x
  self.y = y
  self.z = z
  return self
end

deadReckoner = {}
local dr = deadReckoner

--- relative to turtle heading at start 
deadReckoner.FORE = 0
deadReckoner.STARBOARD = 1
deadReckoner.AFT = 2
deadReckoner.PORT = 3


deadReckoner.WAYS = {}
dr.WAYS[deadReckoner.FORE] = "FORE"
dr.WAYS[deadReckoner.STARBOARD]= 
    "STARBOARD"
dr.WAYS[deadReckoner.AFT] = "AFT"
dr.WAYS[deadReckoner.PORT] = "PORT"
  
deadReckoner.heading=deadReckoner.FORE

--- Current position relative to start
deadReckoner.place= Locus.new(0, 0, 0)

--- Maximum x, y, z relative to start,
-- located or dug
deadReckoner.placeMAX=Locus.new(0,0,0)

--- Minimum x, y, z relative to start,
-- located or dug
deadReckoner.placeMIN=Locus.new(0,0,0)

--- forward regardless of heading
deadReckoner.AHEAD = 4

deadReckoner.UP = 5
deadReckoner.DOWN = 6

--- again regardless of heading
deadReckoner.BACK = 7

--- Turns as needed to face the 
-- target direction indicated
-- @param target must be dr.FORE, 
-- dr.STARBOARD, dr.AFT, or dr.PORT
deadReckoner.bearTo= function(target)

  local trnsRght = 
      target - deadReckoner.heading
  
  local trns = math.abs( trnsRght )
  if trns ~= 0 then
    
    if trns== 3 then
      trns= 1
      trnsRght= trnsRght/-3
    end
    
    local i = 0
    while i < trns do
      if trnsRght >= 0 then
        t.turnRight()
      else
        t.turnLeft()
      end -- which way
      i = i + 1
    end -- turn loop
  end -- there were any turns
  
  deadReckoner.heading = target
end

--- If way is fore, starboard, aft or
-- port, then bear to that direction,
-- unless this is called for movement
-- purposes and turtle was facing the
-- opposite way to begin with.
-- @param way can any of the heading
-- constants: FORE, STARBOARD, AFT,
-- PORT, UP, DOWN or even AHEAD
-- @param [isForMovement] true if the 
-- caller is using this in order to 
-- move.
-- @return way is AHEAD if the param 
-- had been a horizontal direction 
-- (FORE, AFT, PORT, STARBOARD). 
-- Otherwise it's the same as the input
-- param. If isForMovement, and the
-- turtle is facing opposite way, then
-- this will return BACK
deadReckoner.correctHeading=
    function(way, isForMovement)
    
  if way < 4 then
    if isForMovement and 
        way ~= dr.heading and 
        (way - dr.heading) % 2== 0 then
      way = dr.BACK
    else
      dr.bearTo( way )
      way = dr.AHEAD
    end
  elseif way== dr.BACK and 
      not isForMovement then
    -- This means it's digging or 
    -- inspecting something behind, so
    -- it needs to turn around
    way = dr.heading + 2
    way = way % 4
    dr.bearTo(way)
    way = dr.AHEAD
  end
  
  return way
  
end

--- Adjusts placeMAX and placeMIN as
-- applicable.
deadReckoner.setMaxMin=function(x,y,z)

  if x > dr.placeMAX.x then
    dr.placeMAX.x = x
  elseif x < dr.placeMIN.x then
    dr.placeMIN.x = x
  end
  
  if y > dr.placeMAX.y then
    dr.placeMAX.y = y
  elseif y < dr.placeMIN.y then
    dr.placeMIN.y = y
  end
  
  if z > dr.placeMAX.z then
    dr.placeMAX.z = z
  elseif z < dr.placeMIN.z then
    dr.placeMIN.z = z
  end
  
end

--- Gets the coordinates of the block
-- currently next to the turtle,
-- depending on which way one would
-- look.
-- @param way must be deadReckoner's 
-- (dr's) AFT, FORE, PORT, STARBOARD,
-- UP, DOWN or AHEAD.
-- @return x, y, z coordinates of the 
-- adjacent block.
deadReckoner.getTargetCoords=
    function(way)
  
  local ix = dr.place.x
  local iy = dr.place.y
  local iz = dr.place.z
  
  if way == dr.AHEAD then
    way = dr.heading
  end
  
  if way== dr.AFT then
    iz= iz - 1
  elseif way== dr.FORE then
    iz= iz + 1
  elseif way== dr.PORT then
    ix= ix- 1
  elseif way== dr.STARBOARD then
    ix= ix+ 1
  elseif way== dr.UP then
    iy= iy + 1
  elseif way== dr.DOWN then
    iy= iy - 1
  end
  
  return ix, iy, iz
  
end


--- Finds the distance between the
-- current location and some other
-- place, without diagonal travel
-- @param x, y, z are the coords of
-- the other place
-- @return the distance
deadReckoner.howFarFrom=function(x,y,z)
  local dx= math.abs( dr.place.x- x )
  local dy= math.abs( dr.place.y- y )
  local dz= math.abs( dr.place.z- z )
  return dx + dy + dz
end

--- Calculates distance from starting
-- place, considering that turtles
-- do not move diagonally in their 
-- present form.
-- @return number of moves to get back
deadReckoner.howFarFromHome=function()
  return math.abs(dr.place.x)+ 
      math.abs(dr.place.y)+ 
      math.abs(dr.place.z)
end

--- Inspects the given direction, and
-- also calls to evaluate the target
-- block for max and min coords.
-- @param way FORE, UP, AHEAD etc
-- @return boolean success, table 
-- data/string error message
deadReckoner.inspect= function(way)

  way = dr.correctHeading(way)
  local ok, item
  if way== dr.AHEAD then
    ok, item= t.inspect()
  elseif way== dr.UP then
    ok, item= t.inspectUp()
  else
    ok, item= t.inspectDown()
  end
  
  local ix, iy, iz = 
      dr.getTargetCoords(way)
  
  dr.setMaxMin(ix, iy, iz)
  return ok, item
end

--- Digs.
-- @param way must be dr.FORE, 
-- dr.STARBOARD, dr.FORE, dr.AFT
-- dr.AHEAD, dr.UP or dr.DOWN
-- @return isAble true if it really 
-- was able to dig
-- @return whyNot if isAble, nil. Else,
-- reason why not.
deadReckoner.dig= function( way )

  way = dr.correctHeading( way )
  
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

--- Tries to move laterally, up or down. 
-- If successful,
-- it updates its current location
-- relative to where it started and 
-- returns true.
-- Else, it returns false and the
-- reason why not.
-- @param way is dr.FORE, dr.STARBOARD, 
-- dr.AFT, dr.PORT, dr.AHEAD, dr.UP 
-- or dr.DOWN, where dr is deadReckoner
-- @return isAble, whyNot
deadReckoner.move= function( way )
  
  way = dr.correctHeading(way, true)
  
  -- where way is dr.AHEAD, UP or DOWN
  local isAble, whynot
  if way==dr.AHEAD or way==dr.BACK then
    local forwardness = 1
    if way== dr.AHEAD then
      isAble, whynot = t.forward()
    else
      isAble, whynot = t.back()
      forwardness = -1
    end
    
    if isAble then
      if dr.heading== dr.AFT then
        dr.place.z= 
            dr.place.z - forwardness
      elseif dr.heading== dr.FORE then
        dr.place.z= 
            dr.place.z + forwardness
      elseif dr.heading== dr.PORT then
        dr.place.x= 
            dr.place.x- forwardness
      else
        dr.place.x= 
            dr.place.x+ forwardness
      end
      
    end -- isAble
  elseif way== dr.UP then
    isAble, whynot = t.up()
    if isAble then
      dr.place.y = dr.place.y + 1
    end
  elseif way== dr.DOWN then
    isAble, whynot = t.down()
    if isAble then
      dr.place.y = dr.place.y - 1
    end
  end -- AHEAD, UP or DOWN
  
  if isAble then
    dr.setMaxMin( dr.place.x, 
        dr.place.y, dr.place.z )
  end
  
  return isAble, whynot
end

--- Places.
-- @param way must be dr.FORE, 
-- dr.STARBOARD, dr.FORE, dr.AFT
-- dr.AHEAD, dr.UP or dr.DOWN
-- @return isAble true if it really 
-- was able to place the item
-- @return whyNot if isAble, nil. Else,
-- reason why not.
deadReckoner.placeItem = function(way)
  
  way = dr.correctHeading( way )
  
  local placed= false
  local whyNot
  if way== dr.AHEAD then
    placed, whyNot= t.place()
  elseif way== dr.UP then
    placed, whyNot= t.placeUp()
  elseif way== dr.DOWN then
    placed, whyNot= t.placeDown()
  end
  
  return placed, whyNot
end

--- Comparing destination with current
-- location, this finds the dominant
-- direction and distance in that
-- direction. X - Z plane gets
-- priority.
-- @param dest destination coordinates
-- @return direction: up, down, fore, 
-- aft, port or starboard
-- @return distance
deadReckoner.furthestWay = 
    function(dest)
  
  -- Dest - Current: +Srbrd -Port
  local direction = 0
  local dist = dest.x - dr.place.x
  if dist >= 0 then
    direction= dr.STARBOARD
  else
    direction= dr.PORT
  end
  
  -- Find Z diff +fore -aft
  local zDist = dest.z - dr.place.z
  if math.abs(zDist)>math.abs(dist)then
    dist= zDist
    if dist >= 0 then
      direction= dr.FORE
    else
      direction= dr.AFT
    end
  end
  
  -- Y:  +up -down
  local yDist = dest.y - dr.place.y
  if math.abs(yDist)>math.abs(dist)then
    dist= yDist
    if dist >= 0 then
      direction= dr.UP
    else
      direction= dr.DOWN
    end
  end
  
  return direction, math.abs(dist)
  
end

return deadReckoner
