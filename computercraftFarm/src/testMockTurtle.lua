local t = require "mockTurtle"
t.select(1)

local isSame = t.compareTo(2)

print( "Items 1 & 2 same?", isSame )
local isFail = false
if isSame then
  print("1 & 2 should be different")
  isFail = true
end

t.select(2)
isSame = t.compareTo(5)
print( "Items 2 & 5 same?", isSame )
if isSame == false then
  print("2 & 5 should be same.")
  isFail = true
end

isSame = t.compareTo(3)
print( "Items 1 & 3 same?", isSame )

if isSame == true then
  print("1 & 3 should be different.")
  isFail = true
end

t.placeDown()
local iCnt = t.getItemCount()
print(
  "After placedown, getItemCount: ", 
  iCnt)
  
if iCnt ~= 49 then
  print("placeDown() didn't work")
  isFail = true
end 
 
-- should be nill without error-out
local n = t.getItemDetail(7)

if t.transferTo(1,5) then
  isFail = true
  print("slots 1 & 2 are different")
end

if not t.transferTo(5,2) then
  isFail = true
  print("transfer should've worked")
end
if t.getItemCount(5) ~= 27 or
    t.getItemCount() ~= 47 then
  isFail = true
  print("itemCounts not as expected" )
  print("t.getItemCount(5): ".. 
      t.getItemCount(5) )
  print( "t.getItemCount(): ".. 
      t.getItemCount() )
end

-- Tests the movement of all 
-- items to empty slot
local item
if not t.transferTo( 7 ) then
  isFail = true
  print("transfer should've worked")
else
   item = t.getItemDetail(7)
end
if t.getItemCount(7) ~= 47 or
    t.getItemCount() ~= 0 or
    item.name ~= "minecraft:melon"
    then
  isFail = true
  print( "itemCounts not as expected" )
  print("t.getItemCount(7): ".. 
      t.getItemCount(7) )
  print( "t.getItemCount(): ".. 
      t.getItemCount() )
end

t.craft()

if isFail then
  print("No good.  See above.")
else
  print("OK")
end