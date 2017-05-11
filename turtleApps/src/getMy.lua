--[[ Get My... <ScriptName>

A convenience script to more easily
get the script I want

Copyright (c) 2017
Robert David Alkire II, IGN 
goatsbuster FKA ian_xw
Distributed under the MIT License.
(See accompanying file LICENSE or copy
at http://opensource.org/licenses/MIT)
]]

-- NOTE on turtle copy, update branch
MY_BRANCH= "master/"

DEP_VERSION="1.1"

local MY_BASE = "https://"..
  "raw.githubusercontent.com/"..
  "rdalkire/"..
  "computercraft-programs/"..
  MY_BRANCH ..
  "turtleApps/src/"

local args= {...}

if table.getn( args ) > 0 then
  local lclFile= args[1]
  local lclOldFile= "OLD_".. lclFile
  
  if fs.exists( lclOldFile ) then
    fs.delete( lclOldFile )
    print("deleted ".. lclOldFile)
  end
  
  if fs.exists( lclFile ) then
    fs.move( lclFile, lclOldFile )
    print("Renamed original to ".. 
        lclOldFile )
  end
  
  local url= MY_BASE.. lclFile.. ".lua"
  
  shell.run("wget", url, lclFile)
  
  print("Got a new copy of ".. lclFile)

end
