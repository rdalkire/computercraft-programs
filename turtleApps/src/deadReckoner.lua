--[[ NOTE: This is a component, *not* 
a stand-alone, runnable script.

Copyright (c) 2015 - 2017
Robert David Alkire II, IGN 
goatsbuster, FKA ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

--- To ensure this is the version
-- you're looking for
DEP_VERSION="1.1.6"

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
deadReckoner.__index = deadReckoner

deadReckoner.new= function()
  local self = setmetatable( {}, 
      deadReckoner )
      
  self.heading=self.FORE
  
  return self
end

--- relative to turtle heading at start 
deadReckoner.FORE = 0
deadReckoner.STARBOARD = 1
deadReckoner.AFT = 2
deadReckoner.PORT = 3


deadReckoner.WAYS = {}
deadReckoner.WAYS[deadReckoner.FORE] = 
    "FORE"
deadReckoner.WAYS[
    deadReckoner.STARBOARD]="STARBOARD"
deadReckoner.WAYS[deadReckoner.AFT] = 
    "AFT"
deadReckoner.WAYS[deadReckoner.PORT] = 
    "PORT"
  
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
function deadReckoner:bearTo(target)

  local trnsRght = 
      target - self.heading
  
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
  
  self.heading = target
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
function deadReckoner:correctHeading(
    way, isForMovement )
    
  if way < 4 then
    if isForMovement and 
        way ~= self.heading and 
        (way - self.heading) % 2== 0 
        then
      way = self.BACK
    else
      self.bearTo( way )
      way = self.AHEAD
    end
  elseif way== self.BACK and 
      not isForMovement then
    -- This means it's digging or 
    -- inspecting something behind, so
    -- it needs to turn around
    way = self.heading + 2
    way = way % 4
    self.bearTo(way)
    way = self.AHEAD
  end
  
  return way
  
end

--- Adjusts placeMAX and placeMIN as
-- applicable.
function deadReckoner:setMaxMin(x,y,z)

  if x > self.placeMAX.x then
    self.placeMAX.x = x
  elseif x < self.placeMIN.x then
    self.placeMIN.x = x
  end
  
  if y > self.placeMAX.y then
    self.placeMAX.y = y
  elseif y < self.placeMIN.y then
    self.placeMIN.y = y
  end
  
  if z > self.placeMAX.z then
    self.placeMAX.z = z
  elseif z < self.placeMIN.z then
    self.placeMIN.z = z
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
function deadReckoner:getTargetCoords(
    way )
  
  local ix = self.place.x
  local iy = self.place.y
  local iz = self.place.z
  
  if way == self.AHEAD then
    way = self.heading
  end
  
  if way== self.AFT then
    iz= iz - 1
  elseif way== self.FORE then
    iz= iz + 1
  elseif way== self.PORT then
    ix= ix- 1
  elseif way== self.STARBOARD then
    ix= ix+ 1
  elseif way== self.UP then
    iy= iy + 1
  elseif way== self.DOWN then
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
function deadReckoner:howFarFrom(x,y,z)
  local dx= math.abs( self.place.x- x )
  local dy= math.abs( self.place.y- y )
  local dz= math.abs( self.place.z- z )
  return dx + dy + dz
end

--- Calculates distance from starting
-- place, considering that turtles
-- do not move diagonally in their 
-- present form.
-- @return number of moves to get back
function deadReckoner:howFarFromHome()
  return math.abs(self.place.x)+ 
      math.abs(self.place.y)+ 
      math.abs(self.place.z)
end

--- Inspects the given direction, and
-- also calls to evaluate the target
-- block for max and min coords.
-- @param way FORE, UP, AHEAD etc
-- @return boolean success, table 
-- data/string error message
function deadReckoner:inspect(way)

  -- FIXME: attempt to index local 
  -- 'self' (a number value)
  way = self.correctHeading(way)
  
  local ok, item
  if way== self.AHEAD then
    ok, item= t.inspect()
  elseif way== self.UP then
    ok, item= t.inspectUp()
  else
    ok, item= t.inspectDown()
  end
  
  local ix, iy, iz = 
      self.getTargetCoords(way)
  
  self.setMaxMin(ix, iy, iz)
  return ok, item
end

--- Digs.
-- @param way must be dr.FORE, 
-- dr.STARBOARD, dr.FORE, dr.AFT
-- dr.AHEAD, dr.BACK, dr.UP or dr.DOWN
-- @return isAble true if it really 
-- was able to dig
-- @return whyNot if isAble, nil. Else,
-- reason why not.
function deadReckoner:dig( way )

  way = self.correctHeading( way )
  
  local dug= false
  local whyNot
  if way== self.AHEAD then
    dug, whyNot= t.dig()
  elseif way== self.UP then
    dug, whyNot= t.digUp()
  elseif way== self.DOWN then
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
function deadReckoner:move( way )
  
  way = self.correctHeading(way, true)
  
  -- where way is self.AHEAD, UP or DOWN
  local isAble, whynot
  if way==self.AHEAD or 
      way==self.BACK then

    local forwardness = 1
    if way== self.AHEAD then
      isAble, whynot = t.forward()
    else
      isAble, whynot = t.back()
      forwardness = -1
    end
    
    if isAble then
      if self.heading== self.AFT then
        self.place.z= 
            self.place.z - forwardness
      elseif self.heading== self.FORE 
          then
        self.place.z= 
            self.place.z + forwardness
      elseif self.heading== self.PORT 
          then
        self.place.x= 
            self.place.x- forwardness
      else
        self.place.x= 
            self.place.x+ forwardness
      end
      
    end -- isAble
  elseif way== self.UP then
    isAble, whynot = t.up()
    if isAble then
      self.place.y = self.place.y + 1
    end
  elseif way== self.DOWN then
    isAble, whynot = t.down()
    if isAble then
      self.place.y = self.place.y - 1
    end
  end -- AHEAD, UP or DOWN
  
  if isAble then
    self.setMaxMin( self.place.x, 
        self.place.y, self.place.z )
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
function deadReckoner:placeItem(way)
  
  way = self.correctHeading( way )
  
  local placed= false
  local whyNot
  if way== self.AHEAD then
    placed, whyNot= t.place()
  elseif way== self.UP then
    placed, whyNot= t.placeUp()
  elseif way== self.DOWN then
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
function deadReckoner:furthestWay(dest)
  
  -- Dest - Current: +Srbrd -Port
  local direction = 0
  local dist = dest.x - self.place.x
  if dist >= 0 then
    direction= self.STARBOARD
  else
    direction= self.PORT
  end
  
  -- Find Z diff +fore -aft
  local zDist = dest.z - self.place.z
  if math.abs(zDist)>math.abs(dist)then
    dist= zDist
    if dist >= 0 then
      direction= self.FORE
    else
      direction= self.AFT
    end
  end
  
  -- Y:  +up -down
  local yDist = dest.y - self.place.y
  if math.abs(yDist)>math.abs(dist)then
    dist= yDist
    if dist >= 0 then
      direction= self.UP
    else
      direction= self.DOWN
    end
  end
  
  return direction, math.abs(dist)
  
end

return deadReckoner
