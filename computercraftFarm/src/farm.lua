--[[ 2014-08-06 xtra prints rmvd

  Farms X rows, trying to alternate
     crops according to the reference
     slots, which are the first
     contiguous slots that have seeds.
  
  See the HOWTO file for how-to-use
     
  Also: 
     There are two globals constants -
     to sleep GROW_WAIT minutes, and
     repeat MAX_REPEATS or until out
     of fuel.
     
  @author R David Alkire, IGN ian_xw
     
TODO/WIP:
- Select the waiting time depending
    on whether the reference slots are
    gapless.
- Add melon/pumpkin slots, handling.
- Sugarcane.
- Cocoa beans, maybe.
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
 
-- Decides what to plant based on the
--  reference slots (plntblCnt).
-- @param rowIndex the current row
-- @block block # within the row,
--  starting with 0, closest to start
-- @param prevRow an array of crop
--  types for previous row
local function sow( rowIndex, block,
    prevRow )
  local seedy = true
 
  -- Alternate among the plantables:
  -- loop through reference slots.
  local i = 0
  local refSlt = 0
  local isPlanted = false
  local isAvailable = false
  local isAppropriate = false
  local unavailCount = 0
  while i < plntblCnt and not isPlanted do
    --use what was for a given reference slot
    refSlt = ( (rowIndex + i )% plntblCnt) + 1
   
    turtle.select(refSlt)
    -- leave 1 in each reference slot
    if turtle.getItemCount(refSlt) > 1 then
      isAvailable = true
    else
      isAvailable = selectNonRefSlot()
    end
    
    isAppropriate = 
        not( prevRow[block]== refSlt )
    
    if isAvailable and isAppropriate then
      prevRow[block] = refSlt
      turtle.placeDown()
      isPlanted = true
    else
      if not isAvailable then
        unavailCount= unavailCount + 1
      end
    end
    
    i = i + 1
  end
  
  if not isPlanted then
    prevRow[block] = 0
    if unavailCount >= plntblCnt then
      seedy = false
      print("Apparently, out of seeds")
    end
  end
  
  return seedy
end
 
-- Harvests a row: Digs (hoes) and
-- moves forward the length or until
-- the way is blocked
-- @param lth the expected length of
--  the row or 0 if not yet determined
-- @param firstRow
-- @param prevRow - array of seed types
--  represented by ref slots
-- @param rowIdx the row index
-- @return how long the row was, or
--  0 if there was an unexpected stop
--  due to fuel outage after first row.
--  Also returns isSeedy, that is, are
--  there still enough seeds to use.
local function sowAndReapRow( lth, 
    firstRow, prevRow, rowIdx )
  -- print( "Reaping a row ")

-- Loop until length is reached or
-- the way is blocked
  local keepGoing = true
  local placeR = 1
 
  if firstRow then
    local fuel = turtle.getFuelLevel()

    local maxLth = fuel/2 - 1
    if lth > maxLth then
      lth = maxLth
      print(string.format("First row. "
          .."fuel %d, max length %d",
          fuel, lth))
    end
  end
  
  local isSeedy = true
  while keepGoing do
   
    turtle.digDown() -- reaps
    
    if firstRow then
      prevRow[placeR - 1] = 0
    end
    
    local placeIdx = placeR-1
    local block = 0
    if rowIdx % 2 == 0 then  --Even
      block = placeIdx
    else
      block = (lth-1) - placeIdx 
    end
    
    isSeedy = sow(rowIdx, block,
        prevRow )
 
    -- sees if it can keepGoing
    if keepGoing then
      placeR = placeR + 1
      if placeR > lth and lth > 0 then
        keepGoing = false
      else
        keepGoing = turtle.forward()
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
 
  lth = placeR - 1
  return lth, isSeedy
end
 
-- Determines whether there's enough
-- fuel to: move to another row,
-- reap it, sow it, and return to
-- base
-- @param rowIndex, rowLength
local function isFuelOKForNextRow(
    rowIndex, rowLength)
  
  local fuelNeed = rowIndex+ rowLength
 
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

--[[ Turns and moves to the next row
     @param rowIndex 
     @param isFuelOK
     @returns isBlocked ]]
local function moveToNext(rowIndex, 
    isFuelOK )

  local isEven= rowIndex % 2== 0
    
  print( string.format(
          "moveToNext( isEven %s, "
          .."isFuelOK %s )",
          tostring( isEven ),
          tostring( isFuelOK ) ) )

  local isBlocked = false
  
  if isFuelOK then
    -- Move to the next row
    if isEven then
      turtle.turnRight()
      
      isBlocked=turtle.forward()==false

        turtle.turnRight()
      
    else -- is odd
      turtle.turnLeft()
      
      isBlocked=turtle.forward()==false

        turtle.turnLeft()
      
    end -- even vs odd
  end -- isFuelOK
  
  print( string.format(
      "moveToNext(): isBlocked= %s", 
      tostring( isBlocked )) )
  
  return isBlocked
  
end

-- Checks fuel, and if good, moves to
--    next row, reaps and sows.
-- @param rowLength, isFirst, prevRow,
--    rowIndex.
--    prevRow is array of ints, each
--    a reference item slot, from, you
--    guessed it: the previous row.
-- @return isFuelOK, rowLength, isSeedy,
--    isBlocked.  isSeedy means there
--    are still seeds to be planted.
--    isBlocked means it was blocked
--    when moving from one row to the 
--    next, which is meant to be a 
--    normal scene.
local function doOneAndMoveOn( rowLength,
    isFirst, prevRow, rowIndex )
 
  local isFuelOK = true
  local isSeedy = true
  local isBlocked = false
 
  isFuelOK = isFuelOKForNextRow( 
      rowIndex, rowLength )
 
  if isFuelOK and isSeedy and 
      not isBlocked then
    
    rowLength, isSeedy= sowAndReapRow( 
        rowLength, isFirst, prevRow, 
        rowIndex )

  end -- if fuel OK
  
  isBlocked = moveToNext( rowIndex, 
      isFuelOK )

  return isFuelOK, rowLength, isSeedy,
      isBlocked
 
end
 
-- Harvests and plants the rows
-- @param width/ rows number of 
--  expected plantable rows
-- @return number of rows planted.
--  If stopped unexpectedly this will
--  be 0. 
-- Also returns row length, & isBlocked
local function reapAndSow( rows )
  -- print("beginning reapAndSow()")
  -- Find out how many slots are for
  -- reference.
  local plntbl = initPlntblCnt()
 
  print("The first "..plntbl..
    " slots \nare deemed plantable")
  
  turtle.up()
  
  local prevRow = {}
  print("rows = ".. rows)
  local rowLength = rows
  local rowIndex = 0
  local isSeedy = true
  local isFuelOK = true
  local isFirst = true
  local isBlocked = false
 
  while (rowIndex< rows) and isSeedy
      and isFuelOK and not isBlocked do
    
    print( "rowIndex ".. rowIndex )
   
    -- If there was an unexpected
    -- stop in previous row, then
    -- rowLength will be its initial
    -- value, 0
    if rowLength<= 0 and isFirst== false then  
      -- Stops loop
      isSeedy = false
    else
     
      isFuelOK, rowLength, isSeedy, 
          isBlocked =
          doOneAndMoveOn( rowLength,
          isFirst, prevRow, rowIndex )
     
      -- for troubleshooting
      print( string.format(
          "in farm(), after "
          .."doOneAndMoveOn( rowLength %d, "
          .."isFirst %s, rowIndex %d)",
          rowLength, tostring(isFirst),
          rowIndex ) )
     
      print( string.format(
          "Which returned isFuelOK %s, "
          .."rowLength %d, isSeedy %s"
          ..", isBlocked %s",
          tostring( isFuelOK ), rowLength,
          tostring(isSeedy), 
          tostring(isBlocked) ) )
      
      print("_____")
      -- os.sleep(5)
     
    end -- if rowLength > 0 & not first
   
    isFirst = false
    rowIndex = rowIndex + 1
   
  end -- while rows & isSeedy
 
  -- The number of rows traversed
  -- or 0 if unexpected problem
  local rowsDone = 0
  if rowLength > 0 then
  
    -- If fuel was too low, it did not
    -- move to next row, so therefore
    -- its row is one less than otherwise
    -- TODO re-test
    if isFuelOK then
      rowsDone = rowIndex
    else
      rowsDone = rowIndex - 1
    end
  else
    rowsDone = 0
  end
 
  return rowsDone, rowLength, isBlocked
 
end
 
-- Returns to the start and drops all
-- inventory except one of each
-- reference item. (It's assumed there
-- are hoppers & a chest.)
-- @param rows how many rows are
--  planted.
-- @param length in case we're at the
--  other end of a row, how many 
-- @param isBlocked indicates that
--  we could *not* move to next row.
-- @return true if successful. False
--  means there was blockage or fuel
--  outage.
local function returnAndStore( rows, 
    length, isBlocked )
  
  local canGo = true
  local steps = rows
  if isBlocked then 
    steps = rows - 1
  end
  
  print( string.format(
        "returnAndStore(): rows %d,"
        .. " steps %d, length %d, "
        .. "isBlocked %s", 
        rows, steps, length, 
        tostring(isBlocked) ))
 
  -- If rows is odd, turtle is at
  -- opposite end so it must return
  if rows % 2 == 1 then   -- odd
    for i = 1, length - 1 do
      turtle.forward()
    end
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
  
  local stp = 1
  while (stp <= steps) and canGo do
    canGo = turtle.forward()
    stp = stp + 1
  end
 
  turtle.turnLeft()
  turtle.digDown()
  turtle.down()
 
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
    print("couldn't store")
  end --canGo
  turtle.turnLeft()
  turtle.turnLeft()
  return canGo
end

-- This prints a message about the fuel
-- situation.
-- @param n is how many plantings have
--  been completed so far
-- @param fuelStart
-- @param widthFromUsr is how wide the
--  farm should have been according to
--  the user.
local function printFuelMsg(n, fuelStart,
    widthFromUsr)

  local fuelLevel = turtle.getFuelLevel()
 
  print("after harvest: "..(n)
    .." of ".. MAX_REPEATS)
   
  print("fuelLevel ".. fuelLevel)
  local fuelPerTurn = (fuelStart-fuelLevel)
  print( "fuelPerTurn ".. fuelPerTurn )
  
  local fltTurns = fuelLevel/fuelPerTurn
  local floorTrns = math.floor( fltTurns )
  local frction = fltTurns - floorTrns
  local rowsPart = frction * widthFromUsr
  
  print( string.format(
      "There would be enough fuel "
      .."for %d more turns "
      .."plus %d rows.",
      floorTrns, rowsPart ))
      
  if fuelLevel< fuelPerTurn and n < MAX_REPEATS then
    local fuelNeeded = (1 - frction) * fuelPerTurn
    local coals = math.ceil(fuelNeeded/80);
    
    print( string.format(
        "To finish the next harvest "
        .."as well or better than this one, "
        .."%d more fuel units are "
        .."needed.  That's %d pieces "
        .."of coal at least.  "
        .."Slot #9 please", fuelNeeded,
        coals ) )
        
  end

end

-- Farms the field repeatedly up to
-- MAX_REPEATS, or the fuel runs out,
-- or there's some unexpected stop.
-- @param widthFromUsr is the width 
--  of the square farm, according to 
--  user.  If 0, this will estimate
--  the maximum width according to
--  fuel.
local function farm( widthFromUsr )
 
    --[[ Start ]]
    -- three times, if enough fuel
    local n = 1
    local okSoFar = true
    while n<= MAX_REPEATS and okSoFar do
      local startTime = os.clock();
      turtle.select(9)
      turtle.refuel()
      local fuelStart = turtle.getFuelLevel()
      print("fuel at start = ".. fuelStart)
      
      local maxLnth = math.floor( 
          math.sqrt(fuelStart+ 1)- 1)
      
      print("Estimated max field "
          .. "side \nfor full cycle: "
          .. maxLnth)
      
      if widthFromUsr == 0 then
        widthFromUsr = maxLnth
      end
      
      local rowsDone, lngth, isBlocked = 
          reapAndSow( widthFromUsr )
      
      okSoFar = returnAndStore(
          rowsDone, lngth, isBlocked )

      if rowsDone > 0 then
        if okSoFar then
       
          printFuelMsg(n, fuelStart, widthFromUsr )
          
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
  local widthFromUsr = 0
 
  --[[ If user supplies a good number,
  this uses it as row count.  If user
  supplied a bad argument, it indicates.
  ]]
  local argCount = table.getn(tArgs)
  local badArg = false
  local badArgMsg = "Argument OK"
  if argCount > 0 then
    widthFromUsr = tArgs[1]
    if tonumber(widthFromUsr)==nil then
      badArg = true
      badArgMsg = "Argument not a number"
    else
      widthFromUsr = tonumber(widthFromUsr)
    end
   
  else
    badArg = true
    badArgMsg = "Supply width of farm."
  end
   
  if badArg then
    print( badArgMsg )
    print("Put at least 1 of something" )
    print(" plantable in first few slots.")
  else
    farm( widthFromUsr )
  end
 
end
 
local tArgs = {...}
main(tArgs)
