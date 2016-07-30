--[[ This is for after you've used the 
excavate script, and you have a deep 
hole in front of you.  Finds out how 
many ladders and torches you need, and
places them ]]

-- TODO at release, use native turtle
local t = require "mockTurtle"

--- Finds out if there are enough 
-- ladders and torches.  If not it
-- displays a manifest of what's needed
local function checkSupplies(height)
  local areOK = false
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
    elseif sltDt.name=="minecraft:ladder"
        then
      laddersHave= laddersHave +
          sltDt.count
    elseif sltDt.name=="minecraft:torch" 
        then
      torchesHave = torchesHave +
          sltDt.count
    end -- slotname if
  end -- slots loop
  
  local ladderCnt = math.max(0, 
      ladderReq - laddersHave )
  local torchCnt = math.max( 0,
      torchReq - torchesHave )
  
  local trchStckCnt = 0
  if torchCnt > 0 then
    print("== need ".. torchCnt..
        " more torches")
    -- Nearest higher factor of 4
    torchCnt= math.ceil(torchCnt/4)*4
    print("Craft ".. torchCnt.. 
        " torches" )
    local coalCnt= math.ceil(
        torchCnt / 4 )
    trchStckCnt= coalCnt
    print("coal & sticks needed for ".. 
        "torches: ".. coalCnt ) 
  end
  
  local lddrStckCnt = 0
  if ladderCnt > 0 then
    print("== more ladders needed: "..
        ladderCnt )
    -- Nearest higher factor of 3
    ladderCnt= math.ceil(ladderCnt/3)*3
    print("Ladders to craft: "..
        ladderCnt )
    lddrStckCnt= math.ceil(
        ladderCnt * 7 / 3 )
    print("ladder-sticks needed: "..
        lddrStckCnt )
  end
  
  if ladderCnt + torchCnt == 0 then
    areOK = true
  else
    local stickCnt= lddrStckCnt +
        trchStckCnt
    
    -- Nearest higher factor of 4
    stickCnt= math.ceil(stickCnt/4 )*4
    print( "total sticks to craft: "..
        stickCnt )
    
    local plankCnt= math.ceil(
        stickCnt * 2 / 4 )
    
    plankCnt= math.ceil(plankCnt/4)*4
    print("planks to craft for sticks "..
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
    print("usage: shaftSafety <Y>")
    print("  where <Y> is turtle's"..
        " Y-coord.")
  else
    local n = tonumber( targs[1] )
    if n == nil then
      print("argument not a number")
    elseif n < 6 then
      print("arg should be 6 or more")
    else
      isOK = checkSupplies(n)
    end
  end
  return isOK
end

local function main( targs )

  -- Check prereqs; warn as applicable
  if checkPrereqs(targs) then
    print("prereqs OK")
    -- TODO finish main()
    -- Adjust starting location
    
    -- Go down, placing ladders
    
    -- Come back up, placing torches
  
  end

end

local tArgs = {...}
main(tArgs)