-- For trees, straight up, no branches
-- but with 4x4 thick trunks
-- Start at the close left one

-- local t = require("mockTurtle")
local t = turtle
local smpljck = "simplejack"

for i= 1, 2 do
 shell.run(smpljck)
end

for i= 1, 2 do
  t.turnRight()
  shell.run(smpljck)
end