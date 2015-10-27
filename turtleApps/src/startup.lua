--[[ Runs a script for
redstone events. ]]

local EVENT_DESCRIPTION = 
    "Push the button"
local SKIP = 0
local SCRIPT = {"frm", "0"}

local goOn = true
local count = 0

while goOn do
  
  print()
  print(EVENT_DESCRIPTION.. " to run,")
  print("or press any key to cancel.")
  
  local event = os.pullEvent()
  
  if "redstone" == event then
    count = count + 1
    
    -- To skip every so many
    if count % (SKIP + 1) == 0 then
      shell.run("clear")
      shell.run( unpack(SCRIPT) )
    end
  elseif "key" == event then
    print("Canceling.  "..
        "Run startup to continue.")
    goOn = false
  else
    print("(event: "..event..")")
  end
 
end
