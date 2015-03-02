--[[ SortAndBlock 1.0.1

Takes the items from the chest
fore of it, puts non-blockable to the 
port chest, Nine-block blocks to the 
starboard. Blockables are crafted to 
blocks. 

CopyLeft (MIT License) 2014
Robert David Alkire II
]]

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

deadReckoner.heading=deadReckoner.FORE

-- Turns as needed to face the 
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

  -- From Table (list) of blockables
  local blockables = {}
  blockables["minecraft:melon"] = 0
  blockables["minecraft:wheat"] = 0
  blockables["minecraft:diamond"] = 0
  blockables["minecraft:emerald"] = 0
  blockables["minecraft:iron_ingot"]=0
  blockables["minecraft:gold_ingot"]=0
  blockables["minecraft:gold_nugget"]=0
  blockables["minecraft:redstone"] = 0
  blockables["minecraft:coal"] = 0

--[[ For items in the turtle's 
inventory, which one would be best for 
crafting into 9-item blocks.
@return table with name = blockable 
  item, and nameBlock name of the item
  which is the block. ]]
local function findBlockable()
  
--  NOTE to check for lapis, would 
--  have to check for data value 4
  
  -- Tracks the blockable counts
  for i = 1, 16 do --through inventory
    local itm =  t.getItemDetail(i)
    
    if itm ~= nill then
      local nme = itm.name
      
      -- If item name is in the list
      if blockables[ nme ]~= nill then
        -- Add the count
        blockables[ nme ] = 
            blockables[ nme ] + 
            itm.count
            
      end -- if blckble
    end -- not nill
  end --invtry loop

  -- Loop through blockable list
  local max = 0
  local rtrn = nill
  for nme, cnt in pairs(blockables) do
    -- If found count > max
    if cnt > max then
      -- Assign result name
      max = cnt
      rtrn = nme
    end -- if higher is found
    
  end --blockable loop

  if rtrn ~= nill then
    print("Most blockable item: ".. 
        rtrn)
  end
  
  return rtrn
  
end

--[[ From its inventory, removes all 
but the most blockable kind of item
according to quantity, putting all 
non-wanted items into the appropriate 
chests: already-blocked into the right
one, non-blockable into left one, and
remaining blockable back to the source
chest.
@return number of remaining items,
  evenly divisible by 9 ]]
local function sortAllButBlockables()

  local blckbl = findBlockable()
  
  -- Going through the inventory
  local blckblCnt = 0
  for i = 1, 16 do
    local itm = t.getItemDetail(i)
    
    if itm ~= nill then
      
--      Uses whatever is most 
--      blockable to craft.
      if itm.name == blckbl then 
        -- add to the slice count
        blckblCnt = blckblCnt + 
            itm.count
      
      -- If it's blockable, yet not
      -- the *most* blockable
      elseif blockables[ itm.name ] ~= 
          nill then
         -- put it back into the source
        dr.bearTo( dr.FORE )
        t.select(i)
        t.drop()
        
      -- If item name has "_block" 
      elseif string.find( itm.name,
          "_block", 1, true ) then
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
    
    end -- if there are items
    
  end -- loop of slots

  dr.bearTo(dr.FORE)
  
  -- Limit is 64 * 9 for crafting
  local rmndr = blckblCnt % 9
  if blckblCnt > 576 then
    dropFromInv( blckblCnt - 576 )
    blckblCnt = 576
  elseif rmndr > 0 then
    dropFromInv( rmndr )
    blckblCnt = blckblCnt - rmndr
    print("Returned: ".. rmndr)
  end
  
  print("Blockable: ".. blckblCnt )
  
  return blckblCnt
end

--[[ Slots used as crafting table ]]
local crftSlts = { 1, 2, 3, 5, 6, 7,
    9, 10, 11 }

--[[ Transfers from the selected slot
to any crafting-table slot that doesn't
yet have the amount needed.
@param rightAmt is the amount that the
    current slot should have
@param blCnt is number of items per
    crafting table slot, which will
    be the number of blocks produced ]]
local function trnsfr(rightAmt, blCnt)
  
  local slcCount = t.getItemCount()
  local toTrnsfr = slcCount - rightAmt
  
  -- Until down to rightAmt
  while(toTrnsfr> 0) do
  
    -- Finds a crafting table slot that
    -- has less than blCnt
    local i = 1
    local cSlt = 0
    local isFound = false
    local csWants = 0
    while i <= 9 and isFound==false do
      cSlt = crftSlts[i]
      local csAmt= t.getItemCount(cSlt)
      csWants = blCnt - csAmt
      if csWants > 0 then
        isFound = true
      end
      i = i + 1
    end
    
    -- Transfers needed amount
    local thisTrnsf = 0
    if csWants > toTrnsfr then
      thisTrnsf = toTrnsfr
    else
      thisTrnsf = csWants
    end
    
    t.transferTo( cSlt, thisTrnsf )
    
    -- updates toTransfr
    toTrnsfr = toTrnsfr - thisTrnsf
    
  end -- trnsfr loop
    
end -- function


--[[ Crafts the blockable items into
blocks.
@param count number of craftable itmes
in the inventory ]]
local function craftBlocks( count )
  -- Set up the slots and craft
  local blCnt = math.floor(count / 9)
  
  print("Block count: ".. blCnt)
  
  --[[ Slots that must be empty ]]
  local emptySlts = {4, 8, 12, 13, 14,
      15, 16 }
    
  --[Loop through empty-able slts]]
  for i = 1, 7 do
    local slotIndx = emptySlts[i]
    t.select(slotIndx)
    trnsfr( 0, blCnt )
  end --empty slots loop
  
  --[[Loops through craftable slts]]
  for i = 1, 9 do
    local slotIndx = crftSlts[i]
    t.select(slotIndx)
    trnsfr( blCnt, blCnt )
  end
  
  t.craft()
  
end


local function main( tArgs )

  --[[ Pulls items from chest ]]
  local stillSucks = true
  while stillSucks do
    stillSucks = t.suck()
  end
  
  local blckblCnt =
      sortAllButBlockables()
  
  -- If there are enough slices, craft!
  if blckblCnt >= 9 then
    craftBlocks( blckblCnt )
    -- Put away the resulting blocks
    dr.bearTo(dr.STARBOARD)
    t.drop()
    dr.bearTo(dr.FORE)
  end
 
  print("Finished sorting; see chests.")
 
end

local tArgs = {...}
main(tArgs)