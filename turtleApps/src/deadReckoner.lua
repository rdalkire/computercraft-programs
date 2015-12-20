--[[
Copyright (c) 2015 
Robert David Alkire II, IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

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

local deadReckoner = {}
local dr = deadReckoner

--- relative to turtle heading at start 
deadReckoner.FORE = 0
deadReckoner.STARBOARD = 1
deadReckoner.AFT = 2
deadReckoner.PORT = 3

deadReckoner.heading=deadReckoner.FORE

deadReckoner.place=Locus.new(0, 0, 0)

--- forward regardless of heading
deadReckoner.AHEAD = 4
deadReckoner.UP = 5
deadReckoner.DOWN = 6

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

--- Turns as needed to face the 
-- target direction indicated
deadReckoner.bearTo= function(target)

  local WAYS = {}
  WAYS[deadReckoner.FORE] = "FORE"
  WAYS[deadReckoner.STARBOARD]= 
      "STARBOARD"
  WAYS[deadReckoner.AFT] = "AFT"
  WAYS[deadReckoner.PORT] = "PORT"

  local trnsRght = 
      target - deadReckoner.heading
  
  local trns = math.abs( trnsRght )
  if trns ~= 0 then
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

--- Tries to move ahead, up or down. 
-- If successful,
-- it updates its current location
-- relative to where it started and 
-- returns true.
-- Else, it returns false and the
-- reason why not.
-- @param way is either dr.AHEAD, dr.UP 
-- or dr.DOWN, where dr is deadReckoner
deadReckoner.move= function( way )
  
  -- where way is dr.AHEAD, UP or DOWN
  local isAble, whynot
  if way== dr.AHEAD then
    isAble, whynot = t.forward()
    
    if isAble then
      if dr.heading== dr.AFT then
        dr.place.z= dr.place.z - 1
      elseif dr.heading== dr.FORE then
        dr.place.z= dr.place.z + 1
      elseif dr.heading== dr.PORT then
        dr.place.x= dr.place.x- 1
      else
        dr.place.x= dr.place.x+ 1
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
  
  return isAble, whynot
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
deadReckoner.furthestWay= function(dest)
  
  -- Dest - Current: +Srbrd -Port
  local direction = 0
  local dist = dest.x - dr.place.x
  if dist >= 0 then
    direction= dr.STARBOARD
  else
    direction= dr.PORT
  end
  
  -- Find Z diff +fore -aft
  local zDist = dest.x - dr.place.x
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
