--[[ Runs the "srt" script whenever
trapped chest is opened. ]]

local goOn = true
 
local count = 0
 
while goOn do
 
  print("Open the source chest to run,")
  print("or press any key to cancel.")

  if "redstone" == os.pullEvent() then
    count = count + 1
    -- To filter for opens, not closes
    if count % 2 == 1 then
      shell.run("clear")
      shell.run("srt")
    end
  else
    print("Canceling.  "..
        "Run startup to continue.")
    goOn = false
  end
 
end