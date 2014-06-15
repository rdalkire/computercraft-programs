--[[ com.ape42.turtle.Farm 0.7.1
  For computercraft 1.63
  Farms X rows, trying to alternate
     crops according to the reference
     slots, which are the first
     contiguous slots that have seeds.
     If it doesn't have enough seed to
     alternate,  it will leave a gap.
     There are two globals constants -
     to sleep GROW_WAIT minutes, and
     repeat MAX_REPEATS or until out
     of fuel.
  @author R David Alkire, IGN ian_xw
     
TODO:
- Estimate max field size plantable
    for two harvests, given the fuel.
- After run - Estimate how many more
    runs & rows it'll be able to do
    with current fuel level.
- Change param meaning so that the
  result is N rows, N blocks long
- Add melon/pumpkin slots, handling.
- Give more explicit usage instructions
- Allow use of blockers instead of row
    parameter.
- Allow the turtle to start at right
    corner, depending which way is
    open.
- Create a routine for automated field
    creation, given flat grassy area,
    a bucket and a source of water.
 
This work is licensed under the
 Creative Commons Attribution 4.0
 International License. To view a copy
 of this license, visit
 http://creativecommons.org/licenses/by/4.0/
 or send a letter to Creative Commons,
 444 Castro Street, Suite 900, Mountain
 View, California, 94041, USA.
]]
 
-- The wait time between beginning of
-- each harvest, in minutes.
GROW_WAIT = 40
 
-- The number of times to farm the
-- field, baring other constraints
MAX_REPEATS = 3
 
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
local function sow( rowIndex, block,
    prevRow )
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
 
-- Harvests a row: Digs (hoes) and
-- moves forward the length or until
-- the way is blocked
-- @param lth the expected length of
--  the row or 0 if not yet determined
-- @return how long the row was, or
--  0 if there was an unexpected stop
--  due to fuel outage after first row.
local function reapRow( lth )
  print( "Reaping a row ")
 
-- Loop until length is reached or
-- the way is blocked
  local keepGoing = true
  local placeR = 1
 
-- lth 0 just means that really
-- the length is not yet determined
  local firstRow = lth == 0
  if firstRow then
    local fuel = turtle.getFuelLevel()
    lth = fuel/2 - 1
    print(string.format("First row. "
        .."fuel %d, max length %d",
        fuel, lth))
  end
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
-- @return true if successful.  False
--  means seeds or fuel ran out, or
--  there was a blockage.
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
 
-- Determines whether there's enough
-- fuel to: move to another row,
-- reap it, sow it, and return to
-- base
-- @param rowIndex, rowLength
local function isFuelOKForNextRow(
    rowIndex, rowLength)
 
  local fuelNeed = 1 + rowIndex
      + ( rowLength * 2 )
 
  local fuelLevel = turtle.getFuelLevel()
 
  local isEnough= fuelLevel >= fuelNeed
  if isEnough ~= true then
    print("Not enough fuel for next "
        .."row and return trip.")
    print( string.format(
        "fuelNeed %d, rowIndex %d, "
        .."rowLength %d", fuelNeed,
        rowIndex, rowLength ) )
       
    print( string.format( "fuelLevel %d",
        fuelLevel ) )
   
  end
 
  return isEnough
 
end
 
-- Checks fuel, and if good, moves to
--    next row, reaps and sows.
-- @param rowLength, isFirst, prevRow,
--    rowIndex.
--    prevRow is array of ints, each
--    a reference item slot, from, you
--    guessed it: the previous row.
-- @return isFuelOK, rowLength, isSeedy
local function moveOnAndDoOne( rowLength,
    isFirst, prevRow, rowIndex )
 
  local isFuelOK = true
 
  -- After the first row
  if isFirst == false then
 
    isFuelOK = isFuelOKForNextRow(rowIndex,
        rowLength)
   
    if isFuelOK then
      -- Move to the next row
      turtle.turnRight()
      turtle.forward()
      turtle.turnLeft()
    end
   
  end -- if after first
 
  local isSeedy = true
  if isFuelOK then
    rowLength= reapRow( rowLength )
    if isFirst then
      -- initializes previous array
      for i = 1, rowLength do
        prevRow[i] = 0
      end
    end
   
    if rowLength > 0 then
      isSeedy=sowRow( rowLength, rowIndex, prevRow)
      -- if stopped, zeroes-out.
      rowLength= isSeedy and rowLength or 0
    end -- if rowLength
   
  end -- if fuel OK
 
  return isFuelOK, rowLength, isSeedy
 
end
 
-- Harvests and plants the rows
-- @param rows number of plantable rows
-- @return number of rows planted.
--  If stopped unexpectedly this will
--  be 0.
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
  local isFuelOK = true
  local isFirst = true
 
  while (rowIndex< rows) and isSeedy
      and isFuelOK do
    print( "rowIndex ".. rowIndex )
   
    -- If there was an unexpected
    -- stop in previous row, then
    -- rowLength will be its initial
    -- value, 0
    if rowLength<= 0 and isFirst== false then  
      -- Stops loop
      isSeedy = false
    else
     
      isFuelOK, rowLength, isSeedy =
          moveOnAndDoOne(rowLength,
              isFirst, prevRow,
              rowIndex )
     
      print( string.format(  
          "in farm(), after "
          .."moveOnAndDoOne( rowLength %d, "
          .."isFirst %s, rowIndex %d)",
          rowLength, tostring(isFirst),
          rowIndex ) )
     
      print( string.format(
          "Which returned isFuelOK %s, "
          .."rowLength %d, isSeedy %s",
          tostring( isFuelOK ), rowLength,
          tostring(isSeedy) ) )
     
    end -- if rowLength > 0 & not first
   
    isFirst = false
    rowIndex = rowIndex + 1
   
  end -- while rows & isSeedy
 
  -- The number of rows traversed
  -- or 0 if unexpected problem
  local rtrnVal = 0
  if rowLength > 0 then
    -- If fuel was too low, it did not
    -- move to next row, so therefore
    -- its row is one less than otherwise
    rtrnVal = isFuelOK and rowIndex or rowIndex - 1
  else
    rtrnVal = 0
  end
 
  return rtrnVal
 
end
 
-- Returns to the start and drops all
-- inventory except one of each
-- reference item. (It's assumed there
-- are hoppers & a chest.)
-- @param rows how many rows are
--  planted.
-- @return true if successful. False
--  means there was blockage or fuel
--  outage.
local function returnAndStore(rows)
  print( "Returning to the start.")
 
  turtle.turnLeft()
  local canGo = true
  local forwards = (rows - 1)
  local stp = 1
  while (stp <= forwards) and canGo do
    canGo = turtle.forward()
    stp = stp + 1
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
  else
    print( string.format(
        "returnAndStore(rows) "
        .."couldn't store.  rows %d, "
        .."forwards %d", rows, forwards ))
  end --canGo
  turtle.turnLeft()
  turtle.turnLeft()
  return canGo
end
 
-- Farms the field repeatedly up to
-- MAX_REPEATS, or the fuel runs out,
-- or there's some unexpected stop.
-- @param rowCntFromUsr is the number
-- of rows to farm, according to user
local function farm( rowCntFromUsr )
 
    --[[ Start ]]
    -- three times, if enough fuel
    local n = 1
    local okSoFar = true
    while n<= MAX_REPEATS and okSoFar do
      local startTime = os.clock();
      turtle.select(9)
      turtle.refuel()
      local fuelStart = turtle.getFuelLevel()
      print("fuelStart = ".. fuelStart)
      local rowsDone = reapAndSow( rowCntFromUsr )
      okSoFar = returnAndStore(rowsDone)
      if rowsDone == rowCntFromUsr then
        if okSoFar then
       
          local fuelLevel = turtle.getFuelLevel()
         
          print("after harvest: "..(n)
              .." of ".. MAX_REPEATS)
             
          print("fuelLevel ".. fuelLevel)
          local fuelPerTurn = (fuelStart-fuelLevel)
          print( "fuelPerTurn ".. fuelPerTurn )
          if fuelLevel< fuelPerTurn and n < MAX_REPEATS then
            print("Next harvest will be partial,")
            print("unless enough more fuel is added.")
            print("Use slot 9 (first slot of 3rd row).")
          end
          local endTime = os.clock()
          local duration = endTime - startTime
          local waitTime = ( GROW_WAIT*60)-duration
          local nextTime = endTime+ waitTime
          if (n < MAX_REPEATS) and okSoFar then
            os.sleep(waitTime)
          end
        end --okSofar
      else
        okSoFar = false
      end
      n = n + 1
    end -- of MAX_REPEATS loop
   
    if okSoFar == false then
      print("Stopped.")
    end
 
end
 
local function main( tArgs )
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
    farm( rowCntFromUsr )
  end
 
end
 
local tArgs = {...}
main(tArgs)