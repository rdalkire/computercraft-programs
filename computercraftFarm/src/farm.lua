--[[
    com.ape42.turtle.Farm
    tested on computercraft 1.63
    @author R David Alkire, IGN ian_xw
     Farms X rows that are spaced one
     row apart, then sleeps, repeats.
Changes by version:
     0.1.0: Reaps one row.
     0.2.0: Reaps & sows X rows, then
      retrieves the harvest.
     0.2.1: Seed selection defect is
      corrected, so that you now get
      a whole row of a given plantable,
      if there are enough seeds.
     0.2.2: Better stoppage for out-of
      -fuel or if blocked.
     0.3.0: Sleeps and runs twice more
     0.3.1: Fixes a return-stop bug
     
TODO:
- Ensure that there's enough fuel to
    return from a given point, and use
    it when needed.
- Estimate fuel required for harvest,
    given row length & number of rows.
    Display.
- Given fuel and field size, estimate
    the number of harvests.
- Allow use of block instead of row
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
local function sow( rowIndex )
  local seedy = false
 
  -- Alternate among the plantables:
  -- loop through reference slots.
  local i = 0
  while i < plntblCnt and seedy == false do
    --use what was for a given reference slot
    local othr = ( (rowIndex + i )% plntblCnt) + 1
--    print( "rIdx="..rowIndex, "i="..i,
--        "othr="..othr)
    turtle.select(othr)
    if turtle.getItemCount(othr) > 1 then
      seedy = true
    else
      seedy = selectNonRefSlot()
    end
    i = i + 1
  end
 
  if seedy then
    turtle.place()
  end
 
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
local function sowRow(lnth, indx)
        print( "Sowing a row." )
  local block = 1
  local seedy = true
  -- while it has length & seeds
  while block < lnth and seedy do
   
    seedy = turtle.back()
    turtle.dig()
   
    -- if there are still seeds
    if seedy then
      seedy = sow(indx)
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
        turtle.forward()
        turtle.turnLeft()
      end
      rowLength = reapRow( rowLength )
      if rowLength > 0 then
        isSeedy=sowRow(rowLength, rowIndex)
        -- if stopped, zero-out.
        rowLength= isSeedy and rowLength or 0
      end
    end
    isFirst = false
    rowIndex = rowIndex + 1
  end
  return rowLength
end
 
local function returnAndStore(rows)
  print( "Returning to the start.")
 
  turtle.turnLeft()
  local canGo = true
  local forwards = (rows - 1) * 2
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
  while n<3 and okSoFar do
    local startTime = os.clock();
    local zeroStopped = reapAndSow( rowCntFromUsr )
    if zeroStopped > 0 then
      okSoFar = returnAndStore(rowCntFromUsr)
      if okSoFar then
        local endTime = os.clock()
        local duration = endTime - startTime
        local waitTime = (40* 60)-duration
        local nextTime = endTime+ waitTime
        print("harvest: "..(n).." of 3")
        if n < 3 then
          os.sleep(waitTime)
        end
      end --okSofar
    else
      okSoFar = false
    end
    n = n + 1
  end -- of three times.
 
  if okSoFar == false then
    print("Out of fuel or other stop.")
  end
end
