-- For trees, straight up, no branches
-- but with 4x4 thick trunks
-- Start at the close left one

-- BEGIN BOILERPLATE
-- XXX My apologies for the stink

local lf = loadfile( "mockTurtle.lua")
if lf ~= nil then
  lf()
  lf= loadfile("mockMiscellaneous.lua")
  lf()
end
local t = turtle

--- Base URL for dependencies
local getDependencyBase= function()
  local myBranch = "master/"
  
  if MY_BRANCH then
    myBranch = MY_BRANCH 
  end
  
  return
    "https://".. 
    "raw.githubusercontent.com/".. 
    "rdalkire/"..
    "computercraft-programs/".. 
    myBranch..
    "turtleApps/src/"

end

--- Ensures dependency exists.
local function ensureDep(depNme,depVer)

  print("Ensuring presence of "..
      depNme.. " ".. depVer)
      
  local drFile= loadfile( depNme )
  local isGood = false
  
  if drFile ~= nil then
    drFile()
    if depVer == DEP_VERSION then
      isGood = true
    else
      print("existing version: ".. 
          DEP_VERSION)
      shell.run("rename", depNme, 
          depNme.."_".. DEP_VERSION )
    end
  end
  
  if isGood== false then
  
    print("getting latest version")

    shell.run("wget", 
        getDependencyBase().. depNme, 
        depNme )
    
    drFile= loadfile(depNme)
    drFile()
  end
  
end

ensureDep("getMy.lua", "1.1")
-- END BOILERPLATE

local smpljck = "simpleJack.lua"
ensureDep(smpljck, "1.1")

for i= 1, 2 do
 shell.run(smpljck)
end

for i= 1, 2 do
  t.turnRight()
  shell.run(smpljck)
end