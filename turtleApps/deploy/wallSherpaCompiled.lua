-- Starting at top of hole/cliff/wall,
-- this places ladders and torches
-- downward so you can climb safetly

-- Run with no args or -h for usage

--[[ shaftsafety
Copyright (c) 2016
Robert David Alkire II, AKA rdalkire,
IGN ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

-- when 'compiling', use native turtle
local t = turtle

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

--[[ BEGIN IN-LINE RELEASE getopt
Copyright (c) 2016 
Authors: Admicos, dalkire.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]
local getopt = {}

local g_name
local g_desc 
local g_options

--- displays help
getopt.help= function()
  
  local help= g_name.. ": ".. 
      g_desc.."\n".."USAGE: "..g_name.. 
      " [options] [arg(s)]\n"..
      "Options:\n"
      
  for key, val in pairs(g_options) do
    help = help .. "--" .. key .. 
        " (-" .. val[2] .. ")"

    if val[3] ~= nil then
      help = help .. 
          " [" .. val[3] .. "]"
    end
    
    help= help.. ": ".. val[1].. "\n"
  end

  if textutils then
    textutils.pagedPrint(help)
  else
    print(help)
  end
  
end

--- Initializes
-- @param name program name
-- @param desc program description 
-- @param options a table of options, 
--  **not** including --help or -h 
--  because getopt creates them for 
--  you.
-- @param args the arguments passed in
-- @return table or nil
getopt.init= function(name, desc,
    options, args)

  g_name = name
  g_desc = desc
  g_options = options
  
  local _resTbl = {}
  local _isArg = false
  local _optCnt = 1

  for indx, val in ipairs(args) do
  
    if val== "-h" or val=="--help" then
      _resTbl = {}

      getopt.help()

      return nil
    end

    if val:sub( 1, 1 ) == "-" then
    
      for nme, trio in pairs(options)do
      
        if val== "--".. nme or 
            val== "-".. trio[2] then
            
          if trio[3] ~= nil then
            _resTbl[nme]= args[indx+ 1]
            _isArg = true
          else
            _resTbl[nme] = true
          end
          
        end -- if arg
        
      end -- options loop
      
    elseif not _isArg then
      _resTbl["opt-" .. _optCnt] = val
      _optCnt = _optCnt + 1
    else
      _isArg = false
    end
    
  end -- args loop

  return _resTbl
end
-- END IN-LINE RELEASE getopt

-- SHAFTSAFETY ITSELF BEGINS HERE

local FILL_MIN = 12

local ITM_FILL="minecraft:cobblestone"
local ITM_LADDER = "minecraft:ladder"
local ITM_TORCH = "minecraft:torch"

local g_stay = false
local g_height = 0
local g_bed = true -- stops at bedrock
local g_up = false
local g_gap = false -- stops at gap

local g_torchInterval = 5

--- estimates and inventories torches, 
-- ladders and cobbles
-- @return how many torches, ladders, 
-- and cobbles are needed to make up, 
-- and how many cobbles you actually 
-- have
local function lddrsNTrchsDiff()

  local n = g_height
  if g_bed then
    n = n - 5
  end
  
  local ladderReq = n * 2
  local torchReq= math.ceil( n/ 
      g_torchInterval )
      
  local cobbleReq= n * 3
  
  -- inventories ladders & torches
  local laddersHave = 0
  local torchesHave = 0
  local cobbleHave = 0
  for iSlot = 1, 16 do
    local sltDt= t.getItemDetail(iSlot)
    if t.getItemCount(iSlot)==0 then
      -- no op
    elseif sltDt.name==
        ITM_LADDER then
      laddersHave= laddersHave +
          sltDt.count
    elseif sltDt.name==
        ITM_TORCH then
      torchesHave = torchesHave +
          sltDt.count
    elseif sltDt.name== ITM_FILL then
      cobbleHave=cobbleHave+sltDt.count 
    end -- slotname if
  end -- slots loop
  
  local ladderDif = math.max(0, 
      ladderReq - laddersHave )
  local torchDif = math.max( 0,
      torchReq - torchesHave )
  local cobbleDif = math.max( 0, 
      cobbleReq - cobbleHave )
      
  return ladderDif,torchDif, cobbleDif,
      cobbleHave

end

--- Finds how many sticks needed for
-- ladders, and how many sticks for 
-- torches
local function lddrNTrchSticks( 
    ladderDif, torchDif )
  
  local trchStcks = 0
  if torchDif > 0 then
    print("== need ".. torchDif..
        " more torches")
    -- Nearest higher factor of 4
    torchDif= math.ceil(torchDif/4)*4
    print("Craft ".. torchDif.. 
        " torches" )
    local coalCnt= math.ceil(
        torchDif / 4 )
    trchStcks= coalCnt
    print("coal & sticks needed for ".. 
        "torches: ".. coalCnt ) 
  end
  
  local lddrStcks = 0
  if ladderDif > 0 then
    print("== more ladders needed: "..
        ladderDif )
    -- Nearest higher factor of 3
    ladderDif= math.ceil(ladderDif/3)*3
    print("Ladders to craft: "..
        ladderDif )
    lddrStcks= math.ceil(
        ladderDif * 7 / 3 )
    print("ladder-sticks needed: "..
        lddrStcks )
  end
  
  return lddrStcks, trchStcks
  
end

--- @return true if fuel is enough
local function checkFuel()
  local isGood = false
  local fuel = t.getFuelLevel()
  if fuel == "unlimited" then
    isGood = true
  else
  
    local d = g_height
    if g_bed then
      d = d - 5
    end
    
    -- returning fuel
    local rtn = d
    if g_stay then
      rtn = 0
    end
    
    local needed = d * 2 + -- ladders
                  (d/5)*2+ -- torches
                   rtn +   -- returning
                   20      -- buffer
                   
    local diff = math.max(0, 
        needed - fuel )
    
    if diff == 0 then
      isGood = true
    else
      print("fuel is too low: ".. fuel)
      print("needs at least: "..needed)
      print("difference: ".. diff)
    end  
  end
  return isGood
end

--- Finds out if there are enough 
-- ladders and torches.  If not it
-- displays a manifest of what's needed
local function checkSupplies()
  local areOK = false
  
  local ladderDif, torchDif, cobbleDif, 
      cobbleHave = lddrsNTrchsDiff()
  
  local lddrStcks, trchStcks = 
      lddrNTrchSticks( ladderDif,
          torchDif )
  
  if ladderDif + torchDif == 0 then
    areOK = true
  else
    local stickCnt= lddrStcks +
        trchStcks
    
    -- Nearest higher factor of 4
    stickCnt= math.ceil(stickCnt/4 )*4
    print( "total sticks to craft: "..
        stickCnt )
    
    local plankCnt= math.ceil(
        stickCnt * 2 / 4 )
    
    plankCnt= math.ceil(plankCnt/4)*4
    
    print(
        "planks to craft for sticks "..
        plankCnt )
    
    local logCnt = math.ceil(
        plankCnt / 4 )
    print("logs for planks: ".. 
        logCnt )
    
  end
  
  if cobbleHave < FILL_MIN then
    areOK = false
    
    -- TODO parse fill item for warning
    print("You should have at least "..
        FILL_MIN.. " cobbles")
    print("If building whole wall "..
        "you'd need ".. cobbleDif..
        " more cobblestone blocks")
  end
  
  if not checkFuel() then
    areOK = false
  end
  
  return areOK
end

--- Manages the input arguments. 
-- Validates and parses them.
-- @param targs the arguments passed
-- in when starting the program
local function mngArgs(targs)
  local _optionsExample = {
      ["stay"] = {
          "Stay and don't come back.",
          "s", nill },
      ["bedrock"] = {
          "go all the way to "..
          "Bedrock (true if not "..
          "specified and going "..
          "down.  If going up, "..
          "this isn't applicable).",
          "b", "<true|false>"},
      ["up"] = {
          "go Up instead.",
          "u", nill },
      ["gap"] = {
          "stop at the first Gap "..
          "(If not specified, "..
          "defaults true going up,"..
          " false going down).",
          "g", "<true|false>"},
      ["torchInterval"] = {
          "Define Interval between "..
          "torches.",
          "i", "<num>"}
  }
  
  local isOK = true
  
  local tbl= getopt.init("shaftSafety",
      "This is for after you've "..
      "used the excavate script, "..
      "and you have a deep hole in"..
      " front of you.  Finds out "..
      "how many ladders and torches "..
      "you need, and places them. "..
      "\nUse turtle's Y coord "..
      "as the argument to go all "..
      "the way to bedrock", 
      _optionsExample, targs )
  
  if tbl== nil then
    -- user had used -h as option
    isOK = false
  elseif next(tbl)== nil then
    -- no options or args specified
    isOK = false
    getopt.help()
  else
  
    if tbl["stay"] then
      g_stay = true
    end
    
    if tbl["up"] then
      g_up = true
      g_bed = false
      g_gap = true
    end
    
    if tbl["bedrock"] then
    
      local bedTxt = string.lower( 
          tbl["bedrock"] )
      
      if "true" == bedTxt then
        g_bed = true
      elseif "false" == bedTxt then
        g_bed = false
      elseif g_up then
        isOK = false
        print("Going up, so bedrock"..
            "doesn't really apply.")
      else
        isOK = false
        print("For Bedrock, you ".. 
            "must specify true or "..
            "false.")
      end
      
    end
    
    if tbl["gap"] then
      local gapTxt = string.lower(
          tbl["gap"])
          
      if "true" == gapTxt then
        g_gap = true
      elseif "false" == gapTxt then
        g_gap = false
      else
        print("Gap option requires"..
            " true|false argument.")
        isOK = false
      end
    end
    
    if tbl["torchInterval"] then
      g_torchInterval = tonumber( 
          tbl["torchInterval"] )
      if g_torchInterval == nil then
        isOK = false
        print("TorchInterval option"..
            " requires number.")
      end
    end
    
    if tbl["opt-1"] then
      g_height= tonumber( tbl["opt-1"])
      if g_height== nil then
        isOK = false
        print("Arg must be numeric.")
      elseif g_bed and g_height< 6 then
        isOK = false
        print("Arg must be 6 or more.")
      end
    elseif isOK then
      isOK = false
      print("Arg required for height.")
    end -- opt-1
  end
  
  return isOK
end

--- Manages prerequisites. Validates
-- and parses the options, arguments,
-- and inventory supplies.
-- @param targs the raw arguments
-- @return true if prerequisites
-- are OK
local function mngPrereqs(targs)
  local isOK = true
  
    isOK = mngArgs(targs)
    if isOK then
      isOK = checkSupplies()
    end
    
  return isOK
end

--- Select the slot that has the item
-- @param itmName the item to match
-- @return true if item is found
local function selectSltWthItm(itmName)
  local itm = t.getItemDetail()
  local isFound = false
  local nme
  if itm ~= nill then
    nme = itm.name
    isFound = itmName == nme
  end
  
  if not isFound then
    local slt = t.getSelectedSlot()
    local i = 1
    while not isFound and i <= 16 do
      if i ~= slt then
        itm = t.getItemDetail(i)
        if itm ~= nill then
          nme = itm.name
          if nme == itmName then
            isFound = true
            t.select(i)
          end
        end -- not nill
      end -- not current slot
      i = i + 1
    end -- while
  end -- not yet found
  return isFound
end

---Meant for placing torches or ladders
-- AFT if going down, or FORE if going 
-- up. When encountering a gap, it will
-- depend on whether it's supposed to
-- stop at gaps.  If so (g_gap, default
-- true going up), it will return 
-- false.  Otherwise will fill in the
-- gap with ITM_FILL and continue.
-- @param itmName
-- @return true if successful
local function placeItem( itmName )
  local isAble=selectSltWthItm(itmName)
  local whyNt = nil
  local way = dr.AFT
  if g_up then
    way = dr.FORE
  end
  if isAble then
    
    dr.dig(way)
    isAble, whyNt=dr.placeItem(way)
  
    if not isAble and not g_gap then
      
      -- go back and place filler
      
      isAble, whyNt = dr.move(way)
      
      if isAble then
        isAble = selectSltWthItm(
            ITM_FILL )
        
        if isAble then
          -- Could be abandoned mine
          -- with fencing or cobweb
          dr.dig(way)
          
          isAble, whyNt = dr.placeItem( 
              way )

          dr.move(dr.BACK)
          
          -- try again
          selectSltWthItm(itmName)
          isAble, whyNt = dr.placeItem(
              way )
        else
          -- TODO parse fill item
          whyNt = "out of ".. itmName
        end -- if there's cobble
      end -- able to move aft
    elseif not isAble then
      print("Not filling gap")
      print(
        "isAble: "..tostring(isAble)..
        " g_gap: "..tostring(g_gap))
    end -- wasn't able to place
  else
    whyNt = "Out of ".. itmName
  end
  
  if not isAble then
    print("unable to place; ".. whyNt)
  end
  
  return isAble
end

--- if fifth, move starboard, 
--  place a torch and come back
--  @param d is distance down so far
local function placeNthTrchStrbrd(d)
  local rtrn = true
  if d % g_torchInterval == 0 then
    dr.move(dr.STARBOARD)
    rtrn = placeItem(ITM_TORCH)
    dr.move(dr.PORT)
  end
  return rtrn
end

--- Moves down the shaft wall, placing
-- ladders and torches.
-- @return vertical distance traveled
local function goPlaceThings()
  
  local lmt = g_height
  if g_bed then
    lmt = lmt - 5
  end
  
  local actlDst = 0
  local keepGoing = true
  
  local vert = dr.DOWN
  if g_up then
    vert = dr.UP
  end
  
  local isFirstGoingUp = g_up
  
  while keepGoing and actlDst < lmt do
    
    if isFirstGoingUp then
      isFirstGoingUp = false
    else
      keepGoing = dr.move(vert)
    end
    
    if keepGoing then
      
      if actlDst % 2 == 0 then --even
        
        keepGoing =
            placeItem( ITM_LADDER) and
            dr.move(dr.STARBOARD ) and
            placeItem( ITM_LADDER) and
            placeNthTrchStrbrd(actlDst)
        
      else -- odd
        
        keepGoing =
            placeNthTrchStrbrd(actlDst)
            and
            placeItem( ITM_LADDER) and
            dr.move(dr.PORT) and
            placeItem( ITM_LADDER )
        
      end -- even/odd
      actlDst = actlDst + 1
    end -- if keepgoing
  end -- while
  return actlDst
end -- function

--- Moves the turtle to the original
-- location. First left/right, then
-- up/down (in this app's case up, to 
-- be realistic), then for/aft
local function comeBack()
  
  -- left/right
  local x = dr.place.x
  if x < 0 then
    -- move right abs x places
    for m = 1, math.abs(x) do
      dr.move(dr.STARBOARD)
    end
  elseif x > 0 then
    -- move left x times
    for m = 1, x do
      dr.move(dr.PORT)
    end
  end
  
  -- up/down
  local y = dr.place.y
  if y < 0 then
    for m = 1, math.abs(y) do
      dr.move(dr.UP)
    end
  elseif y > 0 then
    for m = 1, y do
      dr.move(dr.DOWN)
    end
  end
  
  -- fore/aft
  local z = dr.place.z
  if z < 0 then
    for m = 1, math.abs(z) do
      dr.move(dr.FORE)
    end
  elseif z > 0 then
    for m = 1, z do
      dr.move(dr.AFT)
    end
  end
end

local function adjStartLocation()

  if g_up then
    -- If up against wall, back up
    -- so that a ladder can be placed
    if t.inspect() then
      dr.move(dr.BACK)
    end
  else
    -- so turtle can start 1 from edge
    -- afterward, trtl is 1 away from 
    -- wall, giving room to place
    if t.inspectDown() then
      dr.move(dr.AHEAD)
    end
    dr.move(dr.AHEAD)
    dr.bearTo(dr.AFT);
  end
end

local function main( targs )

  -- Check prereqs; warn as applicable
  if mngPrereqs(targs) then
    print("prereqs OK")
    
    adjStartLocation()
    
    -- Go down, placing things
    local d = goPlaceThings()

    if not g_stay then
      comeBack()
    end
    
    dr.bearTo(dr.FORE)
    
  end

end

local tArgs = {...}
main(tArgs)

