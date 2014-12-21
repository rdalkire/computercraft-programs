
-- assign fake/real turtle
local t
if turtle then
  t = turtle
else
  t = require "mockTurtle"
end

local deadReckoner = {}

deadReckoner.FORE = 0
deadReckoner.STARBOARD = 1
deadReckoner.AFT = 2
deadReckoner.PORT = 3

deadReckoner.heading= deadReckoner.FORE

-- Turns as needed to face the 
-- target direction indicated
deadReckoner.bearTo= function(target)

  local WAYS = {}
  WAYS[deadReckoner.FORE] = "FORE"
  WAYS[deadReckoner.STARBOARD] = "STARBOARD"
  WAYS[deadReckoner.AFT] = "AFT"
  WAYS[deadReckoner.PORT] = "PORT"

  print("heading ".. 
      WAYS[deadReckoner.heading], 
      "target heading "..
      WAYS[ target ] )

  local trnsRght = 
      target - deadReckoner.heading
  
  local trns = math.abs( trnsRght )
  if trns == 0 then
    print("No need to turn.")
  else
    local i = 0
    while i < trns do
      if trnsRght >= 0 then
        t.turnRight()
      else
        t.turnLeft()
      end -- which way
      i = i + 1
    end -- turn loop
    print("done turning this time.")
  end -- there were any turns
  
  deadReckoner.heading = target
end

local dr = deadReckoner

--[[ Drops this much from inventory ]]
local function dropFromInv( cntToDrop )
  
  --[[ loops through inventory until 
  cntToDrop reached ]]
  local i = 16
  while i >= 1 and cntToDrop > 0 do
    local iCnt = t.getItemCount(i)
    local drAmtThs = 0
    if iCnt >= cntToDrop then
      drAmtThs = cntToDrop
    else -- iCnt must be < cntToDrop
      drAmtThs = iCnt
    end
    
    -- If applicable, drop & update
    if drAmtThs > 0 then
      t.select(i)
      t.drop(drAmtThs)
      cntToDrop = cntToDrop - drAmtThs 
    end
    
    i = i - 1
  end
  
end

--[[ From its inventory, removes all 
but the most blockable kind of item
(At time of this edit: only melons),
putting all non-wanted items into the
appropriate chests: already-blocked 
into the right one, non-blockable
into left one, and remaining blockable
back to the source chest.
@return number of remaining items,
  evenly divisible by 9 ]]
local function sortAllButBlockables()

  --[[ TODO Find the most 'blockable' 
    item - ie, which blockable is
    the most plentiful. Use separate
    function ]]
  
  -- Going through the inventory
  local sliceCnt = 0
  for i = 1, 16 do
    local itm = t.getItemDetail(i)
    
    if itm ~= nill then
      print(i, itm.name)
      
      
      --[[ TODO Use whatever is _most_
      blockable.  Put other blockables
      back into the source chest. ]]
      
      if itm.name=="minecraft:melon" then 
        -- add to the slice count
        sliceCnt = sliceCnt + itm.count
        
      elseif itm.name==
          "minecraft:melon_block" then
        -- put stack in starboard chest
        dr.bearTo(dr.STARBOARD)
        t.select(i)
        t.drop()
      else
        -- put stack in the port chest
        dr.bearTo(dr.PORT)
        t.select(i)
        t.drop()
      end
    
    else -- itm is nill
      print(i, "nill")
    end -- if there are items
    
  end -- loop of items

  dr.bearTo(dr.FORE)
  
  -- Limit is 64 * 9 for crafting
  local rmndr = sliceCnt % 9
  print( "sliceCnt pre", sliceCnt )
  if sliceCnt > 576 then
    dropFromInv( sliceCnt - 576 )
    sliceCnt = 576
  elseif rmndr > 0 then
    dropFromInv( rmndr )
    sliceCnt = sliceCnt - rmndr
  end
  
  return sliceCnt
end

--[[ Slots used as crafting table ]]
local crftSlts = { 1, 2, 3, 5, 6, 7,
    9, 10, 11 }

--[[ Transfers from the selected slot
to any crafting-table slot that doesnt
yet have the amount needed. ]]
local function trnsfr(rightAmt, blCnt)
  
  local slcCount = t.getItemCount()
  local toTrnsfr = slcCount - rightAmt
  -- Until down to rightAmt
  while toTrnsfr > 0 do
  
    -- Finds a crafting table slot that
    -- has less than blCnt
    
    -- Transfers needed amount
    
    -- updates toTransfr
    
  end -- trnsfr loop
    
end -- function


--[[ Crafts the blockable items into
blocks.
@param count number of craftable itmes
in the inventory ]]
local function craftBlocks( count )
  -- Set up the slots and craft
  local blCnt = math.floor(count / 9)
  
  --[[ Slots that must be empty ]]
  local emptySlts = {4, 8, 12, 13, 14,
      15, 16 }
    
  --[Loop through empty-able slts]]
  for i = 1, 7 do
    local slotIndx = emptySlts[i]
    t.select(slotIndx)
    trnsfr( 0, blCnt )
  end --empty slots loop
  
  --[[Loops through the craftable slts]]
  for i = 1, 9 do
    local slotIndx = emptySlts[i]
    t.select(slotIndx)
    trnsfr( blCnt, blCnt )
  end
  
end


local function main( tArgs )

  --[[ Pulls items from chest ]]
  local stillSucks = true
  while stillSucks do
    stillSucks = t.suck()
  end
  
  local sliceCnt= sortAllButBlockables()
  
  print("sliceCnt", sliceCnt )
  
  -- If there are enough slices, craft!
  if sliceCnt >= 9 then
    craftBlocks( sliceCnt )
  end
 
end

local tArgs = {...}
main(tArgs)