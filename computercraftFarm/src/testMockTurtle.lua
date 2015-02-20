local t = require "mockTurtle"
t.select(1)

local isSame = t.compareTo(2)

print( "Items 1 & 2 same?", isSame )
local isFail = false
if isSame then
  print("1 & 2 should be different")
  isFail = true
end

isSame = t.compareTo(5)
print( "Items 1 & 5 same?", isSame )
if isSame == false then
  print("1 & 5 should be same.")
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
print("After placedown, getItemCount: ", iCnt)
if iCnt ~= 24 then
  print("placeDown() didn't work")
  isFail = true
end 

if isFail then
  print("No good.  See above.")
else
  print("OK")
end