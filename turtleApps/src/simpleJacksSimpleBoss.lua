-- For trees, straight up, no branches
-- but with 4x4 thick trunks
-- Start at the close left one

local D_BASE = "https://"..
  "raw.githubusercontent.com/"..
  "rdalkire/"..
  "computercraft-programs/"..
  "dalkire-obsidian2/turtleApps/src/"

--- Ensures dependency exists.
local function ensureFile(depNme)

  print("Ensuring presence of "..
      depNme )

  local drFile= loadfile( depNme )

  if drFile == nil then
    
    shell.run("wget",
      D_BASE.. depNme, depNme )
  end

end

local t = turtle
local smpljck = "simpleJack.lua"

ensureFile(smpljck)

for i= 1, 2 do
 shell.run(smpljck)
end

for i= 1, 2 do
  t.turnRight()
  shell.run(smpljck)
end