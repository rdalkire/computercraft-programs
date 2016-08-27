--[[ This is for after you've used the 
excavate script, and you have a deep 
hole in front of you.  Finds out how 
many ladders and torches you need, and
places them ]]

-- TODO at release, in-line deadReckoner
local dr = require "deadReckoner"

-- TODO at release, use native turtle
local t = require "mockTurtle"

--- Finds how many more torches and 
-- ladders are needed.
local function lddrsNTrchsDiff(height)

  local n = height - 5
  local ladderReq = n * 2
  local torchReq= math.ceil( n/5 )
  
  -- inventories ladders & torches
  local laddersHave = 0
  local torchesHave = 0
  for iSlot = 1, 16 do
    local sltDt= t.getItemDetail(iSlot)
    if t.getItemCount(iSlot)==0 then
      -- no op
    elseif sltDt.name==
        "minecraft:ladder" then
      laddersHave= laddersHave +
          sltDt.count
    elseif sltDt.name==
        "minecraft:torch" then
      torchesHave = torchesHave +
          sltDt.count
    end -- slotname if
  end -- slots loop
  
  local ladderDif = math.max(0, 
      ladderReq - laddersHave )
  local torchDif = math.max( 0,
      torchReq - torchesHave )

  return ladderDif, torchDif

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

--- Finds out if there are enough 
-- ladders and torches.  If not it
-- displays a manifest of what's needed
local function checkSupplies(height)
  local areOK = false
  
  local ladderDif, torchDif = 
      lddrsNTrchsDiff(height)
  
  local lddrStcks, trchStcks = 
      lddrNTrchSticks(ladderDif,
          torchDif)
  
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
  
  return areOK
end


local function checkPrereqs(targs)
  local isOK = false
  if table.maxn(targs) < 1 then
    print("usage: shaftSafety <Y> "..
        "[r]")
    print("  where <Y> is turtle's"..
        " Y-coord.  Use the \"r\" "..
        "option to have the robot "..
        "return to start afterward")
  else
    local n = tonumber( targs[1] )
    if n == nil then
      print("first arg not a number")
    elseif n < 6 then
      print("arg should be 6 or more")
    else
      isOK = checkSupplies(n)
      -- TODO also estimate fuel
    end
    
    
    
  end
  return isOK
end

local function placeAladder()
  -- TODO placeAladder()
  
end


--- Moves down the shaft wall, placing
-- ladders and torches.
local function goDownPlacing(n)
  
  local lmt = n - 5
  local actlDst = 0
  local keepGoing = true
  
  while keepGoing and actlDst < lmt do
    -- TODO Deadreckoner to go down
    keepGoing = t.down()
    if keepGoing then
      -- TODO placing
      -- If even

        -- place a ladder aft
        
        -- move starboard
        
        -- place a ladder aft
        
        -- move starboard
        
        -- if fifth, place a torch
      -- else, its odd
        -- if fifth, place torch
        
        -- move port
        
        -- place ladder
        
        -- move port
        
        -- place ladder
      -- end if even
      
      actlDst = actlDst + 1
    end -- if keepgoing
  end -- while
  return actlDst
end -- function

local function main( targs )

  -- Check prereqs; warn as applicable
  if checkPrereqs(targs) then
    print("prereqs OK")
    
    -- TODO finish main()
    
    -- Adjust starting location:
    -- so turtle can start 1 from edge

    if t.inspectDown() then
      dr.move(dr.AHEAD)
    end
    dr.move(dr.AHEAD)
    dr.bearTo(dr.AFT);
    
    local n = tonumber(targs[1])
    
    -- Go down, placing things
    local d = goDownPlacing(n)

    -- TODO if specified come back up
  
  end

end

local tArgs = {...}
main(tArgs)