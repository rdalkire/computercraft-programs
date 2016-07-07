-- For trees, straight up, no branches

local isBlck, blck =
    turtle.inspect()

local blckNme = blck.name
print( "block name = ".. blckNme )

-- (for now assume it's a log of wood)
turtle.dig()
turtle.forward()

-- While block above matches first one
local keepUpping = true
local ups = 0
while keepUpping do 
  isBlck, blck = turtle.inspectUp()
  
  if isBlck and blck.name== blckNme
      then
    
    keepUpping = true
    turtle.digUp()
    turtle.up()
    ups = ups + 1
  else
    keepUpping = false
  end
end

-- Loop again to move back down
for i = 0, ups do 
  turtle.down()
end
