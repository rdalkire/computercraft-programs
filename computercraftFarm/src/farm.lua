--[[ com.ape42.turtle.Farm
  For computercraft 1.63
  Farms X rows, trying to alternate
     crops according to the reference
     slots, The first contiguous slots
     that have seeds.  If it doesn't
     have enough seed to alternate it
     will leave a gap.  Sleeps, repeats.
  Note, the x.x.0 releases are
    untested and almost always defective.
  @author R David Alkire, IGN ian_xw
     
TODO:
- Ensure that there's enough fuel to
    return from a given point, and use
    it when needed.
- Given fuel and field size, estimate
    the number of harvests.
- Allow use of blocks instead of row
    parameter.
- Allow the turtle to start at right
    corner, depending which way is
    open.
- Create a routine for automated field
    creation, given flat grassy area,
    a bucket and a source of water.
  - Estimate max field size plantable
    for two harvests, given the fuel.
 
This work is licensed under the
 Creative Commons Attribution 4.0
 International License. To view a copy
 of this license, visit
 http://creativecommons.org/licenses/by/4.0/
 or send a letter to Creative Commons,
 444 Castro Street, Suite 900, Mountain
 View, California, 94041, USA.
]]
 
-- Initial slots indicate what items
-- the user deems plantable.
local plntblCnt = 1
 
-- Initializes the Plantable Count.
-- Called before any work is done, this
-- finds the last populated inventory
-- slot.  That and the ones below
-- will be used as reference.
-- @return plntblCnt
local function initPlntblCnt()
  local indx = 0
  local isPlntbl = true
  while isPlntbl and indx < 16 do
    indx = indx + 1
    turtle.select(indx)
    isPlntbl= turtle.getItemCount()> 0
  end
  plntblCnt = indx - 1
  return plntblCnt
end
 
-- For the non - reference slots,
-- find one that matches the
-- currently selected and match that.
-- Or return false.
local function selectNonRefSlot()
 
  local s = plntblCnt + 1
  local seedy = false
  while s < 16 and seedy == false do
    seedy = turtle.compareTo( s )
    if seedy then
      turtle.select(s)
    end
    s = s + 1
  end --while
  return seedy
end
 
-- Decides what to plant based the
--  reference slots (plntblCnt)
-- @param rowIndex the current row
-- @block block # within the row,
--  starting with 1.
-- @param prevRow an array of crop
--  types for previous row
local function sow( rowIndex, block, prevRow )
  local seedy = false
 
  -- Alternate among the plantables:
  -- loop through reference slots.
  local i = 0
  local refSlt = 0
  while i < plntblCnt and seedy == false do
    --use what was for a given reference slot
    refSlt = ( (rowIndex + i )% plntblCnt) + 1
   
    turtle.select(refSlt)
    if turtle.getItemCount(refSlt) > 1 then
      seedy = true
    else
      seedy = selectNonRefSlot()
    end
    i = i + 1
  end
 
  if seedy then
    if prevRow[block]== refSlt then
      prevRow[block] = 0
    else
      prevRow[block] = refSlt
      turtle.place()
    end -- if matches
  end -- if seedy
 
  return seedy
end
 
local function reapRow( lth )
  print( "Reaping a row ")
 
-- Loop until length is reached or
-- the way is blocked
  local keepGoing = true
  local placeR = 1
 
-- lth 0 just means that really
-- the length is not yet determined
  local firstRow = lth == 0
  while keepGoing do
   
    turtle.dig() -- reaps
    keepGoing = turtle.forward()
   
    -- sees if it can keepGoing
    if keepGoing then
      placeR = placeR + 1
      if placeR >= lth and lth > 0 then
        keepGoing = false
      end
      -- prevents infinite loop
      if placeR > 1023 then
        keepGoing = false
      end
    else
      if firstRow == false then
        print("Stopped unexpectedly")
        placeR = 0
        print("placeR="..placeR)
      end
    end
   
  end -- while loop
 
  lth = placeR
  return lth
end
 
-- Backs up, tilling & planting
-- @param lnth row length
-- @param indx which row
-- @param prevRow array of crop plantings
--  for the previous row
local function sowRow(lnth, indx, prevRow)
        print( "Sowing a row." )
  local block = 1
  local seedy = true
 
  -- while it has length & seeds
  while block < lnth and seedy do
   
    seedy = turtle.back()
    turtle.dig()
 
    -- if there are still seeds
    if seedy then
      seedy = sow(indx, block, prevRow)
    else
        print("sowRow(): seedy== false" )
    end
    block = block + 1
  end
 
  -- return if there's seeds still.
  return seedy
 
end
 
-- Harvests and plants every other row
-- @param rows number of plantable rows
-- @return found row length. If stopped
--  unexpectedly this will be 0.
local function reapAndSow( rows )
  print("beginning reapAndSow()")
  -- Find out how many slots are for
  -- reference.
  local plntbl = initPlntblCnt()
 
  print("The first "..plntbl..
    " slots \nare deemed plantable")
 
  local prevRow = {}
  print("rows = ".. rows)
  local rowLength = 0
  local rowIndex = 0
  local isSeedy = true
  local isFirst = true
 
  while (rowIndex< rows) and isSeedy do
    print( "rowIndex ".. rowIndex )
   
    -- If there was an unexpected
    -- stop in previous row, then
    -- rowLength will be its initial
    -- value, 0
    if rowLength<= 0 and isFirst== false then  
      -- Stop loop
      isSeedy = false
    else
      -- After the first row
      if isFirst == false then
        -- Move to the next row
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
      end
      rowLength = reapRow( rowLength )
      if isFirst then
        -- initializes previous array
        for i = 1, rowLength do
          prevRow[i] = 0
        end
      end
      if rowLength > 0 then
        isSeedy=sowRow(rowLength, rowIndex, prevRow)
        -- if stopped, zero-out.
        rowLength= isSeedy and rowLength or 0
      end
    end --else
    isFirst = false
    rowIndex = rowIndex + 1
  end -- while
  return rowLength
end
 
local function returnAndStore(rows)
  print( "Returning to the start.")
 
  turtle.turnLeft()
  local canGo = true
  local forwards = (rows - 1)
  for i= 1, forwards do
    canGo = turtle.forward()
  end
 
  turtle.turnLeft()
  if canGo then
    for i = 16, 1, -1 do
      turtle.select(i)
      if i > plntblCnt then
        turtle.drop()
      else
        turtle.drop(
            turtle.getItemCount(i)- 1)
      end
    end
  end --canGo
  turtle.turnLeft()
  turtle.turnLeft()
  return canGo
end
 
local tArgs = {...}
local rowCntFromUsr = 0
 
--[[ If user supplies a good number,
this uses it as row count.  If user
supplied a bad argument, it indicates.
]]
local argCount = table.getn(tArgs)
local badArg = false
local badArgMsg = "Argument OK"
if argCount > 0 then
  rowCntFromUsr = tArgs[1]
  if tonumber(rowCntFromUsr)==nil then
    badArg = true
    badArgMsg = "Argument not a number"
  else
    rowCntFromUsr = tonumber(rowCntFromUsr)
  end
 
else
  badArg = true
  badArgMsg = "Supply how many rows"
end
 
if badArg then
  print( badArgMsg )
  print("Put at least 1 of something" )
  print(" plantable in first few slots.")
else
 
  --[[ Start ]]
  -- three times, if enough fuel
  local n = 1
  local okSoFar = true
  local fuelStart = turtle.getFuelLevel()
  while n<3 and okSoFar do
    local startTime = os.clock();
    local zeroStopped = reapAndSow( rowCntFromUsr )
    if zeroStopped > 0 then
      okSoFar = returnAndStore(rowCntFromUsr)
      if okSoFar then
     
        local fuelLevel = turtle.getFuelLevel()
        print("after harvest: "..(n).." of 3")
        print("fuelLevel ".. fuelLevel)
        local fuelPerTurn = (fuelStart-fuelLevel)/n
        print( "fuelPerTurn ".. fuelPerTurn )
        if fuelLevel< fuelPerTurn then
          print("not enough for another go")
          okSoFar = false
        end
        local endTime = os.clock()
        local duration = endTime - startTime
        local waitTime = (40* 60)-duration
        local nextTime = endTime+ waitTime
        if (n < 3) and okSoFar then
          os.sleep(waitTime)
        end
      end --okSofar
    else
      okSoFar = false
    end
    n = n + 1
  end -- of three times loop
 
  if okSoFar == false then
    print("Unplanned stop.")
  end
end
