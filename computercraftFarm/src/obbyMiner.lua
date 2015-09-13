local MXLTH, MxSlt, canDig, canGo, cntFwds, gotBckt, i, lp, sltDone
-- Fills the groove with lava:
MXLTH = 50
MxSlt = 11
sltDone = false
i = 0
lp = false
while not sltDone do
  -- Fetches a bucket-full
  gotBckt = false
  canGo = true
  cntFwds = 0
  -- Until it has a bucket or is obstructed
  while not gotBckt and canGo do
    canGo = turtle.forward()
    if canGo then
      cntFwds = cntFwds + 1
      -- Tries to get a bucket-load of lava
      gotBckt = turtle.placeDown()
    end
    -- Limits any robot run-away
    if cntFwds >= MXLTH then
      canGo = false
    end
  end
  -- Takes the lava back to the slot
  for bk = 1, cntFwds do
    turtle.back()
  end
  -- Goes down into slot, places lava, rises
  turtle.down()
  lp = turtle.placeDown()
  turtle.up()
  -- Tries to get to the next place in slot
  turtle.turnLeft()
  canGo = turtle.forward()
  turtle.turnRight()
  if canGo then
    i = i + 1
  end
  -- Sees whether slot is done
  if i >= MxSlt or not canGo then
    sltDone = true
  end
end
-- Back to beginning of slot
turtle.turnRight()
for bk = 1, i do
  turtle.forward()
end
-- Get and place water
for n = 1, 2 do
  turtle.forward()
end
lp = turtle.placeDown()
for n = 1, 5 do
  turtle.back()
end
lp = turtle.placeDown()
for n = 1, 3 do
  turtle.forward()
end
turtle.turnLeft()
-- Mine the obby
turtle.turnLeft()
turtle.down()
for mn = 1, i do
  canDig = turtle.digDown()
  turtle.forward()
end
turtle.digDown()
turtle.up()
-- Come on back
for b = 1, i do
  turtle.back()
end
turtle.turnRight()
