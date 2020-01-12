--[[ Some ad hoc mock values and 
behaviors that aren't otherwise
available within the IDE
Initially for obbyMiner2
]]

keys = {}
keys.c = 46

os.pullEvent= function(evntNme)

  local rtnKey = 0
  if evntNme== "key" then
    print("mocking keypress 'c' (46)")
    rtnKey= 46
  else
    print(evntNme.. " not mocked")
  end
  return evntNme, rtnKey
end

os.sleep= function(seconds)
  print( string.format( 
      "pretending to sleep %d seconds",
      seconds ) )
end

os.wait= function(seconds)
  print("pretending to wait")
end

shell= {}
shell.run = function(...)
  print("Pretending to use ".. 
      "shell.run() with the following")
  print( ... )
end

term= {}
term.clear= function()
  print("pretending to clear screen")
end
