--[[ Runs the "srt" script whenever
trapped chest is opened. ]]

local goOn = true
local count = 0

while goOn do
  
  print()
  print("Open the source chest to run,")
  print("or press any key to cancel.")
  
  local event = os.pullEvent()
  
  if "redstone" == event then
    count = count + 1
    -- To filter for opens, not closes
    if count % 2 == 1 then
      shell.run("clear")
      shell.run("srt")
    end
  elseif "key" == event then
    print("Canceling.  "..
        "Run startup to continue.")
    goOn = false
  else
    print("(event: "..event..")")
  end
 
end