local lf = loadfile( "mockTurtle.lua")
if lf ~= nil then 
  lf()
  lf= loadfile("mockMiscellaneous.lua")
  lf()
end
local t = turtle

while true do
  local isThere= t.inspect()
  if isThere then
    t.dig()
  else
    t.turnRight()
  end
  -- wait
  os.sleep(270)
end